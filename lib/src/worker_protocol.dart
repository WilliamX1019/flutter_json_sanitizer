import 'dart:isolate';

class ParseAndModelTask {
  final SendPort replyPort;
  final Map<String, dynamic> data;
  final Map<String, dynamic> schema;
  final String modelName;
  final dynamic Function(Map<String, dynamic> json) fromJson;

  ParseAndModelTask({
    required this.replyPort,
    required this.data,
    required this.schema,
    required this.modelName,
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