import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';
import 'package:flutter_json_sanitizer/src/parser_isolate_entry.dart';
import 'package:flutter_json_sanitizer/src/worker_protocol.dart';

import 'json_transferable_utils.dart';
import 'model_registry.dart';

/// 一个管理长期驻留的JSON解析Worker Isolate的单例服务。
/// 支持自动恢复机制，当后台Isolate崩溃或退出时自动重启。
/// 1.	检测 Isolate 异常退出或错误（通过 onError / onExit 信号）
/// 2.	自动重启并重新建立握手
/// 3.	线程安全的状态切换（防止在恢复过程中派发任务）
/// 4.	带最大重试次数与退避间隔（防止无限重启循环）
///
///
//  ┌──────────────────────────────┐
//  │  sanitizeJson(...) 调用开始  │
//  └──────────────┬───────────────┘
//                 │
//                 ▼
//      判断 health.status 是否正常？
//           │
//           ├── 是 ✅ → 发任务到 Worker → 正常返回结果
//           │
//           └── 否 ⚠️ → 回退到主线程执行 JsonSanitizer
//                 │
//                 ▼
//        主线程直接运行 schema 校验和清洗逻辑
//                 │
//                 ▼
//            返回兜底结果
/*

Main Isolate                                Worker Isolate
--------------                               -----------------------
ParseRequest<T> ------------------------->   (ReceivePort)
                                             ↓
                                             Deserialize bytes
                                             JSON Clean
                                             Lazy register factory(Type → fromJson)
                                             Build model<T>
<------------ ParseResponse<T> -------------  Encode/TransferableTypedData

*/
/// Worker 状态枚举
enum WorkerStatus { healthy, unresponsive, restarting, stopped }

/// Worker 健康信息快照
class JsonParserWorkerHealth {
  final bool isAlive;
  final Duration? lastPongAgo;
  final int restartAttempts;
  final WorkerStatus status;

  const JsonParserWorkerHealth({
    required this.isAlive,
    this.lastPongAgo,
    required this.restartAttempts,
    required this.status,
  });

  @override
  String toString() {
    final ago = lastPongAgo != null
        ? "${lastPongAgo!.inSeconds}.${(lastPongAgo!.inMilliseconds % 1000) ~/ 100}s"
        : "N/A";
    return "JsonParserWorkerHealth(isAlive: $isAlive, lastPongAgo: $ago, "
        "restartAttempts: $restartAttempts, status: $status)";
  }
}

class JsonParserWorker {
  JsonParserWorker._();
  static final JsonParserWorker instance = JsonParserWorker._();

  SendPort? _workerSendPort;
  Isolate? _isolate;
  ReceivePort? _monitorPort;

  bool get isInitialized => _workerSendPort != null && _isolate != null;

  // ==== 自动恢复配置 ====
  final bool _autoRecoveryEnabled = true;
  int _restartAttempts = 0;
  final int _maxRestartAttempts = 3;
  final Duration _restartDelay = const Duration(seconds: 1);

  // ==== 状态与保护锁 ====
  WorkerStatus _lastStatus = WorkerStatus.stopped;
  bool _isRestarting = false;

  /// 对外暴露的健康快照（不再包含心跳时延信息）
  JsonParserWorkerHealth get health {
    final alive = isInitialized && _isolate != null;
    WorkerStatus status = _lastStatus;
    if (!alive) status = WorkerStatus.stopped;
    return JsonParserWorkerHealth(
      isAlive: alive,
      restartAttempts: _restartAttempts,
      status: status,
    );
  }

  /// 初始化并启动Worker Isolate。
  Future<void> initialize(
      {Duration timeout = const Duration(seconds: 5)}) async {
    if (isInitialized) {
      if (kDebugMode) print("ℹ️ JsonParserWorker is already initialized.");
      return;
    }

    await _startWorker(timeout: timeout);
  }

  /// 实际的Isolate启动逻辑
  Future<void> _startWorker({required Duration timeout}) async {
    final completer = Completer<SendPort>();
    final mainPort = ReceivePort();
    _monitorPort = ReceivePort();

    // 如果已有旧的 monitor port，先清理
    try {
      _monitorPort?.close();
    } catch (_) {}
    _monitorPort = ReceivePort();

    mainPort.listen((message) {
      if (message is SendPort) {
        if (!completer.isCompleted) completer.complete(message);
      } else if (!completer.isCompleted) {
        completer.completeError(
            StateError("Unexpected handshake message: $message"));
      }
    });

    // 监听退出与错误信号
    // 监听退出与错误信号 — 区分 onExit (null) 与 onError (通常非 null 背负错误信息)
    _monitorPort!.listen((event) {
      // event == null => onExit
      if (kDebugMode) {
        if (event == null) {
          print("⚠️ Worker isolate exit signal received (onExit).");
        } else {
          print("⚠️ Worker isolate error signal received (onError): $event");
        }
      }
      _handleWorkerCrash();
    });

    try {
      _isolate = await Isolate.spawn(
        parserIsolateEntryWithHeartbeat,
        mainPort.sendPort,
        onError: _monitorPort!.sendPort,
        onExit: _monitorPort!.sendPort,
      );

      _workerSendPort = await completer.future.timeout(timeout);
      _restartAttempts = 0; // 成功启动后重置重试计数
      if (kDebugMode) print("✅ JsonParserWorker initialized successfully.");
    } catch (e, s) {
      if (kDebugMode) {
        print("❌ Failed to initialize JsonParserWorker: $e");
        print(s);
      }
      // 清理并向上抛出
      try {
        mainPort.close();
      } catch (_) {}
      dispose();
      rethrow;
    } finally {
      // mainPort 在失败路径已被关闭或将被关闭；在成功路径我们也可以关闭它 -- one-shot
      try {
        mainPort.close();
      } catch (_) {}
    }
  }

