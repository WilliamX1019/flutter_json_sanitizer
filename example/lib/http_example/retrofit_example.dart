import 'package:dio/dio.dart' hide Headers;
import 'package:example/http_example/retrofit_sanitizer_interceptor.dart';
import 'package:example/http_example/to_do.dart';
import 'package:retrofit/retrofit.dart';

part 'retrofit_example.g.dart';

/// 一个最小的 retrofit + JsonSanitizer 组合示例（Interceptor 方式）。
///
/// 步骤：
/// 1. 运行 build_runner 生成 retrofit 与 schema 代码。
/// 2. 在 Dio 中注册 [SanitizerInterceptor]。
/// 3. 在 API 方法上添加 `@Extra` 注解关联 Schema。
/// 4. 直接调用 API，无需手动清洗。

@RestApi(baseUrl: 'https://jsonplaceholder.typicode.com')
abstract class TodoApi {
  factory TodoApi(Dio dio, {String baseUrl}) = _TodoApi;

  /// 使用 @Headers 添加元数据 (x-sanitizer-key)，Interceptor 会拦截并清洗数据。
  /// 注意：Retrofit 的 @Extra 对返回值有限制，故改用 Header。
  @GET('/todos/{id}')
  @Headers({'x-sanitizer-key': 'Todo'})
  Future<Todo> getTodo(@Path('id') int id);
}

class RetrofitSanitizerDemo {
  RetrofitSanitizerDemo({Dio? dio}) : _dio = dio ?? Dio() {
    // Keep var for compatibility if needed, but unused here

    // 注册 Schema
    final schemaRegistry = <String, Map<String, dynamic>>{
      'Todo': $TodoSchema,
    };

    // 添加拦截器
    _dio.interceptors.add(SanitizerInterceptor(schemaRegistry));

    _api = TodoApi(_dio);
  }

  final Dio _dio;
  late final TodoApi _api;

  /// 调用示例：直接获取已清洗的 Todo。
  Future<Todo?> fetchTodo({
    int id = 1,
  }) async {
    try {
      // 此时返回的已经在 Interceptor 中被清洗过了
      final todo = await _api.getTodo(id);
      return todo;
    } catch (e) {
      print('Fetch error: $e');
      return null;
    }
  }
}
