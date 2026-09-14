import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_assets.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/core/widgets/app_icon.dart';

/// Faixa com o nome da trilha no topo do caminho (tela 2).
class TrilhaBanner extends StatelessWidget {
  const TrilhaBanner({super.key, required this.titulo});

  final String titulo;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Semantics(
      header: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceSelected,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: colors.borderDefault, width: 1.5),
        ),
        child: Row(
          children: [
            AppIcon(
              AppIcons.learningBook,
              size: 30,
              color: colors.actionSecondary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: colors.textOnSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
