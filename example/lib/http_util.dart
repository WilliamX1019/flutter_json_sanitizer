import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';

/// 标准化的返回结果，方便上层区分网络错误 / 清洗问题
class SanitizedResponse<T> {
  final T? data;
  final int? statusCode;
  final Object? error;
  final List<String> issues;
  final Response<dynamic>? rawResponse;

  const SanitizedResponse({
    this.data,
    this.statusCode,
    this.error,
    this.issues = const [],
    this.rawResponse,
  });

  bool get isSuccess => error == null && data != null;
  bool get hasIssues => issues.isNotEmpty;
}

/// 网络请求工具类
/// 结合 Dio 和 JsonSanitizer 实现自动化的数据清洗和类型安全转换
class HttpUtil {
  // 单例模式
  static final HttpUtil _instance = HttpUtil._internal();
  factory HttpUtil() => _instance;

  late final Dio _dio;
  late final Future<void> _workerInitFuture;

  HttpUtil._internal() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      // 默认响应类型为 JSON，Dio 会自动解码
      responseType: ResponseType.json,
    ));

    // 添加日志拦截器（可选）
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));

    // 优先初始化 Worker，失败时自动降级到主 Isolate
    _workerInitFuture = _ensureWorkerInitialized();
  }

  /// 通用的网络请求方法，返回标准化结果
  ///
  /// [path] 请求路径
  /// [method] 请求方法 (GET, POST, etc.)
  /// [data] 请求体数据
  /// [queryParameters] 查询参数
  /// [fromJson] 模型工厂方法
  /// [schema] 模型对应的 Schema (由 flutter_json_sanitizer 生成)
  /// [onIssuesFound] 数据问题回调
  Future<SanitizedResponse<T>> request<T>({
    required String path,
    String method = 'GET',
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> schema,
    DataIssueCallback? onIssuesFound,
    ResponseType? responseType,
    List<String>? monitoredKeys,
    bool sanitize = true,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    // 确保 Worker 尝试初始化；失败会降级到主线程清洗
    await _workerInitFuture.catchError((e) {
      if (kDebugMode) {
        print('JsonParserWorker 初始化失败，降级主线程清洗: $e');
      }
    });

    final reportedIssues = <String>[];
    final baseIssueCallback =
        onIssuesFound ?? JsonSanitizer.globalDataIssueCallback;
    DataIssueCallback? wrappedIssueCallback;
    if (baseIssueCallback != null) {
      wrappedIssueCallback = ({required modelType, required issues}) {
        reportedIssues.addAll(issues);
        baseIssueCallback(modelType: modelType, issues: issues);
      };
    }

    final effectiveOptions = (options ?? Options()).copyWith(
      method: method,
      responseType: responseType,
      // 让非 2xx 不抛异常，便于统一处理
      validateStatus: (_) => true,
    );

    try {
      final response = await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: effectiveOptions,
      );

      final statusCode = response.statusCode;
      final isOk = statusCode == null || (statusCode >= 200 && statusCode < 300);
      if (!isOk) {
        return SanitizedResponse<T>(
          statusCode: statusCode,
          error: DioException.badResponse(
            statusCode: statusCode,
            requestOptions: response.requestOptions,
            response: response,
          ),
          issues: reportedIssues,
          rawResponse: response,
        );
      }

      if (!sanitize) {
        // 跳过清洗（例如下载文件或纯文本）
        return SanitizedResponse<T>(
          data: response.data is T ? response.data as T : null,
          statusCode: statusCode,
          issues: reportedIssues,
          rawResponse: response,
        );
      }

      // 使用 JsonSanitizer 进行异步解析和清洗
      // 直接传递 response.data (可能是 Map, String 或其他)，让 parseAsync 内部处理。
      // 如果是 String，parseAsync 会利用 TransferableTypedData 高效传输给 Worker，避免主线程解码。
      final parsed = await JsonSanitizer.parseAsync<T>(
        data: response.data,
        schema: schema,
        fromJson: fromJson,
        modelType: T,
        monitoredKeys: monitoredKeys,
        onIssuesFound: wrappedIssueCallback,
      );

      return SanitizedResponse<T>(
        data: parsed,
        statusCode: statusCode,
        issues: reportedIssues,
        rawResponse: response,
        error: parsed == null ? 'Sanitized result is null' : null,
      );
    } on DioException catch (e) {
      final message = _handleDioError(e);
      return SanitizedResponse<T>(
        error: message,
        statusCode: e.response?.statusCode,
        issues: reportedIssues,
        rawResponse: e.response,
      );
    } catch (e) {
      return SanitizedResponse<T>(
        error: e,
        issues: reportedIssues,
      );
    }
  }

  /// GET 请求便捷方法
  Future<SanitizedResponse<T>> get<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> schema,
    DataIssueCallback? onIssuesFound,
    ResponseType? responseType,
    List<String>? monitoredKeys,
    bool sanitize = true,
    CancelToken? cancelToken,
    Options? options,
  }) {
    return request<T>(
      path: path,
      method: 'GET',
      queryParameters: queryParameters,
      fromJson: fromJson,
      schema: schema,
      onIssuesFound: onIssuesFound,
      responseType: responseType,
      monitoredKeys: monitoredKeys,
      sanitize: sanitize,
      cancelToken: cancelToken,
      options: options,
    );
  }

  /// POST 请求便捷方法
  Future<SanitizedResponse<T>> post<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> schema,
    DataIssueCallback? onIssuesFound,
    ResponseType? responseType,
    List<String>? monitoredKeys,
    bool sanitize = true,
    CancelToken? cancelToken,
    Options? options,
  }) {
    return request<T>(
      path: path,
      method: 'POST',
      data: data,
      queryParameters: queryParameters,
      fromJson: fromJson,
      schema: schema,
      onIssuesFound: onIssuesFound,
      responseType: responseType,
      monitoredKeys: monitoredKeys,
      sanitize: sanitize,
      cancelToken: cancelToken,
      options: options,
    );
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

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return "Connection timeout";
      case DioExceptionType.sendTimeout:
        return "Send timeout";
      case DioExceptionType.receiveTimeout:
        return "Receive timeout";
      case DioExceptionType.badResponse:
        return "Bad response: ${e.response?.statusCode}";
      case DioExceptionType.cancel:
        return "Request cancelled";
      default:
        return "Dio error: ${e.message}";
    }
  }
}
