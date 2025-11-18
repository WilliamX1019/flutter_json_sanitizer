import 'dart:isolate';


class ParseAndModelTask {
  final SendPort replyPort;
  final Type type; // T 的 Type 对象
  /// JSON 数据以 bytes 传输（TransferableTypedData）提高性能
  final TransferableTypedData jsonBytes;
  final Map<String, dynamic> schema;
  final dynamic Function(Map<String, dynamic> json) fromJson;

  ParseAndModelTask({
    required this.replyPort,
    required this.type,
    required this.jsonBytes,
    required this.schema,
    required this.fromJson,
  });
}

class ParseResult<T> {
  final bool isSuccess;
  final T? modelInstance;  // 支持模型实例
  final Map<String, dynamic>? sanitizedJson;  // 依然保留清洗后的JSON
  final dynamic error;
  final StackTrace? stackTrace;

  ParseResult.success(this.modelInstance, this.sanitizedJson)
      : isSuccess = true, error = null, stackTrace = null;

  ParseResult.failure(this.error, this.stackTrace)
      : isSuccess = false, modelInstance = null, sanitizedJson = null;
}