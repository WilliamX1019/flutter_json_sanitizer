import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_json_sanitizer/src/json_sanitizer.dart';
import 'package:flutter_json_sanitizer/src/json_parser_worker.dart';

// --- Mock Models (Must be top-level for Isolate compatibility) ---
class TestWorkerUser {
  final int id;
  final String? name;

  TestWorkerUser({required this.id, this.name});

  static TestWorkerUser fromJson(Map<String, dynamic> json) {
    return TestWorkerUser(
      id: json['id'] as int,
      name: json['name'] as String?,
    );
  }
}

final Map<String, dynamic> testWorkerUserSchema = {
  'id': int,
  'name': String,
};

void main() {
  group('JsonParserWorker Integration Tests', () {
    setUpAll(() async {
      // Initialize the worker
      await JsonParserWorker.instance.initialize();
    });

    tearDownAll(() {
      JsonParserWorker.instance.dispose();
    });

    test('parseAsync sanitizes and returns model', () async {
      final data = {
        'id': '999', // String to Int
        'name': 'Worker Alice',
      };

      final result = await JsonSanitizer.parseAsync<TestWorkerUser>(
        data: data,
        schema: testWorkerUserSchema,
        fromJson: TestWorkerUser.fromJson,
        modelType: TestWorkerUser,
        onIssuesFound: ({required modelType, required issues}) {
          // Should not have critical issues, but maybe sanitization logs
          print('TestWorkerUser issues: $issues');
        },
      );

      expect(result, isNotNull);
      expect(result!.id, 999);
      expect(result.name, 'Worker Alice');
    });

    test('parseAsync sanitizes empty string to null', () async {
      final data = {
        'id': 123,
        'name': '', // Empty string -> null
      };

      final result = await JsonSanitizer.parseAsync<TestWorkerUser>(
        data: data,
        schema: testWorkerUserSchema,
        fromJson: TestWorkerUser.fromJson,
        modelType: TestWorkerUser,
      );

      expect(result, isNotNull);
      expect(result!.id, 123);
      expect(result.name, isNull);
    });

    test(
        'parseAsync handles crash (missing required field) and reports via callback',
        () async {
      final badData = {
        // 'id': 123, // Missing ID will cause fromJson to crash (int cast null)
        'name': 'Worker Bob',
      };

      bool issueReported = false;
      String? reportedIssues;

      final result = await JsonSanitizer.parseAsync<TestWorkerUser>(
        data: badData,
        schema: testWorkerUserSchema,
        fromJson: TestWorkerUser.fromJson,
        modelType: TestWorkerUser,
        onIssuesFound: ({required modelType, required issues}) {
          issueReported = true;
          reportedIssues = issues;
        },
      );

      expect(result, isNull);
      expect(issueReported, true);
      expect(reportedIssues, isNotNull);
      final decoded = jsonDecode(reportedIssues!);
      expect(decoded.toString(), contains("unexpected exception"));
    });
  });
}
