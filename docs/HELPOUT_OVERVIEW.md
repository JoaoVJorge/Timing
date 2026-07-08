# HelpOut — Documento de Referência Completo do Aplicativo

> Documento descritivo do app **HelpOut** (pacote Flutter `help_out`, versão `0.1.0+1`).
> Objetivo: fornecer a qualquer sistema de IA (ou humano) uma compreensão completa e sem ambiguidades
> do propósito, arquitetura, modelo de dados e de **todos os fluxos** do aplicativo.
> Última síntese baseada no código-fonte em `lib/`.

---

## 1. Visão Geral (o que o app é)

**HelpOut** é um aplicativo mobile Flutter de **produtividade e gestão de tempo/estudos com componente social**.
O usuário cronometra e acumula tempo dedicado a diferentes atividades (estudar, exercícios, hobbies),
registra progresso de leitura por páginas, mantém metas/hábitos diários, organiza uma grade de horários
semanal e compete com amigos em grupos com rankings (leaderboards).

Conceito central: **transformar tempo e constância em métricas visíveis e comparáveis**, misturando um
cronômetro de foco (estilo Pomodoro) com gamificação social.

- **Nome de exibição:** `HelpOut` (`AppConstants.appTitle`).
- **Público:** estudantes e pessoas que querem acompanhar hábitos e tempo de foco.
- **Idiomas suportados:** Inglês (`en`), Português (`pt`), Espanhol (`es`) — ver seção 11.
- **Plataforma-alvo principal:** Android (notificações persistentes de timer só funcionam em Android; ver seção 10).

### Estado de maturidade / dados simulados
Partes do backend são **mockadas** (não há servidor real ainda):
- **Login social** (Google/Apple): apenas define um nome fake e entra. Nenhuma autenticação real.
- **Login por telefone/OTP:** o "envio de SMS" é simulado (delay); a verificação aceita **qualquer código de 6 dígitos**.
- **Sincronização de perfil com backend:** simulada (delay de ~600ms, sempre sucesso).
- **Grupos e amigos:** dados fixos em memória (mock). Grupos criados persistem apenas na sessão (lista em memória).
- Todo o resto (subjects, tarefas diárias, grade de horários, config/perfil) é **persistido localmente** no dispositivo.

---

## 2. Stack Técnica e Arquitetura

### 2.1 Dependências principais (`pubspec.yaml`)
- **State management + navegação + DI:** `get` (GetX) `^4.7.2`.
- **Programação funcional / erros:** `dartz` `^0.10.1` (uso de `Either<AppError, T>` em toda a camada de domínio/dados).
- **Igualdade de valor:** `equatable` `^2.0.8` (todas as entidades estendem `Equatable`).
- **HTTP:** `dio` `^5.9.2` (infra HTTP existe, mas o app hoje roda em mocks locais).
- **Persistência local:** `shared_preferences` `^2.5.3` (dados normais) + `flutter_secure_storage` `^10.3.1` (dados sensíveis).
- **Notificações locais:** `flutter_local_notifications` `^22.0.1` (API de parâmetros nomeados da v22).
- **Config de ambiente:** `flutter_dotenv` `^6.0.1` (arquivos `lib/env/debug.env` e `lib/env/prod.env`).
- **UI utilitária:** `flutter_svg` (ícones SVG), `gap` (espaçamentos), `intl` (formatação/i18n).
- **Fonte:** `Nunito` (todos os pesos, 200–900, incluindo itálicos).

### 2.2 Arquitetura em camadas (Clean Architecture simplificada)
```
lib/
├── main.dart                → bootstrap: inicializa bindings e roda AppWidget
├── app/                     → shell do app (rotas, controller global, navegação, DI raiz)
├── core/
│   ├── domain/              → entities, enums, use_cases, errors (regras de negócio puras)
│   ├── data/                → data_sources (I/O bruto) + repositories (contrato/orquestração)
│   ├── services/            → http, local_storage, notifications, last_activity, log
│   └── utils/               → extensions
├── presentation/           → uma pasta por tela: <feature>_page + _controller + _bindings [+ widgets/]
├── theme/                  → tokens de cor, tipografia, presets (cores, ícones, wallpapers, idiomas)
├── l10n/                   → arquivos ARB + AppLocalizations gerados (en/pt/es)
└── shared/                 → widgets/extensions/functions reutilizáveis
```

