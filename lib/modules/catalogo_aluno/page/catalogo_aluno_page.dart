import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/core/widgets/app_empty_state.dart';
import 'package:unipar_trilha_app/core/widgets/app_page.dart';
import 'package:unipar_trilha_app/core/widgets/page_section.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/models/trilha_resumo.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/widgets/trilha_card.dart';
import 'package:unipar_trilha_app/shared/models/aluno_resumo.dart';
import 'package:unipar_trilha_app/shared/widgets/aluno_header.dart';

/// Tela 3 — Trilhas de Aprendizado.
///
/// Estrutura: cabeçalho do aluno → título da seção → lista de trilhas.
class CatalogoAlunoPage extends StatelessWidget {
  const CatalogoAlunoPage({
    super.key,
    required this.aluno,
    required this.trilhas,
    required this.onAbrirTrilha,
  });

  final AlunoResumo aluno;
  final List<TrilhaResumo> trilhas;
  final ValueChanged<TrilhaResumo> onAbrirTrilha;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      header: AlunoHeader(aluno: aluno),
      body: PageSection(
        title: 'Trilhas de Aprendizado',
        child: trilhas.isEmpty
            ? const AppEmptyState(
                title: 'Nenhuma trilha disponível',
                message:
                    'Quando o professor liberar uma trilha, ela aparece aqui.',
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final trilha in trilhas) ...[
                    TrilhaCard(trilha: trilha, onAbrir: onAbrirTrilha),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ],
              ),
      ),
    );
  }
}
