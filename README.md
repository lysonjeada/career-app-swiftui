# TechStep (career-app)

App iOS em SwiftUI para apoiar pessoas em transição/evolução de carreira em tecnologia: geração de perguntas de entrevista por IA, simulação de entrevista com áudio, feedback de currículo, plano de estudos personalizado, acompanhamento de candidaturas a vagas e dashboard de progresso.

## Funcionalidades

- **Autenticação** — login, cadastro, verificação de e-mail por código e recuperação de senha.
- **Home** — feed de artigos técnicos (via API pública do dev.to), próximas entrevistas e vagas em destaque.
- **Assistente de Entrevista**
  - Geração de perguntas de entrevista por IA a partir de cargo/senioridade/descrição da vaga e/ou currículo.
  - Feedback de currículo (upload de PDF, avaliação síncrona ou assíncrona com polling de status).
- **Simulação de Entrevista** — sessão de entrevista simulada com gravação de áudio, transcrição das respostas e avaliação por IA.
- **Plano de Estudos** — geração de plano de estudos personalizado por IA, com tópicos e prioridades.
- **Tracker de Candidaturas** — CRUD de candidaturas a vagas, próximas entrevistas e listagem de vagas abertas (por repositório/fonte no GitHub).
- **Dashboard de Progresso** — evolução mensal, empresas ativas e principais skills trabalhadas.
- **Perfil e Menu** — edição de perfil, foto (com crop), exclusão de conta e logout.

## Arquitetura

- **Padrão**: MVVM + Coordinator. Cada feature tem `View` + `ViewModel` (`ObservableObject`, estado via enum `viewState`), com chamadas de rede em `async/await` e injeção de serviço via protocolo no `init` (facilita mocks em teste).
- **Navegação**: `Coordinator` (`career-app/Coordinator/Coordinator.swift`) controla um `NavigationPath` único, login persistido em `UserDefaults`, e roteamento via enum `AppPages`. Deep linking (`careerapp://home`, `interview`, `tracker`, `menu`) tratado por `DeepLinkManager` em `career-app/AppDelegate.swift`.
- **Camada de rede**: `URLSession` puro por feature (sem Alamofire/terceiros), um `*Service` + `*ServiceProtocol` por módulo.
- **Persistência local**: Core Data (`CareerApp.xcdatamodeld`) para dados locais; login/estado de sessão em `UserDefaults`.
- **Dois "mundos" no repositório** (atenção ao navegar no código):
  1. O app real, compilado via Xcode (`career-app.xcodeproj`), com o código-fonte em `career-app/`.
  2. Um `Package.swift` na raiz, que declara um target `career-app-swiftui` apontando para `Sources/` (contém só um `main.swift` placeholder, excluído do build) e o `testTarget` dos testes unitários. Esse pacote SPM serve apenas para rodar `swift build`/`swift test` no CI/Fastlane — não reflete o app completo.
  - As pastas `CareerAppExample/` e `CareerAppExampleUITests/` existem no disco mas **não estão conectadas a nenhum target buildável** no `.xcodeproj` atual — são resíduos de um setup/POC inicial.

## Stack técnica

- **Linguagem/UI**: Swift 5.0, SwiftUI, Combine, AVFoundation (gravação de áudio na simulação de entrevista).
- **Deployment target real**: iOS 17.0+ (target `career-app`); o `Package.swift` declara iOS 14, mas isso vale apenas para o pacote SPM auxiliar, não para o app.
- **Persistência**: Core Data.
- **Dependências (Swift Package Manager)**:
  - `firebase-ios-sdk` — apenas **Firebase Analytics** está em uso ativo no código; não há Firestore, Auth, Storage ou Cloud Functions. A inicialização `FirebaseApp.configure()` está comentada em `AppDelegate.swift` (ponto de atenção, ver seção de notas).
  - `TOCropViewController` — crop de imagem de perfil/currículo (declarado apenas no `Package.resolved` do `.xcodeproj`).
  - `swift-snapshot-testing` e `swift-testing` — suporte a testes (snapshot tests e o novo framework `@Test` da Apple).