**Fluxo de dependência (regra):** `presentation → domain (use_cases) → data (repositories → data_sources) → services`.
A camada de domínio não conhece detalhes de UI nem de armazenamento; a comunicação de erro é feita sempre por `Either<AppError, T>`.

### 2.3 Padrão de cada tela (feature)
Cada rota segue o trio GetX:
- **`*_page.dart`** — Widget (`StatelessWidget`) que observa o controller via `Obx`.
- **`*_controller.dart`** — `GetxController` com estado reativo (`.obs`) e handlers de interação.
- **`*_bindings.dart`** — registra o controller e suas dependências no container GetX (lazy).

### 2.4 Injeção de Dependência (DI)
Feita no boot via `AppBindings().dependencies()` (chamado em `main.dart` antes de `runApp`). Estrutura em `lib/app/bindings/`:
- `services_bindings.dart` — instancia serviços (storage, http, notificações, last activity, logger).
- `data_sources_bindings.dart` — data sources.
- `repositories_bindings.dart` — repositories.
- `use_cases_bindings.dart` — use cases.
- `app_bindings.dart` — agrega tudo + registra o `AppController` global.
Bindings por tela injetam apenas o controller daquela rota (lazy) quando a rota é aberta.

### 2.5 Controller global — `AppController`
Vive durante toda a sessão (registrado no boot). Guarda o **estado global do usuário e preferências**, todos reativos:
`isDarkMode`, `accentColor`, `userName`, `nickName`, `email`, `phoneNumber`, `birthDate`, `avatarIconIndex`,
`notificationsEnabled`, `languageCode`.
Responsabilidades:
- `initialize()` — carrega `AppConfig` do storage e aguarda a duração do splash; depois decide a rota inicial.
- `_navigateAfterSplash()` — se `userName` está vazio → `/login`; senão → `/mainNavigation`. **`userName` não vazio é o proxy de "usuário logado".**
- Setters (`setDarkMode`, `setAccentColor`, `setUserName`, `setAvatarIconIndex`, `setNotificationsEnabled`, `setLanguageCode`) — atualizam o estado e **persistem** via `SaveAppConfigUseCase`.
- `updateProfile(...)` — atualiza dados de perfil, persiste localmente **e** chama `SyncProfileToBackendUseCase` (mock).
- `logOut()` — limpa dados de identidade e vai para `/login`.
- Detalhe de i18n: `setLanguageCode` usa `Get.updateLocale(...)` porque `GetMaterialApp` só lê o parâmetro `locale:` no primeiro build.

---

## 3. Modelo de Dados (Entities)

Todas em `lib/core/domain/entities/`. Todas imutáveis, com `fromMap`/`toMap` (+ `fromJson`/`toJson`) e `Equatable`.

### 3.1 `AppConfigEntity` — configuração global + identidade do usuário
Persistida como JSON único sob a chave `appConfig`.
| Campo | Tipo | Descrição |
|---|---|---|
| `isDarkMode` | bool | tema claro/escuro |
| `userName` | String | nome do usuário (vazio = deslogado) |
| `nickName` | String | apelido |
| `email` | String? | opcional |
| `phoneNumber` | String? | opcional (preenchido no login por telefone) |
| `birthDate` | String? | ISO-8601 `yyyy-MM-dd`; null até completar credenciais |
| `accentColorValue` | int (ARGB) | cor de destaque; default `0xFFFFC107` (âmbar) |
| `avatarIconIndex` | int | índice do ícone de avatar |
| `notificationsEnabled` | bool | default true |
| `languageCode` | String | `en`/`pt`/`es`, default `en` |

`AppConfigEntity.fallback()` fornece o estado inicial de um usuário novo (tudo vazio/default).

### 3.2 `SubjectEntity` — uma "matéria"/atividade cronometrável
Persistida numa lista JSON sob a chave `subjects`. É o objeto central do app.
| Campo | Tipo | Descrição |
|---|---|---|
| `id` | String | `DateTime.now().microsecondsSinceEpoch` |
| `name` | String | nome |
| `category` | `TimeCategoryType` | studying / exercises / reading / hobbies |
| `colorValue` | int | cor do card |
| `totalSeconds` | int | tempo acumulado total (segundos) |
| `goalSeconds` | int | meta de tempo (para categorias por tempo) |
| `currentPages` | int | páginas lidas (categoria reading) |
| `goalPages` | int | meta de páginas |
| `notes` | String | anotações de texto livre |
| `iconName` | String | chave de ícone (ver `SubjectIcons`) |
| `restMinutes` | int | duração da pausa no timer (default 5) |
| `musicSuggestion` | String | sugestão de música/playlist |
| `wallpaperIndex` | int | índice do gradiente de fundo do timer |

