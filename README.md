# Flutter JSON Sanitizer 使用文档

`flutter_json_sanitizer` 是一个强大的 Flutter JSON 数据清洗与解析库。它旨在解决后端接口返回数据类型不规范、字段缺失、空值异常等常见问题，并提供高性能的异步解析能力，确保 App 在处理复杂 JSON 数据时的稳定性和流畅性。

## 核心功能

*   **类型自动纠正**：自动将不匹配的数据类型转换为目标类型（例如：String "123" -> int 123, String "true" -> bool true）。
*   **空值安全处理**：自动处理 `null` 值，为非空字段提供安全的默认值（如 `0`, `0.0`, `false`, `""`, `[]`, `{}`）。
*   **PHP 兼容性**：专门处理 PHP 接口常见的“空数组返回 `[]` 而不是 `{}`”以及“数字键名的 Map 作为 List”等问题。
*   **异步解析 Worker**：内置长期驻留的后台 Isolate Worker，将繁重的 JSON 解析和清洗任务移出主线程，避免 UI 卡顿。
*   **健壮的错误上报**：提供详细的数据结构错误报告回调，方便接入 Crashlytics 或 Sentry 进行监控。
*   **自动恢复**：后台解析 Worker 具备崩溃自动重启和恢复机制。

## 快速开始

### 1. 初始化 Worker (可选但推荐)

在 App 启动时（如 `main.dart` 中）初始化 `JsonParserWorker`，以便使用异步解析功能。

```dart
import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化后台解析 Worker
  await JsonParserWorker.instance.initialize();
  
  // 设置全局错误回调 (可选)
  JsonSanitizer.globalDataIssueCallback = ({required Type modelType, required String issues}) {
    print("⚠️ JSON Issue in $modelType: $issues");
    // 这里可以上报给 Firebase Crashlytics / Sentry
  };

  runApp(MyApp());
}
```

### 2. 定义模型

使用 `@generateSchema` 注解标记你的模型类（配合代码生成器使用，假设你已有对应的 builder 配置）。

```dart
import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';

@generateSchema
class User {
  final int id;
  final String name;
  final bool isActive;

  User({required this.id, required this.name, required this.isActive});

  // 标准 fromJson
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      isActive: json['isActive'] as bool,
    );
  }
}
```

### 3. 使用异步解析与清洗

使用 `JsonSanitizer.parseAsync` 方法来替代标准的 `fromJson` 调用。这个方法会自动在后台 Isolate 中清洗数据并构建模型对象。

```dart
Future<void> fetchUser() async {
  final responseData = {
    "id": "1001",       // 错误类型: String -> 会自动转为 int
    "name": null,       // 空值 -> 会自动转为 "" (如果 Schema 定义为非空 String)
    "isActive": "true"  // 错误类型: String -> 会自动转为 bool
  };

  // 假设 UserSchema.schema 是生成代码中提供的 Schema Map
  final User? user = await JsonSanitizer.parseAsync<User>(
    data: responseData,
    schema: UserSchema.schema, // 生成的 Schema
    modelType: User,
    fromJson: User.fromJson,
  );

  if (user != null) {
    print(user.id); // 1001
    print(user.isActive); // true
  }
}
```

## 核心 API 详解

### JsonSanitizer

核心清洗类，负责数据的验证和转换。

*   **`validate<T>({...})`**:
    *   **功能**: 验证 JSON 数据是否符合 Schema，并上报发现的问题。
    *   **参数**: `data` (原始数据), `schema` (模型定义), `modelType`, `onIssuesFound` (回调)。
    *   **返回**: `bool` (验证是否通过)。

*   **`parseAsync<T>({...})`**:
    *   **功能**: 在后台 Isolate 中执行 `validate` -> `clean` -> `fromJson` 的全流程。
    *   **优势**: 不阻塞 UI 线程，适合大数据量解析。
    *   **自动降级**: 如果 Worker 不可用或发生错误，会自动回退到主线程执行，保证业务不中断。

*   **`processMap(Map map)`**:
    *   **功能**: 同步清洗一个 Map。
    *   **转换逻辑**:
        *   `String` -> `int`/`double`: 尝试解析，移除非数字字符。
        *   `String` -> `bool`: 支持 "true", "1" 等转换。
        *   `null` -> Default: 根据目标类型填充默认值。
        *   `Map` (数字 Key) -> `List`: 自动转换 PHP 风格的数组。

### JsonParserWorker

管理后台解析 Isolate 的单例。

*   **`initialize({Duration timeout})`**: 启动 Worker。
*   **`health`**: 获取 Worker 的健康状态（是否存活、重启次数等）。
*   **自动恢复机制**: 如果后台 Isolate 意外崩溃，Worker 会尝试自动重启（默认最多重试 3 次）。

### 错误处理

你可以通过 `JsonSanitizer.globalDataIssueCallback` 设置全局的错误监听，或者在调用 `parseAsync` 时传入单独的 `onIssuesFound` 回调。

回调会收到：
*   `modelType`: 发生问题的模型类型。
*   `issues`: 一个 JSON 格式的字符串列表，详细描述了字段缺失、类型不匹配等问题。

## 常见问题处理 (FAQ)

**Q: 后端返回的 List 是一个 Map，key 是 "0", "1", "2"... 怎么办？**
A: `JsonSanitizer` 会自动检测这种情况。如果 Schema 期望的是 `List` 但收到了数字 Key 的 `Map`，它会自动将其转换为 `List` 并按 Key 排序。

**Q: 后端返回的 int 字段是字符串 "123.00"？**
A: `JsonSanitizer` 的 `_convertValue` 方法会处理这种情况，它会尝试解析字符串中的数字，兼容性很强。

**Q: Worker 初始化失败会怎样？**
A: 库设计了完善的降级策略。如果 Worker 初始化失败或运行时崩溃，`parseAsync` 会自动在主线程执行解析逻辑，确保业务功能不受影响（虽然可能会有轻微的性能损耗）。
