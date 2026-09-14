import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/core/api_client.dart';
import 'package:unipar_trilha_app/core/auth_session.dart';
import 'package:unipar_trilha_app/core/health_service.dart';
import 'package:unipar_trilha_app/modules/login/dto/login_request.dart';
import 'package:unipar_trilha_app/modules/login/service/login_service.dart';

import '../support/memory_auth_storage.dart';

const runBackendIntegration = bool.fromEnvironment('RUN_BACKEND_INTEGRATION');
const backendLogin = String.fromEnvironment('BACKEND_TEST_LOGIN');
const backendPassword = String.fromEnvironment('BACKEND_TEST_PASSWORD');

void main() {
  test(
    'health, login, perfil corrente e logout na API real',
    () async {
      if (backendLogin.isEmpty || backendPassword.isEmpty) {
        fail('Informe BACKEND_TEST_LOGIN e BACKEND_TEST_PASSWORD.');
      }

      final client = ApiClient();
      final storage = MemoryAuthStorage();
      final session = AuthSession.forTesting(storage: storage, dio: client.dio);
      client.configureAuthentication(
        tokenReader: session.obterToken,
        onUnauthorized: session.invalidarPorUnauthorized,
      );

      expect((await HealthService(dio: client.dio).consultar()).isUp, isTrue);
      await LoginService(dio: client.dio, authSession: session).efetuarLogin(
        const LoginRequest(login: backendLogin, senha: backendPassword),
      );
      expect((await session.restaurar()).autenticada, isTrue);
      await session.logout();
      expect(session.state.status, AuthSessionStatus.semSessao);
    },
    skip: runBackendIntegration
        ? false
        : 'Integração real é executada somente quando solicitada.',
  );
}