## Endpoints e integrações consumidas

### Backend próprio (Python)

Base URL definida em `career-app/CareerApp/Home/Network/APIConstants.swift` (`APIConstants.pythonURL`), atualmente um **IP local de desenvolvimento** (`http://192.168.0.58:8000`) hardcoded no código-fonte.

Toda a geração de conteúdo por IA (perguntas de entrevista, avaliação de simulação, transcrição de áudio, plano de estudos) é feita **no backend** — o app iOS não chama nenhum provedor de LLM diretamente.

| Recurso | Método | Endpoint | Descrição |
|---|---|---|---|
| Autenticação | POST | `/users/register` | Cadastro de novo usuário |
| Autenticação | POST | `/users/login/` | Login (retorna access token) |
| Verificação de e-mail | POST | `/users/verify-email` | Confirma e-mail via código |
| Verificação de e-mail | POST | `/users/resend-verification` | Reenvia código de verificação |
| Perfil | GET | `/users/{userId}/` | Busca dados do perfil |
| Perfil | DELETE | `/users/{userId}` | Exclui a conta do usuário |
| Tracker de vagas | GET | `/interviews/` | Lista candidaturas/entrevistas cadastradas |
| Tracker de vagas | GET | `/interviews/next/` | Lista próximas entrevistas |
| Tracker de vagas | POST | `/interviews/` | Cria uma candidatura/entrevista |
| Tracker de vagas | PUT | `/interviews/{interviewId}` | Atualiza uma candidatura/entrevista |
| Tracker de vagas | DELETE | `/interviews/{interviewId}` | Remove uma candidatura/entrevista |
| Tracker de vagas | GET | `/job-listings/?repository={repo}` | Lista vagas por repositório/fonte |
| Tracker de vagas | GET | `/repositories-available/` | Lista repositórios/fontes de vagas disponíveis |
| Feedback de currículo | POST | `/resume-feedback/` (multipart, campo `resume`) | Avaliação síncrona de currículo |
| Feedback de currículo | POST | `/submit-feedback/` (multipart, campo `resume`) | Envia currículo para avaliação assíncrona, retorna `task_id` |
| Feedback de currículo | GET | `/feedback-status/{taskID}` | Consulta status da avaliação assíncrona |
| Feedback de currículo | GET | `/feedback-result/{taskID}` | Busca o resultado final da avaliação |
| Geração de perguntas | POST | `/generate-interview-questions/` (multipart: `job_title`, `seniority`, `description`, `resume`) | Gera perguntas de entrevista por IA |
| Simulação de entrevista | POST | `/interview-simulation/questions` | Gera perguntas para a simulação |
| Simulação de entrevista | POST | `/interview-simulation/transcribe` (multipart, campo `audio` .m4a) | Transcreve a resposta em áudio |
| Simulação de entrevista | POST | `/interview-simulation/evaluate` | Avalia as respostas da simulação |
| Simulação de entrevista | POST | `/interview-simulation/saved-questions` | Salva perguntas geradas |
| Plano de estudos | POST | `/study-plan/generate` (multipart: `job_title`, `seniority`, `description`, `resume`) | Gera plano de estudos por IA |
| Dashboard | GET | `/dashboard/progress?months={n}` | Dados de evolução/progresso |

### API pública externa

| Serviço | Método | Endpoint | Descrição |
|---|---|---|---|
| dev.to | GET | `https://dev.to/api/articles?tag={tag}` | Lista de artigos técnicos para a Home |
| dev.to | GET | `https://dev.to/api/articles/{id}` | Detalhe de um artigo |

### Firebase

Apenas **Firebase Analytics** é usado no código ativo (`import FirebaseAnalytics` em `career_appApp.swift`). Configuração em `career-app/GoogleService-Info.plist`.

### Endpoints legados / não confirmados em uso

O código contém dois conjuntos de endpoints apontando para mocks do Apiary que parecem resíduo de versões anteriores — não foram encontradas referências ativas a eles nas telas atuais:

