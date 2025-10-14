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