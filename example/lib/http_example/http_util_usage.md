# HttpUtil 使用指南（Dio + flutter_json_sanitizer）

本文档说明 `example/lib/http_util.dart` 中 `HttpUtil` 与 `SanitizedResponse` 的用途、初始化方式以及常见使用场景。

## 组件概览
- `HttpUtil`：封装 Dio 请求，统一接入 `JsonSanitizer.parseAsync` 做异步校验/净化。
- `SanitizedResponse<T>`：统一返回体，字段含义：
  - `data`：净化后转换的模型实例。
  - `statusCode`：HTTP 状态码。
  - `error`：网络异常、非 2xx 或解析失败时的描述。
  - `issues`：以 Map 形式返回的异常列表，每项包含接口信息与 `JsonSanitizer` 提示，例如  
    `{request: {method: GET, path: /api/user, query: {...}}, modelType: UserProfile, issues: ["'name' is null"]}`。
  - `rawResponse`：原始 `Response`，便于调试或特殊处理。
  - `isSuccess`：`error == null && data != null`。
  - `hasIssues`：是否存在数据质量问题（即使 `isSuccess` 也可能为 true）。

## 使用前准备
1) 依赖：已在示例工程中引入 `dio` 与 `flutter_json_sanitizer`。模型需配套生成的 `Schema`（如 `$UserProfileSchema`）。
2) Worker 初始化（推荐在应用启动时调用一次，可降级主线程）：
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     try {
       await JsonParserWorker.instance.initialize();
     } catch (e) {
       // 初始化失败仅影响性能，HttpUtil 会自动降级主线程清洗
       debugPrint('JsonParserWorker init failed: $e');
     }
     runApp(const MyApp());
   }
   ```

## 快速上手：GET 示例
```dart
final http = HttpUtil();

final res = await http.get<UserProfile>(
  path: '/api/user/9981',
  queryParameters: {'preview': true},
  fromJson: UserProfile.fromJson,
  schema: $UserProfileSchema,
  monitoredKeys: ['name'], // 指定需要监控/上报问题的关键字段
  onIssuesFoundWithContext: ({required issues, required modelType}) {
    for (final issue in issues) {
      debugPrint('接口问题: $issue');
    }
  },
);

if (res.isSuccess) {
  final profile = res.data!;
  if (res.hasIssues) {
    // 数据被净化但存在异常字段，可提示或上报
  }
} else {
  // res.error 可能是 DioException 或解析错误字符串
}
```

## POST 示例
```dart
final res = await HttpUtil().post<ProductModel>(
  path: '/api/products',
  data: {'name': 'Book', 'price': '19.9'},
  fromJson: ProductModel.fromJson,
  schema: $ProductModelSchema,
  onIssuesFoundWithContext: ({required issues, required modelType}) {
    debugPrint('POST 数据问题: $issues');
  },
);
```

## 参数说明（适用于 `request/get/post`）
- `path`：必填，接口路径。
- `method`：HTTP 方法，`get/post` 包装已默认。
- `data` / `queryParameters`：请求体与查询参数。
- `fromJson`：模型工厂，用于将净化后的 `Map` 转成业务模型。
- `schema`：生成的 Schema，用于字段校验与类型纠正。
- `onIssuesFoundWithContext`：带接口上下文的回调，形如 `[{"request": {...}, "modelType": "...", "issues": [...] }]`，便于直接消费；若为空，仍会尝试使用 `JsonSanitizer.globalDataIssueCallback`（字符串列表形式）。
- `monitoredKeys`：指定优先检查/上报的字段列表。
- `responseType`：透传 Dio 的响应类型；下载文件或纯文本时可设置 `ResponseType.bytes` / `ResponseType.plain`。
- `sanitize`：是否执行净化/转换；下载文件或非 JSON 内容时设为 `false`。
- `cancelToken`：用于取消请求。
- `options`：额外的 Dio 配置，会在内部合并并强制 `validateStatus: (_) => true`，避免非 2xx 抛异常。

## 状态码与错误处理
- 非 2xx 响应：`isSuccess` 为 false，`error` 为 `DioException.badResponse`，`statusCode` 会返回。
- 解析/净化失败：`data` 为空，`error` 为字符串 `Sanitized result is null` 或抛出的异常描述。
- 网络异常：`_handleDioError` 会将常见超时/取消转换为可读文案。

## 下载或跳过净化
当接口返回文件或非 JSON：
```dart
final res = await HttpUtil().get<List<int>>(
  path: '/files/report',
  responseType: ResponseType.bytes,
  sanitize: false, // 跳过 JsonSanitizer
);
```
此时 `data` 即 Dio 的原始 `response.data`（需自行断言类型）。

## 取消请求与超时
- 默认超时：连接与接收均为 30s（在 `_dio` 初始化时设置）。
- 取消：创建 `CancelToken` 并在外部持有，适用于页面销毁或竞态请求。

## 调试与日志
`HttpUtil` 默认添加了 `LogInterceptor(requestBody: true, responseBody: true)`，便于开发阶段观察请求/响应；生产环境可移除或替换为自定义拦截器。

## 小结
`HttpUtil` 提供了请求、校验与模型转换的一站式封装：先确保 Worker 初始化（性能最佳），再通过 `get/post` 传入 `schema` 与 `fromJson`。`SanitizedResponse` 统一返回网络状态、模型与数据问题，使调用端能同时处理网络异常与数据质量告警。