### 3.3 `DailyTaskEntity` — hábito/meta diária
Lista JSON sob a chave `dailyTasks`.
| Campo | Tipo | Descrição |
|---|---|---|
| `id` | String | id |
| `name` | String | nome do hábito |
| `colorValue` | int | cor |
| `targetDays` | int | meta de dias a cumprir |
| `completedDates` | List\<String\> | datas (`yyyy-MM-dd`) em que foi marcado |

Getters derivados: `isCheckedToday`, `completedDays` (= tamanho da lista), `isCompleted` (= `completedDays >= targetDays`).
Marcar/desmarcar é **por dia**: adiciona/remove a data de hoje da lista.

### 3.4 `ScheduleEntryEntity` — bloco na grade de horários semanal
Lista JSON sob a chave `scheduleEntries`.
| Campo | Tipo | Descrição |
|---|---|---|
| `id` | String | id |
| `title` | String | título do compromisso |
| `weekday` | int | 1=segunda … 7=domingo (`DateTime.monday`…) |
| `startMinutes` | int | minutos desde 00:00 (início) |
| `endMinutes` | int? | fim opcional |
| `colorValue` | int | cor do bloco |

### 3.5 `GroupEntity` + `GroupMemberEntity` — grupos sociais e ranking
| `GroupEntity` | Descrição |
|---|---|
| `id`, `name` | identificação |
| `theme` | `GroupThemeType` (studying/dailyGoals/exercises/reading/hobbies) |
| `members` | `List<GroupMemberEntity>` |

| `GroupMemberEntity` | Descrição |
|---|---|
| `id`, `name` | identificação |
| `avatarColorValue` | cor do avatar |
| `todaySeconds` / `weekSeconds` / `monthSeconds` | tempo acumulado por período |
| `avatarUrl` (getter) | `https://i.pravatar.cc/150?u=<id>` |
| `secondsFor(period)` | retorna o valor conforme `LeaderboardPeriodType` |

### 3.6 `ProfileStatsEntity` — estatísticas agregadas do perfil (derivadas de subjects)
Construída por `ProfileStatsEntity.fromSubjects(...)`. Agrega:
- `studyingTotalSeconds`, `exercisesTotalSeconds`, `readingTotalSeconds` (somas por categoria),
- `topStudyingSubject` (matéria de estudo com maior tempo),
- `topReadingSubjects` (top 3 leituras por tempo).

### 3.7 `LastActivityEntity` — última atividade registrada
`label` + `timestamp`. Persistida sob a chave `lastActivity`. Alimenta o card "última atividade" na Home.

### 3.8 `FriendOption`
Typedef de record: `({String id, String name})`. Usado na criação de grupos.

### 3.9 Enums
- **`TimeCategoryType`**: `studying`, `exercises`, `reading`, `hobbies` — cada um com `iconName`. `reading` é tratada como **baseada em páginas** (não em timer).
- **`GroupThemeType`**: `studying`, `dailyGoals`, `exercises`, `reading`, `hobbies` — cada um com `iconName` e `unit` (`GroupMetricUnit`: hours/days/pages) que define como o ranking é medido. `byName` faz fallback para `studying` (compat. legada).
- **`LeaderboardPeriodType`**: `today`, `thisWeek`, `thisMonth`.
- **`GroupMetricUnit`**: `hours`, `days`, `pages`.
- **`HttpMethod`**: GET/POST/DELETE/PUT/PATCH (infra HTTP).

---

## 4. Persistência Local

Serviço: `AppLocalStorageService` (`lib/core/services/local_storage/`). Roteia por chave:
- Chaves **não sensíveis** → `SharedPreferences`.
- Chaves **sensíveis** (`hasSensitiveData: true`) → `FlutterSecureStorage`.

Chaves (`LocalStorageKeys`):
| Chave | Sensível | Conteúdo |
|---|---|---|
| `appConfig` | não | `AppConfigEntity` (JSON) |
| `subjects` | não | lista de `SubjectEntity` (JSON) |
| `dailyTasks` | não | lista de `DailyTaskEntity` (JSON) |
| `lastActivity` | não | `LastActivityEntity` (JSON) |
| `scheduleEntries` | não | lista de `ScheduleEntryEntity` (JSON) |
| `accessToken` | **sim** | reservado para auth real (ainda não usado) |
| `refreshToken` | **sim** | reservado para auth real (ainda não usado) |

