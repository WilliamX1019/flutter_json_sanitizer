import 'package:dio/dio.dart' hide Headers;
import 'package:example/http_example/retrofit_sanitizer_interceptor.dart';
import 'package:example/http_example/schema_resolver.dart';
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

  /// 使用 @Extra 添加元数据，Interceptor 会拦截并清洗数据。
  @GET('/todos/{id}')

  /// 使用 Options 传入 Schema
  @GET('/todos/{id}')
  Future<Todo> getTodo(@Path('id') int id, @DioOptions() Options options);

  /// 方式 2: 直接在 Extra 中传入 Schema (避免在 Interceptor 中注册)
  /// 方式 2: 通过运行时参数 Options 传入 Schema
  @GET('/todos/{id}')
  Future<Todo> getTodoDynamic(
      @Path('id') int id, @DioOptions() Options options);
}

class RetrofitSanitizerDemo {
  RetrofitSanitizerDemo({Dio? dio}) : _dio = dio ?? Dio() {
    // 注册 Schema (静态注册一次即可)
    SchemaResolver.register(Todo, $TodoSchema);

    // 添加拦截器
    _dio.interceptors.add(SanitizerInterceptor());

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
      final todo = await _api.getTodo(
        id,
        Options(extra: {
          'sanitizer_schema': $TodoSchema,
          'sanitizer_model_type': Todo,
        }),
      );
      return todo;
    } catch (e) {
      print('Fetch error: $e');
      return null;
    }
  }

  /// 示例：直接传 Schema，不依赖 Interceptor 中的 Registry
  Future<Todo?> fetchTodoDynamic() async {
    try {
      final todo = await _api.getTodoDynamic(
        1,
        Options(extra: {
          'sanitizer_schema': $TodoSchema,
          'sanitizer_model_type': Todo,
        }),
      );
      return todo;
    } catch (e) {
      print('Fetch error: $e');
      return null;
    }
  }
}
