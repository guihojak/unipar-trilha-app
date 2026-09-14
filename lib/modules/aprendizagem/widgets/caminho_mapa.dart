import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_assets.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/core/widgets/app_icon.dart';
import 'package:unipar_trilha_app/core/widgets/app_mascot.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/models/caminho_trilha.dart';

/// Caminho em zigue-zague das lições (tela 2).
///
/// A primeira lição fica embaixo, como no wireframe. Nós, pontilhado e
/// balão são widgets; notebook e iguana são ilustrações decorativas.
class CaminhoMapa extends StatelessWidget {
  const CaminhoMapa({
    super.key,
    required this.licoes,
    required this.onSelecionar,
  });

  final List<LicaoCaminho> licoes;
  final ValueChanged<LicaoCaminho> onSelecionar;

  static const double _passo = 100;
  static const double _margemTopo = 72;
  static const double _margemBase = 56;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final largura = constraints.maxWidth;
        final altura =
            _margemTopo + _margemBase + math.max(0, licoes.length - 1) * _passo;

        Offset centro(int index) => Offset(
          largura * (0.37 + 0.13 * math.cos(index * math.pi / 3)),
          altura - _margemBase - index * _passo,
        );

        final pontos = [for (var i = 0; i < licoes.length; i++) centro(i)];
        final indiceAtual = licoes.indexWhere(
          (licao) => licao.status == StatusLicao.atual,
        );

        return SizedBox(
          height: altura,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _PontilhadoPainter(
                    pontos: pontos,
                    cor: colors.pathConnector,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                bottom: 0,
                child: ExcludeSemantics(
                  child: Image.asset(
                    AppIllustrations.codingLaptop,
                    width: math.min(120, largura * 0.24),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: altura * 0.22,
                child: AppMascot(
                  pose: MascotPose.front,
                  height: math.min(220, largura * 0.42),
                ),
              ),
              for (var i = 0; i < licoes.length; i++)
                Positioned(
                  left: pontos[i].dx - _NoLicao.largura / 2,
                  top: pontos[i].dy - _NoLicao.altura / 2,
                  child: _NoLicao(
                    licao: licoes[i],
                    ordem: i + 1,
                    onTap: licoes[i].interativa
                        ? () => onSelecionar(licoes[i])
                        : null,
                  ),
                ),
              if (indiceAtual >= 0)
                Positioned(
                  left: pontos[indiceAtual].dx + AppSpacing.xs,
                  top: pontos[indiceAtual].dy - _NoLicao.altura / 2 - 28,
                  child: _BalaoAtual(
                    texto: indiceAtual == 0 ? 'Comece aqui' : 'Continue aqui',
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _NoLicao extends StatelessWidget {
  const _NoLicao({required this.licao, required this.ordem, this.onTap});

  static const double largura = 88;
  static const double altura = 72;

  final LicaoCaminho licao;
  final int ordem;
  final VoidCallback? onTap;

  String get _statusTexto => switch (licao.status) {
    StatusLicao.bloqueada => 'bloqueada',
    StatusLicao.disponivel => 'disponível',
    StatusLicao.atual => 'atual',
    StatusLicao.concluida => 'concluída',
  };

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final atual = licao.status == StatusLicao.atual;
    final prefixo = licao.recompensa ? 'Recompensa' : 'Lição $ordem';

    final Widget base = licao.recompensa
        ? Image.asset(AppIllustrations.treasureChest, height: 64)
        : Container(
            width: 80,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: atual ? colors.pathNodeCurrent : colors.pathNode,
              borderRadius: const BorderRadius.all(Radius.elliptical(40, 24)),
              border: atual
                  ? Border.all(color: colors.pathNodeRing, width: 5)
                  : null,
            ),
            child: switch (licao.status) {
              StatusLicao.disponivel => AppIcon(
                AppIcons.play,
                size: 18,
                color: colors.textOnSurface,
              ),
              StatusLicao.concluida => Image.asset(
                AppIcons.statusSuccess,
                height: 24,
              ),
              _ => null,
            },
          );

    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      label: '$prefixo: ${licao.titulo}, $_statusTexto',
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: largura,
          height: altura,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              base,
              if (licao.status == StatusLicao.bloqueada && !licao.recompensa)
                Positioned(
                  top: 0,
                  child: AppIcon(
                    AppIcons.lock,
                    size: 30,
                    color: colors.iconActive,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalaoAtual extends StatelessWidget {
  const _BalaoAtual({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colors.pathNodeRing,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          texto,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: colors.onAction),
        ),
      ),
    );
  }
}

class _PontilhadoPainter extends CustomPainter {
  const _PontilhadoPainter({required this.pontos, required this.cor});

  final List<Offset> pontos;
  final Color cor;

  static const double _espaco = 14;
  static const double _folga = 36;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = cor.withValues(alpha: 0.55);
    for (var i = 0; i < pontos.length - 1; i++) {
      final inicio = pontos[i];
      final fim = pontos[i + 1];
      final distancia = (fim - inicio).distance;
      final direcao = (fim - inicio) / distancia;
      for (var d = _folga; d <= distancia - _folga; d += _espaco) {
        canvas.drawCircle(inicio + direcao * d, 3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_PontilhadoPainter oldDelegate) {
    return oldDelegate.cor != cor || oldDelegate.pontos != pontos;
  }
}
