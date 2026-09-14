import 'package:unipar_trilha_app/core/widgets/trail_card.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/models/caminho_trilha.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/models/desafio_pratica.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/models/trilha_resumo.dart';
import 'package:unipar_trilha_app/modules/home/models/aluno_conteudo.dart';
import 'package:unipar_trilha_app/modules/home/models/home_aluno.dart';
import 'package:unipar_trilha_app/modules/perfil/models/visao_geral_aluno.dart';
import 'package:unipar_trilha_app/shared/models/aluno_resumo.dart';

/// Conteúdo de exemplo com os textos dos wireframes 1–7.
///
/// Usado somente por `main_preview.dart` e pelos testes de tela. Não é um
/// service e não pode ser referenciado por `main.dart`.
abstract final class AlunoPreviewConteudo {
  static const aluno = AlunoResumo(
    nome: 'Maria Joaquina',
    ra: '60020223',
    sequenciaDias: 3,
  );

  static const trilhas = [
    TrilhaResumo(
      id: 1,
      titulo: 'Algoritmos e Lógica',
      progresso: 0.4,
      status: TrailStatus.inProgress,
      icone: IconeTrilha.codigo,
    ),
    TrilhaResumo(
      id: 2,
      titulo: 'Orientação a Objetos',
      progresso: 0,
      status: TrailStatus.notStarted,
      tom: TrailCardTone.purple,
      icone: IconeTrilha.objetos,
      temNotificacao: true,
    ),
    TrilhaResumo(
      id: 3,
      titulo: 'XAMPP e Tomcat',
      progresso: 0,
      status: TrailStatus.notStarted,
      tom: TrailCardTone.cyan,
      icone: IconeTrilha.servidor,
    ),
  ];

  static const frontend = TrilhaResumo(
    id: 4,
    titulo: 'Frontend - Básico',
    progresso: 0,
    status: TrailStatus.notStarted,
    tom: TrailCardTone.cyan,
  );

  static const desafio = DesafioPratica(
    id: 1,
    enunciado: 'Qual tag HTML cria um parágrafo?',
    numero: 1,
    total: 5,
    opcoes: [
      OpcaoPratica(id: 1, texto: '<h1>'),
      OpcaoPratica(id: 2, texto: '<th>'),
      OpcaoPratica(id: 3, texto: '<td>'),
      OpcaoPratica(id: 4, texto: '<p>'),
    ],
  );

  static CaminhoTrilha caminho(TrilhaResumo trilha) {
    const titulos = [
      'Primeiros passos',
      'Variáveis',
      'Condicionais',
      'Laços',
      'Funções',
      'Revisão',
    ];
    final concluidas = (trilha.progresso * titulos.length).floor();
    return CaminhoTrilha(
      trilha: trilha,
      licoes: [
        for (var i = 0; i < titulos.length; i++)
          LicaoCaminho(
            id: trilha.id * 10 + i,
            titulo: titulos[i],
            status: i < concluidas
                ? StatusLicao.concluida
                : i == concluidas
                ? StatusLicao.atual
                : StatusLicao.bloqueada,
          ),
        LicaoCaminho(
          id: trilha.id * 10 + titulos.length,
          titulo: 'Baú da trilha',
          status: StatusLicao.bloqueada,
          recompensa: true,
        ),
      ],
    );
  }

  static Future<CorrecaoPratica> responder(
    DesafioPratica desafio,
    OpcaoPratica opcao, {
    Duration atraso = const Duration(milliseconds: 900),
  }) async {
    await Future<void>.delayed(atraso);
    return switch (opcao.id) {
      4 => const CorrecaoPratica(
        correta: true,
        explicacao: 'A tag <p> em HTML cria um parágrafo.',
        codigo: '<p>Meu parágrafo!</p>',
      ),
      2 => const CorrecaoPratica(
        correta: false,
        explicacao: 'A tag <th> cria uma célula de cabeçalho de tabela.',
        codigo: '<th>Nome</th>',
        dica: 'pense na inicial de parágrafo.',
      ),
      3 => const CorrecaoPratica(
        correta: false,
        explicacao: 'A tag <td> cria uma célula de dados de tabela.',
        codigo: '<td>Maria</td>',
        dica: 'pense na inicial de parágrafo.',
      ),
      _ => const CorrecaoPratica(
        correta: false,
        explicacao: 'A tag <h1> cria um título, não um parágrafo.',
        codigo: '<h1>Meu título</h1>',
        dica: 'pense na inicial de parágrafo.',
      ),
    };
  }

  static const visaoGeral = VisaoGeralAluno(
    aluno: aluno,
    pontos: 115,
    xp: 16860,
    turma: '2ª série',
    professores: ['Jaime William Dias'],
    ranking: 'Diamante',
    cursos: [
      CursoResumo(nome: 'Spring', quantidade: 2),
      CursoResumo(nome: 'XAMPP', quantidade: 1),
      CursoResumo(nome: 'JavaScript', quantidade: 4),
      CursoResumo(nome: 'Hibernate', quantidade: 3),
    ],
  );

  static AlunoConteudo conteudo({ResponderDesafio? responder}) {
    return AlunoConteudo(
      aluno: aluno,
      trilhas: trilhas,
      metaDiaria: const MetaDiaria(xpRestante: 20, progresso: 0.8),
      proximaLicao: const ProximaLicao(
        trilha: frontend,
        titulo: 'Preparando o ambiente',
        mensagemMascote: 'Antes da ação,\na preparação.',
        recompensa: 1,
      ),
      caminhoDe: caminho,
      desafioDe: (_, _) => desafio,
      responder: responder ?? AlunoPreviewConteudo.responder,
      visaoGeral: visaoGeral,
    );
  }
}