`clearStorage()` limpa ambos os storages. Ao **carregar subjects**, o data source **ignora entradas de categorias removidas** (ex.: uma antiga "working"), garantindo compatibilidade com dados salvos por versões anteriores.

---

## 5. Mapa de Navegação (Rotas)

Definidas em `lib/app/app_routes.dart` (GetX `GetPage`). Rota inicial: `/` (splash).
Transição padrão entre páginas empilhadas: `rightToLeft`, 320ms, `easeInOutCubic`.

| Rota | Constante | Tela | Observações |
|---|---|---|---|
| `/` | `splash` | Splash | dispara `AppController.initialize()` |
| `/login` | `login` | Login | Google/Apple (mock) + telefone |
| `/phoneLogin` | `phoneLogin` | Login por telefone | pede número |
| `/otp` | `otp` | Verificação OTP | recebe telefone como argumento |
| `/credentials` | `credentials` | Cadastro (nome/apelido/nascimento) | recebe telefone |
| `/mainNavigation` | `mainNavigation` | **Shell com bottom nav** | contém navegação aninhada (id=1) |
| `/home` | `home` | Home | filho de mainNavigation |
| `/profile` | `profile` | Perfil | filho de mainNavigation |
| `/groups` | `groups` | Grupos | filho de mainNavigation |
| `/config` | `config` | Configurações | filho de mainNavigation |
| `/category` | `category` | Lista de subjects da categoria | recebe `TimeCategoryType` |
| `/createSubject` | `createSubject` | Criar subject | recebe categoria; retorna `SubjectEntity` |
| `/createTask` | `createTask` | Criar tarefa diária | retorna `DailyTaskEntity` |
| `/dailyGoals` | `dailyGoals` | Metas diárias | lista de hábitos |
| `/timer` | `timer` | Cronômetro de foco | recebe `SubjectEntity` |
| `/editProfile` | `editProfile` | Editar perfil | |
| `/faq` | `faq` | FAQ / ajuda | |
| `/createGroup` | `createGroup` | Criar grupo | retorna `GroupEntity` |
| `/schedule` | `schedule` | Grade de horários semanal | |
| `/notes` | `notes` | Editor de anotações do subject | recebe `SubjectEntity`; retorna String (notas) |

**Navegação aninhada (bottom nav):** `MainNavigationPage` mantém um `Navigator` interno (id=1). `MainNavigationController.onTapBottomBarButton` troca entre `home`/`profile`/`groups`/`config` via `offAllNamed(rota, id: nestedKey)`, sem empilhar. As telas fora do shell (timer, createSubject, etc.) são empilhadas sobre o shell inteiro.

**Abstração de navegação:** todas as telas navegam por `AppNavigator` (`lib/app/app_navigator.dart`), que encapsula `Get.toNamed/offAllNamed/back`, diálogos e snackbars de erro/sucesso (padronizados e i18n).

---

## 6. Fluxo de Autenticação e Onboarding

### 6.1 Splash → decisão de rota
1. `SplashPage` monta e no `onReady` chama `AppController.initialize()`.
2. `initialize()` carrega a config salva e aguarda `splashScreenDuration` (2s) em paralelo.
3. Decisão: `userName` vazio → **`/login`**; caso contrário → **`/mainNavigation`** (auto-login por dado local).

### 6.2 Login social (mock)
- `LoginPage` oferece Google, Apple e "entrar por telefone".
- Tocar Google/Apple → `_mockSocialSignIn("Google User"/"Apple User")` → grava `userName` e vai para `/mainNavigation`. **Não há OAuth real.**

### 6.3 Login por telefone → OTP → credenciais
1. `/phoneLogin`: campo de telefone; botão habilita quando há ≥ 8 dígitos. Ao enviar → `RequestPhoneCodeUseCase` (mock, delay 700ms) → navega para `/otp` passando o telefone.
2. `/otp`: campo de 6 dígitos. Ao completar 6 dígitos, **auto-submete** → `VerifyPhoneCodeUseCase` (mock aceita qualquer 6 dígitos numéricos). Também há "reenviar código".
   - Após verificação: se já existe conta (`userName` não vazio) → `/mainNavigation`; senão → `/credentials`.
3. `/credentials`: coleta **nome** (obrigatório), **apelido** (opcional) e **data de nascimento** (obrigatória, via date picker; default sugere idade 18). Botão habilita com nome + data preenchidos. Ao enviar → `AppController.updateProfile(...)` (grava local + sync mock) → `/mainNavigation`.

