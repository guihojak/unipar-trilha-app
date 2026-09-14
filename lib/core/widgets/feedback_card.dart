import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_assets.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/core/theme/app_typography.dart';
import 'package:unipar_trilha_app/core/widgets/app_icon.dart';
import 'package:unipar_trilha_app/core/widgets/app_mascot.dart';

enum FeedbackVariant { success, danger }

/// Feedback exibido após a correção de uma resposta.
///
/// Agrupa mascote, ícone de estado, título, explicação, trecho de código e
/// dica. É anunciado como região dinâmica para leitores de tela.
class FeedbackCard extends StatelessWidget {
  const FeedbackCard({
    super.key,
    required this.variant,
    required this.title,
    required this.message,
    this.code,
    this.hint,
    this.action,
    this.showMascot = true,
  });

  final FeedbackVariant variant;
  final String title;
  final String message;

  /// Trecho de código exibido em fonte monoespaçada.
  final String? code;

  /// Texto exibido após o prefixo "Dica:".
  final String? hint;

  /// Ação opcional, como "Tentar novamente" ou "Continuar".
  final Widget? action;
  final bool showMascot;

  static const double _wideBreakpoint = 480;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final success = variant == FeedbackVariant.success;
    final accent = success
        ? colors.feedbackSuccessText
        : colors.feedbackDangerText;
    final border = success
        ? colors.feedbackSuccessBorder
        : colors.feedbackDangerBorder;
    final pose = success ? MascotPose.speaking : MascotPose.neutral;

    Widget statusIcon(double size) => success
        ? Image.asset(
            AppIcons.statusSuccess,
            width: size,
            height: size,
            excludeFromSemantics: true,
          )
        : AppIcon(AppIcons.statusError, size: size, color: accent);

    final details = <Widget>[
      const SizedBox(height: AppSpacing.sm),
      Text(
        message,
        style: textTheme.bodyLarge?.copyWith(
          fontFamily: AppTypography.readingFamily,
        ),
      ),
      if (code != null) ...[
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceDefault,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: colors.borderSubtle),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(code!, style: AppTypography.code(colors.codeText)),
          ),
        ),
      ],
      if (hint != null) ...[
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Dica: $hint',
          style: textTheme.bodyMedium?.copyWith(
            fontFamily: AppTypography.readingFamily,
            color: colors.textSecondary,
          ),
        ),
      ],
      if (action != null) ...[
        const SizedBox(height: AppSpacing.md),
        Align(alignment: Alignment.centerLeft, child: action),
      ],
    ];

    Widget titleRow(double iconSize) => Row(
      children: [
        statusIcon(iconSize),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            title,
            style: textTheme.titleLarge?.copyWith(color: accent),
          ),
        ),
      ],
    );

    return Semantics(
      container: true,
      liveRegion: true,
      label: success ? 'Resposta correta' : 'Resposta incorreta',
      child: Container(
        decoration: BoxDecoration(
          color: colors.backgroundApp,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: border, width: 2),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= _wideBreakpoint;
            if (!wide) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (showMascot) ...[
                          AppMascot(pose: pose, height: 56),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Expanded(child: titleRow(32)),
                      ],
                    ),
                    ...details,
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showMascot) ...[
                    AppMascot(pose: pose, width: constraints.maxWidth * 0.2),
                    const SizedBox(width: AppSpacing.lg),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [titleRow(44), ...details],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
