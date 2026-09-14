import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_assets.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/core/theme/app_typography.dart';
import 'package:unipar_trilha_app/core/widgets/app_mascot.dart';
import 'package:unipar_trilha_app/modules/perfil/models/visao_geral_aluno.dart';

/// Card com ranking, turma, XP e professores ao lado da iguana (tela 7).
class MetricasCard extends StatelessWidget {
  const MetricasCard({super.key, required this.visaoGeral});

  final VisaoGeralAluno visaoGeral;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    final itens = <Widget>[
      if (visaoGeral.ranking != null)
        _Metrica(
          rotulo: 'Ranking',
          semantica: visaoGeral.ranking!,
          valor: Image.asset(AppIcons.diamond, height: 44),
        ),
      _Metrica(
        rotulo: 'Turma',
        valor: Text(
          visaoGeral.turma,
          style: textTheme.bodyLarge?.copyWith(
            fontFamily: AppTypography.readingFamily,
          ),
        ),
      ),
      _Metrica(
        rotulo: 'XP',
        valor: Text(
          '${visaoGeral.xp}',
          style: textTheme.bodyLarge?.copyWith(
            fontFamily: AppTypography.readingFamily,
          ),
        ),
      ),
      _Metrica(
        rotulo: visaoGeral.professores.length == 1
            ? 'Professor'
            : 'Professores',
        valor: Text(
          visaoGeral.professores.join('\n'),
          style: textTheme.bodyLarge?.copyWith(
            fontFamily: AppTypography.readingFamily,
          ),
        ),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceInfo,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.borderCard, width: 1.5),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final alturaMascote = constraints.maxWidth < 420 ? 120.0 : 200.0;
          final larguraMascote = alturaMascote * MascotPose.phone.aspectRatio;
          final disponivel =
              constraints.maxWidth - larguraMascote - AppSpacing.md;
          final colunas = disponivel >= 2 * 140 ? 2 : 1;
          final larguraItem =
              (disponivel - (colunas - 1) * AppSpacing.md) / colunas;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.lg,
                  children: [
                    for (final item in itens)
                      SizedBox(width: larguraItem, child: item),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              AppMascot(pose: MascotPose.phone, height: alturaMascote),
            ],
          );
        },
      ),
    );
  }
}

class _Metrica extends StatelessWidget {
  const _Metrica({required this.rotulo, required this.valor, this.semantica});

  final String rotulo;
  final Widget valor;

  /// Texto lido no lugar de um [valor] gráfico.
  final String? semantica;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final conteudo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          rotulo,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontFamily: AppTypography.displayFamily,
            color: colors.actionInfo,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        valor,
      ],
    );
    if (semantica == null) return conteudo;
    return Semantics(
      label: '$rotulo: $semantica',
      excludeSemantics: true,
      child: conteudo,
    );
  }
}
