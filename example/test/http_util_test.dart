import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/http_example/http_util.dart';

class User {
  final int id;
  final String name;
  User({required this.id, required this.name});

  static User fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: (json['name'] ?? 'Unknown').toString(),
    );
  }

  static Map<String, dynamic> get schema => {"id": "int", "name": "String"};
}

void main() {
  late HttpUtil httpUtil;
  late Dio mockDio;

  setUp(() {
    httpUtil = HttpUtil();
    mockDio = Dio();
    mockDio.options.baseUrl = 'https://api.test';
    httpUtil.setDio(mockDio);
  });

  group('HttpUtil Basic Methods', () {
    test('GET - Zero Mode (Worker)', () async {
      mockDio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.resolve(Response(
            requestOptions: options,
            data:
                '{"code": 200000, "message": "OK", "data": {"id": 1, "name": "Alice"}}',
            statusCode: 200,
          ));
        },
      ));

      final response = await httpUtil.get<User>(
        path: '/user',
        fromJson: User.fromJson,
        schema: User.schema,
        useWorker: true,
      );

      expect(response.isSuccessful, true);
      expect(response.data?.name, 'Alice');
    });

    test('POST - Zero Mode (List)', () async {
      mockDio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.resolve(Response(
            requestOptions: options,
            data:
                '{"code": 200000, "message": "OK", "data": [{"id": 1, "name": "Bob"}, {"id": 2, "name": "Charlie"}]}',
            statusCode: 200,
          ));
        },
      ));

      final response = await httpUtil.post<List<User>>(
        path: '/users',
        fromJson: (list) =>
            (list as List).map((e) => User.fromJson(e)).toList(),
        schema: User.schema,
        useWorker: true,
        isListData: true,
      );

      expect(response.isSuccessful, true);
      expect(response.data?.length, 2);
    });

    test('PUT - Update User', () async {
      mockDio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.method, 'PUT');
          expect((options.data as Map)['name'], 'NewName');
          return handler.resolve(Response(
            requestOptions: options,
            data:
                '{"code": 200000, "message": "Updated", "data": {"id": 1, "name": "NewName"}}',
            statusCode: 200,
          ));
        },
      ));

      final response = await httpUtil.put<User>(
        path: '/user/1',
        data: {"name": "NewName"},
        fromJson: User.fromJson,
        schema: User.schema,
        useWorker: true,
      );

      expect(response.isSuccessful, true);
      expect(response.data?.name, 'NewName');
    });

    test('DELETE - Delete User', () async {
      mockDio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.method, 'DELETE');
          return handler.resolve(Response(
            requestOptions: options,
            data: '{"code": 200000, "message": "Deleted", "data": null}',
            statusCode: 200,
          ));
        },
      ));

      final response = await httpUtil.delete<void>(
        path: '/user/1',
        fromJson: (json) {},
        schema: {},
        useWorker: true,
      );

      expect(response.isSuccessful, true);
      expect(response.message, 'Deleted');
    });
  });

  group('HttpUtil Advanced Scenarios', () {
    test('Interceptor Injection', () async {
      // Inject logic to add header
      httpUtil
          .addInterceptor(InterceptorsWrapper(onRequest: (options, handler) {
        options.headers['X-Custom-Auth'] = 'SecretToken';
        handler.next(options);
      }));

      mockDio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          // Verify header present
          if (options.headers['X-Custom-Auth'] == 'SecretToken') {
            return handler.resolve(Response(
                requestOptions: options,
                data: '{"code": 200000, "message": "Auth OK", "data": null}',
                statusCode: 200));
          } else {
            return handler.reject(
                DioException(requestOptions: options, error: 'Auth Failed'));
          }
        },
      ));

      final response = await httpUtil.get<void>(
        path: '/secure',
        fromJson: (json) {},
        schema: {},
      );

      expect(response.isSuccessful, true);
      expect(response.message, 'Auth OK');
    });

    test('Business Error (Code != 200000)', () async {
      mockDio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.resolve(Response(
            requestOptions: options,
            data: '{"code": 500000, "message": "Server Error", "data": null}',
            statusCode: 200,
          ));
        },
      ));

      final response = await httpUtil.get<void>(
        path: '/error',
        fromJson: (json) {},
        schema: {},
      );

      expect(response.isSuccessful, false);
      expect(response.isBusinessSuccess, false);
      expect(response.code, 500000);
      expect(response.message, 'Server Error');
    });

    test('HTTP Generic Error (404)', () async {
      mockDio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.reject(DioException(
            requestOptions: options,
            response: Response(requestOptions: options, statusCode: 404),
            type: DioExceptionType.badResponse,
          ));
        },
      ));

      final response = await httpUtil.get<void>(
        path: '/not_found',
        fromJson: (json) {},
        schema: {},
      );

      expect(response.isSuccessful, false);
      expect(response.isHttpSuccess, false);
      expect(response.statusCode, 404);
      expect(response.error, contains('Bad response: 404'));
    });

    test('Fallback Mode (List) - Re-verification', () async {
      // Using map data directly to force fallback path usage in test env
      mockDio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.resolve(Response(
            requestOptions: options,
            data: {
              "code": 200000,
              "message": "OK",
              "data": [
                {"id": 10, "name": "FallbackUser"}
              ]
            },
            statusCode: 200,
          ));
        },
      ));

      final response = await httpUtil.request<List<User>>(
        path: '/fallback_list',
        method: 'GET',
        fromJson: (list) =>
            (list as List).map((e) => User.fromJson(e)).toList(),
        schema: User.schema,
        useWorker: false,
        isListData: true,
      );

      expect(response.isSuccessful, true);
      expect(response.data?[0].name, 'FallbackUser');
    });
  });
}
