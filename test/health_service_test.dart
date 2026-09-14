import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/health_service.dart';

import 'support/fake_http_client_adapter.dart';

void main() {
  test('considera a API online somente com status UP', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://teste'));
    dio.httpClientAdapter = FakeHttpClientAdapter(
      (_) => jsonResponse('{"status":"UP"}'),
    );

    final health = await HealthService(dio: dio).consultar();
    expect(health.isUp, isTrue);
  });

  test('rejeita health com status diferente de UP', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://teste'));
    dio.httpClientAdapter = FakeHttpClientAdapter(
      (_) => jsonResponse('{"status":"DOWN"}'),
    );

    await expectLater(
      HealthService(dio: dio).consultar(),
      throwsA(isA<ApiError>()),
    );
  });
}
