# HelpOut - Documento de Referencia do Projeto

> Documento atualizado do app Flutter `help_out` (`0.1.0+1`).
> Objetivo: dar uma visao clara do produto, arquitetura, dados, servicos e fluxos principais para humanos ou sistemas de IA que precisem continuar o projeto.
> Baseado no codigo atual em `lib/`.

---

## 1. Visao Geral

**HelpOut** e um app mobile Flutter de produtividade, estudos e acompanhamento de habitos com camada social.
O usuario cria atividades, registra tempo de foco, acompanha leituras por paginas, marca metas diarias, organiza uma agenda semanal e compara desempenho em grupos.

Ideia central: transformar **tempo, paginas e constancia** em metricas visiveis, com um fluxo leve de gamificacao.

- **Nome de exibicao:** `HelpOut` (`AppConstants.appTitle`).
- **Pacote Flutter:** `help_out`.
- **Estado de login:** atualmente `userName` vazio significa usuario deslogado; `userName` preenchido significa usuario logado.
- **Idiomas:** ingles (`en`), portugues (`pt`) e espanhol (`es`).
- **Plataforma principal:** Android, especialmente por causa das notificacoes persistentes do timer.

### Estado atual de backend e mocks

O app ainda nao depende de um backend real para os fluxos principais.

- Login Google/Apple e mockado.
- Login por telefone/OTP e mockado; qualquer codigo numerico de 6 digitos e aceito.
- Sync de perfil com backend e mockado.
- Grupos, amigos e rankings usam dados fixos em memoria.
- Subjects, tarefas, agenda, configuracoes, ultima atividade e progresso diario sao persistidos localmente.

---

## 2. Stack Tecnica

Principais dependencias em `pubspec.yaml`:

| Area | Dependencia | Uso |
|---|---|---|
| Estado, rotas e DI | `get` | GetX para controllers, bindings, navegacao e injecao |
| Erros funcionais | `dartz` | `Either<AppError, T>` nos use cases e repositorios |
| Valor/igualdade | `equatable` | entidades imutaveis comparaveis |
| HTTP | `dio` | infraestrutura pronta para backend real |
| Persistencia | `shared_preferences` | dados locais nao sensiveis |
| Persistencia sensivel | `flutter_secure_storage` | tokens/reservado para auth real |
| Notificacoes | `flutter_local_notifications` | timer persistente no Android |
| Ambiente | `flutter_dotenv` | `lib/env/debug.env` e `lib/env/prod.env` |
| UI | `flutter_svg`, `gap`, `intl` | icones, espacamentos, formatacao |
| Fonte | `Nunito` | familia tipografica completa |

---

## 3. Arquitetura

O projeto segue uma Clean Architecture simplificada:

```text
lib/
  main.dart                 -> bootstrap do Flutter e bindings
  app/                      -> app shell, rotas, navegacao, DI raiz, AppController
  core/
    domain/                 -> entities, enums, use_cases, errors
    data/                   -> data_sources e repositories
    services/               -> storage, HTTP, notificacoes, progresso, logs
    utils/                  -> extensoes
  presentation/             -> telas por feature: page, controller, bindings, widgets
  theme/                    -> cores, tipografia, presets, icones, wallpapers
  l10n/                     -> ARB e classes geradas de localizacao
  shared/                   -> widgets e funcoes reutilizaveis
```

Fluxo de dependencia:

```text
presentation -> domain/use_cases -> data/repositories -> data_sources -> services
```

Padrao de tela:

- `*_page.dart`: widget de UI, normalmente observando estado com `Obx`.
- `*_controller.dart`: estado reativo e regras de interacao.
- `*_bindings.dart`: injeta o controller da rota.

### Bootstrap e DI

`main.dart` chama `WidgetsFlutterBinding.ensureInitialized()`, executa `AppBindings().dependencies()` e entao roda `AppWidget`.

`AppBindings`:

- carrega o `.env` de debug ou prod;
- registra `AppNavigator`;
- inicializa servicos;
- registra data sources, repositories e use cases;
- registra `AppController` como permanente;
- registra `ScheduleController` como singleton permanente, para Perfil e Agenda observarem a mesma lista de horarios.

---

## 4. Estado Global

`AppController` e o controller global do app. Ele guarda preferencias e dados de identidade:

