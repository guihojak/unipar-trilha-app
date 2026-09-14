class LoginRequest {
  const LoginRequest({required this.login, required this.senha});

  final String login;
  final String senha;

  Map<String, dynamic> toJson() => {'login': login, 'senha': senha};
}
