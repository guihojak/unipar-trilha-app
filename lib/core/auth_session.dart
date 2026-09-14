import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unipar_trilha_app/core/api_client.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/constants_api.dart';
import 'package:unipar_trilha_app/modules/login/dto/login_response.dart';
import 'package:unipar_trilha_app/modules/login/dto/perfil_usuario.dart';
import 'package:unipar_trilha_app/modules/login/dto/usuario_response.dart';

enum AuthSessionStatus { semSessao, validando, autenticada, naoValidada }

class AuthSessionState {
  const AuthSessionState({required this.status, this.usuario, this.message});

  const AuthSessionState.semSessao()
    : status = AuthSessionStatus.semSessao,
      usuario = null,
      message = null;

  final AuthSessionStatus status;
  final UsuarioResponse? usuario;
  final String? message;

  bool get autenticada => status == AuthSessionStatus.autenticada;
}

class StoredAuthSession {
  const StoredAuthSession({required this.token, required this.usuario});

  final String token;
  final UsuarioResponse usuario;
}

abstract interface class AuthStorage {
  Future<StoredAuthSession?> read();
  Future<void> write(StoredAuthSession session);
  Future<void> clear();
}

class SharedPreferencesAuthStorage implements AuthStorage {
  static const _token = 'auth.accessToken';
  static const _usuarioId = 'auth.usuarioId';
  static const _login = 'auth.login';
  static const _nome = 'auth.nome';
  static const _perfil = 'auth.perfil';
  static const _ativo = 'auth.ativo';

  @override
  Future<StoredAuthSession?> read() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString(_token);
    final usuarioId = preferences.getInt(_usuarioId);
    final login = preferences.getString(_login);
    final nome = preferences.getString(_nome);
    final perfil = preferences.getString(_perfil);
    final ativo = preferences.getBool(_ativo);
    if (token == null ||
        token.isEmpty ||
        usuarioId == null ||
        login == null ||
        nome == null ||
        perfil == null ||
        ativo == null) {
      return null;
    }
    try {
      return StoredAuthSession(
        token: token,
        usuario: UsuarioResponse(
          id: usuarioId,
          login: login,
          nome: nome,
          perfil: PerfilUsuario.fromJson(perfil),
          ativo: ativo,
        ),
      );
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> write(StoredAuthSession session) async {
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.setString(_token, session.token),
      preferences.setInt(_usuarioId, session.usuario.id),
      preferences.setString(_login, session.usuario.login),
      preferences.setString(_nome, session.usuario.nome),
      preferences.setString(_perfil, session.usuario.perfil.apiValue),
      preferences.setBool(_ativo, session.usuario.ativo),
    ]);
  }

  @override
  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.remove(_token),
      preferences.remove(_usuarioId),
      preferences.remove(_login),
      preferences.remove(_nome),
      preferences.remove(_perfil),
      preferences.remove(_ativo),
    ]);
  }
}

class AuthSession extends ChangeNotifier {
  AuthSession._({
    required AuthStorage storage,
    required Dio dio,
    ApiClient? clientToConfigure,
  }) : _storage = storage,
       _dio = dio {
    clientToConfigure?.configureAuthentication(
      tokenReader: obterToken,
      onUnauthorized: invalidarPorUnauthorized,
    );
  }

  static final AuthSession instance = AuthSession._(
    storage: SharedPreferencesAuthStorage(),
    dio: ApiClient.shared.dio,
    clientToConfigure: ApiClient.shared,
  );

  @visibleForTesting
  factory AuthSession.forTesting({
    required AuthStorage storage,
    required Dio dio,
  }) => AuthSession._(storage: storage, dio: dio);

  final AuthStorage _storage;
  final Dio _dio;
  AuthSessionState _state = const AuthSessionState.semSessao();
  String? _token;
  int _generation = 0;
  Future<void>? _invalidating;

  AuthSessionState get state => _state;

  Future<String?> obterToken() async {
    if (_token != null) return _token;
    _token = (await _storage.read())?.token;
    return _token;
  }

  Future<void> salvarLogin(LoginResponse login) async {
    _generation++;
    final usuario = UsuarioResponse(
      id: login.usuarioId,
      login: login.login,
      nome: login.nome,
      perfil: login.perfil,
      ativo: true,
    );
    final stored = StoredAuthSession(
      token: login.accessToken,
      usuario: usuario,
    );
    await _storage.write(stored);
    _token = stored.token;
    _setState(
      AuthSessionState(status: AuthSessionStatus.autenticada, usuario: usuario),
    );
  }

  Future<AuthSessionState> restaurar() async {
    final operation = ++_generation;
    final stored = await _storage.read();
    if (operation != _generation) return _state;
    if (stored == null) {
      _token = null;
      _setState(const AuthSessionState.semSessao());
      return _state;
    }

    _token = stored.token;
    _setState(
      AuthSessionState(
        status: AuthSessionStatus.validando,
        usuario: stored.usuario,
      ),
    );
    try {
      final response = await _dio.get<Object?>(ConstantsApi.usuarioAtual);
      if (operation != _generation) return _state;
      final data = response.data;
      if (data is! Map) {
        throw const ApiError(message: 'A resposta do usuário é inválida.');
      }
      final usuario = UsuarioResponse.fromJson(Map<String, dynamic>.from(data));
      if (!usuario.ativo) {
        await _clear(operation);
        return _state;
      }
      await _storage.write(
        StoredAuthSession(token: stored.token, usuario: usuario),
      );
      if (operation != _generation) return _state;
      _setState(
        AuthSessionState(
          status: AuthSessionStatus.autenticada,
          usuario: usuario,
        ),
      );
    } on DioException catch (exception) {
      if (operation != _generation) return _state;
      final error = ApiError.fromDioException(exception);
      if (error.statusCode == 401) {
        await _clear(operation);
      } else {
        _setState(
          AuthSessionState(
            status: AuthSessionStatus.naoValidada,
            usuario: stored.usuario,
            message: error.message,
          ),
        );
      }
    } on FormatException catch (exception) {
      if (operation == _generation) {
        _setState(
          AuthSessionState(
            status: AuthSessionStatus.naoValidada,
            usuario: stored.usuario,
            message: exception.message,
          ),
        );
      }
    } on ApiError catch (error) {
      if (operation == _generation) {
        _setState(
          AuthSessionState(
            status: AuthSessionStatus.naoValidada,
            usuario: stored.usuario,
            message: error.message,
          ),
        );
      }
    }
    return _state;
  }

  Future<void> invalidarPorUnauthorized() {
    return _invalidating ??= logout().whenComplete(() => _invalidating = null);
  }

  Future<void> logout() async {
    _generation++;
    _token = null;
    await _storage.clear();
    _setState(const AuthSessionState.semSessao());
  }

  Future<void> _clear(int operation) async {
    if (operation != _generation) return;
    _generation++;
    _token = null;
    await _storage.clear();
    _setState(const AuthSessionState.semSessao());
  }

  void _setState(AuthSessionState value) {
    _state = value;
    notifyListeners();
  }
}
