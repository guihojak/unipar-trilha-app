import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/auth_session.dart';
import 'package:unipar_trilha_app/modules/login/dto/login_response.dart';
import 'package:unipar_trilha_app/modules/login/dto/perfil_usuario.dart';
import 'package:unipar_trilha_app/modules/login/dto/usuario_response.dart';

import 'support/fake_http_client_adapter.dart';
import 'support/memory_auth_storage.dart';

const usuario = UsuarioResponse(
  id: 2,
  login: 'professor',
  nome: 'Professor Demo',
  perfil: PerfilUsuario.professor,
  ativo: true,
);

const login = LoginResponse(
  accessToken: 'jwt',
  tokenType: 'Bearer',
  expiresInMinutes: 480,
  usuarioId: 2,
  login: 'professor',
  nome: 'Professor Demo',
  perfil: PerfilUsuario.professor,
);

void main() {
  test('salva, fornece token e remove a sessão', () async {
    final storage = MemoryAuthStorage();
    final session = AuthSession.forTesting(storage: storage, dio: Dio());

    await session.salvarLogin(login);
    expect(await session.obterToken(), 'jwt');
    expect(session.state.usuario?.perfil, PerfilUsuario.professor);

    await session.logout();
    expect(await session.obterToken(), isNull);
    expect(session.state.status, AuthSessionStatus.semSessao);
    expect(storage.value, isNull);
  });

  test('restaura sessão somente após validar em usuarios me', () async {
    final storage = MemoryAuthStorage()
      ..value = const StoredAuthSession(token: 'jwt', usuario: usuario);
    final dio = Dio(BaseOptions(baseUrl: 'http://teste'));
    dio.httpClientAdapter = FakeHttpClientAdapter(
      (_) => jsonResponse('''{
        "id":2,"login":"professor","nome":"Professor Atualizado",
        "perfil":"PROFESSOR","ativo":true
      }'''),
    );
    final session = AuthSession.forTesting(storage: storage, dio: dio);

    final state = await session.restaurar();
    expect(state.status, AuthSessionStatus.autenticada);
    expect(state.usuario?.nome, 'Professor Atualizado');
    expect(storage.value?.usuario.nome, 'Professor Atualizado');
  });

  test('401 ao restaurar limpa a sessão', () async {
    final storage = MemoryAuthStorage()
      ..value = const StoredAuthSession(token: 'jwt', usuario: usuario);
    final dio = Dio(BaseOptions(baseUrl: 'http://teste'));
    dio.httpClientAdapter = FakeHttpClientAdapter(
      (_) => jsonResponse('{"status":401}', statusCode: 401),
    );
    final session = AuthSession.forTesting(storage: storage, dio: dio);

    final state = await session.restaurar();
    expect(state.status, AuthSessionStatus.semSessao);
    expect(storage.value, isNull);
  });

  test('falha de rede mantém dados salvos mas não autentica', () async {
    final storage = MemoryAuthStorage()
      ..value = const StoredAuthSession(token: 'jwt', usuario: usuario);
    final dio = Dio(BaseOptions(baseUrl: 'http://teste'));
    dio.httpClientAdapter = FakeHttpClientAdapter((options) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    });
    final session = AuthSession.forTesting(storage: storage, dio: dio);

    final state = await session.restaurar();
    expect(state.status, AuthSessionStatus.naoValidada);
    expect(state.autenticada, isFalse);
    expect(storage.value?.token, 'jwt');
  });

  test('resposta atrasada não restaura sessão depois do logout', () async {
    final storage = MemoryAuthStorage()
      ..value = const StoredAuthSession(token: 'jwt', usuario: usuario);
    final response = Completer<ResponseBody>();
    final dio = Dio(BaseOptions(baseUrl: 'http://teste'));
    dio.httpClientAdapter = FakeHttpClientAdapter((_) => response.future);
    final session = AuthSession.forTesting(storage: storage, dio: dio);

    final restoring = session.restaurar();
    await Future<void>.delayed(Duration.zero);
    await session.logout();
    response.complete(
      jsonResponse('''{
        "id":2,"login":"professor","nome":"Professor Demo",
        "perfil":"PROFESSOR","ativo":true
      }'''),
    );
    await restoring;

    expect(session.state.status, AuthSessionStatus.semSessao);
    expect(storage.value, isNull);
  });

  test('401 simultâneo executa uma única invalidação', () async {
    final storage = MemoryAuthStorage()
      ..value = const StoredAuthSession(token: 'jwt', usuario: usuario);
    final session = AuthSession.forTesting(storage: storage, dio: Dio());

    await Future.wait([
      session.invalidarPorUnauthorized(),
      session.invalidarPorUnauthorized(),
    ]);

    expect(storage.clearCalls, 1);
  });
}
