// 引入Firebase Crashlytics (可选)
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:stack_trace/stack_trace.dart';

import 'json_parser_worker.dart';
import 'model_registry.dart';

/// 一个可复用的回调函数类型定义，用于上报在数据验证期间发现的问题。
/// [modelName] 是正在解析的模型的名称。
/// [issues] 是一个描述性字符串列表，说明了发现的具体问题。
typedef DataIssueCallback = void Function({
  required Type modelType,
  required List<String> issues,
});

class JsonSanitizer {
  // --- 全局配置 ---
  /// Example:
  /// ```dart
  /// void main() {
  ///   JsonSanitizer.globalDataIssueCallback = ({modelName, issues}) {
  ///     // Your global Firebase/Sentry reporting logic here
  ///     print("GLOBAL REPORTER: Issue for '$modelName': ${issues.join(', ')}");
  ///   };
  ///   runApp(MyApp());
  /// }
  /// ```
  static DataIssueCallback? globalDataIssueCallback;

  final Map<String, dynamic> schema;
  final Type modelType;

  /// 使用异步方式上报问题时，会在子Isolate中进行
  /// 需要避免捕获了外部作用域的变量
  final DataIssueCallback? onIssuesFound;

  /// 构造函数现在接收上报所需的信息。
  JsonSanitizer._({
    required this.schema,
    required this.modelType,
    this.onIssuesFound,
  });

  /// [Isolate专用] - 一个特殊的内部构造函数，供后台Isolate使用。
  factory JsonSanitizer.createInstanceForIsolate({
    required Map<String, dynamic> schema,
    required Type modelType,
    DataIssueCallback? onIssuesFound,
  }) {
    return JsonSanitizer._(
        schema: schema, modelType: modelType, onIssuesFound: onIssuesFound);
  }

  /// 🧩 [主Isolate专用] - 对原始JSON数据进行验证和上报。
  static bool validate<T>({
    required dynamic data,
    required Map<String, dynamic> schema,
    required Type modelType,
    DataIssueCallback? onIssuesFound,
    List<String>? monitoredKeys,
  }) {
    // 步骤 1: 验证最外层容器的有效性
    if (data == null || data is! Map<String, dynamic>) {
      onIssuesFound?.call(
        modelType: modelType,
        issues: [
          "Response body is null or not a valid JSON object. Received: $data"
        ],
      );
      return false;
    }

    // 步骤 2: (可选) 处理空Map的情况
    if (data.isEmpty) {
      return false;
    }

    // 对原始的、未经处理的`data`进行验证和上报
    if (onIssuesFound != null) {
      // 决定要验证哪些字段。如果用户指定了列表，就用它；否则，默认使用schema中的所有字段。
      final keysToValidate = monitoredKeys ?? schema.keys.toList();
      final validationIssues = <String>[];

      for (final key in keysToValidate) {
        final value = data[key];
        if (value == null) {
          validationIssues.add("'$key' is null");
        } else if (value is String && value.isEmpty) {
          validationIssues.add("'$key' is an empty string");
        } else if (value is List && value.isEmpty) {
          // 仅当期望的类型是列表时，才将空列表视为一个“问题”。
          final expectedType = schema[key];
          if (expectedType is ListSchema) {
            validationIssues.add("'$key' is an empty list");
          }
        } else if (value is Map && value.isEmpty) {
          final expectedType = schema[key];
          // 我们只关心那些本应是嵌套对象 (MapSchema 或自定义模型)
          // 却返回了空Map的情况。
          if (expectedType is MapSchema ||
              expectedType is Map<String, dynamic>) {
            validationIssues.add("'$key' is an empty map {}");
          }
        }
      }

      // 如果发现了任何问题，就通过回调执行上报
      if (validationIssues.isNotEmpty) {
        onIssuesFound(modelType: modelType, issues: validationIssues);
      }
    }
    return true;
  }

