import 'package:unipar_trilha_app/modules/aprendizagem/models/caminho_trilha.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/models/desafio_pratica.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/models/trilha_resumo.dart';
import 'package:unipar_trilha_app/modules/home/models/home_aluno.dart';
import 'package:unipar_trilha_app/modules/perfil/models/visao_geral_aluno.dart';
import 'package:unipar_trilha_app/shared/models/aluno_resumo.dart';

/// Tudo o que a navegação do aluno precisa para montar as telas 1–7.
///
/// Nesta etapa (FE-002) o conteúdo é entregue pronto. Nos tickets de cada
/// módulo, estes campos passam a vir dos services HTTP correspondentes.
class AlunoConteudo {
  const AlunoConteudo({
    required this.aluno,
    required this.trilhas,
    required this.caminhoDe,
    required this.desafioDe,
    required this.responder,
    required this.visaoGeral,
    this.metaDiaria,
    this.proximaLicao,
  });

  final AlunoResumo aluno;
  final List<TrilhaResumo> trilhas;
  final MetaDiaria? metaDiaria;
  final ProximaLicao? proximaLicao;
  final CaminhoTrilha Function(TrilhaResumo trilha) caminhoDe;
  final DesafioPratica Function(TrilhaResumo trilha, LicaoCaminho licao)
  desafioDe;
  final ResponderDesafio responder;
  final VisaoGeralAluno visaoGeral;
}
