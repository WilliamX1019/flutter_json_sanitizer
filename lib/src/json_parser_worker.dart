// 在 flutter_json_sanitizer/lib/src/worker_isolate.dart 或类似文件中

import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter_json_sanitizer/src/parser_isolate_entry.dart';
import 'package:flutter_json_sanitizer/src/worker_protocol.dart';

/// 一个管理长期驻留的JSON解析Worker Isolate的单例服务。
/// 设计用于在应用启动时进行一次性的、健壮的初始化。
class JsonParserWorker {
  JsonParserWorker._();
  static final JsonParserWorker instance = JsonParserWorker._();

  SendPort? _workerSendPort;
  Isolate? _isolate;
  bool get isInitialized => _workerSendPort != null;

  /// [启动时专用] - 初始化并启动Worker Isolate。
  ///
  /// 这个方法被设计为在应用启动的关键路径上调用。它内置了超时和
  /// 详尽的错误监听，以确保它能在确定的时间内返回一个成功或失败的结果。
  ///
  /// - [timeout]: 等待Isolate启动并完成握手的最大时长。如果超时，
  ///   将抛出一个`TimeoutException`。
  ///
  /// 如果成功，此`Future`会正常完成。如果失败，它会抛出一个描述性异常。
  Future<void> initialize({Duration timeout = const Duration(seconds: 5)}) async {
    // 防止重复初始化
    if (isInitialized) {
      if (kDebugMode) print("ℹ️ JsonParserWorker is already initialized.");
      return;
    }

    // Completer 用于统一处理来自 Isolate 的握手成功信号或启动时错误信号。
    final completer = Completer<SendPort>();
    final mainPort = ReceivePort();

    // 监听来自 Isolate 的第一条消息。
    mainPort.listen((message) {
      // Isolate 启动后，可能会发送两种消息：
      // 1. SendPort：这是成功的握手信号。
      // 2. Error：这是 Isolate 启动过程中发生的未捕获异常。
      if (message is SendPort) {
        if (!completer.isCompleted) {
          completer.complete(message);
        }
      } else {
        // 如果收到的不是SendPort，说明发生了错误或意外退出。
        if (!completer.isCompleted) {
          completer.completeError(
            StateError("JsonParserWorker Isolate sent an unexpected message during handshake: $message"),
          );
        }
      }
    });

    try {
      // 启动 Isolate，并将 mainPort 的发送端传给它。
      // 关键：我们将 onError 端口也指向了 mainPort，这样 Isolate 内部的
      // 任何未捕获异常都会通过 mainPort 发送回来，并被我们的 listener 捕获。
      _isolate = await Isolate.spawn(
        parserIsolateEntry,
        mainPort.sendPort,
        onError: mainPort.sendPort,
        onExit: mainPort.sendPort, // 意外退出也会发送信号
      );

      // 等待 Completer 完成，同时设置超时。
      _workerSendPort = await completer.future.timeout(timeout);
      
      if (kDebugMode) print("✅ JsonParserWorker successfully initialized.");

    } catch (e, s) {
      if (kDebugMode) {
        print("❌ JsonParserWorker Failed to initialize JsonParserWorker: $e");
        print(s);
      }
      // 初始化失败后，进行彻底的清理
      dispose();
      // 将原始错误重新抛出，以便上层调用者（如main函数）能够捕获并处理
      rethrow;
    } finally {
      // 无论成功与否，关闭主端口，因为它只用于一次性的握手
      mainPort.close();
    }
  }

  /// 派发一个清洗任务到Worker Isolate。
  Future<Map<String, dynamic>?> sanitizeJson({
    required Map<String, dynamic> data,
    required Map<String, dynamic> schema,
    required String modelName,
  }) async {
    if (!isInitialized) {
      throw StateError(
          'JsonParserWorker is not initialized. Please call initialize() during app startup.');
    }
    
    final replyPort = ReceivePort();
    final task = ParseTask(
      replyPort: replyPort.sendPort,
      data: data,
      schema: schema,
      modelName: modelName,
    );

    _workerSendPort!.send(task);

    final result = await replyPort.first as ParseResult;
    replyPort.close(); // 每个任务使用一次性的回传端口

    if (result.isSuccess) {
      return result.sanitizedJson;
    } else {
      Error.throwWithStackTrace(result.error, result.stackTrace!);
    }
  }

  /// 销毁Worker Isolate，在应用退出时调用。
  void dispose() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _workerSendPort = null;
    if (kDebugMode) print("🗑️ JsonParserWorker disposed.");
  }
}