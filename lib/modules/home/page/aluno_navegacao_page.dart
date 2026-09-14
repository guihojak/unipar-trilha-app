import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unipar_trilha_app/core/theme/app_assets.dart';
import 'package:unipar_trilha_app/core/widgets/app_bottom_navigation.dart';
import 'package:unipar_trilha_app/core/widgets/app_empty_state.dart';
import 'package:unipar_trilha_app/core/widgets/app_page.dart';
import 'package:unipar_trilha_app/core/widgets/app_shell.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/models/caminho_trilha.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/page/caminho_trilha_page.dart';
import 'package:unipar_trilha_app/modules/aprendizagem/page/pratica_page.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/models/trilha_resumo.dart';
import 'package:unipar_trilha_app/modules/catalogo_aluno/page/catalogo_aluno_page.dart';
import 'package:unipar_trilha_app/modules/home/models/aluno_conteudo.dart';
import 'package:unipar_trilha_app/modules/home/models/home_aluno.dart';
import 'package:unipar_trilha_app/modules/home/page/aluno_home_page.dart';
import 'package:unipar_trilha_app/modules/perfil/page/perfil_page.dart';
import 'package:unipar_trilha_app/shared/widgets/aluno_header.dart';

enum AbaAluno { inicio, desempenho, trilhas, perfil }

/// Navegação do aluno: `AppShell` + navegação inferior com quatro abas.
///
/// | Aba | Ícone | Telas |
/// |---|---|---|
/// | Início | casa | 1 |
/// | Desempenho | barras | sem wireframe (estado vazio) |
/// | Trilhas | livro | 3 → 2 → 4/5/6 (pilha própria) |
/// | Perfil | menu | 7 |
///
/// A aba Trilhas tem um `Navigator` interno para manter a navegação inferior
/// visível no caminho e na prática, como nos wireframes.
class AlunoNavegacaoPage extends StatefulWidget {
  const AlunoNavegacaoPage({super.key, required this.conteudo});

  final AlunoConteudo conteudo;

  static const destinos = [
    AppNavigationDestination(
      icon: AppIcons.home,
      label: 'Início',
      iconSize: 28,
    ),
    AppNavigationDestination(
      icon: AppIcons.ranking,
      label: 'Desempenho',
      iconSize: 33,
    ),
    AppNavigationDestination(
      icon: AppIcons.learningBook,
      label: 'Trilhas',
      iconSize: 34,
    ),
    AppNavigationDestination(
      icon: AppIcons.menu,
      label: 'Perfil',
      iconSize: 28,
    ),
  ];

  @override
  State<AlunoNavegacaoPage> createState() => _AlunoNavegacaoPageState();
}

class _AlunoNavegacaoPageState extends State<AlunoNavegacaoPage> {
  final _trilhasNavigator = GlobalKey<NavigatorState>();
  AbaAluno _aba = AbaAluno.inicio;

  AlunoConteudo get _conteudo => widget.conteudo;
  NavigatorState get _trilhas => _trilhasNavigator.currentState!;

  void _selecionarAba(int index) {
    final aba = AbaAluno.values[index];
    if (aba == _aba && aba == AbaAluno.trilhas) {
      _trilhas.popUntil((route) => route.isFirst);
      return;
    }
    setState(() => _aba = aba);
  }

  void _abrirTrilha(TrilhaResumo trilha, {LicaoCaminho? licao}) {
    setState(() => _aba = AbaAluno.trilhas);
    _trilhas
      ..popUntil((route) => route.isFirst)
      ..push(_rotaCaminho(trilha));
    if (licao != null) _trilhas.push(_rotaPratica(trilha, licao));
  }

  void _comecarProximaLicao(ProximaLicao proxima) {
    final licao = _conteudo.caminhoDe(proxima.trilha).licaoAtual;
    _abrirTrilha(proxima.trilha, licao: licao);
  }

  void _voltar() {
    if (_aba == AbaAluno.trilhas && _trilhas.canPop()) {
      _trilhas.pop();
    } else if (_aba != AbaAluno.inicio) {
      setState(() => _aba = AbaAluno.inicio);
    } else {
      SystemNavigator.pop();
    }
  }

  Route<void> _rotaCaminho(TrilhaResumo trilha) {
    return MaterialPageRoute(
      builder: (context) => CaminhoTrilhaPage(
        aluno: _conteudo.aluno,
        caminho: _conteudo.caminhoDe(trilha),
        onSelecionarLicao: (licao) =>
            Navigator.of(context).push(_rotaPratica(trilha, licao)),
      ),
    );
  }

  Route<void> _rotaPratica(TrilhaResumo trilha, LicaoCaminho licao) {
    return MaterialPageRoute(
      builder: (context) => PraticaPage(
        desafio: _conteudo.desafioDe(trilha, licao),
        onResponder: _conteudo.responder,
        onVoltar: () => Navigator.of(context).pop(),
        onContinuar: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _voltar();
      },
      child: AppShell(
        bottomNavigation: AppBottomNavigation(
          destinations: AlunoNavegacaoPage.destinos,
          currentIndex: _aba.index,
          onSelected: _selecionarAba,
        ),
        body: IndexedStack(
          index: _aba.index,
          children: [
            AlunoHomePage(
              aluno: _conteudo.aluno,
              trilhas: _conteudo.trilhas,
              metaDiaria: _conteudo.metaDiaria,
              proximaLicao: _conteudo.proximaLicao,
              onAbrirTrilha: _abrirTrilha,
              onVerTodas: () => _selecionarAba(AbaAluno.trilhas.index),
              onComecarProximaLicao: _comecarProximaLicao,
            ),
            AppPage(
              header: AlunoHeader(aluno: _conteudo.aluno),
              body: const AppEmptyState(
                title: 'Desempenho',
                message: 'Em breve você poderá acompanhar seu desempenho aqui.',
              ),
            ),
            Navigator(
              key: _trilhasNavigator,
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (_) => CatalogoAlunoPage(
                  aluno: _conteudo.aluno,
                  trilhas: _conteudo.trilhas,
                  onAbrirTrilha: _abrirTrilha,
                ),
              ),
            ),
            PerfilPage(visaoGeral: _conteudo.visaoGeral),
          ],
        ),
      ),
    );
  }
}
