import 'package:dio/dio.dart';
import 'package:example/http_example/to_do.dart';
import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';
import 'package:retrofit/retrofit.dart';

import 'retrofit_json_sanitizer.dart';

part 'retrofit_example.g.dart';

/// 一个最小的 retrofit + JsonSanitizer 组合示例。
///
/// 步骤：
/// 1. 运行 build_runner 生成 retrofit 与 schema 代码：
///    flutter pub run build_runner build --delete-conflicting-outputs
/// 2. 在应用启动时可提前初始化 worker（可选）：
///    await JsonParserWorker.instance.initialize();
/// 3. 调用 [RetrofitSanitizerDemo.fetchTodo] 获取并清洗模型。

@RestApi(baseUrl: 'https://jsonplaceholder.typicode.com')
abstract class TodoApi {
  factory TodoApi(Dio dio, {String baseUrl}) = _TodoApi;

  /// 保持原始字符串，不让 retrofit 先做 fromJson；
  /// retrofit 只做了一层包装：把 response.data（此时是 String）和原始 Response 放进 HttpResponse<String> 返回。
  /// 后续交给 JsonSanitizer (Worker) 完成 string -> json -> model。
  @GET('/todos/{id}')
  Future<HttpResponse<String>> getTodo(@Path('id') int id);
}

class RetrofitSanitizerDemo {
  RetrofitSanitizerDemo({Dio? dio})
      : _dio = dio ?? Dio(),
        _sanitizer = const RetrofitJsonSanitizer() {
    _api = TodoApi(_dio);
  }

  final Dio _dio;
  late final TodoApi _api;
  final RetrofitJsonSanitizer _sanitizer;

  /// 调用示例：获取 todo 并在返回时完成清洗。
  Future<Todo?> fetchTodo({
    int id = 1,
    List<String>? monitoredKeys,
    DataIssueCallback? onIssuesFound,
  }) async {
    // 可选：初始化后台 worker；失败会自动回退主线程清洗。
    await JsonParserWorker.instance.initialize().catchError((_) {});

    final raw = await _api.getTodo(id); // HttpResponse<String>

    final todo = await raw.sanitizeWith<Todo>(
      schema: $TodoSchema,
      fromJson: Todo.fromJson,
      modelType: Todo,
      monitoredKeys: monitoredKeys,
      onIssuesFound: onIssuesFound ??
          ({required modelType, required issues}) {
            // 在示例中简单打印，实际可上报 Crashlytics/Sentry。
            // ignore: avoid_print
            print('Sanitizer issues for $modelType: $issues');
          },
    );

    return todo;
  }
}
