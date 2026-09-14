import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/core/theme/app_typography.dart';

int _percent(double value) => (value.clamp(0.0, 1.0) * 100).round();

/// Barra de progresso horizontal. [value] vai de 0 a 1.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.height = 10,
    this.color,
    this.trackColor,
    this.semanticLabel = 'Progresso',
  });

  final double value;
  final double height;
  final Color? color;
  final Color? trackColor;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Semantics(
      label: semanticLabel,
      value: '${_percent(value)}%',
      child: ExcludeSemantics(
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: trackColor ?? colors.progressTrack,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color ?? colors.progressFill,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Anel de progresso com percentual e legenda ao centro.
class AppProgressRing extends StatelessWidget {
  const AppProgressRing({
    super.key,
    required this.value,
    this.size = 112,
    this.color,
    this.trackColor,
    this.caption = 'concluído',
    this.semanticLabel = 'Progresso',
    this.strokeWidth,
  });

  final double value;
  final double size;
  final Color? color;
  final Color? trackColor;
  final String caption;
  final String semanticLabel;

  /// Espessura do anel. Padrão: 13% de [size], como nos cards da tela 1.
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final strokeWidth = this.strokeWidth ?? size * 0.13;
    return Semantics(
      label: semanticLabel,
      value: '${_percent(value)}%',
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: _RingPainter(
              value: value.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              color: color ?? colors.progressTrail,
              trackColor: trackColor ?? colors.progressTrack,
            ),
            child: Padding(
              padding: EdgeInsets.all(strokeWidth * 1.3),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_percent(value)}%',
                      style: textTheme.titleLarge?.copyWith(
                        fontFamily: AppTypography.displayFamily,
                        fontSize: size * 0.183,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        color: colors.textOnSurface,
                      ),
                    ),
                    if (caption.isNotEmpty)
                      Text(
                        caption,
                        style: textTheme.bodySmall?.copyWith(
                          fontFamily: AppTypography.displayFamily,
                          fontSize: size * 0.097,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                          color: colors.textOnSurface,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.strokeWidth,
    required this.color,
    required this.trackColor,
  });

  final double value;
  final double strokeWidth;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);
    if (value <= 0) return;
    final progress = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * value, false, progress);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}

/// Indicador segmentado de questões ("Questão 1 de 5").
///
/// [current] começa em 1. Questões anteriores ficam com a borda de destaque,
/// a atual com a cor ativa e as seguintes com a cor neutra.
class QuizStepper extends StatelessWidget {
  const QuizStepper({
    super.key,
    required this.current,
    required this.total,
    this.showLabel = true,
  }) : assert(total > 0),
       assert(current >= 1 && current <= total);

  final int current;
  final int total;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final label = 'Questão $current de $total';
    final segments = Row(
      children: [
        for (var index = 0; index < total; index++) ...[
          if (index > 0) const SizedBox(width: AppSpacing.xs),
          Expanded(
            flex: index == current - 1 ? 3 : 2,
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: index == current - 1
                    ? colors.iconActive
                    : index < current - 1
                    ? colors.borderDefault
                    : colors.iconDefault,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
        ],
      ],
    );
    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: !showLabel
            ? segments
            : LayoutBuilder(
                builder: (context, constraints) {
                  final text = Text(
                    label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colors.textSecondary,
                    ),
                  );
                  // Em telas estreitas o rótulo fica acima dos segmentos.
                  if (constraints.maxWidth < 480) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        text,
                        const SizedBox(height: AppSpacing.xs),
                        segments,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      text,
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: segments),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
