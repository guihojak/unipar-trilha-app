import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/api_client.dart';

import 'support/fake_http_client_adapter.dart';

void main() {
  late Dio dio;
  late FakeHttpClientAdapter adapter;
  late ApiClient client;
  var unauthorizedCalls = 0;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://teste'));
    adapter = FakeHttpClientAdapter((_) => jsonResponse('{}'));
    dio.httpClientAdapter = adapter;
    client = ApiClient(dio: dio)
      ..configureAuthentication(
        tokenReader: () async => 'token-seguro',
        onUnauthorized: () async => unauthorizedCalls++,
      );
    unauthorizedCalls = 0;
  });

  test('adiciona Bearer somente em endpoint protegido', () async {
    await client.dio.get<Object?>('/usuarios/me');
    await client.dio.get<Object?>('/auth/login');
    await client.dio.get<Object?>('/actuator/health');

    expect(adapter.requests[0].headers['Authorization'], 'Bearer token-seguro');
    expect(adapter.requests[1].headers['Authorization'], isNull);
    expect(adapter.requests[2].headers['Authorization'], isNull);
  });

  test('401 protegido solicita invalidação sem repetir requisição', () async {
    adapter = FakeHttpClientAdapter(
      (_) => jsonResponse('{"status":401}', statusCode: 401),
    );
    dio.httpClientAdapter = adapter;

    await expectLater(
      client.dio.get<Object?>('/usuarios/me'),
      throwsA(isA<DioException>()),
    );
    expect(unauthorizedCalls, 1);
    expect(adapter.requests, hasLength(1));
  });

  test('401 do login não invalida sessão', () async {
    adapter = FakeHttpClientAdapter(
      (_) => jsonResponse('{"status":401}', statusCode: 401),
    );
    dio.httpClientAdapter = adapter;

    await expectLater(
      client.dio.post<Object?>('/auth/login'),
      throwsA(isA<DioException>()),
    );
    expect(unauthorizedCalls, 0);
  });
}
