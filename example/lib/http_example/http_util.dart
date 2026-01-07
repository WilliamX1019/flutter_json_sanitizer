import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';

/// 带上下文的回调（接口 + 模型 + issues）
typedef IssueContextCallback = void Function({
  required Type modelType,
  required List<Map<String, dynamic>> issues,
});

/// 标准化的返回结果，方便上层区分网络错误 / 清洗问题
class SanitizedResponse<T> {
  final T? data;
  final String? message;
  final int? code;
  final int? businessCode;
  final dynamic page;

  /// HTTP 状态码
  final int? statusCode;
  final Object? error;

  /// 以 Map 形式组织的异常信息，便于携带接口上下文
  /// 结构示例：
  /// {
  ///   "request": {"method": "GET", "path": "/api/user", "query": {...}},
  ///   "modelType": "UserProfile",
  ///   "issues": ["'name' is null", ...]
  /// }
  final List<Map<String, dynamic>> issues;
  final Response<dynamic>? rawResponse;

  const SanitizedResponse({
    this.data,
    this.code,
    this.message,
    this.businessCode,
    this.page,
    this.statusCode,
    this.error,
    this.issues = const [],
    this.rawResponse,
  });

  /// HTTP请求成功 且 业务状态码为 200000
  bool get isSuccessful => isHttpSuccess && isBusinessSuccess;

  bool get isHttpSuccess => (statusCode ?? 0) >= 200 && (statusCode ?? 0) < 300;

