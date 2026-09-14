enum PerfilUsuario {
  administrador('ADMINISTRADOR'),
  professor('PROFESSOR'),
  aluno('ALUNO');

  const PerfilUsuario(this.apiValue);

  final String apiValue;

  static PerfilUsuario fromJson(Object? value) {
    return PerfilUsuario.values.firstWhere(
      (perfil) => perfil.apiValue == value,
      orElse: () => throw FormatException('Perfil de usuário inválido: $value'),
    );
  }
}
