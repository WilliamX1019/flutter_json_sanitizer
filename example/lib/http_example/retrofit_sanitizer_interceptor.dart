import 'package:dio/dio.dart';
import 'package:example/http_example/schema_resolver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';

/// 一个集成 JsonSanitizer 的 Dio Interceptor (异步 Worker 版)。
///
/// 它会检查请求配置中的 extra 字段，寻找 `sanitizer_key` 和 `sanitizer_model_type`。
/// 如果找到对应的 schema，就会使用 [JsonParserWorker] 在后台 Isolate 中进行数据清洗，
/// 减轻主线程压力。
class SanitizerInterceptor extends Interceptor {
  late final Future<void> _workerInitFuture;

  SanitizerInterceptor() {
    // 优先初始化 Worker，失败时自动降级到主 Isolate
    _workerInitFuture = _ensureWorkerInitialized();
  }

  /// 确保 JsonParserWorker 初始化，失败时仅打印，后续会自动主线程清洗
  Future<void> _ensureWorkerInitialized() async {
    try {
      await JsonParserWorker.instance.initialize();
    } catch (e) {
      if (kDebugMode) {
        print('JsonParserWorker 初始化失败: $e');
      }
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // 注意：Interceptor 的 onResponse 如果需要执行异步操作，
    // 不能直接 await，或者需要确保在 await 后调用 handler.next/resolve/reject。
    // 这里我们先进行异步清洗，完成后再放行。

    try {
      await _handleResponseAsync(response);
      handler.next(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ SanitizerInterceptor logic error: $e');
      }
      // 即使清洗过程出错，也尽量把原始数据交给下游，而不是卡死
      handler.next(response);
    }
  }

  Future<void> _handleResponseAsync(Response response) async {
    // 确保 Worker 尝试初始化；失败会降级到主线程清洗
    // await _workerInitFuture.catchError((_) {});

    // 1. 获取 Model Type
    final modelType =
        response.requestOptions.extra['sanitizer_model_type'] as Type? ??
            Object;

    // 2. 获取 Schema
    var schema = response.requestOptions.extra['sanitizer_schema']
        as Map<String, dynamic>?;

    if (schema == null) {
      // Fallback: Check SchemaResolver using modelType
      if (modelType != Object) {
        schema = SchemaResolver.get(modelType);
      }
    }

    if (schema == null) {
      // No schema provided or found, skip sanitization
      return;
    }

    final data = response.data;
    // 目前只支持 Map 类型的自动清洗
    if (data is Map<String, dynamic>) {
      // 使用 JsonSanitizer.parseAsync 在 Worker 中清洗
      // 为了适配 Retrofit 生成的代码 (它期望 data 是 Map 然后自己做 fromJson)，
      // 我们这里让 Worker 返回清洗后的 Map。
      // Trick: 传入一个 identity 函数作为 fromJson。
      final sanitizedMap = await JsonSanitizer.parseAsync<Map<String, dynamic>>(
        data: data,
        schema: schema,
        modelType: modelType,
        fromJson: (json) => json, // 直接返回 Map
        onIssuesFound: ({required modelType, required issues}) {
          if (kDebugMode) {
            print('⚠️ Sanitizer issues for $modelType: $issues');
          }
          // TODO: 也可以考虑把 issues 塞回 response.extra 以便上层获取
          // response.extra['sanitizer_issues'] = issues;
        },
      );

      if (sanitizedMap != null) {
        response.data = sanitizedMap;
      }
    }
  }
}
