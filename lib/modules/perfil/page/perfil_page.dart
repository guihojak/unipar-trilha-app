import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/core/widgets/app_page.dart';
import 'package:unipar_trilha_app/modules/perfil/models/visao_geral_aluno.dart';
import 'package:unipar_trilha_app/modules/perfil/widgets/cursos_card.dart';
import 'package:unipar_trilha_app/modules/perfil/widgets/metricas_card.dart';
import 'package:unipar_trilha_app/modules/perfil/widgets/perfil_resumo_card.dart';

/// Tela 7 — Perfil e visão geral do aluno.
///
/// Estrutura: card do perfil → "VISÃO GERAL" → cursos/trilhas → métricas.
class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key, required this.visaoGeral});

  final VisaoGeralAluno visaoGeral;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppPage(
      topPadding: AppSpacing.xs,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PerfilResumoCard(visaoGeral: visaoGeral),
          const SizedBox(height: AppSpacing.xl),
          Semantics(
            header: true,
            child: Text(
              'VISÃO GERAL',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          CursosCard(cursos: visaoGeral.cursos),
          const SizedBox(height: AppSpacing.lg),
          MetricasCard(visaoGeral: visaoGeral),
        ],
      ),
    );
  }
}