- `isDarkMode`
- `accentColor`
- `userName`
- `nickName`
- `email`
- `phoneNumber`
- `birthDate`
- `avatarIconIndex`
- `notificationsEnabled`
- `languageCode`

Responsabilidades principais:

- carregar `AppConfigEntity` do storage;
- decidir a rota apos splash;
- persistir tema, idioma, avatar, notificacoes e perfil;
- aplicar idioma em runtime com `Get.updateLocale`;
- executar sync de perfil mockado;
- fazer logout limpando identidade local.

Rota inicial real:

```text
Splash -> AppController.initialize()
  -> userName vazio: /login
  -> userName preenchido: /mainNavigation
```

---

## 5. Modelo de Dados

Todas as entidades principais ficam em `lib/core/domain/entities/`, sao imutaveis, usam `Equatable` e possuem serializacao `toMap`/`fromMap`.

### AppConfigEntity

Persistida em `LocalStorageKeys.appConfig`.

Campos:

- `isDarkMode`
- `userName`
- `nickName`
- `email`
- `phoneNumber`
- `birthDate`
- `accentColorValue`
- `avatarIconIndex`
- `notificationsEnabled`
- `languageCode`

`AppConfigEntity.fallback()` representa um usuario novo.

### SubjectEntity

Representa uma atividade/materia acompanhavel.

Campos principais:

- `id`
- `name`
- `category` (`studying`, `exercises`, `reading`, `hobbies`)
- `colorValue`
- `totalSeconds`
- `goalSeconds`
- `currentPages`
- `goalPages`
- `notes`
- `iconName`
- `restMinutes`
- `musicSuggestion`
- `wallpaperIndex`

Categorias de tempo usam `totalSeconds` e `goalSeconds`.
Leitura usa `currentPages` e `goalPages`.

### DailyTaskEntity

Representa uma meta/habito diario.

- `id`
- `name`
- `colorValue`
- `targetDays`
- `completedDates`

Getters:

- `isCheckedToday`
- `completedDays`
- `isCompleted`

Marcar/desmarcar alterna a presenca da data atual em `completedDates`.

### ScheduleEntryEntity

Representa um bloco da agenda semanal.

- `id`
- `title`
- `weekday` (`1` segunda a `7` domingo)
- `startMinutes`
- `endMinutes`
- `colorValue`

### DailyProgressEntity

Agregado diario usado pela Home para mostrar metricas honestas do dia, sem precisar de historico completo de sessoes.

- `focusSeconds`
- `sessions`
- `pages`

Fica em um mapa persistido por data (`yyyy-MM-dd`) via `DailyProgressService`.

### LastActivityEntity

Ultima atividade registrada.

- `label`
- `timestamp`
- `subjectId`

Quando `subjectId` existe, `isResumable` e verdadeiro e a Home pode reabrir o timer daquele subject.
Quando a atividade veio de uma tarefa diaria, `subjectId` fica `null`.

### GroupEntity e GroupMemberEntity

`GroupEntity`:

- `id`
- `name`
- `theme`
- `members`
- `ownerId`
- `createdAt`
- `inviteCode`
- `privacy`

`GroupMemberEntity`:

- `id`
- `name`
- `avatarColorValue`
- `todaySeconds`
- `weekSeconds`
- `monthSeconds`
- `avatar`
- `role`
- `joinedAt`

`secondsFor(period)` retorna a metrica usada no leaderboard.
O usuario atual e identificado pelo id `"me"`.

### ProfileStatsEntity

Derivada dos subjects.

- soma tempo de estudo, exercicios e hobbies;
- soma metas de estudo e exercicios;
- soma paginas atuais e meta de paginas de leitura;
- identifica a principal materia de estudo por tempo;
- lista top 3 leituras por paginas.

Leitura e tratada como fluxo baseado em paginas, nao como tempo.

---

## 6. Persistencia Local

Servico: `AppLocalStorageService`.

Ele roteia leitura/escrita por chave:

- chaves normais usam `SharedPreferences`;
- chaves sensiveis usam `FlutterSecureStorage`.

| Chave | Sensivel | Conteudo |
|---|---|---|
| `appConfig` | nao | configuracao e identidade local |
| `subjects` | nao | lista de subjects |
| `dailyTasks` | nao | lista de metas diarias |
| `lastActivity` | nao | ultima atividade |
| `dailyProgress` | nao | progresso diario por data |
| `scheduleEntries` | nao | agenda semanal |
| `accessToken` | sim | reservado para auth real |
| `refreshToken` | sim | reservado para auth real |

