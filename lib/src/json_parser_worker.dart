import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';
import 'package:flutter_json_sanitizer/src/parser_isolate_entry.dart';
import 'package:flutter_json_sanitizer/src/worker_protocol.dart';

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

  bool get isInitialized => _workerSendPort != null;

  // ==== 自动恢复配置 ====
  final bool _autoRecoveryEnabled = true;
  int _restartAttempts = 0;
  final int _maxRestartAttempts = 3;
  final Duration _restartDelay = const Duration(seconds: 1);

  // ==== 心跳检测配置 ====
  Timer? _heartbeatTimer;
  final Duration _heartbeatInterval = const Duration(seconds: 5);
  final Duration _heartbeatTimeout = const Duration(seconds: 5);
  DateTime? _lastPongTime;
  // ==== 健康状态 ====
  WorkerStatus _lastStatus = WorkerStatus.stopped;

  /// 对外暴露的健康快照
  JsonParserWorkerHealth get health {
    final now = DateTime.now();
    final lastPongAgo =
        _lastPongTime != null ? now.difference(_lastPongTime!) : null;

    bool alive = isInitialized && _isolate != null;
    WorkerStatus status;

    if (!alive) {
      status = WorkerStatus.stopped;
    } else if (_lastStatus == WorkerStatus.restarting) {
      status = WorkerStatus.restarting;
    } else if (lastPongAgo != null &&
        lastPongAgo > _heartbeatInterval * 2) {
      status = WorkerStatus.unresponsive;
    } else {
      status = WorkerStatus.healthy;
    }

    _lastStatus = status;

    return JsonParserWorkerHealth(
      isAlive: alive,
      lastPongAgo: lastPongAgo,
      restartAttempts: _restartAttempts,
      status: status,
    );
  }
    /// 初始化并启动Worker Isolate。
  Future<void> initialize({Duration timeout = const Duration(seconds: 5)}) async {
    if (isInitialized) {
      if (kDebugMode) print("ℹ️ JsonParserWorker is already initialized.");
      return;
    }

    await _startWorker(timeout: timeout);
    _startHeartbeat();
  }

  /// 实际的Isolate启动逻辑
  Future<void> _startWorker({required Duration timeout}) async {
    final completer = Completer<SendPort>();
    final mainPort = ReceivePort();
    _monitorPort = ReceivePort();

    mainPort.listen((message) {
      if (message is SendPort) {
        if (!completer.isCompleted) completer.complete(message);
      } else if (message == 'pong') {
        _lastPongTime = DateTime.now();
        if (kDebugMode) print("💓 Received pong from worker.");
      } else if (!completer.isCompleted) {
        completer.completeError(StateError("Unexpected handshake message: $message"));
      }
    });

    // 监听退出与错误信号
    _monitorPort!.listen((event) {
      if (kDebugMode) print("⚠️ Worker isolate exited or crashed: $event");
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
      _lastStatus = WorkerStatus.healthy;
      if (kDebugMode) print("✅ JsonParserWorker initialized successfully.");
    } catch (e, s) {
      if (kDebugMode) {
        print("❌ Failed to initialize JsonParserWorker: $e");
        print(s);
      }
      dispose();
      rethrow;
    } finally {
      mainPort.close();
    }
  }

  /// 定期心跳检测
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _lastPongTime = DateTime.now();

    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) async {
      if (!isInitialized) return;

      final pingPort = ReceivePort();
      _workerSendPort?.send(PingTask(pingPort.sendPort));

      try {
        await pingPort.first.timeout(_heartbeatTimeout);
        _lastPongTime = DateTime.now();
      } catch (_) {
        final diff = DateTime.now().difference(_lastPongTime ?? DateTime.now());
        if (diff > _heartbeatTimeout) {
          if (kDebugMode) {
            print("💀 Worker did not respond to heartbeat ping in ${_heartbeatTimeout.inSeconds}s. Restarting...");
          }
          _handleWorkerCrash();
        }
      } finally {
        pingPort.close();
      }
    });

    if (kDebugMode) print("❤️ Heartbeat started (every ${_heartbeatInterval.inSeconds}s).");
  }

  /// 当Worker崩溃或退出时的处理逻辑
  Future<void> _handleWorkerCrash() async {
    if (!_autoRecoveryEnabled) {
      if (kDebugMode) print("🛑 Auto recovery disabled, worker will not restart.");
      return;
    }

    // 防止重复触发
    if (_workerSendPort == null && _isolate == null) return;

    _workerSendPort = null;
    _isolate = null;
    _heartbeatTimer?.cancel();
    _lastStatus = WorkerStatus.restarting;

    if (_restartAttempts >= _maxRestartAttempts) {
      if (kDebugMode) print("🚫 Max restart attempts reached. Giving up.");
      _lastStatus = WorkerStatus.stopped;
      return;
    }

    _restartAttempts++;
    final delay = _restartDelay * _restartAttempts;
    if (kDebugMode) print("🔁 Attempting to restart worker... (attempt $_restartAttempts)");

    await Future.delayed(delay);
    try {
      await _startWorker(timeout: const Duration(seconds: 5));
      _restartAttempts = 0;
      _startHeartbeat();
      if (kDebugMode) print("✅ Worker successfully restarted.");
    } catch (e) {
      if (kDebugMode) print("❌ Restart failed: $e");
      _lastStatus = WorkerStatus.stopped;
    }
  }

  /// 派发一个清洗任务到Worker Isolate。
  Future<Map<String, dynamic>?> sanitizeJson({
    required Map<String, dynamic> data,
    required Map<String, dynamic> schema,
    required String modelName,
  }) async {
    final currentHealth = health;

    // 如果 Worker 不可用或状态异常，走主线程兜底逻辑
    final shouldFallback = !isInitialized ||
        currentHealth.status == WorkerStatus.stopped ||
        currentHealth.status == WorkerStatus.restarting ||
        currentHealth.status == WorkerStatus.unresponsive;

    if (shouldFallback) {
      if (kDebugMode) {
        print("⚠️ Worker unavailable (${currentHealth.status}), using main isolate fallback.");
      }

      try {
        // 直接在主线程执行相同逻辑
        final sanitizer = JsonSanitizer.createInstanceForIsolate(
          schema: schema,
          modelName: modelName,
        );
        return sanitizer.processMap(data);
      } catch (e, s) {
        if (kDebugMode) {
          print("❌ Fallback sanitize failed: $e");
          print(s);
        }
        rethrow; // 让上层感知失败
      }
    }

    // ==============================
    // ✅ Worker Isolate 正常逻辑
    // ==============================
    final replyPort = ReceivePort();
    final task = ParseTask(
      replyPort: replyPort.sendPort,
      data: data,
      schema: schema,
      modelName: modelName,
    );

    try {
      _workerSendPort!.send(task);
      final result = await replyPort.first as ParseResult;
      replyPort.close();

      if (result.isSuccess) {
        return result.sanitizedJson;
      } else {
        Error.throwWithStackTrace(result.error, result.stackTrace!);
      }
    } catch (e, _) {
      replyPort.close();
      if (kDebugMode) {
        print("❌ Worker sanitize failed, fallback to main isolate: $e");
      }
      // 如果 Worker 异常，也执行兜底
      final sanitizer = JsonSanitizer.createInstanceForIsolate(
        schema: schema,
        modelName: modelName,
      );
      return sanitizer.processMap(data);
    }
  }

  /// 销毁Worker Isolate。
  void dispose() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _workerSendPort = null;
    _monitorPort?.close();
    _monitorPort = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _lastStatus = WorkerStatus.stopped;
    if (kDebugMode) print("🗑️ JsonParserWorker disposed.");
  }
}
