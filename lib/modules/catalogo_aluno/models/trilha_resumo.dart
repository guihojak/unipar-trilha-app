import 'package:unipar_trilha_app/core/widgets/trail_card.dart';
import 'package:unipar_trilha_app/shared/models/icone_trilha.dart';

export 'package:unipar_trilha_app/shared/models/icone_trilha.dart';

/// Trilha exibida nos cards da home (tela 1) e do catálogo (tela 3).
class TrilhaResumo {
  const TrilhaResumo({
    required this.id,
    required this.titulo,
    required this.progresso,
    required this.status,
    this.tom = TrailCardTone.blue,
    this.icone = IconeTrilha.livro,
    this.temNotificacao = false,
  });

  final int id;
  final String titulo;

  /// Progresso de 0 a 1.
  final double progresso;
  final TrailStatus status;
  final TrailCardTone tom;
  final IconeTrilha icone;

  /// Exibe o sino de novidade no card.
  final bool temNotificacao;
}
