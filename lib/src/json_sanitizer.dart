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
  required String modelName,
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
  final String modelName;

  /// 使用异步方式上报问题时，会在子Isolate中进行
  /// 需要避免捕获了外部作用域的变量
  final DataIssueCallback? onIssuesFound;

  /// 构造函数现在接收上报所需的信息。
  JsonSanitizer._({
    required this.schema,
    required this.modelName,
    this.onIssuesFound,
  });

  /// [Isolate专用] - 一个特殊的内部构造函数，供后台Isolate使用。
  factory JsonSanitizer.createInstanceForIsolate({
    required Map<String, dynamic> schema,
    required String modelName,
  }) {
    return JsonSanitizer._(
        schema: schema, modelName: modelName, onIssuesFound: null);
  }

  /// 🧩 [主Isolate专用] - 对原始JSON数据进行验证和上报。
  static bool validate({
    required dynamic data,
    required Map<String, dynamic> schema,
    required String modelName,
    DataIssueCallback? onIssuesFound,
    List<String>? monitoredKeys,
  }) {
    // 步骤 1: 验证最外层容器的有效性
    if (data == null || data is! Map<String, dynamic>) {
      onIssuesFound?.call(
        modelName: modelName,
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
        onIssuesFound(modelName: modelName, issues: validationIssues);
      }
    }
    return true;
  }

  /// 一个健壮的、一体化的API响应解析器。
  ///
  /// 它在一个调用中完成验证、上报问题、清洗数据和创建模型实例的全过程。
  ///
  /// - [T]: 期望返回的模型类型。
  /// - [data]: 来自API的原始响应体（例如，通过`jsonDecode`解码后的结果）。
  /// - [schema]: 对应目标模型的、由`@generateSchema`自动生成的Schema（例如，`$UserProfileSchema`）。
  /// - [fromJson]: 目标模型的工厂构造函数（例如，`UserProfile.fromJson`）。
  /// - [modelName]: 模型的字符串名称，用于上报目的。
  /// - [onIssuesFound]: 一个可选的回调函数。当发现`null`或空值时触发，
  ///   允许用户实现自定义的上报逻辑（例如，记录到Firebase或Sentry）。
  /// - [monitoredKeys]: 一个可选的、指定需要监控`null`或空值的特定字段键名列表。
  ///   如果提供此列表，则只会验证这些指定的字段。
  ///   如果省略（为`null`），则默认验证`schema`中定义的所有字段。
  ///
  /// 如果数据从根本上无效（例如，不是一个Map）或在解析过程中发生异常，则返回`null`。
  /// 否则，返回成功解析后的模型实例。
  /// 🧩 同步版 - 适用于小中型 JSON
  static T? parse<T>({
    required dynamic data,
    required Map<String, dynamic> schema,
    required T Function(Map<String, dynamic>) fromJson,
    required String modelName,
    DataIssueCallback? onIssuesFound, //局部回调
    List<String>? monitoredKeys,
  }) {
    // 优先使用局部传入的回调。如果局部回调为null，则使用全局默认回调。
    final effectiveCallback = onIssuesFound ?? globalDataIssueCallback;
    // 验证数据是否符合预期的Schema
    final isValid = JsonSanitizer.validate(
        data: data,
        schema: schema,
        modelName: modelName,
        onIssuesFound: effectiveCallback,
        monitoredKeys: monitoredKeys);
    if (!isValid) return fromJson({});
    //  清洗和解析
    try {
      // 调用内部的、私有的 _sanitize 方法来执行实际的数据清洗
      // --- 核心改动：创建实例时传入回调和模型名 ---
      final sanitizer = JsonSanitizer._(
        schema: schema,
        modelName: modelName,
        onIssuesFound: effectiveCallback,
      );
      final sanitizedJson = sanitizer.processMap(data);
      // 使用清洗后的、类型安全的数据来创建模型实例
      return fromJson(sanitizedJson);
    } catch (e, stackTrace) {
      _reportError(
        // _reportError 保持为静态方法，处理顶层异常
        modelName: modelName,
        exception: e,
        stackTrace: stackTrace,
        onIssuesFound: effectiveCallback,
      );
      return null;
    }
  }

  /// 🚀 异步版 - 适用于大型 JSON，自动在独立 isolate 执行
  static Future<T?> parseAsync<T>({
    required dynamic data,
    required Map<String, dynamic> schema,
    required T Function(Map<String, dynamic>) fromJson,
    required String modelName,
    DataIssueCallback? onIssuesFound,
    List<String>? monitoredKeys,
  }) async {
    ///! 完成模型注册，确保在后台 Isolate 中可用。
    // ModelRegistry.register<T>(modelName, (json) => fromJson(json));
      // 动态注册模型（确保只注册一次）
  if (!ModelRegistry.isRegistered(modelName)) {
    ModelRegistry.register<T>(modelName, (json) => fromJson(json));
  }

    final effectiveCallback = onIssuesFound ?? globalDataIssueCallback;
    // 验证数据是否符合预期的Schema
    final isValid = JsonSanitizer.validate(
        data: data,
        schema: schema,
        modelName: modelName,
        onIssuesFound: effectiveCallback,
        monitoredKeys: monitoredKeys);
    if (!isValid) return fromJson({});
    // 只将【清洗和解析】这个纯计算任务和纯数据发送到后台 Isolate。
    try {
      //现在是纯数据清洗，解析在主 Isolate 中进行。
      final sanitizedJson = await JsonParserWorker.instance.parseAndSanitize<T>(
        data: data,
        schema: schema,
        modelName: modelName,
        fromJson: (json) => ModelRegistry.create(modelName, json),
      );
      // if (sanitizedJson != null) {
      //   return fromJson(sanitizedJson);
      // }
      return sanitizedJson;
    } catch (e, stackTrace) {
      // 捕获后台的纯解析异常，并在【主 Isolate】中上报。
      _reportError(
        modelName: modelName,
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
    // --- 结构性错误修复（优化和整合后）---
    final isExpectingMap =
        expectedSchema is MapSchema || expectedSchema is Map<String, dynamic>;
    if (isExpectingMap) {
      if (value is List && value.isEmpty) {
        // 空List -> 空Map
        _reportStructuralError(
            key: key, expectedType: 'Map', receivedValue: value);
        return <String, dynamic>{};
      }
      if (value is String && value.trim().isEmpty) {
        // 空String -> 空Map
        _reportStructuralError(
            key: key, expectedType: 'Map', receivedValue: value);
        return <String, dynamic>{};
      }
    }
    if (expectedSchema is ListSchema) {
      if (value is Map) {
        // Map -> 空List
        _reportStructuralError(
            key: key, expectedType: 'List', receivedValue: value);
        return [];
      }
      if (value is String) {
        // String -> List (支持逗号分隔)
        _reportStructuralError(
            key: key, expectedType: 'List', receivedValue: value);
        return value
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    // 场景: 处理 List
    if (expectedSchema is ListSchema) {
      if (value is List) {
        return value
            .map((item) => _convertValue(item, expectedSchema.itemSchema, key))
            .toList();
      }
      _reportStructuralError(
        key: key,
        expectedType: 'List',
        receivedValue: value,
      );
      return []; // 返回安全的空List
    }

    // 场景: 处理 Map
    if (expectedSchema is MapSchema) {
      if (value is Map) {
        return value.map((k, v) => MapEntry(
            k, _convertValue(v, expectedSchema.valueSchema, '$key.$k')));
      }
      _reportStructuralError(
        key: key,
        expectedType: 'Map<String, dynamic>',
        receivedValue: value,
      );
      return {}; // 返回安全的空Map
    }

    // 场景: 处理嵌套的自定义模型
    if (expectedSchema is Map<String, dynamic>) {
      if (value is Map<String, dynamic>) {
        // 为嵌套调用创建一个新的Sanitizer实例
        final nestedSanitizer = JsonSanitizer._(
          schema: expectedSchema,
          modelName: key, // 使用字段名作为嵌套模型的名
          onIssuesFound: onIssuesFound,
        );
        return nestedSanitizer.processMap(value);
      }
      // --- 关键改动：调用上报方法 ---
      _reportStructuralError(
        key: key,
        expectedType: 'Map<String, dynamic>',
        receivedValue: value,
      );
      return <String, dynamic>{}; // 返回安全的默认值
    }

    // 场景: 处理基础类型
    if (expectedSchema is Type) {
      try {
        if (expectedSchema == int) {
          if (value is int) return value;
          if (value is double) return value.toInt();
          if (value is String) return int.tryParse(value) ?? 0;
          throw 'Cannot convert to int';
        }
        if (expectedSchema == double) {
          if (value is double) return value;
          if (value is int) return value.toDouble();
          if (value is String) return double.tryParse(value) ?? 0.0;
          throw 'Cannot convert to double';
        }
        if (expectedSchema == String) {
          if (value is String) return value;
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

    // 如果没有匹配的规则，返回原值
    return value;
  }

  void _reportStructuralError({
    required String key,
    required String expectedType,
    required dynamic receivedValue,
  }) {
    onIssuesFound?.call(
      modelName: modelName,
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
    required String modelName,
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
      modelName: modelName,
      issues: issues,
    );
    if (kDebugMode) {
      debugPrint(
          'JsonSanitizer encountered an unhandled exception for model "$modelName":');
      debugPrint(issues.join('\n'));
    }
  }
}
