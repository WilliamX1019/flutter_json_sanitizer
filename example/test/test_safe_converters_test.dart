import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/safe_convert/parse_error_reporter.dart';
import 'package:example/safe_convert/safe_converter_utils.dart';

void main() {
  setUpAll(() {
    ParseErrorReporter.onReport = (expectedType, invalidValue, stackTrace) {
      print('🚨 [全局上报] 数据异常拦截 -> 预期: [$expectedType], 脏数据: [$invalidValue]');
    };
  });

  group('SafeIntConverter Tests', () {
    const converter = SafeIntConverter();
    const nullConverter = SafeNullableIntConverter();

    test('normal int', () => expect(converter.fromJson(123), 123));
    test('string int', () => expect(converter.fromJson("456"), 456));
    test('double to int', () => expect(converter.fromJson(78.9), 78));
    test('php empty string to nullable int',
        () => expect(nullConverter.fromJson(""), null));
    test('dirty data fallback', () => expect(converter.fromJson({"a": 1}), 0));
  });

  group('SafeDoubleConverter Tests', () {
    const converter = SafeDoubleConverter();
    const nullConverter = SafeNullableDoubleConverter();

    test('normal double', () => expect(converter.fromJson(12.34), 12.34));
    test('int to double', () => expect(converter.fromJson(12), 12.0));
    test('string double', () => expect(converter.fromJson("56.78"), 56.78));
    test('php empty string to nullable',
        () => expect(nullConverter.fromJson(""), null));
    test('dirty data fallback',
        () => expect(converter.fromJson([1, 2, 3]), 0.0));
  });

  group('SafeBoolConverter Tests', () {
    const converter = SafeBoolConverter();

    test('normal bool', () => expect(converter.fromJson(true), true));
    test('int 1 to bool', () => expect(converter.fromJson(1), true));
    test('string "TrUe" to bool',
        () => expect(converter.fromJson("TrUe"), true));
    test('string "0" to bool', () => expect(converter.fromJson("0"), false));
    test('dirty data fallback', () => expect(converter.fromJson("wtf"), false));
  });

  group('SafeMapConverter Tests', () {
    const converter = SafeMapConverter();
    const nullConverter = SafeNullableMapConverter();

    test('normal map', () {
      final normalMap = jsonDecode('{"name": "yunlong", "age": 30}');
      expect(converter.fromJson(normalMap), {"name": "yunlong", "age": 30});
    });

    test('php empty list to map fallback', () {
      final phpEmptyMapAssumedAsList = jsonDecode('[]');
      expect(converter.fromJson(phpEmptyMapAssumedAsList), {});
    });

    test('php null to nullable map', () {
      expect(nullConverter.fromJson(null), null);
    });

    test('dirty data fallback', () {
      final dirtyData = jsonDecode('"not a map"');
      expect(converter.fromJson(dirtyData), {});
    });
  });
}