`clearStorage()` limpa storage normal e seguro.

---

## 7. Navegacao

Rotas em `lib/app/app_routes.dart`.

| Rota | Tela | Observacoes |
|---|---|---|
| `/` | Splash | dispara inicializacao global |
| `/login` | Login | social mock + telefone |
| `/phoneLogin` | Login por telefone | coleta numero |
| `/otp` | OTP | recebe telefone |
| `/credentials` | Credenciais | recebe telefone, coleta nome/nascimento |
| `/mainNavigation` | Shell principal | bottom navigation com navigator aninhado |
| `/home` | Home | aba do shell |
| `/profile` | Perfil | aba do shell |
| `/groups` | Grupos | aba do shell |
| `/config` | Configuracoes | aba do shell |
| `/category` | Categoria | recebe `TimeCategoryType` |
| `/createSubject` | Criar subject | recebe categoria e retorna `SubjectEntity` |
| `/dailyGoals` | Metas diarias | lista habitos |
| `/createTask` | Criar tarefa | retorna `DailyTaskEntity` |
| `/timer` | Timer | recebe `SubjectEntity` |
| `/notes` | Notas | recebe subject e retorna texto |
| `/schedule` | Agenda | usa `ScheduleController` singleton |
| `/editProfile` | Editar perfil | altera dados globais |
| `/faq` | FAQ | conteudo estatico |
| `/createGroup` | Criar grupo | retorna `GroupEntity` |

`MainNavigationPage` usa um `Navigator` interno com id `1`.
Trocar abas chama `offAllNamed` no navigator aninhado, entao Home/Perfil/Grupos/Config nao ficam empilhadas.

Rotas fora do shell sao abertas sobre o app inteiro.
`AppNavigator` centraliza `toNamed`, `offAllNamed`, `back`, dialogos e snackbars.

---

## 8. Fluxo de Autenticacao

### Splash

1. `SplashPage` inicia.
2. `AppController.initialize()` carrega config local e aguarda a duracao minima do splash.
3. Se `userName` esta vazio, vai para `/login`.
4. Se `userName` esta preenchido, vai para `/mainNavigation`.

### Login social mockado

Na tela de login:

- Google grava `"Google User"`;
- Apple grava `"Apple User"`;
- ambos entram direto em `/mainNavigation`.

Nao ha OAuth real ainda.

### Login por telefone

Fluxo:

```text
/phoneLogin -> /otp -> /credentials -> /mainNavigation
```

Detalhes:

- telefone precisa ter pelo menos 8 digitos;
- `RequestPhoneCodeUseCase` simula envio;
- OTP exige 6 digitos e auto-submete ao completar;
- `VerifyPhoneCodeUseCase` aceita qualquer codigo numerico de 6 digitos;
- se ja houver `userName`, o OTP vai direto para Main;
- se nao houver, coleta nome, apelido opcional e nascimento.

### Logout

Config -> dialogo de confirmacao -> `AppController.logOut()` limpa identidade e navega para `/login`.

---

## 9. Home

Controller: `HomeController`.

A Home carrega:

- todos os subjects;
- metas diarias;
- agenda semanal;
- ultima atividade;
- progresso de hoje.

Ela exibe/resume:

- saudacao pelo nome do usuario;
- resumo do dia vindo de `DailyProgressService`;
- categorias (`studying`, `exercises`, `reading`, `hobbies`);
- card de metas diarias;
- proxima entrada de agenda ainda futura no dia;
- ultima atividade;
- acao de continuar o ultimo timer quando a ultima atividade tem `subjectId`;
- sugestao de iniciar o subject com maior `totalSeconds` quando nao ha retomada.

Depois de navegar para telas que podem alterar dados, a Home chama `load()` novamente ao retornar.

---

## 10. Categorias, Subjects, Leitura e Notas

### Categoria

Controller: `CategoryController`.

Recebe uma `TimeCategoryType`, carrega todos os subjects e filtra pela categoria.

Comportamento ao tocar:

- `reading`: abre `LogPagesDialog`, atualiza `currentPages` e soma paginas no `DailyProgressService`;
- outras categorias: abre `/timer` com o subject.

Acoes:

- adicionar subject em `/createSubject`;
- editar notas em `/notes`;
- deletar subject com remocao otimista.