  // 当Worker崩溃或退出时的处理逻辑
  Future<void> _handleWorkerCrash() async {
    if (!_autoRecoveryEnabled) {
      if (kDebugMode) {
        print("🛑 Auto recovery disabled, worker will not restart.");
      }
      return;
    }

    // 防止重复触发
    if (_isRestarting) {
      if (kDebugMode) {
        print(
            "ℹ️ _handleWorkerCrash already running, ignoring duplicate call.");
      }
      return;
    }

    _isRestarting = true;
    _lastStatus = WorkerStatus.restarting;

    try {
      // 清理当前资源（以便 isInitialized 反映真实状态）
      _workerSendPort = null;
      try {
        _isolate?.kill(priority: Isolate.beforeNextEvent);
      } catch (_) {}
      _isolate = null;

      // 如果重试次数已达上限，则标记停止，不再重启
      if (_restartAttempts >= _maxRestartAttempts) {
        if (kDebugMode) print("🚫 Max restart attempts reached. Giving up.");
        _lastStatus = WorkerStatus.stopped;
        return;
      }

      _restartAttempts++;
      final delay =
          Duration(seconds: _restartDelay.inSeconds * _restartAttempts);
      if (kDebugMode) {
        print(
            "🔁 Attempting to restart worker... (attempt $_restartAttempts) after ${delay.inSeconds}s");
      }

      await Future.delayed(delay);

      try {
        await _startWorker(timeout: const Duration(seconds: 5));
        if (kDebugMode) print("✅ Worker successfully restarted.");
      } catch (e, s) {
        if (kDebugMode) {
          print("❌ Restart failed: $e");
          print(s);
        }
        // 如果重启失败则保留计数，后续可能再次触发（或到达上限）
        _lastStatus = WorkerStatus.stopped;
      }
    } finally {
      _isRestarting = false;
    }
  }

  /// 后续需要优化，暂时不用
  /// 清洗并转换为模型对象。
  /// 当 Worker 不可用时，自动在主线程兜底执行。
  Future<T?> parseAndSanitize<T>({
    required Map<String, dynamic> data,
    required Map<String, dynamic> schema,
    required T Function(Map<String, dynamic> json) fromJson,
    required Type modelType,
    DataIssueCallback? onIssuesFound,
  }) async {

    final shouldFallback = !isInitialized;

    if (shouldFallback) {
      if (kDebugMode) {
        print(
            "⚠️ Worker available = ($isInitialized), parsing in main isolate.");
      }
      try {
        final sanitizer = JsonSanitizer.createInstanceForIsolate(
            schema: schema, modelType: modelType, onIssuesFound: onIssuesFound);
        final sanitizedJson = sanitizer.processMap(data);
        return fromJson(sanitizedJson);
        // 主线程兜底创建模型
        // return ModelRegistry.create(modelName, sanitizedJson) as T?;
      } catch (e, s) {
        if (kDebugMode) {
          print("❌ Fallback parse failed: $e");
          print(s);
        }
        rethrow;
      }
    }

    // ==============================
    // ✅ Worker 正常逻辑
    // ==============================
    final replyPort = ReceivePort();
    final task = ParseAndModelTask(
      replyPort: replyPort.sendPort,
      type: modelType,
      jsonBytes: JsonTransferableUtils.encode(data),
      schema: schema,
      fromJson: fromJson, // 直接把 fromJson 传给 worker
    );

    try {
      _workerSendPort!.send(task);
      final raw = await replyPort.first;
      replyPort.close();

      if (raw is ParseResult) {
        final result = raw;
        if (result.isSuccess) {
          // Worker 返回了 modelInstance（已在子 isolate 创建）
          final modelInstance = result.modelInstance!;
          return modelInstance as T?;
        } else {
          // Worker 返回失败：将错误抛出（保留stack）
          if (result.stackTrace != null) {
            Error.throwWithStackTrace(
                result.error ?? StateError("Worker parse failed"),
                result.stackTrace!);
          } else {
            throw result.error ?? StateError("Worker parse failed");
          }
        }
      } else {
        if (kDebugMode) {
          print(
              "⚠️ Unexpected worker response type: ${raw.runtimeType}. Fallback to main isolate.");
        }
        final sanitizer = JsonSanitizer.createInstanceForIsolate(
          schema: schema,
          modelType: modelType,
          onIssuesFound: onIssuesFound,
        );
        final sanitizedJson = sanitizer.processMap(data);
        return ModelRegistry.create(modelType, sanitizedJson);
      }
    } catch (e, _) {
      // 通信异常或其他意外 -> 兜底
      try {
        replyPort.close();
      } catch (_) {}
      if (kDebugMode) {
        print("❌ Worker parse failed, fallback to main isolate: $e");
      }
      // Worker异常 → 主线程兜底
      final sanitizer = JsonSanitizer.createInstanceForIsolate(
        schema: schema,
        modelType: modelType,
        onIssuesFound: onIssuesFound,
      );
      final sanitizedJson = sanitizer.processMap(data);
      return ModelRegistry.create(T, sanitizedJson);
    }
  }

  /// 销毁Worker Isolate。
  void dispose() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _workerSendPort = null;
    _monitorPort?.close();
    _monitorPort = null;
    // _heartbeatTimer?.cancel();
    // _heartbeatTimer = null;
    // _lastStatus = WorkerStatus.stopped;
    if (kDebugMode) print("🗑️ JsonParserWorker disposed.");
  }
}
