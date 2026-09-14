# Unipar Trilha App

Fundação Flutter do sistema **Unipar Trilha**, organizada pelo mesmo padrão modular do GulaPay e adaptada ao domínio e aos contratos reais deste projeto.

Esta entrega contém somente o esqueleto, a comunicação HTTP e a autenticação sem interface. Ainda não existem telas de login, home, autoria, prática ou acompanhamento, nem identidade visual.

## Estado da implementação

| Item | Entrega | Estado |
|---|---|---|
| 1.1 | Projeto Android/Web, estrutura modular e configuração | concluído |
| 1.2 técnico | Cliente HTTP, health, DTO e service de login | concluído sem tela |
| 1.3 técnico | Persistência, restauração, invalidação e logout | concluído sem navegação |
| Telas e design system | Aguardam elementos visuais e cores | não iniciado |
| Módulos de negócio | Trilha, distribuição, catálogo, prática e painel | não iniciado |

Isso não conclui as etapas funcionais 1.1–1.3 do plano: o aceite visual e a integração pela interface serão realizados nos tickets seguintes.

## Tecnologias

- Flutter 3.41.2 utilizado na criação.
- Dart compatível com `^3.9.2`.
- `dio` para HTTP.
- `shared_preferences` para dados locais da sessão.
- `cupertino_icons` e `font_awesome_flutter` reservados para as telas futuras.
- `flutter_test` e `flutter_lints` para qualidade.

## Estrutura

```text
lib/
├── main.dart
├── core/
│   ├── api_client.dart
│   ├── api_error.dart
│   ├── auth_session.dart
│   ├── constants_api.dart
│   ├── health_service.dart
│   ├── theme/
│   └── widgets/
├── modules/
│   ├── login/
│   │   ├── dto/
│   │   ├── page/
│   │   └── service/
│   ├── home/
│   ├── trilha/
│   ├── distribuicao/
│   ├── catalogo_aluno/
│   ├── aprendizagem/
│   └── acompanhamento/
└── shared/
```

Pastas vazias possuem `.gitkeep`. Os módulos de negócio foram apenas reservados; nenhum contrato foi antecipado neles.

## Comunicação com a API

A URL é definida em compilação:

```dart
const String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);
```

Não acrescentar `/api`. O cliente possui timeout de 15 segundos, envia e recebe JSON, injeta `Authorization: Bearer <token>` somente em rotas protegidas e nunca repete POST automaticamente.

`ApiError` interpreta o Problem Details RFC 7807 do backend, incluindo `detail` e `errors`. Também diferencia timeout e falha de conexão.

Rotas implementadas na fundação:

| Método | Rota | Responsabilidade |
|---|---|---|
| `GET` | `/actuator/health` | confirma `status=UP` |
| `POST` | `/auth/login` | autentica e persiste a sessão |
| `GET` | `/usuarios/me` | valida uma sessão restaurada |

O token não é enviado no health ou no login. A senha é enviada apenas ao endpoint de login e nunca é persistida.

## Sessão

`AuthSession` é a fonte única do estado de autenticação:

- armazena token, ID, login, nome, perfil e situação ativa;
- reconhece `ADMINISTRADOR`, `PROFESSOR` e `ALUNO`;
- valida dados salvos consultando `/usuarios/me`;
- limpa a sessão em `401` de rota protegida;
- mantém os dados salvos, mas não libera estado autenticado, quando a validação falha por rede;
- impede resposta atrasada de restaurar dados depois do logout;
- notifica futuros consumidores por `ChangeNotifier`.

O frontend não decodifica o JWT para decidir se uma sessão é válida.

## Como executar

Na raiz deste projeto:

```powershell
flutter pub get
flutter analyze
flutter test
```

Web com backend na mesma máquina:

```powershell
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

Emulador Android padrão:

```powershell
flutter run -d <ID_DO_EMULADOR> --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Aparelho físico: use o IPv4 da máquina na mesma rede, por exemplo `http://192.168.0.10:8080`, e permita a porta no firewall. `localhost` no aparelho aponta para o próprio celular.

O Android possui permissão de internet em todos os builds. Tráfego HTTP sem TLS é permitido somente no manifesto `debug`; a configuração de produção deverá utilizar HTTPS. No Web, o backend precisa permitir a origem usada pelo navegador via CORS.

## Teste opcional com backend real

Com a API em execução, informe credenciais somente no comando:

```powershell
flutter test test/integration/backend_integration_test.dart `
  --dart-define=RUN_BACKEND_INTEGRATION=true `
  --dart-define=API_BASE_URL=http://localhost:8080 `
  --dart-define=BACKEND_TEST_LOGIN=<LOGIN> `
  --dart-define=BACKEND_TEST_PASSWORD=<SENHA>
```

O teste executa health → login → `/usuarios/me` → logout. Sem essas opções ele fica ignorado, portanto a suíte comum não depende de PostgreSQL nem de uma API ligada.

## Decisões e próximos passos

- O `MaterialApp` inicial é propositalmente vazio; não representa uma tela pronta.
- Não foram adicionados mocks em `lib/`, dependências extras, assets ou regras do GulaPay.
- O plano original está em `PLANO_IMPLEMENTACAO_FRONTEND.md` neste repositório.
- O próximo incremento deve aplicar o design system e construir login/navegação sobre esta base.
- Para reencontrar rascunhos e versões em qualquer dispositivo, a decisão FE-005 adotada exige endpoints autenticados adicionais no backend. Essa alteração permanece separada desta fundação.
- Não houve alteração no backend, commit ou push durante esta entrega.

## Validação realizada em 14/09/2026

```text
flutter analyze: No issues found
flutter test: 22 testes passaram e 1 integração opcional foi ignorada
flutter build web --debug: concluído
flutter build apk --debug: concluído
```

Artefatos locais gerados para conferência:

- `build/web/`;
- `build/app/outputs/flutter-apk/app-debug.apk`.

As pastas de build são temporárias e já estão ignoradas pelo Git. Chrome e Edge estavam disponíveis; não havia emulador ou aparelho Android conectado, portanto o APK foi compilado, mas não executado em dispositivo nesta validação.
