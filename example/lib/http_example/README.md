# Flutter JSON Sanitizer 与 Retrofit 集成最佳实践

本目录演示如何将 `flutter_json_sanitizer` 与 Retrofit 结合使用，实现对后端"脏数据"的自动清洗和类型安全解析。

---

## 📁 文件说明

| 文件 | 用途 |
|------|------|
| `retrofit_json_sanitizer.dart` | 核心集成工具类与扩展方法 |
| `retrofit_example.dart` | 完整使用示例（Retrofit API + 清洗调用） |
| `retrofit_json_sanitizer_examples.dart` | 三种不同调用方式的演示 |
| `to_do.dart` | 带 `@GenerateSchema` 注解的 Model 定义 |
| `http_util.dart` | 通用 HTTP 工具封装 |

---

## 🚀 快速开始

### Step 1: 定义 Model 并添加注解

```dart
// to_do.dart
import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';
import 'package:json_annotation/json_annotation.dart';

part 'to_do.g.dart';
part 'to_do.schema.g.dart';  // Schema 自动生成

@JsonSerializable()
@GenerateSchema()  // ← 关键注解：启用 Schema 自动生成
class Todo {
  final int id;
  final String title;
  final bool completed;

  Todo({required this.id, required this.title, required this.completed});

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
}
```

### Step 2: 运行代码生成

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

生成的 `to_do.schema.g.dart` 内容如下：

```dart
const Map<String, dynamic> $TodoSchema = {
  'id': int,
  'title': String,
  'completed': bool,
};
```

### Step 3: 修改 Retrofit 接口返回类型

```dart
@RestApi(baseUrl: 'https://jsonplaceholder.typicode.com')
abstract class TodoApi {
  factory TodoApi(Dio dio, {String baseUrl}) = _TodoApi;

  // ⚠️ 关键：返回 HttpResponse<String>，跳过 Retrofit 自动 fromJson
  @GET('/todos/{id}')
  Future<HttpResponse<String>> getTodo(@Path('id') int id);
}
```

> **为什么用 `HttpResponse<String>`？**  
> 防止 Retrofit 在数据清洗前就调用 `fromJson`，避免因脏数据导致解析异常。

### Step 4: 初始化后台 Worker（推荐）

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Worker（失败会自动降级到主线程）
  await JsonParserWorker.instance.initialize().catchError((_) {});
  
  runApp(MyApp());
}
```

### Step 5: 使用清洗方法

#### 方式 1：扩展方法（推荐）

```dart
final raw = await _api.getTodo(1);

final todo = await raw.sanitizeWith<Todo>(
  schema: $TodoSchema,
  fromJson: Todo.fromJson,
  modelType: Todo,
  monitoredKeys: ['title'],  // 可选：只监控特定字段
  onIssuesFound: ({required modelType, required issues}) {
    print('Issues for $modelType: $issues');
  },
);
```

#### 方式 2：显式调用

```dart
final todo = await const RetrofitJsonSanitizer().sanitizeResponse<Todo>(
  response: raw,
  schema: $TodoSchema,
  fromJson: Todo.fromJson,
  modelType: Todo,
);
```

#### 方式 3：处理原始 Dio Response

```dart
final todo = await const RetrofitJsonSanitizer().sanitizeRawResponse<Todo>(
  response: dioResponse,
  schema: $TodoSchema,
  fromJson: Todo.fromJson,
  modelType: Todo,
);
```

---

## 📐 数据流示意图

```
┌─────────────────────────────────────────────────────────────────┐
│  Retrofit API 定义                                              │
│  Future<HttpResponse<String>> getTodo(@Path('id') int id);      │
└─────────────────────┬───────────────────────────────────────────┘
                      │ 网络请求
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│  HttpResponse<String>  (原始 JSON 字符串)                        │
└─────────────────────┬───────────────────────────────────────────┘
                      │ .sanitizeWith<T>()
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│  JsonSanitizer.parseAsync()                                     │
│  ├─ 1. validate(): 验证数据并回调问题                           │
│  ├─ 2. Worker Isolate: JSON 解码 + Schema 类型清洗              │
│  └─ 3. fromJson(): 生成类型安全的模型实例                       │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│  Todo 模型实例（类型安全，脏数据已自动修正）                     │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔧 核心类说明

### `RetrofitJsonSanitizer`

```dart
class RetrofitJsonSanitizer {
  /// 处理 Retrofit HttpResponse
  Future<T?> sanitizeResponse<T>({
    required HttpResponse<dynamic> response,
    required Map<String, dynamic> schema,
    required T Function(Map<String, dynamic>) fromJson,
    Type? modelType,
    List<String>? monitoredKeys,
    DataIssueCallback? onIssuesFound,
  });

  /// 处理原始 Dio Response
  Future<T?> sanitizeRawResponse<T>({...});
}
```

### `HttpResponseSanitizeX` 扩展

```dart
extension HttpResponseSanitizeX on HttpResponse<dynamic> {
  Future<T?> sanitizeWith<T>({
    required Map<String, dynamic> schema,
    required T Function(Map<String, dynamic>) fromJson,
    Type? modelType,
    List<String>? monitoredKeys,
    DataIssueCallback? onIssuesFound,
  });
}
```

---

## ⚙️ 可选配置

### 全局错误回调

```dart
void main() {
  JsonSanitizer.globalDataIssueCallback = ({required modelType, required issues}) {
    // 上报到 Crashlytics/Sentry
    FirebaseCrashlytics.instance.recordError(
      Exception('Data issues for $modelType: ${issues.join(', ')}'),
      null,
    );
  };
}
```

### 监控特定字段

```dart
monitoredKeys: ['id', 'title'],  // 只验证这些字段
```

---

## ✅ 最佳实践总结

| 要点 | 建议 |
|------|------|
| **Retrofit 返回类型** | 使用 `HttpResponse<String>` 或 `HttpResponse<dynamic>` |
| **Schema 生成** | 为每个模型添加 `@GenerateSchema()` 注解 |
| **Worker 初始化** | 在 `main()` 中调用 `JsonParserWorker.instance.initialize()` |
| **错误上报** | 配置 `globalDataIssueCallback` 或使用 `onIssuesFound` |
| **代码生成** | 执行 `flutter pub run build_runner build` |

---

## 🛡️ 清洗能力示例

| 后端返回 | 期望类型 | 清洗结果 |
|---------|---------|---------|
| `"123"` | `int` | `123` |
| `1` | `bool` | `true` |
| `"true"` | `bool` | `true` |
| `101.5` | `int` | `101` |
| `[]` (期望Map) | `Map` | `{}` |
| PHP 数字键数组 | `List` | 正常列表 |
