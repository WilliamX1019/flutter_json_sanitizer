import 'dart:isolate';
import 'package:flutter_json_sanitizer/src/json_sanitizer.dart';
import 'package:flutter_json_sanitizer/src/worker_protocol.dart';

/// 长期驻留的 Isolate 的入口点。
Future<void> parserIsolateEntry(SendPort mainPort) async {
  final workerPort = ReceivePort();
  mainPort.send(workerPort.sendPort);

  await for (final message in workerPort) {
    if (message is ParseTask) {
      try {
        final sanitizer = JsonSanitizer.createInstanceForIsolate(
          schema: message.schema,
          modelName: message.modelName,
        );
        final sanitizedJson = sanitizer.processMap(message.data);
        message.replyPort.send(ParseResult.success(sanitizedJson));
      } catch (e, s) {
        message.replyPort.send(ParseResult.failure(e, s));
      }
    }
  }
}