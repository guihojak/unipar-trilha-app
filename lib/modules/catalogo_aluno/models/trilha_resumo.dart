import 'package:unipar_trilha_app/core/widgets/trail_card.dart';

/// Ícone do curso exibido na caixa do card.
///
/// O kit não traz ícones de curso; `TrilhaCard` usa os glifos equivalentes do
/// Font Awesome, dependência já prevista no projeto.
enum IconeTrilha { codigo, objetos, servidor, livro }

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
