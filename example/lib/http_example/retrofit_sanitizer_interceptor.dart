import 'package:dio/dio.dart';
import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';

/// 一个集成 JsonSanitizer 的 Dio Interceptor。
///
/// 它会检查请求配置中的 extra 字段，寻找 `sanitizer_key` 和 `sanitizer_model_type`。
/// 如果找到对应的 schema，就会在数据返回给 Retrofit 之前自动执行清洗。
class SanitizerInterceptor extends Interceptor {
  /// 预先注册的 Schema 表。
  /// Key: 你在 @Extra 定义的标识符 (推荐直接用 Model Type 字符串，或自定义 ID)。
  /// Value: 该 Model 对应的 Schema Map。
  final Map<String, Map<String, dynamic>> _schemaRegistry;

  SanitizerInterceptor(this._schemaRegistry);

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _handleResponse(response);
    super.onResponse(response, handler);
  }

  void _handleResponse(Response response) {
    try {
      // 优先从 extra 读（兼容性），其次从 headers 读
      var sanitizerKey =
          response.requestOptions.extra['sanitizer_key'] as String?;

      // 如果 extra 没有，尝试 headers (用于绕过 Retrofit @Extra 的限制)
      if (sanitizerKey == null) {
        final headers = response.requestOptions.headers;
        if (headers.containsKey('x-sanitizer-key')) {
          sanitizerKey = headers['x-sanitizer-key'] as String?;
          // Header 已在请求中发送，此处仅作读取用于决定是否清洗
        }
      }

      if (sanitizerKey == null) return;

      // modelType 依然尝试从 extra 获取，如果 Header 方式使用则可能缺失，
      // 缺失时默认使用 Object，或者我们也可以在 Header 传类型名？
      // 但类型无法通过 header 传 Type 对象。
      // 所以如果使用 Header 方式，interceptor 将无法确切知道 modelType，
      // 除非我们在 Registry 里同时存 Type？
      // 现在的 Registry 从 sanitizerKey -> Schema。
      // Sanitizer 需要 modelType 主要是为了 上报 时的文案。
      // 我们可以尝试从 extra 取，取不到就用 placeholder。
      final modelType =
          response.requestOptions.extra['sanitizer_model_type'] as Type? ??
              Object;

      final schema = _schemaRegistry[sanitizerKey];
      if (schema == null) {
        print(
            '⚠️ SanitizerInterceptor: No schema found for key "$sanitizerKey"');
        return;
      }

      final data = response.data;
      // 目前只支持 Map 类型的自动清洗
      if (data is Map<String, dynamic>) {
        // 创建 Sanitizer 并执行 processMap
        // 注意：这里是在主线程同步执行。
        final sanitizer = JsonSanitizer.createInstanceForIsolate(
          schema: schema,
          modelType: modelType,
          onIssuesFound: ({required modelType, required issues}) {
            print('⚠️ Sanitizer issues for $modelType: $issues');
          },
        );

        final cleanedData = sanitizer.processMap(data);
        response.data = cleanedData;
      }
    } catch (e) {
      print('❌ SanitizerInterceptor error: $e');
      // 不中断流程，让它继续往下走，可能会在 fromJson 时报错
    }
  }
}
