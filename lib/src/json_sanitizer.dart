// 引入Firebase Crashlytics (可选)
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';

/// 一个可复用的回调函数类型定义，用于上报在数据验证期间发现的问题。
/// [modelName] 是正在解析的模型的名称。
/// [issues] 是一个描述性字符串列表，说明了发现的具体问题。
typedef DataIssueCallback = void Function({
  required String modelName,
  required List<String> issues,
});

class JsonSanitizer {
  final Map<String, dynamic> schema;

  JsonSanitizer(this.schema);

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
  static T? parse<T>({
    required dynamic data,
    required Map<String, dynamic> schema,
    required T Function(Map<String, dynamic>) fromJson,
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
      return null;
    }

    // 步骤 2: (可选) 处理空Map的情况
    if (data.isEmpty) {
      // 通常，一个空的JSON对象是合法的，可以解析为一个具有默认值的模型。
      // 如果您的业务逻辑视其为无效，可以在这里返回null。
    }

    // 步骤 3: 根据用户定义，验证指定或全部字段
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
        }
      }

      // 如果发现了任何问题，就通过回调执行上报
      if (validationIssues.isNotEmpty) {
        onIssuesFound(modelName: modelName, issues: validationIssues);
      }
    }

    // 步骤 4: 清洗和解析
    try {
      // 调用内部的、私有的 _sanitize 方法来执行实际的数据清洗
      final sanitizedJson = sanitize(data, schema);
      // 使用清洗后的、类型安全的数据来创建模型实例
      return fromJson(sanitizedJson);
    } catch (e, stackTrace) {
      // 捕获在清洗或模型创建过程中可能发生的任何未预料的异常
      onIssuesFound?.call(
        modelName: modelName,
        issues: ["An unexpected exception occurred during parsing: $e"],
      );
      // 在开发环境中打印堆栈跟踪信息总是有益的
      if (kDebugMode) {
        debugPrint(
            'JsonSanitizer encountered an unhandled exception for model "$modelName":');
        debugPrint(stackTrace.toString());
      }
      return null;
    }
  }

  /// 静态入口方法，接收原始JSON和自动生成的Schema，返回清洗后的JSON。
  static Map<String, dynamic> sanitize(
      Map<String, dynamic> json, Map<String, dynamic> schema) {
    final sanitizer = JsonSanitizer(schema);
    return sanitizer._processMap(json);
  }

  Map<String, dynamic> _processMap(Map<String, dynamic> map) {
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
    // 关键场景：期望得到Map，但后端返回了空List []
    final isExpectingMap =
        expectedSchema is MapSchema || expectedSchema is Map<String, dynamic>;
    if (isExpectingMap && value is List && value.isEmpty) {
      if (kDebugMode) {
        debugPrint(
            'JsonSanitizer Info: Converting empty List [] to empty Map {} for key "$key".');
      }
      // 显式地创建一个类型为 Map<String, dynamic> 的空Map
      return <String, dynamic>{};
    }

    // 场景1: 处理 List
    if (expectedSchema is ListSchema) {
      if (value is List) {
        return value
            .map((item) => _convertValue(item, expectedSchema.itemSchema, key))
            .toList();
      }
      _reportError(
          'Expected List for key "$key", but got ${value.runtimeType}', value);
      return []; // 返回安全的空List
    }

    // 场景2: 处理 Map
    if (expectedSchema is MapSchema) {
      if (value is Map) {
        return value.map((k, v) => MapEntry(
            k, _convertValue(v, expectedSchema.valueSchema, '$key.$k')));
      }
      _reportError(
          'Expected Map for key "$key", but got ${value.runtimeType}', value);
      return {}; // 返回安全的空Map
    }

    // 场景3: 处理嵌套的自定义模型
    if (expectedSchema is Map<String, dynamic>) {
      if (value is Map<String, dynamic>) {
        return JsonSanitizer.sanitize(value, expectedSchema);
      }
      _reportError(
          'Expected nested object for key "$key", but got ${value.runtimeType}',
          value);
      return {}; // 返回安全的空Map
    }

    // 场景4: 处理基础类型
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
        _reportError(
            'Failed to convert key "$key" with value "$value" to type $expectedSchema',
            value);
        if (expectedSchema == int) return 0;
        if (expectedSchema == double) return 0.0;
        if (expectedSchema == String) return '';
        if (expectedSchema == bool) return false;
      }
    }

    // 如果没有匹配的规则，返回原值
    return value;
  }

  void _reportError(String reason, dynamic value) {
    if (kDebugMode) {
      debugPrint('JsonSanitizer Error: $reason. Value: $value');
    }
    // 可选：上报到Firebase
    // FirebaseCrashlytics.instance.recordError(
    //   Exception(reason),
    //   StackTrace.current,
    //   information: ['Received value: $value'],
    // );
  }
}
