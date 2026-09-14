import 'package:flutter/material.dart';
import 'package:unipar_trilha_app/core/theme/app_colors.dart';
import 'package:unipar_trilha_app/core/theme/app_spacing.dart';
import 'package:unipar_trilha_app/modules/perfil/models/visao_geral_aluno.dart';

/// Card "Cursos/Trilhas" com a quantidade por curso (tela 7).
///
/// Os logotipos dos cursos não fazem parte do kit; cada curso usa um selo com
/// as iniciais até que os ícones oficiais sejam definidos.
class CursosCard extends StatelessWidget {
  const CursosCard({super.key, required this.cursos});

  final List<CursoResumo> cursos;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceDefault,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.borderCard, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cursos/Trilhas', style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          if (cursos.isEmpty)
            Text('Nenhum curso iniciado.', style: textTheme.bodyMedium)
          else
            Wrap(
              spacing: AppSpacing.xl,
              runSpacing: AppSpacing.md,
              children: [
                for (final curso in cursos)
                  Semantics(
                    label:
                        '${curso.nome}: ${curso.quantidade} '
                        '${curso.quantidade == 1 ? 'trilha' : 'trilhas'}',
                    excludeSemantics: true,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Tooltip(
                          message: curso.nome,
                          child: Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colors.surfaceBrand,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Text(
                              _iniciais(curso.nome),
                              style: textTheme.titleSmall,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          '${curso.quantidade}',
                          style: textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  static String _iniciais(String nome) {
    final partes = nome.trim().split(RegExp(r'\s+'));
    if (partes.length == 1) {
      return nome.substring(0, nome.length < 2 ? nome.length : 2).toUpperCase();
    }
    return partes.take(2).map((p) => p[0].toUpperCase()).join();
  }
}
