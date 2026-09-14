import 'package:unipar_trilha_app/modules/login/dto/perfil_usuario.dart';

class UsuarioResponse {
  const UsuarioResponse({
    required this.id,
    required this.login,
    required this.nome,
    required this.perfil,
    required this.ativo,
  });

  final int id;
  final String login;
  final String nome;
  final PerfilUsuario perfil;
  final bool ativo;

  factory UsuarioResponse.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final login = json['login'];
    final nome = json['nome'];
    final ativo = json['ativo'];
    if (id is! num || login is! String || nome is! String || ativo is! bool) {
      throw const FormatException('Resposta do usuário inválida.');
    }
    return UsuarioResponse(
      id: id.toInt(),
      login: login,
      nome: nome,
      perfil: PerfilUsuario.fromJson(json['perfil']),
      ativo: ativo,
    );
  }
}
