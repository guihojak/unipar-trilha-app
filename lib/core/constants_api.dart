final class ConstantsApi {
  ConstantsApi._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const String health = '/actuator/health';
  static const String login = '/auth/login';
  static const String usuarioAtual = '/usuarios/me';
}