### 6.4 Logout
Em Configurações → confirma em diálogo → `AppController.logOut()` limpa identidade e volta a `/login`.

---

## 7. Núcleo Funcional — Categorias, Subjects, Timer, Leitura

### 7.1 Home (`/home`)
- Saúda o usuário pelo `userName`.
- Mostra um **grid de categorias** (`CategoryCard`), uma para cada `TimeCategoryType` (studying, exercises, reading, hobbies).
- **Logo após "studying"**, insere um card extra **"Metas Diárias"** (`onTapDailyGoals` → `/dailyGoals`).
- Tocar numa categoria → `/category` com aquele `TimeCategoryType`.
- Exibe o card de **última atividade** (`LastActivityCard`), alimentado pelo `LastActivityService`.

### 7.2 Lista da Categoria (`/category`)
Controller: `CategoryController` (recebe a `category`).
- Carrega todos os subjects e filtra pelos da categoria.
- `isPageBased = (category == reading)` — muda o comportamento de "tocar no subject":
  - **Reading (baseada em páginas):** tocar abre `LogPagesDialog` para **registrar páginas lidas**; ao confirmar, atualiza `currentPages` via `UpdateSubjectPagesUseCase`.
  - **Demais categorias (baseadas em tempo):** tocar abre o **Timer** (`/timer`) com o subject.
- Ações por subject:
  - **Notas:** abre `/notes` (retorna texto atualizado, refletido na lista).
  - **Deletar:** remove otimisticamente da lista + `DeleteSubjectUseCase`.
  - **Adicionar:** abre `/createSubject`; ao voltar com o subject criado, adiciona à lista.

### 7.3 Criar Subject (`/createSubject`)
Controller: `CreateSubjectController` (recebe a categoria).
Campos coletados:
- **Nome** (obrigatório; erro i18n se vazio).
- **Cor** (paleta `SubjectColors`, 8 cores).
- **Ícone** (sugestões específicas por categoria via `SubjectIcons.suggestionsFor`).
- **Meta:** se `reading` → meta em **páginas**; senão → meta em **horas** (convertida para segundos: `horas*3600`).
- **Minutos de descanso** (`restMinutesOptions`: 5/10/15/20).
- **Wallpaper** do timer (índice em `TimerWallpapers`).
- **Sugestão de música** (texto livre).
Ao salvar → `AddSubjectUseCase` cria com `totalSeconds=0`, `currentPages=0` e persiste; retorna a entidade para a tela anterior.

### 7.4 Timer de Foco (`/timer`) — coração do app
Controller: `TimerController` (recebe o `SubjectEntity`). Estilo Pomodoro.
Constantes/estado:
- **Intervalo de foco:** 25 min (`_focusIntervalSeconds = 25*60`).
- **Intervalo de descanso:** `subject.restMinutes` (fallback 5) em minutos.
- Reativos: `sessionSeconds` (tempo da sessão atual), `breakCountdownSeconds` (contagem regressiva até a pausa), `restCountdownSeconds` (contagem da pausa), `isRunning`, `isResting`.
- `totalSeconds = baselineSeconds (persistido) + sessionSeconds`.

Lógica do tick (1×/s):
1. Se pausado → não faz nada.
2. Se em descanso → decrementa `restCountdownSeconds`; ao chegar a 0, sai do descanso e reinicia o ciclo de foco (25 min).
3. Se em foco → incrementa `sessionSeconds`, decrementa `breakCountdownSeconds`; ao chegar a 0, entra em **descanso**, **persiste o tempo acumulado** e atualiza a notificação.

Interações e persistência:
- `togglePause()` — pausa/retoma; ao pausar, persiste o acumulado.
- `saveProgress()` — persiste manualmente.
- `_persistAccumulatedTime()` — move `sessionSeconds` para `baselineSeconds`, zera a sessão e grava via `UpdateSubjectTimeUseCase`. Marca que houve tempo logado.
- Ao **sair da tela** (`onClose`): persiste o restante; se houve tempo logado, registra em `LastActivityService.record(subject.name)`; cancela a notificação.
- **Notificação persistente** (Android): mostra estado "rodando" (com cronômetro ao vivo via `usesChronometer`), "descansando" ou "pausado" — ver seção 10.

