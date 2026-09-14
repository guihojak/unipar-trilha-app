import 'package:unipar_trilha_app/modules/login/dto/perfil_usuario.dart';

class LoginResponse {
  const LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresInMinutes,
    required this.usuarioId,
    required this.login,
    required this.nome,
    required this.perfil,
  });

  final String accessToken;
  final String tokenType;
  final int expiresInMinutes;
  final int usuarioId;
  final String login;
  final String nome;
  final PerfilUsuario perfil;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: _requiredString(json, 'accessToken'),
      tokenType: _requiredString(json, 'tokenType'),
      expiresInMinutes: _requiredInt(json, 'expiresInMinutes'),
      usuarioId: _requiredInt(json, 'usuarioId'),
      login: _requiredString(json, 'login'),
      nome: _requiredString(json, 'nome'),
      perfil: PerfilUsuario.fromJson(json['perfil']),
    );
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
    throw FormatException("Campo obrigatório '$key' ausente ou inválido.");
  }

  static int _requiredInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    throw FormatException("Campo obrigatório '$key' ausente ou inválido.");
  }
}