- `TechStepAPI` (`career-app/CareerApp/Home/Network/TechStepAPI.swift`, base `APIConstants.baseURL`) — `/questions`, `/questions/save`, `/questions/saved`, `/jobs/applied`, `/jobs/next-interviews`.
- `StylishStoreAPI` (`career-app/CareerApp/Home/Network/CareerAPI.swift`, base `CareerURL.lysAPI`) — endpoints de e-commerce (`/products`, `/cart`, `/wishlist`, `/categories`) que não fazem sentido no domínio do app — provável resíduo de outro projeto.

Confirme com a equipe antes de remover ou depender desses arquivos.

## Estrutura de pastas (resumo)

```
career-app-swiftui/
├── career-app/                  # código-fonte real do app (target Xcode "career-app")
│   └── CareerApp/<Feature>/     # Views, ViewModels, Services por funcionalidade
├── career-app.xcodeproj/        # projeto Xcode (targets: "career-app", "Career App Unit Tests")
├── Career App Unit Tests/       # testes unitários (Swift Testing)
├── CareerAppExample/            # POC/exemplo não conectado a nenhum target ativo
├── CareerAppExampleUITests/     # testes de UI do exemplo acima (idem)
├── Sources/                     # stub de pacote SPM (não usado pelo app real)
├── Package.swift / Package.resolved
├── fastlane/ , Fastfile, Gemfile
├── github/workflows/ci.yml      # ver nota sobre nome da pasta
└── README.md
```

## Como rodar o projeto

1. Instale as dependências Ruby: `bundle install` (fastlane, cocoapods via `Gemfile`).
2. Resolva as dependências Swift Package Manager: `swift package resolve`.
3. Abra `career-app.xcodeproj` no Xcode (iOS 17.0+, Swift 5.0) e selecione o scheme `career-app`.
4. Antes de rodar, ajuste `APIConstants.pythonURL` (`career-app/CareerApp/Home/Network/APIConstants.swift`) para apontar para a instância do backend Python disponível no seu ambiente.
5. Rode o app no simulador/dispositivo (Cmd+R).

## Testes

- Testes unitários em `Career App Unit Tests/Tests`, usando o framework **Swift Testing** (`@Suite`/`@Test`/`#expect`), com mocks (`HomeServiceMock`) e fixtures JSON.
- Rodar via Xcode: selecione o scheme "Career App Unit Tests" e Cmd+U.
- Rodar via linha de comando: `bundle exec fastlane spm_test_ios` (usa `scan` no simulador iPhone 12) ou `swift test` / `bundle exec fastlane test`.
- `CareerAppExampleUITests` existe no disco mas não está associado a nenhum target ativo no `.xcodeproj` — não é executado no fluxo atual.

## CI/CD

- **Fastlane** (`Fastfile` na raiz):
  - `test` — `swift test --configuration debug`
  - `build` — `swift build --configuration release`
  - `spm_test_ios` — roda os testes no scheme `career-app` via `scan`, simulador iPhone 12
  - `spm_test_coverage` — `swift test --enable-code-coverage`
- **GitHub Actions** (`github/workflows/ci.yml`): checkout → setup Ruby → `bundle install` → `swift package resolve` → `fastlane test` → `fastlane build`.
  - ⚠️ O workflow está em `github/workflows/`, e não em `.github/workflows/` — nesse caminho **não é reconhecido pelo GitHub Actions**. É necessário mover a pasta para `.github/workflows/` para o CI rodar automaticamente.

## Notas e pontos de atenção

- A URL do backend Python (`APIConstants.pythonURL`) está hardcoded para um IP local de desenvolvimento — vale externalizar por ambiente (`.xcconfig`/build settings) antes de builds de produção.
- `career-app/GoogleService-Info.plist` está versionado no repositório.
- A pasta de workflows do GitHub Actions precisa ser renomeada de `github/` para `.github/` para ser executada.
- `Gemfile` declara `ruby '2.0.0'`, desatualizado em relação ao Ruby 2.7 usado no workflow de CI.
- `FirebaseApp.configure()` está comentado em `AppDelegate.swift` — o Analytics pode não estar de fato inicializado em runtime.
