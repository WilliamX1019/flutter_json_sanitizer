import 'package:dio/dio.dart';
import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';
import 'package:retrofit/retrofit.dart';

/// 一个轻量的工具类，用于在 retrofit 4.9.1 的接口返回后，
/// 将原始 JSON 交给 JsonSanitizer 清洗并再交给你的 fromJson 生成模型。
///
/// 推荐接口返回 `Future<HttpResponse<dynamic>>`（或 `HttpResponse<Map<String, dynamic>>`），
/// 这样可以跳过 retrofit 生成代码的 fromJson，避免还没清洗就抛异常。
class RetrofitJsonSanitizer {
  const RetrofitJsonSanitizer();

  /// 直接处理 retrofit 的 HttpResponse。
  Future<T?> sanitizeResponse<T>({
    required HttpResponse<dynamic> response,
    required Map<String, dynamic> schema,
    required T Function(Map<String, dynamic>) fromJson,
    Type? modelType,
    List<String>? monitoredKeys,
    DataIssueCallback? onIssuesFound,
  }) {
    return JsonSanitizer.parseAsync<T>(
      data: response.data,
      schema: schema,
      fromJson: fromJson,
      modelType: modelType ?? T,
      monitoredKeys: monitoredKeys,
      onIssuesFound: onIssuesFound,
    );
  }

  /// 如果你拿到的是 Dio 原始 Response，也可以用这个方法。
  Future<T?> sanitizeRawResponse<T>({
    required Response<dynamic> response,
    required Map<String, dynamic> schema,
    required T Function(Map<String, dynamic>) fromJson,
    Type? modelType,
    List<String>? monitoredKeys,
    DataIssueCallback? onIssuesFound,
  }) {
    return JsonSanitizer.parseAsync<T>(
      data: response.data,
      schema: schema,
      fromJson: fromJson,
      modelType: modelType ?? T,
      monitoredKeys: monitoredKeys,
      onIssuesFound: onIssuesFound,
    );
  }
}

/// 便捷扩展：直接在 HttpResponse 上调用。
extension HttpResponseSanitizeX on HttpResponse<dynamic> {
  Future<T?> sanitizeWith<T>({
    required Map<String, dynamic> schema,
    required T Function(Map<String, dynamic>) fromJson,
    Type? modelType,
    List<String>? monitoredKeys,
    DataIssueCallback? onIssuesFound,
  }) {
    return const RetrofitJsonSanitizer().sanitizeResponse(
      response: this,
      schema: schema,
      fromJson: fromJson,
      modelType: modelType ?? T,
      monitoredKeys: monitoredKeys,
      onIssuesFound: onIssuesFound,
    );
  }
}
