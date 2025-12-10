import 'package:dio/dio.dart';
import 'package:example/http_example/to_do.dart';
import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';
import 'package:retrofit/retrofit.dart';

import 'retrofit_example.dart';
import 'retrofit_json_sanitizer.dart';

/// 演示 retrofit_json_sanitizer.dart 中三种使用方式：
/// 1) 扩展方法 sanitizeWith：直接在 HttpResponse 上链式调用。
/// 2) sanitizeResponse：手动传入 HttpResponse。
/// 3) sanitizeRawResponse：只拿到 Dio Response 也能用。
///
/// 注意：需要先运行 build_runner 生成 retrofit 与 schema 代码。

/// 方式 1：扩展方法，语法最简洁。
Future<Todo?> fetchWithExtension(TodoApi api) async {
  final raw = await api.getTodo(1);
  return raw.sanitizeWith<Todo>(
    schema: $TodoSchema,
    fromJson: Todo.fromJson,
    modelType: Todo,
    monitoredKeys: const ['title'],
    onIssuesFound: ({required modelType, required issues}) {
      // ignore: avoid_print
      print('[extension] issues: $issues');
    },
  );
}

/// 方式 2：显式调用 sanitizeResponse（等价于方式 1）。
Future<Todo?> fetchWithHelper(TodoApi api) async {
  final raw = await api.getTodo(2);
  return const RetrofitJsonSanitizer().sanitizeResponse<Todo>(
    response: raw,
    schema: $TodoSchema,
    fromJson: Todo.fromJson,
    modelType: Todo,
    monitoredKeys: const ['title'],
    onIssuesFound: ({required modelType, required issues}) {
      // ignore: avoid_print
      print('[sanitizeResponse] issues: $issues');
    },
  );
}

/// 方式 3：只有 Dio Response，也可以用 sanitizeRawResponse。
/// 这里用本地构造的 Response 做示例，真实场景就是你已有的 Dio 返回值。
Future<Todo?> sanitizePlainResponse() async {
  final fakeResponse = Response<dynamic>(
    data: {'id': 99, 'title': 'Local response', 'completed': 'true'},
    statusCode: 200,
    requestOptions: RequestOptions(path: '/fake'),
  );

  return const RetrofitJsonSanitizer().sanitizeRawResponse<Todo>(
    response: fakeResponse,
    schema: $TodoSchema,
    fromJson: Todo.fromJson,
    modelType: Todo,
    monitoredKeys: const ['completed'],
    onIssuesFound: ({required modelType, required issues}) {
      // ignore: avoid_print
      print('[sanitizeRawResponse] issues: $issues');
    },
  );
}
