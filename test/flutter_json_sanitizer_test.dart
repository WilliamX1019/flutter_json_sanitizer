import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';

// --- Test Schemas ---
const Map<String, dynamic> testUserSchema = {
  'id': int,
  'name': String,
  'is_active': bool,
  'score': double,
  'tags': ListSchema(itemType: String, itemSchema: String),
  'profile': <String, dynamic>{
    'age': int,
  },
  'meta': MapSchema(valueSchema: String),
};

void main() {
  group('JsonSanitizer Data Cleaning', () {
    late JsonSanitizer sanitizer;
    List<String> collectedIssues = [];

    setUp(() {
      collectedIssues.clear();
      sanitizer = JsonSanitizer.createInstanceForIsolate(
        schema: testUserSchema,
        modelType: Object,
        onIssuesFound: ({required modelType, required issues}) {
          collectedIssues.addAll(issues);
        },
      );
    });

    test('Primitives Sanitization (Type Correction)', () {
      final input = {
        'id': '123', // String -> int
        'name': 456, // int -> String
        'is_active': '1', // String "1" -> bool true
        'score': '99.9', // String -> double
      };

      final result = sanitizer.processMap(input);

      expect(result['id'], equals(123));
      expect(result['name'], equals('456'));
      expect(result['is_active'], isTrue);
      expect(result['score'], equals(99.9));
      expect(collectedIssues, isEmpty);
    });

    test('PHP Array to List conversion', () {
      // PHP often returns {"0": "a", "1": "b"} instead of ["a", "b"]
      final input = {
        'tags': {'0': 'flutter', '1': 'dart'}
      };

      final result = sanitizer.processMap(input);

      expect(result['tags'], isA<List>());
      expect(result['tags'], equals(['flutter', 'dart']));
      expect(collectedIssues, isEmpty);
    });

    test('Empty List to Map conversion (PHP empty object issue)', () {
      // PHP returns [] for empty object, but we expect Map {}
      final input = {'profile': [], 'meta': []};

      final result = sanitizer.processMap(input);

      expect(result['profile'], isA<Map>());
      expect(result['profile'], isEmpty);
      expect(result['meta'], isA<Map>());
      expect(result['meta'], isEmpty);

      // Should report structural errors for fixing raw list to map
      expect(collectedIssues.length, greaterThanOrEqualTo(2));
      expect(
          collectedIssues
              .any((s) => s.contains("Expected a Map<String, dynamic>")),
          isTrue);
    });

    test('Unfixable Type Error Handling', () {
      final input = {
        'id': 'abc' // cannot parse 'abc' to int
      };

      final result = sanitizer.processMap(input);

      // Should return default value 0 for int
      expect(result['id'], equals(0));

      // Should report error
      expect(collectedIssues, isNotEmpty);
      expect(
          collectedIssues.first,
          anyOf(
              contains('Cannot convert to int'), contains('Structural error')));
    });

    test('Bad Double Parsing (Multiple dots)', () {
      final input = {'score': '12.34.56'};

      final result = sanitizer.processMap(input);
      expect(result['score'], equals(0.0)); // Default
      expect(collectedIssues, isNotEmpty);
    });
  });

  group('JsonSanitizer Validation', () {
    test('Empty Map Validation', () {
      List<String> collectedIssues = [];

      // Just call validate
      // Must use <String, dynamic>{} because plain {} is Map<dynamic, dynamic> and validate checks strict type
      final isValid = JsonSanitizer.validate(
          data: <String, dynamic>{},
          schema: testUserSchema,
          modelType: Object,
          onIssuesFound: ({required modelType, required issues}) {
            collectedIssues.addAll(issues);
          });

      expect(isValid, false);
      expect(collectedIssues, isNotEmpty);
      expect(collectedIssues.first, contains('empty map'));
    });

    test('Null Root Validation', () {
      List<String> collectedIssues = [];
      final isValid = JsonSanitizer.validate(
          data: null,
          schema: testUserSchema,
          modelType: Object,
          onIssuesFound: ({required modelType, required issues}) {
            collectedIssues.addAll(issues);
          });

      expect(isValid, false);
      expect(collectedIssues.first, contains('is null'));
    });

    test('Monitored Keys Validation', () {
      List<String> collectedIssues = [];
      final input = {
        'id': null, // Monitored and null
        'name': null // Not monitored
      };

      JsonSanitizer.validate(
          data: input,
          schema: testUserSchema,
          modelType: Object,
          monitoredKeys: ['id'], // Only check id
          onIssuesFound: ({required modelType, required issues}) {
            collectedIssues.addAll(issues);
          });

      expect(collectedIssues.length, equals(1));
      expect(collectedIssues.first, contains("'id' is null"));
    });
  });
}
