import 'package:flutter/painting.dart';

/// Dados do aluno exibidos no cabeçalho das telas 1, 2 e 3.
class AlunoResumo {
  const AlunoResumo({
    required this.nome,
    required this.ra,
    this.avatar,
    this.sequenciaDias,
  });

  final String nome;
  final String ra;
  final ImageProvider? avatar;

  /// Dias seguidos de estudo. Nulo oculta o indicador.
  final int? sequenciaDias;
}
