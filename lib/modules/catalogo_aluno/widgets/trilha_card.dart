import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unipar_trilha_app/core/widgets/trail_card.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/models/trilha_resumo.dart';

/// Liga um [TrilhaResumo] ao `TrailCard` do design system.
///
/// Usado pela home (tela 1) e pelo catálogo (tela 3).
class TrilhaCard extends StatelessWidget {
  const TrilhaCard({super.key, required this.trilha, required this.onAbrir});

  final TrilhaResumo trilha;
  final ValueChanged<TrilhaResumo> onAbrir;

  @override
  Widget build(BuildContext context) {
    return TrailCard(
      title: trilha.titulo,
      progress: trilha.progresso,
      status: trilha.status,
      tone: trilha.tom,
      hasNotification: trilha.temNotificacao,
      leading: switch (trilha.icone) {
        IconeTrilha.codigo => const FaIcon(FontAwesomeIcons.code),
        IconeTrilha.objetos => const FaIcon(FontAwesomeIcons.cube),
        IconeTrilha.servidor => const FaIcon(FontAwesomeIcons.server),
        IconeTrilha.livro => null,
      },
      onAction: () => onAbrir(trilha),
    );
  }
}
