import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_assets.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/core/widgets/app_icon.dart';

enum QuizOptionState { idle, selected, correct, incorrect }

/// Alternativa de múltipla escolha.
///
/// O estado nunca depende só de cor: seleção usa o marcador preenchido e a
/// correção usa ícone e rótulo ("Correta"/"Incorreta"). Com [onTap] nulo a
/// opção fica desabilitada (ex.: durante o envio ou após a correção).
class QuizOption extends StatelessWidget {
  const QuizOption({
    super.key,
    required this.label,
    required this.text,
    this.state = QuizOptionState.idle,
    this.onTap,
  });

  /// Letra da alternativa, sem parêntese (ex.: "a").
  final String label;
  final String text;
  final QuizOptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    final (surface, border) = switch (state) {
      QuizOptionState.idle => (colors.surfaceDefault, colors.borderDefault),
      QuizOptionState.selected => (colors.surfaceSelected, colors.borderFocus),
      QuizOptionState.correct => (
        colors.feedbackSuccessSurface,
        colors.feedbackSuccessBorder,
      ),
      QuizOptionState.incorrect => (
        colors.feedbackDangerSurface,
        colors.feedbackDangerBorder,
      ),
    };

    final semanticState = switch (state) {
      QuizOptionState.correct => ', resposta correta',
      QuizOptionState.incorrect => ', resposta incorreta',
      _ => '',
    };

    final Widget trailing = switch (state) {
      QuizOptionState.idle => _RadioMark(
        selected: false,
        color: colors.borderFocus,
      ),
      QuizOptionState.selected => _RadioMark(
        selected: true,
        color: colors.borderFocus,
      ),
      QuizOptionState.correct => _StatusLabel(
        icon: Image.asset(AppIcons.statusSuccess, width: 26, height: 26),
        text: 'Correta',
        color: colors.feedbackSuccessText,
      ),
      QuizOptionState.incorrect => _StatusLabel(
        icon: AppIcon(
          AppIcons.statusError,
          size: 26,
          color: colors.feedbackDangerText,
        ),
        text: 'Incorreta',
        color: colors.feedbackDangerText,
      ),
    };

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      side: BorderSide(color: border, width: 2),
    );

    return Semantics(
      button: true,
      inMutuallyExclusiveGroup: true,
      checked: state == QuizOptionState.selected,
      enabled: onTap != null,
      label: '$label) $text$semanticState',
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: surface,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: shape,
          splashColor: colors.iconActive.withValues(alpha: 0.16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Text('$label)', style: textTheme.titleMedium),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      text,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  trailing,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioMark extends StatelessWidget {
  const _RadioMark({required this.selected, required this.color});

  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2.5),
      ),
      child: selected
          ? Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            )
          : null,
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({
    required this.icon,
    required this.text,
    required this.color,
  });

  final Widget icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: AppSpacing.xs),
        Text(
          text,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
