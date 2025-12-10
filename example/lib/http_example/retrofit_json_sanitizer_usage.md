使用 flutter_json_sanitizer 搭配 retrofit:^4.9.1 的最小示例

1) 添加依赖  
- `retrofit: ^4.9.1`（已写在 example/pubspec.yaml）  
- 生成代码命令：`flutter pub run build_runner build --delete-conflicting-outputs`

2) 给模型加注解并生成 Schema  
```dart
// user_profile.dart
@JsonSerializable()
@GenerateSchema()
class UserProfile {
  final int id;
  final String? name;
  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
```
生成后会有 `$UserProfileSchema`。

若想直接看可运行的样例，见 `example/lib/retrofit_example.dart`：
- 定义了 `Todo` 模型、`TodoApi` retrofit 接口（返回 `HttpResponse<dynamic>`）
- `RetrofitSanitizerDemo.fetchTodo()` 展示了 `sanitizeWith` 的真实调用

更多调用姿势（对应 helper 的不同入口）参考：
- `example/lib/retrofit_json_sanitizer_examples.dart`
  - `fetchWithExtension`：直接在 `HttpResponse` 上用 `sanitizeWith`
  - `fetchWithHelper`：手动用 `sanitizeResponse`
  - `sanitizePlainResponse`：只有 Dio `Response` 时用 `sanitizeRawResponse`

3) 定义 retrofit Service（返回 HttpResponse<dynamic>，跳过自动 fromJson）  
```dart
part 'user_service.g.dart';

@RestApi(baseUrl: 'https://api.example.com')
abstract class UserService {
  factory UserService(Dio dio, {String baseUrl}) = _UserService;

  @GET('/users/{id}')
  Future<HttpResponse<dynamic>> getUser(@Path('id') int id);
}
```
运行 build_runner 生成 `_UserService`。

4) 使用工具类清洗 + 反序列化  
```dart
final dio = Dio();
await JsonParserWorker.instance.initialize(); // 可选，初始化后台 isolate
final api = UserService(dio);

final raw = await api.getUser(1);
final user = await raw.sanitizeWith<UserProfile>(
  schema: $UserProfileSchema,
  fromJson: UserProfile.fromJson,
  modelType: UserProfile,
  monitoredKeys: ['name'], // 可选：只监控特定字段
  onIssuesFound: ({required issues, required modelType}) {
    // 这里可以上报日志/Sentry
    print('发现脏数据: $issues');
  },
);
```

要点
- 让接口返回 `HttpResponse<dynamic>`/`HttpResponse<Map<String,dynamic>>`，避免 retrofit 先调 fromJson 导致异常。  
- 通过 `sanitizeWith`（定义在 example/lib/retrofit_json_sanitizer.dart）完成：校验 → 清洗 → fromJson。  
- 未初始化后台 worker 时，库会自动回落主线程清洗。  
