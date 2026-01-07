import 'package:dio/dio.dart';
import 'package:example/http_example/retrofit_sanitizer_interceptor.dart';
import 'package:example/http_example/to_do.dart';
import 'package:example/http_example/schema_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SanitizerInterceptor Integration', () {
    late Dio dio;
    late SanitizerInterceptor interceptor;

    setUp(() {
      dio = Dio();
      interceptor = SanitizerInterceptor();
      dio.interceptors.add(interceptor);
    });

    test('should sanitize data via Interceptor logic using schema in Extra',
        () {
      final dirtyData = {
        'id': '123',
        'title': 'Test Title',
        'completed': 'true'
      };

      final requestOptions = RequestOptions(path: '/test', extra: {
        'sanitizer_schema': $TodoSchema,
        'sanitizer_model_type': Todo
      });

      final response = Response<dynamic>(
        requestOptions: requestOptions,
        data: dirtyData,
      );

      final handler = _MockHandler();

      interceptor.onResponse(response, handler);

      // Verify
      final cleaned = response.data as Map<String, dynamic>;
      expect(cleaned['id'], equals(123)); // String "123" -> int 123
      expect(cleaned['completed'], isTrue); // String "true" -> bool true
      expect(cleaned['title'], equals('Test Title'));
    });
    test(
        'Integration should sanitize data via Interceptor using Dynamic Schema',
        () {
      final requestOptions = RequestOptions(path: '/test', extra: {
        // Simulate @Extra passing a dynamic schema
        'sanitizer_schema': {'id': int, 'name': String},
        'sanitizer_model_type': Map // Or any Type
      });

      final dirtyData = {
        'id': '456', // String -> int
        'name': 12345, // int -> String
        'ignored': 'foo'
      };

      final response = Response<dynamic>(
        requestOptions: requestOptions,
        data: dirtyData,
      );

      final handler = _MockHandler();

      interceptor.onResponse(response, handler);

      // Verify
      final cleaned = response.data as Map<String, dynamic>;
      expect(cleaned['id'], equals(456));
      expect(cleaned['name'], equals('12345'));
    });
    test(
        'Integration should sanitize data via Interceptor using SchemaResolver (Hybrid)',
        () {
      // Register schema
      SchemaResolver.register(Todo, $TodoSchema);

      final requestOptions = RequestOptions(path: '/test', extra: {
        // No schema here, only type
        'sanitizer_model_type': Todo
      });

      final dirtyData = {
        'id': '789', // String -> int
        'title': 'Resolver Test',
        'completed': 'false'
      };

      final response = Response<dynamic>(
        requestOptions: requestOptions,
        data: dirtyData,
      );

      final handler = _MockHandler();

      interceptor.onResponse(response, handler);

      // Verify
      final cleaned = response.data as Map<String, dynamic>;
      expect(cleaned['id'], equals(789));
      expect(cleaned['title'], equals('Resolver Test'));
      expect(cleaned['completed'], isFalse);
    });
  });
}

class _MockHandler extends ResponseInterceptorHandler {
  @override
  void next(Response response) {}
}
