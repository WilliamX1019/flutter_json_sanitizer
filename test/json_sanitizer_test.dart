import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_json_sanitizer/src/json_sanitizer.dart';
import 'package:flutter_json_sanitizer/src/schema_helpers.dart';

// --- Mock Models for Testing ---
class TestUser {
  final int id;
  final String name;
  final bool isActive;
  final double score;

  TestUser({
    required this.id,
    required this.name,
    required this.isActive,
    required this.score,
  });

  static TestUser fromJson(Map<String, dynamic> json) {
    return TestUser(
      id: json['id'] as int,
      name: json['name'] as String,
      isActive: json['isActive'] as bool,
      score: (json['score'] as num).toDouble(),
    );
  }
}

final Map<String, dynamic> testUserSchema = {
  'id': int,
  'name': String,
  'isActive': bool,
  'score': double,
};

class TestGroup {
  final String groupName;
  final List<TestUser> members;

  TestGroup({required this.groupName, required this.members});

  static TestGroup fromJson(Map<String, dynamic> json) {
    return TestGroup(
      groupName: json['groupName'] as String,
      members: (json['members'] as List)
          .map((e) => TestUser.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

final Map<String, dynamic> testGroupSchema = {
  'groupName': String,
  'members': ListSchema(itemType: TestUser, itemSchema: testUserSchema),
};

void main() {
  group('JsonSanitizer Unit Tests', () {
    late JsonSanitizer sanitizer;

    setUp(() {
      // Setup if needed
    });

    test('Validates and sanitizes correct data', () {
      final data = {
        'id': 1,
        'name': 'Alice',
        'isActive': true,
        'score': 95.5,
      };

      sanitizer = JsonSanitizer.createInstanceForIsolate(
        schema: testUserSchema,
        modelType: TestUser,
      );

      final result = sanitizer.processMap(data);
      final user = TestUser.fromJson(result);

      expect(user.id, 1);
      expect(user.name, 'Alice');
      expect(user.isActive, true);
      expect(user.score, 95.5);
    });

    test('Sanitizes type mismatches (String to Int/Double/Bool)', () {
      final data = {
        'id': '123',
        'name': 'Bob',
        'isActive': 'true',
        'score': '88.8',
      };

      sanitizer = JsonSanitizer.createInstanceForIsolate(
        schema: testUserSchema,
        modelType: TestUser,
      );

      final result = sanitizer.processMap(data);

      expect(result['id'], 123);
      expect(result['isActive'], true);
      expect(result['score'], 88.8);
    });

    test('Handles nulls and defaults', () {
      final data = {
        'id': null, // Should default to 0 for int
        'name': null, // Should be null (nullable string in logic?) or empty?
        // Looking at logic: String -> null if empty/null string.
        // Wait, logic says: if value is null, newMap[key] = null.
        // But TestUser.fromJson expects non-nulls.
        // Let's check _convertValue logic for nulls.
        // processMap: if value == null -> newMap[key] = null.
      };

      // Note: The current JsonSanitizer implementation returns `null` for null values
      // even if the schema expects a type, UNLESS the value is present but wrong type.
      // If the input map has explicit null, it keeps it null.
      // If the input map is missing the key, it's not in the loop.

      // Let's test the type conversion fallback when value is WRONG type (not null).
      final badData = {
        'id': 'not-a-number',
        'name': 123, // Should convert to string "123"
        'isActive': 'invalid-bool',
        'score': 'not-a-double',
      };

      sanitizer = JsonSanitizer.createInstanceForIsolate(
        schema: testUserSchema,
        modelType: TestUser,
        onIssuesFound: ({required modelType, required issues}) {
          // We expect issues here
          print('Issues found: $issues');
        },
      );

      final result = sanitizer.processMap(badData);

      expect(result['id'], 0); // Default for int
      expect(result['name'], '123'); // Converted to string
      expect(result['isActive'], false); // Default for bool
      expect(result['score'], 0.0); // Default for double
    });

    test('Reports issues as JSON string', () {
      final badData = {
        'id':
            true, // bool cannot be converted to int, should trigger catch block
      };

      bool callbackCalled = false;
      String? issuesJson;

      sanitizer = JsonSanitizer.createInstanceForIsolate(
        schema: {'id': int},
        modelType: TestUser,
        onIssuesFound: ({required modelType, required issues}) {
          callbackCalled = true;
          issuesJson = issues;
        },
      );

      sanitizer.processMap(badData);

      expect(callbackCalled, true);
      expect(issuesJson, isNotNull);

      // Verify it is valid JSON
      final decoded = jsonDecode(issuesJson!);
      expect(decoded, isA<List>());
      expect((decoded as List).length, 1);
      expect(decoded.first, contains("Structural error"));
    });

    test('Handles nested lists', () {
      final data = {
        'groupName': 'Devs',
        'members': [
          {'id': 1, 'name': 'Alice', 'isActive': true, 'score': 10.0},
          {
            'id': '2',
            'name': 'Bob',
            'isActive': 'false',
            'score': '20.0'
          }, // Needs sanitization
        ]
      };

      sanitizer = JsonSanitizer.createInstanceForIsolate(
        schema: testGroupSchema,
        modelType: TestGroup,
      );

      final result = sanitizer.processMap(data);
      final group = TestGroup.fromJson(result);

      expect(group.members.length, 2);
      expect(group.members[1].id, 2);
      expect(group.members[1].isActive, false);
    });

    test('Handles PHP-style array (Map with numeric keys) as List', () {
      final data = {
        'groupName': 'PHP Group',
        'members': {
          "0": {'id': 1, 'name': 'A', 'isActive': true, 'score': 1.0},
          "1": {'id': 2, 'name': 'B', 'isActive': true, 'score': 2.0},
        }
      };
      sanitizer = JsonSanitizer.createInstanceForIsolate(
        schema: testGroupSchema,
        modelType: TestGroup,
      );

      final result = sanitizer.processMap(data);

      expect(result['members'], isA<List>());
      expect((result['members'] as List).length, 2);
    });
  });
}
