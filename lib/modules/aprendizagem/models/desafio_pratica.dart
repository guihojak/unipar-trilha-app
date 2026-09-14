/// Alternativa exibida ao aluno. Não possui o campo `correta`: a correção só
/// chega depois do envio (regra do plano de implementação).
class OpcaoPratica {
  const OpcaoPratica({required this.id, required this.texto});

  final int id;
  final String texto;
}

/// Questão de múltipla escolha das telas 4–6.
class DesafioPratica {
  const DesafioPratica({
    required this.id,
    required this.enunciado,
    required this.numero,
    required this.total,
    required this.opcoes,
  });

  final int id;
  final String enunciado;

  /// Posição da questão, começando em 1.
  final int numero;
  final int total;
  final List<OpcaoPratica> opcoes;
}

/// Resultado da correção de uma resposta (telas 5 e 6).
class CorrecaoPratica {
  const CorrecaoPratica({
    required this.correta,
    required this.explicacao,
    this.codigo,
    this.dica,
  });

  final bool correta;
  final String explicacao;
  final String? codigo;
  final String? dica;
}

/// Envia a opção escolhida e devolve a correção.
typedef ResponderDesafio =
    Future<CorrecaoPratica> Function(
      DesafioPratica desafio,
      OpcaoPratica opcao,
    );
