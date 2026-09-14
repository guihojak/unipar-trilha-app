import 'package:unipar_trilha_app/shared/models/aluno_resumo.dart';

/// Quantidade de trilhas por curso no card "Cursos/Trilhas" (tela 7).
class CursoResumo {
  const CursoResumo({required this.nome, required this.quantidade});

  final String nome;
  final int quantidade;
}

/// Dados da tela 7 — Visão geral do aluno.
class VisaoGeralAluno {
  const VisaoGeralAluno({
    required this.aluno,
    required this.pontos,
    required this.xp,
    required this.turma,
    required this.professores,
    required this.cursos,
    this.ranking,
  });

  final AlunoResumo aluno;

  /// Couves acumuladas, exibidas no card do perfil.
  final int pontos;
  final int xp;
  final String turma;
  final List<String> professores;
  final List<CursoResumo> cursos;

  /// Nome da faixa de ranking (ex.: "Diamante"). Nulo oculta o item.
  final String? ranking;
}
