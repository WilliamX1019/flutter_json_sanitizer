import 'dart:isolate';

class ParseTask {
  final SendPort replyPort;
  final Map<String, dynamic> data;
  final Map<String, dynamic> schema;
  final String modelName;

  ParseTask({
    required this.replyPort,
    required this.data,
    required this.schema,
    required this.modelName,
  });
}
class ParseAndModelTask {
  final SendPort replyPort;
  final Map<String, dynamic> data;
  final Map<String, dynamic> schema;
  final String modelName;

  /// fromJson 函数名字符串，用于定位在主线程传入的函数
  final String? fromJsonFunctionName;

  ParseAndModelTask({
    required this.replyPort,
    required this.data,
    required this.schema,
    required this.modelName,
    this.fromJsonFunctionName,
  });
}

class ParseResult {
  final bool isSuccess;
  final Map<String, dynamic>? sanitizedJson;
  final dynamic error;
  final StackTrace? stackTrace;

  ParseResult.success(this.sanitizedJson) 
    : isSuccess = true, error = null, stackTrace = null;

  ParseResult.failure(this.error, this.stackTrace) 
    : isSuccess = false, sanitizedJson = null;
}