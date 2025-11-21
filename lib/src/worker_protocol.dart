import 'dart:isolate';

class ParseAndModelTask {
  final SendPort replyPort;
  final Type type; // T 的 Type 对象
  /// JSON 数据以 bytes 传输（TransferableTypedData）提高性能
  final TransferableTypedData jsonBytes;
  final Map<String, dynamic>? schema;
  final dynamic Function(Map<String, dynamic> json) fromJson;
  final List<String>? monitoredKeys;

  ParseAndModelTask({
    required this.replyPort,
    required this.type,
    required this.jsonBytes,
    this.schema,
    required this.fromJson,
    this.monitoredKeys,
  });
}

class ParseResult<T> {
  final bool isSuccess;
  final T? modelInstance; // 支持模型实例
  final Map<String, dynamic>? sanitizedJson; // 依然保留清洗后的JSON
  final dynamic error;
  final StackTrace? stackTrace;
  final List<String>? issues; // 新增：携带验证问题

  ParseResult.success(this.modelInstance, this.sanitizedJson, {this.issues})
      : isSuccess = true,
        error = null,
        stackTrace = null;

  ParseResult.failure(this.error, this.stackTrace, {this.issues})
      : isSuccess = false,
        modelInstance = null,
        sanitizedJson = null;
}