### 7.5 Notas do Subject (`/notes`)
`NotesController` recebe o subject, edita `notes` em um `TextField`. Ao salvar → `UpdateSubjectNotesUseCase` persiste e retorna a string para a tela de categoria atualizar o subject.

---

## 8. Metas Diárias (Hábitos)

### 8.1 Lista (`/dailyGoals`)
Controller: `DailyGoalsController`.
- Carrega tarefas (`GetDailyTasksUseCase`).
- **Marcar/desmarcar (`onToggleTask`)** → `ToggleDailyTaskCheckUseCase`: se hoje já está em `completedDates`, remove; senão adiciona hoje. Persiste e devolve a tarefa atualizada. Se ficou marcada hoje, registra em `LastActivityService`.
- **Deletar** → remoção otimista + `DeleteDailyTaskUseCase`.
- **Adicionar** → `/createTask` (retorna a tarefa criada).

### 8.2 Criar Tarefa (`/createTask`)
Controller: `CreateTaskController`.
- **Nome** (obrigatório).
- **Cor** (paleta `SubjectColors`).
- **Meta de dias:** opções pré-definidas `[3,5,7,14,21,30]` **ou** valor customizado (campo numérico). Selecionar um preset limpa o custom, e vice-versa.
- Ao salvar → `AddDailyTaskUseCase` cria com `completedDates` vazio; retorna a entidade.

Semântica de "streak/progresso": a tarefa acumula dias marcados (`completedDays`) rumo a `targetDays`; `isCompleted` quando alcança a meta.

---

## 9. Grupos e Rankings (Social)

### 9.1 Lista de Grupos (`/groups`)
Controller: `GroupsController`. **Dados mockados** (`GroupsDataSource`).
- Carrega grupos (2 mock: "Study Squad" tema studying, "Work Crew" tema exercises) e seleciona o primeiro.
- **Seleção de grupo** e **seleção de período** (`today`/`thisWeek`/`thisMonth`).
- **`rankedMembers`** — ordena os membros do grupo selecionado por `secondsFor(período)` (desc). É o leaderboard.
- **Criar grupo** → `/createGroup`; ao voltar, adiciona e seleciona o novo grupo.
- Observação de implementação: a lista carregada é **copiada** (`List.of`) para não aliasar o store mockado (senão um grupo criado apareceria duplicado).

### 9.2 Criar Grupo (`/createGroup`)
Controller: `CreateGroupController`.
- Carrega **amigos convidáveis** (`GetInvitableFriendsUseCase`, 6 amigos mock).
- Coleta: **nome do grupo** (obrigatório), **tema** (`GroupThemeType`, obrigatório) e **≥1 amigo** selecionado (obrigatório).
- `canCreate` só habilita com os três satisfeitos; erros específicos i18n para cada campo faltante.
- Ao criar → `CreateGroupUseCase`/`GroupsDataSource.createGroup`: monta os membros incluindo **"You"** + os amigos convidados (todos com tempos zerados), gera id por timestamp, adiciona ao store mock e retorna.

O **tema** define a unidade do ranking (`GroupMetricUnit`): studying/exercises/hobbies → horas; dailyGoals → dias; reading → páginas.

---

## 10. Perfil e Grade de Horários

### 10.1 Perfil (`/profile`)
Controller: `ProfileController`.
- Exibe `userName`.
- **Estatísticas agregadas** (`GetProfileStatsUseCase` → `ProfileStatsEntity.fromSubjects`): totais por categoria (studying/exercises/reading), matéria de estudo top e top 3 leituras. Renderizadas em `StatCard` / `TopThemeTile`.
- **Prévia da agenda de hoje:** `sortedScheduleEntries` vem de `ScheduleController.todayEntries` (entradas do dia atual, ordenadas por horário de início).
- Botão para abrir a **grade completa** (`/schedule`).

Nota de DI: `ProfileController` depende de um `ScheduleController` compartilhado, para reaproveitar as entradas já carregadas.

### 10.2 Grade de Horários (`/schedule`)
Controller: `ScheduleController`.
- `selectedWeekday` inicia no dia atual (`DateTime.now().weekday`).
- `sortedEntries` = entradas do dia selecionado ordenadas por `startMinutes`. Seleção de dia via `onSelectWeekday`.
- **Adicionar entrada** → abre `AddScheduleEntryDialog` (título, horário início/fim opcional, cor). Cria via `AddScheduleEntryUseCase` no dia selecionado.
  - **Detalhe importante (bug conhecido evitado):** o resultado do diálogo é obtido como `dynamic` e depois convertido (`as AddScheduleEntryResult?`). Passar o tipo record concreto como genérico do `toNamed`/dialog faz o GetX **descartar o resultado** (a entrada só aparecia após reiniciar o app). Ver memória `feedback_getx_tonamed_generic_crash`.
