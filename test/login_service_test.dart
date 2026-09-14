import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/auth_session.dart';
import 'package:unipar_trilha_app/modules/login/dto/login_request.dart';
import 'package:unipar_trilha_app/modules/login/dto/perfil_usuario.dart';
import 'package:unipar_trilha_app/modules/login/service/login_service.dart';

import 'support/fake_http_client_adapter.dart';
import 'support/memory_auth_storage.dart';

void main() {
  test('login envia contrato real e salva sessão sem senha', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://teste'));
    final adapter = FakeHttpClientAdapter(
      (_) => jsonResponse('''{
        "accessToken":"jwt-real",
        "tokenType":"Bearer",
        "expiresInMinutes":480,
        "usuarioId":2,
        "login":"professor",
        "nome":"Professor Demo",
        "perfil":"PROFESSOR"
      }'''),
    );
    dio.httpClientAdapter = adapter;
    final storage = MemoryAuthStorage();
    final session = AuthSession.forTesting(storage: storage, dio: dio);

    final response = await LoginService(
      dio: dio,
      authSession: session,
    ).efetuarLogin(const LoginRequest(login: 'professor', senha: 'prof123'));

    expect(adapter.requests.single.data, {
      'login': 'professor',
      'senha': 'prof123',
    });
    expect(response.perfil, PerfilUsuario.professor);
    expect(storage.value?.token, 'jwt-real');
    expect(storage.value?.usuario.login, 'professor');
    expect(session.state.autenticada, isTrue);
  });

  test('401 de login usa mensagem de credenciais', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://teste'));
    dio.httpClientAdapter = FakeHttpClientAdapter(
      (_) => jsonResponse('{"status":401}', statusCode: 401),
    );
    final session = AuthSession.forTesting(
      storage: MemoryAuthStorage(),
      dio: dio,
    );

    await expectLater(
      LoginService(
        dio: dio,
        authSession: session,
      ).efetuarLogin(const LoginRequest(login: 'x', senha: 'y')),
      throwsA(
        isA<ApiError>().having(
          (error) => error.message,
          'message',
          'Login ou senha inválidos.',
        ),
      ),
    );
  });
}