  /// 🚀 异步版 - 适用于大型 JSON，自动在独立 isolate 执行
  static Future<T?> parseAsync<T>({
    required dynamic data,
    required Map<String, dynamic> schema,
    required T Function(Map<String, dynamic>) fromJson,
    required Type modelType,
    DataIssueCallback? onIssuesFound,
    List<String>? monitoredKeys,
  }) async {
    final effectiveCallback = onIssuesFound ?? globalDataIssueCallback;
    // 验证最外层数据是否符合预期的Schema
    final isValid = JsonSanitizer.validate(
        data: data,
        schema: schema,
        modelType: modelType,
        onIssuesFound: effectiveCallback,
        monitoredKeys: monitoredKeys);
    if (!isValid) return null;
    // 只将【清洗和解析】这个纯计算任务和纯数据发送到后台 Isolate。
    try {
      //现在是纯数据清洗，解析在主 Isolate 中进行。
      final sanitizedJson = await JsonParserWorker.instance.parseAndSanitize<T>(
        data: data,
        schema: schema,
        modelType: modelType,
        fromJson: fromJson,

        ///(json) => ModelRegistry.create(modelName, json),
      );
      return sanitizedJson;
    } catch (e, stackTrace) {
      // 捕获后台的纯解析异常，并在【主 Isolate】中上报。
      _reportError(
        modelType: modelType,
        exception: e,
        stackTrace: stackTrace,
        onIssuesFound: effectiveCallback,
      );
      return null;
    }
  }

  Map<String, dynamic> processMap(Map<String, dynamic> map) {
    final newMap = <String, dynamic>{};
    map.forEach((key, value) {
      if (value == null) {
        newMap[key] = null;
        return;
      }

      final expectedSchema = schema[key];
      if (expectedSchema != null) {
        newMap[key] = _convertValue(value, expectedSchema, key);
      } else {
        newMap[key] = value; // 如果Schema中未定义，则原样保留
      }
    });
    return newMap;
  }

  dynamic _convertValue(dynamic value, dynamic expectedSchema, String key) {
    // 场景: 处理基础类型
    if (expectedSchema is Type) {
      try {
        if (expectedSchema == int) {
          if (value is int) return value;
          if (value is double) return value.toInt();
          if (value is String) {
            // 处理 PHP 返回的数字字符串
            final result = int.tryParse(value.replaceAll(RegExp(r'[^0-9].'), ''));
            if (result != null) return result;
            return 0; // 若解析失败，返回默认值
          }
          throw 'Cannot convert to int';
        }
        if (expectedSchema == double) {
          if (value is double) return value;
          if (value is int) return value.toDouble();
          if (value is String) {
            final result = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
            if (result != null) return result;
            return 0.0;
          }
          throw 'Cannot convert to double';
        }
        if (expectedSchema == String) {
          if (value is String) {
            // 处理空字符串或 "null" 字符串
            if (value.trim().isEmpty || value.toLowerCase() == 'null') {
              return null; // 将空字符串或 "null" 字符串转为 null
            }
            return value;
          }
          return value.toString();
        }
        if (expectedSchema == bool) {
          if (value is bool) return value;
          if (value is int) return value == 1;
          if (value is String) {
            final lower = value.toLowerCase();
            if (lower == 'true' || lower == '1') return true;
            if (lower == 'false' || lower == '0') return false;
          }
          throw 'Cannot convert to bool';
        }
      } catch (e) {
        // --- 关键改动：调用上报方法 ---
        _reportStructuralError(
          key: key,
          expectedType: expectedSchema.toString(),
          receivedValue: value,
        );
        if (expectedSchema == int) return 0;
        if (expectedSchema == double) return 0.0;
        if (expectedSchema == String) return '';
        if (expectedSchema == bool) return false;
      }
    }

    // 场景: 处理 List
    if (expectedSchema is ListSchema) {
      final nestedType = expectedSchema.itemType;

      if (value is List) {
        return value.map((item) {
          // 如果列表项是一个嵌套模型
          if (nestedType != null &&
              item is Map<String, dynamic> &&
              expectedSchema.itemSchema is Map<String, dynamic>) {
            final nestedSanitizer = JsonSanitizer._(
              schema: expectedSchema.itemSchema,
              modelType: nestedType,
              onIssuesFound: onIssuesFound,
            );
            return nestedSanitizer.processMap(item);
          }

          // 普通列表项
          return _convertValue(item, expectedSchema.itemSchema, key);
        }).where((e) => e != null).toList();
      }

        // --- 处理数字-key的PHP数组，转换为 List ---
      // 这部分代码会检查 expectedSchema 是否是 ListSchema，如果是，则进行数字-key数组的转换
      if (value is Map<String, dynamic>) {
         // 检查是否所有 Key 都是数字
        if (value.keys.every((key) => int.tryParse(key) != null)) {
          // 按 Key 排序（可选，但推荐，因为 Map 无序）
          final entries = value.entries.toList()
            ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));

          return entries.map((entry) {
            // 复用转换逻辑
            if (nestedType != null &&
                entry.value is Map<String, dynamic> &&
                expectedSchema.itemSchema is Map<String, dynamic>) {
              // ... 嵌套模型处理 ...
              final nestedSanitizer = JsonSanitizer._(
                schema: expectedSchema.itemSchema,
                modelType: nestedType,
                onIssuesFound: onIssuesFound,
              );
              return nestedSanitizer.processMap(entry.value);
            }
            return _convertValue(entry.value, expectedSchema.itemSchema, entry.key);
          }).toList();
        }
      }