- **Deletar entrada** → remoção otimista + `DeleteScheduleEntryUseCase`.

---

## 11. Configurações, Perfil Editável e FAQ

### 11.1 Configurações (`/config`)
Controller: `ConfigController` (proxeia estado do `AppController`).
- **Modo escuro** (toggle) → `setDarkMode`.
- **Notificações** (toggle) → `setNotificationsEnabled`.
- **Meu perfil** → `/editProfile`.
- **Idioma** → `LanguagePickerDialog` (en/pt/es) → `setLanguageCode` (aplica `Get.updateLocale`).
- **FAQ** → `/faq`.
- **Logout** → `LogOutDialog` (confirmação) → `logOut()`.
Mostra também `userName`, `nickName`, `avatarIconIndex`.

### 11.2 Editar Perfil (`/editProfile`)
Controller: `EditProfileController`.
- Edita **nome, apelido, email, telefone**.
- **Cor de destaque** (`AppAccentPresets`, 7 cores) — aplicada imediatamente ao tema (`setAccentColor`).
- **Ícone de avatar** (`AppAvatarPresets`, 8 ícones) — aplicado imediatamente.
- **Salvar** → `AppController.updateProfile(...)` (persiste local + sync mock) → snackbar de sucesso i18n.

### 11.3 FAQ (`/faq`)
Lista de perguntas/respostas (dados de conteúdo estático, renderizados em lista expansível).

---

## 12. Tema, Design System e Internacionalização

### 12.1 Sistema de cores dinâmico
`AppColorTokens` (`ThemeExtension`) é **gerado a partir de uma cor semente (accent)** e do brilho (claro/escuro) via `AppColorTokens.fromSeed`. Deriva ~18 tokens (primary, pastel, superfícies, bordas, texto, erro/sucesso/aviso, overlays) manipulando HSL da semente. Isso permite **re-tematização em tempo real** quando o usuário troca a cor de destaque ou o modo escuro (o `AppWidget` reconstrói o `GetMaterialApp` dentro de um `Obx`).

### 12.2 Presets de tema
- `AppAccentPresets` — 7 cores de destaque (default âmbar `0xFFFFC107`).
- `SubjectColors` — 8 cores para subjects/tarefas.
- `AppAvatarPresets` — 8 ícones de avatar (Material rounded).
- `SubjectIcons` — mapa nome→`IconData`, com sugestões por categoria.
- `TimerWallpapers` — 6 gradientes lineares escuros para o fundo do timer.
- `AppTextStyles` — escala tipográfica (Nunito) derivada dos tokens.

### 12.3 Internacionalização (i18n)
- Gerada via `flutter gen-l10n` (`generate: true`), com `AppLocalizations` e delegates.
- **Três locales:** `en`, `pt`, `es` (arquivos `lib/l10n/app_en.arb`, `app_pt.arb`, `app_es.arb`; ~207 chaves).
- Acesso via extensão `context.l10n`.
- Troca em runtime por `Get.updateLocale` (persistida em `AppConfig.languageCode`).

### 12.4 Convenções de código (memórias/regras do projeto)
- **Espaçamentos** (gap/padding/margin) devem ser **múltiplos de 4**.
- **Nunca** aninhar `Obx()` dentro de callbacks `itemBuilder`.
- **Não** alternar entre `color` e `gradient` em `BoxDecoration` de um `AnimatedContainer`.
- **Não** chamar `toNamed<T>()` com tipo concreto; obter `dynamic` e converter (ver §10.2).

---

## 13. Serviços de Suporte

- **`LastActivityService`** — mantém a última atividade reativa (`Rx<LastActivityEntity?>`), carrega do storage e grava com `record(label)`. Alimenta a Home. É registrada tanto em sessões de timer quanto ao marcar tarefas diárias.
- **`TimerNotificationService`** (Android only, `GetPlatform.isAndroid`) — canal `focus_timer`, notificação **ongoing** (não removível), importância baixa, silenciosa, visível na lockscreen, categoria "stopwatch". Três estados: `showRunning` (cronômetro ao vivo baseado em `startedAt`), `showStatic` (descansando/pausado) e `cancel`. É resiliente: qualquer falha é engolida para não interromper o timer.
- **`AppLocalStorageService`** — abstração sobre SharedPreferences + SecureStorage (ver §4).
- **Camada HTTP** (`lib/core/services/http/`: `HttpClientService`, `AppHttpRequest`, `HttpStatusCode`) — infraestrutura pronta para um backend real (Dio), atualmente não exercida pelos fluxos (que usam mocks/local).
- **`AppLoggerService`** — logging.
- **Tratamento de erro** — `AppError` (`lib/core/domain/errors/`) com variantes como `GenericAppError` e `SerializationAppError`; propagado por `Either` e exibido via snackbars padronizados do `AppNavigator`.

