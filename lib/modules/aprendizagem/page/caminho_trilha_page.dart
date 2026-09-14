import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/core/widgets/app_page.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/models/caminho_trilha.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/widgets/caminho_mapa.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/widgets/trilha_banner.dart';
import 'package:unipar_trilha_app/shared/models/aluno_resumo.dart';
import 'package:unipar_trilha_app/shared/widgets/aluno_header.dart';

/// Tela 2 — Caminho da trilha.
///
/// Estrutura: cabeçalho → faixa com o nome da trilha → mapa de lições.
class CaminhoTrilhaPage extends StatelessWidget {
  const CaminhoTrilhaPage({
    super.key,
    required this.aluno,
    required this.caminho,
    required this.onSelecionarLicao,
  });

  final AlunoResumo aluno;
  final CaminhoTrilha caminho;
  final ValueChanged<LicaoCaminho> onSelecionarLicao;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      header: AlunoHeader(aluno: aluno),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TrilhaBanner(titulo: caminho.trilha.titulo),
          const SizedBox(height: AppSpacing.lg),
          CaminhoMapa(licoes: caminho.licoes, onSelecionar: onSelecionarLicao),
        ],
      ),
    );
  }
}