      _reportStructuralError(
          key: key, expectedType: 'List', receivedValue: value);
      return [];
    }



    // 场景: Map
    if (expectedSchema is Map<String, dynamic>) {
      if (value is Map<String, dynamic>) {
        // 为嵌套调用创建一个新的Sanitizer实例
        // return processMap(value);
        final nestedSanitizer = JsonSanitizer._(
          schema: expectedSchema,
          modelType: modelType, // 此处modelType没有实际意义
          onIssuesFound: onIssuesFound,
        );
        return nestedSanitizer.processMap(value);
      }
      if (value is List && value.isEmpty) return <String, dynamic>{};
      // --- 关键改动：调用上报方法 ---
      _reportStructuralError(
        key: key,
        expectedType: 'Map<String, dynamic>',
        receivedValue: value,
      );
      return <String, dynamic>{}; // 返回安全的默认值
    }

    // 如果没有匹配的规则，返回原值
    return value;
  }

  void _reportStructuralError({
    required String key,
    required String expectedType,
    required dynamic receivedValue,
  }) {
    onIssuesFound?.call(
      modelType: modelType,
      issues: [
        "Structural error at field '$key': Expected a $expectedType but received a ${receivedValue.runtimeType}. Sanitizer cannot fix this and will return a default value."
      ],
    );
  }

  /// 统一的、信息丰富的静态错误报告方法。
  ///
  /// 它专门用于处理在 `fromJson` 工厂方法执行期间抛出的、无法预料的异常。
  /// 它能智能地处理不同类型的异常，格式化堆栈信息，并通过回调进行上报。
  ///
  /// - [modelName]: 发生异常的模型名称。
  /// - [exception]: `catch`块捕获到的异常对象。
  /// - [stackTrace]: `catch`块捕获到的堆栈跟踪。
  /// - [onIssuesFound]: 用户提供的、用于上报问题的回调函数。
  static void _reportError({
    required Type modelType,
    required Object exception,
    required StackTrace stackTrace,
    DataIssueCallback? onIssuesFound,
  }) {
    final issues = <String>[];

    // 智能地解析异常类型，优先处理信息最丰富的 CheckedFromJsonException
    if (exception is CheckedFromJsonException) {
      final key = exception.key ?? 'UNKNOWN_KEY';
      final message = exception.message ?? 'No specific message';
      final innerError = exception.innerError != null
          ? " (Inner error: ${exception.innerError})"
          : "";

      issues.add(
          "A structural error occurred at field '$key'. Reason: $message$innerError");
    } else {
      // 处理所有其他类型的通用异常
      issues.add("An unexpected exception occurred during parsing: $exception");
    }

    // 使用 `stack_trace` 包来解析和美化堆栈信息
    try {
      final trace = Trace.from(stackTrace);
      // 找到第一个与我们的项目相关的、非核心库的帧
      final relevantFrame = trace.frames.firstWhere(
        (f) => !f.isCore && f.package != 'flutter',
        // 如果找不到，就回退到第一个帧
        orElse: () => trace.frames.first,
      );
      // 获取文件名、行号和列号
      final location =
          relevantFrame.location.split('/').last; // 只取 "file.dart:line:col"
      issues.add("Probable error location: $location");
    } catch (e) {
      // 如果堆栈解析失败，也能优雅地处理
      issues.add("Could not parse stack trace.");
    }

    // 通过回调将格式化后的问题列表上报给使用者
    onIssuesFound?.call(
      modelType: modelType,
      issues: issues,
    );
    if (kDebugMode) {
      debugPrint(
          'JsonSanitizer encountered an unhandled exception for model "$modelType":');
      debugPrint(issues.join('\n'));
    }
  }
}
