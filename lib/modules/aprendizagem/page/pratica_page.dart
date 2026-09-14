import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/api_error.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/core/widgets/app_back_link.dart';
import 'package:unipar_trilha_app/core/widgets/app_button.dart';
import 'package:unipar_trilha_app/core/widgets/app_page.dart';
import 'package:unipar_trilha_app/core/widgets/app_progress.dart';
import 'package:unipar_trilha_app/core/widgets/feedback_card.dart';
import 'package:unipar_trilha_app/core/widgets/quiz_option.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/models/desafio_pratica.dart';

/// Telas 4, 5 e 6 — Prática de uma questão.
///
/// Uma única página com três estados:
/// - tela 4: alternativa selecionada e "Enviar resposta";
/// - tela 5: resposta incorreta com feedback e "Tentar novamente";
/// - tela 6: resposta correta com feedback e "Continuar".
class PraticaPage extends StatefulWidget {
  const PraticaPage({
    super.key,
    required this.desafio,
    required this.onResponder,
    required this.onVoltar,
    required this.onContinuar,
  });

  final DesafioPratica desafio;
  final ResponderDesafio onResponder;
  final VoidCallback onVoltar;
  final VoidCallback onContinuar;

  @override
  State<PraticaPage> createState() => _PraticaPageState();
}

class _PraticaPageState extends State<PraticaPage> {
  OpcaoPratica? _selecionada;
  CorrecaoPratica? _correcao;
  bool _enviando = false;

  Future<void> _enviar() async {
    final opcao = _selecionada;
    if (opcao == null || _enviando) return;
    setState(() => _enviando = true);
    try {
      final correcao = await widget.onResponder(widget.desafio, opcao);
      if (!mounted) return;
      setState(() => _correcao = correcao);
    } catch (error) {
      if (!mounted) return;
      // A seleção é mantida para o aluno reenviar manualmente.
      final mensagem = error is ApiError
          ? error.message
          : 'Não foi possível enviar a resposta. Tente novamente.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagem)));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _tentarNovamente() => setState(() {
    _selecionada = null;
    _correcao = null;
  });

  QuizOptionState _estado(OpcaoPratica opcao) {
    if (opcao != _selecionada) return QuizOptionState.idle;
    final correcao = _correcao;
    if (correcao == null) return QuizOptionState.selected;
    return correcao.correta
        ? QuizOptionState.correct
        : QuizOptionState.incorrect;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final desafio = widget.desafio;
    final correcao = _correcao;
    final bloqueada = _enviando || correcao != null;

    return AppPage(
      topPadding: AppSpacing.xs,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppBackLink(label: 'Voltar à Trilha', onPressed: widget.onVoltar),
          const SizedBox(height: AppSpacing.sm),
          QuizStepper(current: desafio.numero, total: desafio.total),
          const SizedBox(height: AppSpacing.lg),
          Text(desafio.enunciado, style: textTheme.titleLarge),
          Text(
            'Selecione uma alternativa',
            style: textTheme.bodyMedium?.copyWith(color: colors.textAccent),
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < desafio.opcoes.length; i++) ...[
            QuizOption(
              label: String.fromCharCode(97 + i),
              text: desafio.opcoes[i].texto,
              state: _estado(desafio.opcoes[i]),
              onTap: bloqueada
                  ? null
                  : () => setState(() => _selecionada = desafio.opcoes[i]),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.sm),
          if (correcao == null)
            Center(
              child: AppButton(
                label: 'Enviar resposta',
                isLoading: _enviando,
                onPressed: _selecionada == null ? null : _enviar,
              ),
            )
          else
            FeedbackCard(
              variant: correcao.correta
                  ? FeedbackVariant.success
                  : FeedbackVariant.danger,
              title: correcao.correta
                  ? 'Isso aí, excelente!'
                  : 'Não foi dessa vez...',
              message: correcao.explicacao,
              code: correcao.codigo,
              hint: correcao.dica,
              action: correcao.correta
                  ? AppButton(label: 'Continuar', onPressed: widget.onContinuar)
                  : AppButton(
                      label: 'Tentar novamente',
                      variant: AppButtonVariant.outline,
                      onPressed: _tentarNovamente,
                    ),
            ),
        ],
      ),
    );
  }
}
