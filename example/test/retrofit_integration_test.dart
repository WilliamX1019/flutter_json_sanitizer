import 'package:dio/dio.dart';
import 'package:example/http_example/retrofit_sanitizer_interceptor.dart';
import 'package:example/http_example/to_do.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SanitizerInterceptor Integration', () {
    late Dio dio;
    late SanitizerInterceptor interceptor;

    setUp(() {
      dio = Dio();
      // 使用简单的 SchemaRegistry
      final schemaRegistry = <String, Map<String, dynamic>>{
        'Todo': $TodoSchema,
      };
      interceptor = SanitizerInterceptor(schemaRegistry);
      dio.interceptors.add(interceptor);
    });

    test('should sanitize data via Interceptor logic', () {
      final dirtyData = {
        'id': '123',
        'title': 'Test Title',
        'completed': 'true'
      };

      final requestOptions = RequestOptions(
          path: '/test',
          // 模拟 Retrofit @Headers -> RequestOptions.headers
          headers: {'x-sanitizer-key': 'Todo'},
          extra: {'sanitizer_model_type': Todo});

      final response = Response<dynamic>(
        requestOptions: requestOptions,
        data: dirtyData,
      );

      // Manually trigger interceptor logic by calling onResponse
      // We need a mock handler
      final handler = _MockHandler();

      // Override handler.next to capture result
      // Since ResponseInterceptorHandler is not easily mockable without Mockito,
      // check if we can inspect response.data directly after interceptor modification?
      // SanitizerInterceptor calls super.onResponse(response, handler).
      // We can subclass ResponseInterceptorHandler or just rely on the fact that response.data is modified IN PLACE.

      // Mock handler (minimal)
      // Actually Dio's Handler is abstract class but we can't extend it easily in test without implementing everything.
      // But we don't need to call handler.next() to see the side effect on response.data!
      // The interceptor modifies response.data BEFORE calling super.onResponse.
      // Wait, let's check SanitizerInterceptor implementation:
      // usage: _handleResponse(response); super.onResponse(response, handler);

      interceptor.onResponse(response, handler);

      // Verify
      final cleaned = response.data as Map<String, dynamic>;
      expect(cleaned['id'], equals(123)); // String "123" -> int 123
      expect(cleaned['completed'], isTrue); // String "true" -> bool true
      expect(cleaned['title'], equals('Test Title'));

      // Actually, since we want to test _handleResponse logic, maybe we can just make it public or test side effect?
      // But _handleResponse is private.
      // However, onResponse takes a handler.
      // Let's define a simple class.
    });
  });
}

class _MockHandler extends ResponseInterceptorHandler {
  @override
  void next(Response response) {}
}
