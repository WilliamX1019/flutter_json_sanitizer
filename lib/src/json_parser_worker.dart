import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter_json_sanitizer/src/parser_isolate_entry.dart';
import 'package:flutter_json_sanitizer/src/worker_protocol.dart';

/// 一个管理长期驻留的JSON解析Worker Isolate的单例服务。
class JsonParserWorker {
  JsonParserWorker._();
  static final JsonParserWorker instance = JsonParserWorker._();

  SendPort? _workerSendPort;
  Isolate? _isolate;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    final mainPort = ReceivePort();
    _isolate = await Isolate.spawn(parserIsolateEntry, mainPort.sendPort);
    _workerSendPort = await mainPort.first as SendPort;
    _isInitialized = true;
    if (kDebugMode) print("✅ JsonParserWorker initialized.");
  }

  Future<Map<String, dynamic>?> sanitizeJson({
    required Map<String, dynamic> data,
    required Map<String, dynamic> schema,
    required String modelName,
  }) async {
    if (!_isInitialized || _workerSendPort == null) throw StateError('JsonParserWorker must be initialized before use.');
    
    final replyPort = ReceivePort();
    final task = ParseTask(replyPort: replyPort.sendPort, data: data, schema: schema, modelName: modelName);

    _workerSendPort!.send(task);

    final result = await replyPort.first as ParseResult;

    if (result.isSuccess) {
      return result.sanitizedJson;
    } else {
      // 在主Isolate中重新抛出原始异常和堆栈，以便上层可以捕获
      Error.throwWithStackTrace(result.error, result.stackTrace!);
    }
  }

  void dispose() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _isInitialized = false;
    if (kDebugMode) print("🗑️ JsonParserWorker disposed.");
  }
}