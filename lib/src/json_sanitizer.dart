

// 引入Firebase Crashlytics (可选)
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';

class JsonSanitizer {
  final Map<String, dynamic> schema;

  JsonSanitizer(this.schema);

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
    final isExpectingMap = expectedSchema is MapSchema || expectedSchema is Map<String, dynamic>;
    if (isExpectingMap && value is List && value.isEmpty) {
      if (kDebugMode) {
        debugPrint(
            'JsonSanitizer Info: Converting empty List [] to empty Map {} for key "$key".');
      }

      return {};
    }
    
    // 场景1: 处理 List
    if (expectedSchema is ListSchema) {
      if (value is List) {
        return value
            .map((item) => _convertValue(item, expectedSchema.itemSchema, key))
            .toList();
      }
      _reportError('Expected List for key "$key", but got ${value.runtimeType}', value);
      return []; // 返回安全的空List
    }

    // 场景2: 处理 Map
    if (expectedSchema is MapSchema) {
      if (value is Map) {
        return value.map((k, v) =>
            MapEntry(k, _convertValue(v, expectedSchema.valueSchema, '$key.$k')));
      }
      _reportError('Expected Map for key "$key", but got ${value.runtimeType}', value);
      return {}; // 返回安全的空Map
    }

    // 场景3: 处理嵌套的自定义模型
    if (expectedSchema is Map<String, dynamic>) {
       if (value is Map<String, dynamic>) {
         return JsonSanitizer.sanitize(value, expectedSchema);
       }
        _reportError('Expected nested object for key "$key", but got ${value.runtimeType}', value);
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
        _reportError('Failed to convert key "$key" with value "$value" to type $expectedSchema', value);
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