---

## 14. Resumo dos Casos de Uso (Use Cases)

Todos em `lib/core/domain/use_cases/`, retornando `Either<AppError, T>`:

| Use Case | Função |
|---|---|
| `GetAppConfigUseCase` / `SaveAppConfigUseCase` | ler/gravar configuração global |
| `SyncProfileToBackendUseCase` | sincronizar perfil (mock) |
| `RequestPhoneCodeUseCase` / `VerifyPhoneCodeUseCase` | login por telefone (mock) |
| `GetSubjectsUseCase` / `AddSubjectUseCase` / `DeleteSubjectUseCase` | CRUD de subjects |
| `UpdateSubjectTimeUseCase` | acumular tempo do timer |
| `UpdateSubjectPagesUseCase` | registrar páginas (leitura) |
| `UpdateSubjectNotesUseCase` | salvar notas |
| `GetDailyTasksUseCase` / `AddDailyTaskUseCase` / `DeleteDailyTaskUseCase` | CRUD de tarefas diárias |
| `ToggleDailyTaskCheckUseCase` | marcar/desmarcar hábito no dia |
| `GetScheduleEntriesUseCase` / `AddScheduleEntryUseCase` / `DeleteScheduleEntryUseCase` | CRUD da grade |
| `GetGroupsUseCase` / `CreateGroupUseCase` / `GetInvitableFriendsUseCase` | grupos e amigos (mock) |
| `GetProfileStatsUseCase` | estatísticas agregadas do perfil |

---

## 15. Mapa Mental dos Fluxos (rápido)

```
Splash ─▶ (tem userName?) ─── não ─▶ Login ─▶ [Google/Apple mock] ─▶ MainNavigation
                       │                    └▶ Telefone ─▶ OTP ─▶ (tem conta? sim ─▶ Main / não ─▶ Credentials ─▶ Main)
                       └── sim ─────────────────────────────────────────▶ MainNavigation

MainNavigation (bottom nav):
 ├─ Home ─▶ Categoria ─▶ (reading? LogPagesDialog / senão Timer) ; +Subject ; Notas
 │         └▶ Metas Diárias ─▶ toggle/+Tarefa
 ├─ Perfil ─▶ Estatísticas + Agenda de hoje ─▶ Grade de Horários
 ├─ Grupos ─▶ Leaderboard (período) ─▶ +Criar Grupo
 └─ Config ─▶ tema/idioma/notificações ; Editar Perfil ; FAQ ; Logout
```

---

## 16. Glossário de "Onde está o quê" (para navegação de código por IA)

- **Estado global do usuário/preferências:** `lib/app/app_controller.dart`.
- **Rotas e transições:** `lib/app/app_routes.dart`.
- **Navegação/diálogos/snackbars:** `lib/app/app_navigator.dart`.
- **Bootstrap/DI:** `lib/main.dart` + `lib/app/bindings/`.
- **Modelos de dados:** `lib/core/domain/entities/`.
- **Regras de negócio:** `lib/core/domain/use_cases/`.
- **Persistência:** `lib/core/services/local_storage/` + `lib/core/data/data_sources/`.
- **Mock social (grupos/amigos):** `lib/core/data/data_sources/groups_data_source.dart`.
- **Mock auth telefone:** `lib/core/data/data_sources/phone_auth_data_source.dart`.
- **Timer/Pomodoro:** `lib/presentation/timer/timer_controller.dart`.
- **Notificações:** `lib/core/services/notifications/timer_notification_service.dart`.
- **Tema dinâmico:** `lib/theme/colors.dart` (`AppColorTokens.fromSeed`) + `lib/theme/theme.dart`.
- **Traduções:** `lib/l10n/*.arb`.

---

*Fim do documento. Este arquivo descreve o estado do app HelpOut conforme o código-fonte atual em `lib/`.*
