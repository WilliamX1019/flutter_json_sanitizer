import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:example/http_example/retrofit_sanitizer_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';

// Mock Schema
const Map<String, dynamic> $UserSchema = {
  'id': int,
  'name': String,
  'age': int,
};

// Mock Model
class User {
  final int id;
  final String name;
  final int age;

  User({required this.id, required this.name, required this.age});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int, // expected int
      name: json['name'] as String,
      age: json['age'] as int, // expected int
    );
  }

  @override
  String toString() => 'User(id: $id, name: $name, age: $age)';
}

void main() async {
  print('🚀 Starting SanitizerInterceptor Verification...');

  // Setup Dio
  final dio = Dio();

  // Use a custom adapter to mock network response
  dio.httpClientAdapter = _MockAdapter();

  // Add Sanitizer Interceptor
  dio.interceptors.add(SanitizerInterceptor());

  print('🔧 Interceptors configured.');

  try {
    print('⏳ Making request...');
    final response = await dio.get(
      '/test/user',
      options: Options(extra: {
        'sanitizer_schema': $UserSchema,
        'sanitizer_model_type': User,
      }),
    );

    print('✅ Request completed.');
    print('📄 Response Data: ${response.data}');

    final data = response.data as Map<String, dynamic>;

    // Validate Sanitization
    bool passed = true;
    if (data['id'] != 123) {
      print(
          '❌ FAILED: id should be 123, got ${data['id']} (${data['id'].runtimeType})');
      passed = false;
    }
    if (data['age'] != 25) {
      // 25.5 -> 25
      print(
          '❌ FAILED: age should be 25, got ${data['age']} (${data['age'].runtimeType})');
      passed = false;
    }

    if (passed) {
      print('🎉 Verification SUCCEEDED: Data was properly sanitized!');
    } else {
      print('💀 Verification FAILED.');
    }
  } catch (e) {
    print('❌ Error during request: $e');
  }
}

class _MockAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    print('📡 Adapter: Fetching ${options.path}');
    if (options.path == '/test/user') {
      // Return dirty data as JSON string
      // "id": "123" (String), "age": "25.5" (String)
      final dirtyJson =
          '{"id": "123", "name": "Alice", "age": "25.5", "extra_field": "unused"}';
      return ResponseBody.fromString(
        dirtyJson,
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    throw UnimplementedError('NotFound');
  }

  @override
  void close({bool force = false}) {}
}