  /// 业务状态码是否成功 (根据实际约定调整，如 200000)
  bool get isBusinessSuccess => code == 200000;

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
      // 【生产环境优化建议】:
      // 对于超大数据量，可以将其设为 ResponseType.plain，
      // 这里的代码已做兼容，会自动手动 decode。
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
  /// [onIssuesFoundWithContext] 带接口上下文的数据问题回调
  Future<SanitizedResponse<T>> request<T>({
    required String path,
    String method = 'GET',
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> schema,
    IssueContextCallback? onIssuesFoundWithContext,
    ResponseType? responseType,
    List<String>? monitoredKeys,
    bool sanitize = true,

    /// 是否使用 Worker 在后台 Isolate 进行全量解析 (Data + Envelope)
    /// 开启后 responseType 会被强制设为 plain，大幅降低主线程掉帧风险，适合大数据量接口。
    bool useWorker = false,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    // 确保 Worker 尝试初始化；失败会降级到主线程清洗
    await _workerInitFuture.catchError((e) {
      if (kDebugMode) {
        print('JsonParserWorker 初始化失败，降级主线程清洗: $e');
      }
    });

    final reportedIssues = <Map<String, dynamic>>[];
    final baseIssueCallback = JsonSanitizer.globalDataIssueCallback;
    final contextIssueCallback = onIssuesFoundWithContext;
    DataIssueCallback? wrappedIssueCallback;
    final requestLabel =
        _formatRequestLabel(method: method, path: path, query: queryParameters);
    if (baseIssueCallback != null || contextIssueCallback != null) {
      wrappedIssueCallback = ({required modelType, required issues}) {
        // 如果 Worker 报回来的是 Map (信封)，为了日志清晰，显示为具体的业务模型 T
        // 这样用户能一眼看出是哪个 Model 的接口出了问题
        final effectiveModelType =
            (modelType == Map || modelType.toString().contains('Map<'))
                ? T
                : modelType;

        // 将接口信息与 JsonSanitizer 的问题列表合并为结构化数据
        final issueContext = _buildIssueContext(
          method: method,
          path: path,
          query: queryParameters,
          modelType: effectiveModelType,
          issues: issues,
        );
        reportedIssues.add(issueContext);

        // 向外暴露 Map 结构的回调，便于直接消费上下文信息
        contextIssueCallback?.call(
          modelType: effectiveModelType,
          issues: [issueContext],
        );

        // 对外回调保持原始签名，但附带接口标签，便于快速定位
        if (baseIssueCallback != null) {
          final contextualIssues =
              issues.map((e) => '[$requestLabel] $e').toList();
          baseIssueCallback(
              modelType: effectiveModelType, issues: contextualIssues);
        }
      };
    }

    final effectiveOptions = (options ?? Options()).copyWith(
      method: method,
      // 如果开启 useWorker，强制使用 plain 以便在后台解析；否则遵从传入的 responseType
      responseType: useWorker ? ResponseType.plain : responseType,
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
      final isHttpSuccess =
          statusCode != null && statusCode >= 200 && statusCode < 300;

      dynamic apiData;
      int? apiCode;
      String? apiMessage;
      int? apiBusinessCode;
      dynamic apiPage;

      // 【Zero Main Thread JSON 优化逻辑】
      // 如果响应是字符串且需清洗，我们为了避免主线程卡顿，
      // 将整个 Wrap Schema 传给 Worker，让 Worker 负责解析全部内容，
      // 然后返回清洗过的 Map 给我们，我们在主线程只做最后的 Model 实例化。
      if ((response.data is String || response.data is Map<String, dynamic>) &&
          sanitize &&
          isHttpSuccess) {
        // 1. 动态构建“信封 Schema”
        // 注意：这里我们假设信封包含 code, message, page 等基本字段类型。
        // data 字段对应用户传入的 schema。
        final envelopeSchema = {
          "code": "int",
          "message": "String",
          "business_code": "int", // or String depending on implementation
          "page":
              "dynamic", // page struct can be complex, use dynamic or specific schema if known
          "data": schema
        };

        // 2. 调用 Worker 进行全量解析
        // 返回类型设为 Map<String, dynamic>，因为我们暂时不需要 Envelope Model
        final Map<String, dynamic>? sanitizedEnvelope =
            await JsonSanitizer.parseAsync<Map<String, dynamic>>(
          data: response.data,
          schema: envelopeSchema,
          // 这里的 fromJson 是 identity function，把清洗后的 Map 原样返回
          // 必须是静态或这种简单闭包(如果库支持)。
          // 为了稳妥，通常这类库要求 fromJson 是可调用的。
          // Map<String, dynamic>.from 是个不错的选择，或者 (m) => m。
          fromJson: (map) => map,
          modelType: Map,
          monitoredKeys: monitoredKeys?.map((k) => 'data.$k').toList(),
          onIssuesFound: wrappedIssueCallback,
        );

        // 3. 解析结果处理
        if (sanitizedEnvelope != null) {
          apiCode = sanitizedEnvelope['code'] is int
              ? sanitizedEnvelope['code']
              : null;
          apiMessage = sanitizedEnvelope['message']?.toString();
          if (sanitizedEnvelope['business_code'] != null) {
            // 已经在 worker 里被 sanitize 过了，类型应该是安全的
            apiBusinessCode = sanitizedEnvelope['business_code'] is int
                ? sanitizedEnvelope['business_code']
                : int.tryParse(sanitizedEnvelope['business_code'].toString());
          }
          apiPage = sanitizedEnvelope['page'];

          // 取出 data
          final rawData = sanitizedEnvelope['data'];

          // 4. 构建业务 Model (T)
          // 此时 rawData 已经是清洗过的 Map，直接转换，无需再次 Sanitize
          if (rawData != null && rawData is Map<String, dynamic>) {
            //由于 Map 已经在 Worker 里生成好了，这里只是简单的“指针赋值”和“对象头分配”。
            apiData = fromJson(rawData);
          }
        }

        return SanitizedResponse<T>(
          data: apiData is T ? apiData : null,
          statusCode: statusCode,
          code: apiCode,
          message: apiMessage,
          businessCode: apiBusinessCode,
          page: apiPage,
          issues: reportedIssues,
          rawResponse: response,
          error: apiData == null && sanitizedEnvelope != null
              ? 'Sanitized data is null'
              : null,
        );
      }

      // === 下面是降级逻辑 / Map 模式逻辑 (同前) ===

      Map<String, dynamic>? envelopeMap;
      if (response.data is Map<String, dynamic>) {
        envelopeMap = response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        // 如果前面没有命中 Zero JSON 逻辑 (例如 sanitize=false)，或者 Worker 初始化失败？
        // 或者是 Error 状态，我们可能还是得在主线程解一下来拿错误信息
        try {
          if ((response.data as String).isNotEmpty) {
            final decoded = useWorker
                ? await compute(jsonDecode, response.data as String)
                : jsonDecode(response.data as String);
            if (decoded is Map<String, dynamic>) {
              envelopeMap = decoded;
            }
          }
        } catch (e) {
          if (kDebugMode) print('JSON Decode failed: $e');
        }
      }

      if (envelopeMap != null) {
        apiCode = envelopeMap['code'] is int ? envelopeMap['code'] : null;
        apiMessage = envelopeMap['message']?.toString();

        if (envelopeMap['business_code'] != null) {
          apiBusinessCode = envelopeMap['business_code'] is int
              ? envelopeMap['business_code']
              : int.tryParse(envelopeMap['business_code'].toString());
        }
        apiPage = envelopeMap['page'];

        if (envelopeMap.containsKey('data')) {
          apiData = envelopeMap['data'];
        }
      } else {
        if (response.data != null && envelopeMap == null) {
          // Debug 提示：无法解析信封
          if (kDebugMode && responseType != ResponseType.bytes) {
            debugPrint(
                'HttpUtil: Cannot parse envelope from response data. Type: ${response.data.runtimeType}');
          }
        }
      }

      if (!isHttpSuccess) {
        return SanitizedResponse<T>(
          statusCode: statusCode,
          code: apiCode,
          message: apiMessage,
          businessCode: apiBusinessCode,
          page: apiPage,
          error: DioException.badResponse(
            statusCode: statusCode ?? 0,
            requestOptions: response.requestOptions,
            response: response,
          ),
          issues: reportedIssues,
          rawResponse: response,
        );
      }

      if (!sanitize) {
        return SanitizedResponse<T>(
          data: apiData is T ? apiData : null,
          statusCode: statusCode,
          code: apiCode,
          message: apiMessage,
          businessCode: apiBusinessCode,
          page: apiPage,
          issues: reportedIssues,
          rawResponse: response,
        );
      }

      // Map 模式下的 Sanitize (同前)
      final parsed = await JsonSanitizer.parseAsync<T>(
        data: apiData,
        schema: schema,
        fromJson: fromJson,
        modelType: T,
        monitoredKeys: monitoredKeys,
        onIssuesFound: wrappedIssueCallback,
      );

      return SanitizedResponse<T>(
        data: parsed,
        statusCode: statusCode,
        code: apiCode,
        message: apiMessage,
        businessCode: apiBusinessCode,
        page: apiPage,
        issues: reportedIssues,
        rawResponse: response,
        error: parsed == null && apiData != null
            ? 'Sanitized result is null'
            : null,
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
    IssueContextCallback? onIssuesFoundWithContext,
    ResponseType? responseType,
    List<String>? monitoredKeys,
    bool sanitize = true,
    bool useWorker = false,
    CancelToken? cancelToken,
    Options? options,
  }) {
    return request<T>(
      path: path,
      method: 'GET',
      queryParameters: queryParameters,
      fromJson: fromJson,
      schema: schema,
      onIssuesFoundWithContext: onIssuesFoundWithContext,
      responseType: responseType,
      monitoredKeys: monitoredKeys,
      sanitize: sanitize,
      useWorker: useWorker,
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
    IssueContextCallback? onIssuesFoundWithContext,
    ResponseType? responseType,
    List<String>? monitoredKeys,
    bool sanitize = true,
    bool useWorker = false,
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
      onIssuesFoundWithContext: onIssuesFoundWithContext,
      responseType: responseType,
      monitoredKeys: monitoredKeys,
      sanitize: sanitize,
      useWorker: useWorker,
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

  String _formatRequestLabel({
    required String method,
    required String path,
    Map<String, dynamic>? query,
  }) {
    final buffer = StringBuffer('$method $path');
    if (query != null && query.isNotEmpty) {
      // 转成字符串，避免 dynamic 类型导致 Uri 抛异常
      final stringified = query.map((key, value) => MapEntry(
          key, value == null ? '' : Uri.encodeComponent(value.toString())));
      final queryString =
          stringified.entries.map((e) => '${e.key}=${e.value}').join('&');
      buffer.write('?$queryString');
    }
    return buffer.toString();
  }

  Map<String, dynamic> _buildIssueContext({
    required String method,
    required String path,
    Map<String, dynamic>? query,
    required Type modelType,
    required List<String> issues,
  }) {
    return {
      'request': {
        'method': method,
        'path': path,
        if (query != null && query.isNotEmpty) 'query': query,
      },
      'modelType': modelType.toString(),
      'issues': issues,
    };
  }
}
