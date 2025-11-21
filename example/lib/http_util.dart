import 'package:dio/dio.dart';
import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';

/// 网络请求工具类
/// 结合 Dio 和 JsonSanitizer 实现自动化的数据清洗和类型安全转换
class HttpUtil {
  // 单例模式
  static final HttpUtil _instance = HttpUtil._internal();
  factory HttpUtil() => _instance;

  late Dio _dio;

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
  }

  /// 通用的网络请求方法
  ///
  /// [path] 请求路径
  /// [method] 请求方法 (GET, POST, etc.)
  /// [data] 请求体数据
  /// [queryParameters] 查询参数
  /// [fromJson] 模型工厂方法
  /// [schema] 模型对应的 Schema (由 flutter_json_sanitizer 生成)
  /// [onIssuesFound] 数据问题回调
  Future<T?> request<T>({
    required String path,
    String method = 'GET',
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> schema,
    DataIssueCallback? onIssuesFound,
    ResponseType? responseType,
  }) async {
    try {
      final response = await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method, responseType: responseType),
      );

      // 使用 JsonSanitizer 进行异步解析和清洗
      // 优化：直接传递 response.data (可能是 Map, String 或其他)，让 parseAsync 内部处理。
      // 如果是 String，parseAsync 会利用 TransferableTypedData 高效传输给 Worker，避免主线程解码。
      return await JsonSanitizer.parseAsync<T>(
        data: response.data,
        schema: schema,
        fromJson: fromJson,
        modelType: T,
        onIssuesFound: onIssuesFound,
      );
    } on DioException catch (e) {
      // 处理 Dio 异常
      _handleDioError(e);
      return null;
    } catch (e) {
      // 处理其他异常
      print('Unknown error: $e');
      return null;
    }
  }

  /// GET 请求便捷方法
  Future<T?> get<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> schema,
    DataIssueCallback? onIssuesFound,
    ResponseType? responseType,
  }) {
    return request<T>(
      path: path,
      method: 'GET',
      queryParameters: queryParameters,
      fromJson: fromJson,
      schema: schema,
      onIssuesFound: onIssuesFound,
      responseType: responseType,
    );
  }

  /// POST 请求便捷方法
  Future<T?> post<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> schema,
    DataIssueCallback? onIssuesFound,
    ResponseType? responseType,
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
    );
  }

  void _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        print("Connection timeout");
        break;
      case DioExceptionType.sendTimeout:
        print("Send timeout");
        break;
      case DioExceptionType.receiveTimeout:
        print("Receive timeout");
        break;
      case DioExceptionType.badResponse:
        print("Bad response: ${e.response?.statusCode}");
        break;
      case DioExceptionType.cancel:
        print("Request cancelled");
        break;
      default:
        print("Dio error: ${e.message}");
    }
  }
}
