import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unipar_trilha_app/core/auth_session.dart';
import 'package:unipar_trilha_app/modules/login/dto/perfil_usuario.dart';
import 'package:unipar_trilha_app/modules/login/dto/usuario_response.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'SharedPreferences persiste somente os dados previstos da sessão',
    () async {
      SharedPreferences.setMockInitialValues({});
      final storage = SharedPreferencesAuthStorage();
      await storage.write(
        const StoredAuthSession(
          token: 'jwt',
          usuario: UsuarioResponse(
            id: 3,
            login: 'aluno',
            nome: 'Aluno Demo',
            perfil: PerfilUsuario.aluno,
            ativo: true,
          ),
        ),
      );

      final restored = await storage.read();
      final preferences = await SharedPreferences.getInstance();
      expect(restored?.token, 'jwt');
      expect(restored?.usuario.perfil, PerfilUsuario.aluno);
      expect(preferences.getKeys(), {
        'auth.accessToken',
        'auth.usuarioId',
        'auth.login',
        'auth.nome',
        'auth.perfil',
        'auth.ativo',
      });
      expect(
        preferences.getKeys().any((key) => key.contains('senha')),
        isFalse,
      );

      await storage.clear();
      expect((await SharedPreferences.getInstance()).getKeys(), isEmpty);
    },
  );
}
