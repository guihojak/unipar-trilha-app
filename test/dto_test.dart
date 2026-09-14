import 'package:flutter_test/flutter_test.dart';
import 'package:unipar_trilha_app/modules/login/dto/login_request.dart';
import 'package:unipar_trilha_app/modules/login/dto/login_response.dart';
import 'package:unipar_trilha_app/modules/login/dto/perfil_usuario.dart';
import 'package:unipar_trilha_app/modules/login/dto/usuario_response.dart';

void main() {
  test('serializa login somente com login e senha', () {
    const request = LoginRequest(login: 'professor', senha: 'segredo');
    expect(request.toJson(), {'login': 'professor', 'senha': 'segredo'});
  });

  test('interpreta resposta real de login', () {
    final response = LoginResponse.fromJson({
      'accessToken': 'jwt',
      'tokenType': 'Bearer',
      'expiresInMinutes': 480,
      'usuarioId': 2,
      'login': 'professor',
      'nome': 'Professor Demo',
      'perfil': 'PROFESSOR',
    });

    expect(response.accessToken, 'jwt');
    expect(response.expiresInMinutes, 480);
    expect(response.perfil, PerfilUsuario.professor);
  });

  test('reconhece os três perfis da API', () {
    expect(
      PerfilUsuario.fromJson('ADMINISTRADOR'),
      PerfilUsuario.administrador,
    );
    expect(PerfilUsuario.fromJson('PROFESSOR'), PerfilUsuario.professor);
    expect(PerfilUsuario.fromJson('ALUNO'), PerfilUsuario.aluno);
    expect(() => PerfilUsuario.fromJson('OUTRO'), throwsFormatException);
  });

  test('interpreta perfil corrente sem campo de senha', () {
    final response = UsuarioResponse.fromJson({
      'id': 3,
      'login': 'aluno',
      'nome': 'Aluno Demo',
      'perfil': 'ALUNO',
      'ativo': true,
    });

    expect(response.id, 3);
    expect(response.perfil, PerfilUsuario.aluno);
    expect(response.ativo, isTrue);
  });
}