### Criar subject

Controller: `CreateSubjectController`.

Campos:

- nome obrigatorio;
- meta obrigatoria;
- cor;
- icone sugerido por categoria;
- minutos de descanso (`5`, `10`, `15`, `20`);
- wallpaper do timer;
- sugestao de musica.

Meta:

- leitura usa paginas;
- demais categorias usam horas e convertem para segundos.

Ao salvar, cria via `AddSubjectUseCase`, mostra snackbar de sucesso e retorna o subject para a tela anterior.

### Notas

`NotesController` recebe o subject, edita `notes`, persiste com `UpdateSubjectNotesUseCase` e retorna a string atualizada.

---

## 11. Timer

Controller: `TimerController`.

O timer e baseado em ciclos de foco de 25 minutos:

- `focusIntervalSeconds = 25 * 60`;
- descanso vem de `subject.restMinutes`, com fallback de 5 minutos;
- `sessionSeconds` guarda o tempo da sessao atual;
- `breakCountdownSeconds` conta ate o proximo descanso;
- `restCountdownSeconds` conta o descanso;
- `isRunning`, `isResting` e `isSessionFinished` controlam o estado visual.

Fluxo de tick:

1. Se pausado, nao incrementa.
2. Se esta descansando, decrementa o descanso.
3. Quando o descanso chega a zero, sai do descanso, pausa o timer e reinicia o contador de foco.
4. Se esta em foco, incrementa `sessionSeconds` e decrementa `breakCountdownSeconds`.
5. Quando o foco chega a zero, entra em descanso, persiste o tempo acumulado e atualiza notificacao.

Persistencia:

- pausar chama `_persistAccumulatedTime()`;
- salvar manualmente chama `_persistAccumulatedTime()`;
- finalizar chama `_persistAccumulatedTime()` e registra a sessao;
- sair da tela chama persistencia, registra a sessao se houve tempo e cancela notificacao.

Efeitos colaterais:

- `UpdateSubjectTimeUseCase` grava o novo total do subject;
- `DailyProgressService.addFocusSeconds` soma segundos do dia;
- `DailyProgressService.registerSession` conta a sessao finalizada/registrada;
- `LastActivityService.record(subject.name, subjectId: subject.id)` permite retomar esse timer pela Home.

Saida com sessao ativa:

- `confirmExitIfNeeded()` exibe dialogo se existe tempo ativo nao finalizado;
- se confirmado, finaliza a sessao antes de sair.

Notificacao:

- `TimerNotificationService.showRunning` usa cronometro ao vivo no Android;
- `showStatic` mostra estados pausado/descansando;
- `cancel` remove ao fechar/finalizar.

---

## 12. Metas Diarias

### Lista

Controller: `DailyGoalsController`.

Carrega tarefas com `GetDailyTasksUseCase`.

Acoes:

- adicionar em `/createTask`;
- marcar/desmarcar com `ToggleDailyTaskCheckUseCase`;
- deletar com remocao otimista.

Quando uma tarefa fica marcada hoje, a ultima atividade e registrada com `LastActivityService.record(task.name)`.
Como nao ha `subjectId`, essa atividade nao e retomavel.

### Criar tarefa

Controller: `CreateTaskController`.

Campos:

- nome obrigatorio;
- cor;
- meta de dias por preset ou valor customizado.

Ao salvar, cria com `completedDates` vazio e retorna a tarefa.

---

## 13. Agenda

Controller: `ScheduleController`.

Ele e registrado no binding raiz como singleton permanente.
Isso permite que Perfil, Agenda e outras telas vejam a mesma lista.

Estado:

- `entries`;
- `selectedWeekday`, iniciado no dia atual;
- `sortedEntries`, entradas do dia selecionado;
- `todayEntries`, entradas do dia atual.

Acoes:

- selecionar dia da semana;
- adicionar entrada via `AddScheduleEntryDialog`;
- deletar entrada com remocao otimista.

Detalhe tecnico importante:

- o resultado do dialogo e lido como `dynamic` e depois convertido para `AddScheduleEntryResult?`;
- passar o record concreto como generico em GetX faz o resultado se perder em algumas situacoes.

---

## 14. Perfil

Controller: `ProfileController`.

Mostra:

- nome, apelido e avatar globais;
- estatisticas agregadas de subjects;
- agenda de hoje vinda do `ScheduleController`;
- atalhos para editar perfil, categorias, agenda e metas.

