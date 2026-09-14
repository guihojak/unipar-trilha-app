import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_assets.dart';
import 'package:unipar_trilha_app/core/theme/app_breakpoints.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/core/widgets/app_avatar.dart';
import 'package:unipar_trilha_app/modules/perfil/models/visao_geral_aluno.dart';

/// Card azul com nome, foto, couves e RA (topo da tela 7).
class PerfilResumoCard extends StatelessWidget {
  const PerfilResumoCard({super.key, required this.visaoGeral});

  final VisaoGeralAluno visaoGeral;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final aluno = visaoGeral.aluno;
    final compacto = AppBreakpoints.isCompact(MediaQuery.sizeOf(context).width);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceProfile,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            aluno.nome,
            style: (compacto ? textTheme.titleLarge : textTheme.headlineMedium)
                ?.copyWith(color: colors.textOnSurface),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: AppAvatar(
              name: aluno.nome,
              image: aluno.avatar,
              size: compacto ? 104 : 144,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Semantics(
                label: '${visaoGeral.pontos} couves',
                excludeSemantics: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(AppIllustrations.cabbage, height: 40),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${visaoGeral.pontos}',
                      style: textTheme.titleLarge?.copyWith(
                        color: colors.textOnSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'RA: ${aluno.ra}',
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colors.textOnSurface,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
