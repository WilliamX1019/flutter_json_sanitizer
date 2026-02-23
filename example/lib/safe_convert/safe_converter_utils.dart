import 'package:example/safe_convert/parse_error_reporter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// 1. 兼容 PHP 的 Int 转换器
class SafeIntConverter implements JsonConverter<int, dynamic> {
  const SafeIntConverter();

  @override
  int fromJson(dynamic json) {
    if (json is int) return json;
    if (json is double) return json.toInt();
    if (json is String) return int.tryParse(json) ?? 0; // 解析失败给个默认值 0
    if (json is bool) return json ? 1 : 0;
    // ====== 走到这里说明真的是脏数据 (比如 null, "abc", []) ======
    // 触发全局上报
    ParseErrorReporter.report('int', json);
    return 0;
  }

  @override
  dynamic toJson(int object) => object;
}

class SafeNullableIntConverter implements JsonConverter<int?, dynamic> {
  const SafeNullableIntConverter();

  @override
  int? fromJson(dynamic json) {
    if (json == null || json == '') return null; // 兼容 PHP 的空字符串表示 null
    if (json is int) return json;
    if (json is double) return json.toInt();
    if (json is String) return int.tryParse(json);
    // ====== 走到这里说明真的是脏数据 (比如 null, "abc", []) ======
    // 触发全局上报
    ParseErrorReporter.report('int', json);
    return null;
  }

  @override
  dynamic toJson(int? object) => object;
}

// 2. 兼容 PHP 的 Double/Float 转换器
class SafeDoubleConverter implements JsonConverter<double, dynamic> {
  const SafeDoubleConverter();

  @override
  double fromJson(dynamic json) {
    if (json is double) return json;
    if (json is int) return json.toDouble();
    if (json is String) return double.tryParse(json) ?? 0.0;
    // ====== 走到这里说明真的是脏数据 (比如 null, "abc", []) ======
    // 触发全局上报
    ParseErrorReporter.report('double', json);
    return 0.0;
  }

  @override
  dynamic toJson(double object) => object;
}

class SafeNullableDoubleConverter implements JsonConverter<double?, dynamic> {
  const SafeNullableDoubleConverter();

  @override
  double? fromJson(dynamic json) {
    if (json == null || json == '') return null;
    if (json is double) return json;
    if (json is int) return json.toDouble();
    if (json is String) return double.tryParse(json);
    // ====== 走到这里说明真的是脏数据 (比如 null, "abc", []) ======
    // 触发全局上报
    ParseErrorReporter.report('double', json);
    return null;
  }

  @override
  dynamic toJson(double? object) => object;
}

// 3. 兼容 PHP 的 Bool 转换器 (0/1/true/false/"0"/"1")
class SafeBoolConverter implements JsonConverter<bool, dynamic> {
  const SafeBoolConverter();

  @override
  bool fromJson(dynamic json) {
    if (json is bool) return json;
    if (json is int) return json == 1; // 1 为 true, 其他为 false
    if (json is String) {
      if (json == '1' || json.toLowerCase() == 'true') return true;
      if (json == '0' || json.toLowerCase() == 'false' || json == '')
        return false;
    }
    // ====== 走到这里说明真的是脏数据 (比如 null, "abc", []) ======
    // 触发全局上报
    ParseErrorReporter.report('bool', json);
    return false;
  }

  @override
  dynamic toJson(bool object) => object; // 或者根据后端要求返回 object ? 1 : 0
}

class SafeNullableBoolConverter implements JsonConverter<bool?, dynamic> {
  const SafeNullableBoolConverter();

  @override
  bool? fromJson(dynamic json) {
    if (json == null || json == '') return null;
    if (json is bool) return json;
    if (json is int) return json == 1;
    if (json is String) {
      if (json == '1' || json.toLowerCase() == 'true') return true;
      if (json == '0' || json.toLowerCase() == 'false') return false;
    }
    // ====== 走到这里说明真的是脏数据 (比如 null, "abc", []) ======
    // 触发全局上报
    ParseErrorReporter.report('bool', json);
    return null;
  }

  @override
  dynamic toJson(bool? object) => object;
}

// 4. 兼容 PHP 的 Map(关联数组) 转换器
// PHP 的原生数组有索引数组和关联数组两种，如果关联数组内容被清空或者初始化为空，
// json_encode 后通常会变成普通的空数组 `[]`（List），而不是期望的空对象 `{}`（Map）。
// 这会导致 Dart 在 json 映射时抛出 "type 'List<dynamic>' is not a subtype of type 'Map<String, dynamic>'"
class SafeMapConverter implements JsonConverter<Map<String, dynamic>, dynamic> {
  const SafeMapConverter();

  @override
  Map<String, dynamic> fromJson(dynamic json) {
    if (json is Map) {
      // 正常反序列化或者强转
      return Map<String, dynamic>.from(json);
    }
    // 【核心修复】：如果后端返回了空列表 []，我们将其平滑转换为期望的空 Map {}
    if (json is List && json.isEmpty) {
      return <String, dynamic>{};
    }

    // ====== 走到这里说明真的是脏数据 (比如 null, "abc", [1,2,3]) ======
    ParseErrorReporter.report('Map<String, dynamic>', json);
    return <String, dynamic>{};
  }

  @override
  dynamic toJson(Map<String, dynamic> object) => object;
}

class SafeNullableMapConverter
    implements JsonConverter<Map<String, dynamic>?, dynamic> {
  const SafeNullableMapConverter();

  @override
  Map<String, dynamic>? fromJson(dynamic json) {
    if (json == null || json == '') return null;
    if (json is Map) return Map<String, dynamic>.from(json);

    // 兼容 PHP 关联数组空变列表的问题
    if (json is List && json.isEmpty) {
      return <String, dynamic>{};
    }

    ParseErrorReporter.report('Map<String, dynamic>?', json);
    return null;
  }

  @override
  dynamic toJson(Map<String, dynamic>? object) => object;
}