`ProfileStatsEntity.fromSubjects` calcula:

- tempo total de estudo;
- meta total de estudo;
- tempo total de exercicios;
- meta total de exercicios;
- tempo total de hobbies;
- paginas lidas;
- meta de paginas;
- top subject de estudo por tempo;
- top 3 leituras por paginas.

---

## 15. Grupos e Rankings

### Lista de grupos

Controller: `GroupsController`.

Dados vem de `GroupsDataSource`, atualmente mockado em memoria.

Estado:

- lista de grupos;
- grupo selecionado;
- periodo selecionado (`today`, `thisWeek`, `thisMonth`);
- loading.

Ranking:

- `rankedMembers` ordena por `secondsFor(selectedPeriod)`;
- `currentUserMember` localiza o membro com id `"me"`;
- `currentUserRank` calcula a posicao atual;
- `differenceToPrevious(member)` calcula a distancia para o membro imediatamente acima.

Criar grupo:

- abre `/createGroup`;
- ao voltar com `GroupEntity`, adiciona na lista, seleciona o novo grupo e mostra snackbar de sucesso.

### Criar grupo

Controller: `CreateGroupController`.

Exige:

- nome;
- tema (`GroupThemeType`);
- pelo menos 1 amigo convidado.

Ao criar:

- inclui o usuario atual como `"me"` e role `"owner"`;
- adiciona amigos convidados como membros;
- gera `id` por timestamp;
- gera `inviteCode`;
- define `privacy = "inviteOnly"`;
- persiste apenas no store mockado em memoria.

Temas:

- `studying`: horas;
- `dailyGoals`: dias;
- `exercises`: horas;
- `reading`: paginas;
- `hobbies`: horas.

---

## 16. Configuracoes, Perfil Editavel e FAQ

### Configuracoes

Controller: `ConfigController`.

Expoe o estado do `AppController` e permite:

- alternar modo escuro;
- alternar notificacoes;
- abrir editar perfil;
- trocar idioma;
- abrir FAQ;
- fazer logout.

### Editar perfil

Controller: `EditProfileController`.

Edita:

- nome;
- apelido;
- email;
- telefone;
- cor de destaque;
- icone de avatar.

Cor e avatar sao aplicados imediatamente no estado global.
Salvar chama `AppController.updateProfile(...)`, persiste localmente e executa sync mockado.

### FAQ

Tela simples com perguntas e respostas estaticas em lista expansivel.

---

## 17. Tema e Internacionalizacao

Tema:

- `AppThemes.build(...)` monta o tema a partir da cor de destaque e brilho;
- `AppColorTokens` e um `ThemeExtension` derivado da cor semente;
- trocar modo escuro ou accent reconstrói `GetMaterialApp` via `Obx`;
- presets ficam em `theme/accent_presets.dart`, `avatar_presets.dart`, `subject_colors.dart`, `subject_icons.dart` e `timer_wallpapers.dart`.

Tipografia:

- fonte `Nunito`;
- estilos centralizados em `AppTextStyles`.

i18n:

- arquivos ARB em `lib/l10n/app_en.arb`, `app_pt.arb`, `app_es.arb`;
- `flutter gen-l10n` gera `AppLocalizations`;
- acesso comum via `context.l10n`;
- troca em runtime via `Get.updateLocale`.

---

## 18. Servicos

| Servico | Funcao |
|---|---|
| `AppLocalStorageService` | abstracao sobre SharedPreferences e SecureStorage |
| `LastActivityService` | carrega/grava ultima atividade e expoe `Rx<LastActivityEntity?>` |
| `DailyProgressService` | agrega foco, sessoes e paginas por dia |
| `TimerNotificationService` | notificacao persistente do timer no Android |
| `HttpClientService` | wrapper Dio para backend futuro |
| `AppLoggerService` | logging |

`TimerNotificationService` e resiliente: falhas de notificacao nao devem derrubar o timer.

---

## 19. Use Cases

Todos ficam em `lib/core/domain/use_cases/` e retornam `Either<AppError, T>`.

| Use case | Responsabilidade |
|---|---|
| `GetAppConfigUseCase` | ler configuracao |
| `SaveAppConfigUseCase` | salvar configuracao |
| `SyncProfileToBackendUseCase` | sync mockado de perfil |
| `RequestPhoneCodeUseCase` | solicitar codigo mockado |
| `VerifyPhoneCodeUseCase` | validar OTP mockado |
| `GetSubjectsUseCase` | listar subjects |
| `AddSubjectUseCase` | criar subject |
| `DeleteSubjectUseCase` | deletar subject |
| `UpdateSubjectTimeUseCase` | atualizar tempo acumulado |
| `UpdateSubjectPagesUseCase` | atualizar paginas de leitura |
| `UpdateSubjectNotesUseCase` | atualizar notas |
| `GetDailyTasksUseCase` | listar tarefas |
| `AddDailyTaskUseCase` | criar tarefa |
| `DeleteDailyTaskUseCase` | deletar tarefa |
| `ToggleDailyTaskCheckUseCase` | marcar/desmarcar tarefa hoje |
| `GetScheduleEntriesUseCase` | listar agenda |
| `AddScheduleEntryUseCase` | criar entrada de agenda |
| `DeleteScheduleEntryUseCase` | deletar entrada de agenda |
| `GetGroupsUseCase` | listar grupos mockados |
| `CreateGroupUseCase` | criar grupo mockado |
| `GetInvitableFriendsUseCase` | listar amigos mockados |
| `GetProfileStatsUseCase` | gerar estatisticas agregadas |

---

## 20. Fluxo Geral Resumido

```text
Splash
  -> sem userName
      -> Login
          -> Google/Apple mock -> MainNavigation
          -> Telefone -> OTP -> Credentials -> MainNavigation
  -> com userName
      -> MainNavigation

MainNavigation
  -> Home
      -> Categoria
          -> Reading: registrar paginas
          -> Outras: Timer
          -> Criar Subject
          -> Notas
      -> Metas Diarias
      -> Agenda
      -> Continuar ultimo timer retomavel
  -> Perfil
      -> Estatisticas
      -> Agenda de hoje
      -> Editar Perfil / Categorias / Metas / Agenda
  -> Grupos
      -> Ranking por periodo
      -> Criar Grupo
  -> Config
      -> Tema / idioma / notificacoes
      -> Editar Perfil
      -> FAQ
      -> Logout
```

---

## 21. Onde Encontrar Cada Coisa

| Assunto | Caminho |
|---|---|
| Bootstrap | `lib/main.dart` |
| DI raiz | `lib/app/bindings/app_bindings.dart` |
| Rotas | `lib/app/app_routes.dart` |
| Navegacao | `lib/app/app_navigator.dart` |
| Estado global | `lib/app/app_controller.dart` |
| Entidades | `lib/core/domain/entities/` |
| Enums | `lib/core/domain/enums/` |
| Use cases | `lib/core/domain/use_cases/` |
| Repositorios | `lib/core/data/repositories/` |
| Data sources | `lib/core/data/data_sources/` |
| Storage | `lib/core/services/local_storage/` |
| Progresso diario | `lib/core/services/daily_progress/daily_progress_service.dart` |
| Ultima atividade | `lib/core/services/last_activity/last_activity_service.dart` |
| Notificacao do timer | `lib/core/services/notifications/timer_notification_service.dart` |
| Timer | `lib/presentation/timer/timer_controller.dart` |
| Home | `lib/presentation/home/home_controller.dart` |
| Categorias | `lib/presentation/category/category_controller.dart` |
| Agenda | `lib/presentation/schedule/schedule_controller.dart` |
| Perfil | `lib/presentation/profile/profile_controller.dart` |
| Grupos | `lib/presentation/groups/groups_controller.dart` |
| Tema | `lib/theme/` |
| Traducoes | `lib/l10n/` |

---

## 22. Regras e Cuidados do Projeto

- Responsabilidade das abas deve seguir `docs/SCREEN_OWNERSHIP.md`.
- Espacamentos devem preferir multiplos de 4.
- Evitar `Obx()` dentro de callbacks `itemBuilder`.
- Evitar alternar `color` e `gradient` no mesmo `AnimatedContainer`.
- Em dialogs/rotas GetX com retorno complexo, buscar como `dynamic` e converter depois.
- Nao assumir backend real para login, grupos ou sync de perfil.
- Leitura e medida por paginas, nao por tempo.
- `ScheduleController` e singleton permanente; cuidado ao criar outro controller da agenda.

---

*Fim do documento. Atualizado para refletir os fluxos e servicos atuais do projeto HelpOut.*
