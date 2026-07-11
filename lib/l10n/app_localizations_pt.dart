// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'HelpOut';

  @override
  String get genericErrorMessage =>
      'Algo deu errado. Tente novamente mais tarde.';

  @override
  String get loginHeadline => 'Vamos Começar';

  @override
  String get loginSubtitle => 'Entre para começar.';

  @override
  String get loginNameHint => 'Seu nome';

  @override
  String get loginButton => 'Vamos Começar';

  @override
  String get homeGreetingDefault => 'Olá';

  @override
  String homeGreetingWithName(String userName) {
    return 'Olá, $userName';
  }

  @override
  String get homeSubtitle => 'O que vamos fazer hoje?';

  @override
  String homeSubtitleFocusedToday(String duration) {
    return 'Você já focou $duration hoje';
  }

  @override
  String homeSubtitleNextSchedule(String title, String time) {
    return 'Agenda: $title às $time';
  }

  @override
  String get homeSubtitleStart => 'Comece sua primeira sessão de foco';

  @override
  String get homeTasksSection => 'Metas diárias';

  @override
  String get homeCategoriesSection => 'Atividades';

  @override
  String get homeActionContinueEyebrow => 'Continuar agora';

  @override
  String get homeActionContinueButton => 'Continuar';

  @override
  String get homeActionStartEyebrow => 'Começar foco';

  @override
  String get homeActionStartButton => 'Começar';

  @override
  String get homeActionSuggestedMeta => 'Sua matéria com mais tempo';

  @override
  String get homeActionCreateBody =>
      'Crie sua primeira matéria para iniciar uma sessão de foco.';

  @override
  String get homeActionCreateButton => 'Criar matéria';

  @override
  String get homeSummaryTitle => 'Resumo de hoje';

  @override
  String get homeSummaryFocus => 'Foco';

  @override
  String get homeSummaryGoals => 'Metas';

  @override
  String get homeSummaryPages => 'Páginas';

  @override
  String get homeSummarySessions => 'Sessões';

  @override
  String homeGoalsProgress(int done, int total) {
    return '$done de $total feitas';
  }

  @override
  String get homeCategoryEmpty => 'Nada ainda';

  @override
  String get homeNextScheduleTitle => 'Agenda';

  @override
  String get homeNextScheduleEmpty => 'Nenhum horário hoje';

  @override
  String get homeNextScheduleAdd => 'Adicionar horário';

  @override
  String get addTaskButton => 'Adicionar meta';

  @override
  String get createTaskTitle => 'Nova meta';

  @override
  String get taskNameHint => 'Nome da meta';

  @override
  String get targetDaysLabel => 'Alvo (dias)';

  @override
  String targetDaysChip(int days) {
    return '$days dias';
  }

  @override
  String get targetDaysHint => 'Alvo personalizado';

  @override
  String taskDaysProgress(int completed, int target) {
    return '$completed/$target dias';
  }

  @override
  String get taskCompletedLabel => 'Concluída!';

  @override
  String get lastActivityLabel => 'Última atividade';

  @override
  String get lastActivityNone => 'Nada ainda — comece algo!';

  @override
  String get lastActivityJustNow => 'agora mesmo';

  @override
  String lastActivityMinutesAgo(int minutes) {
    return 'há $minutes min';
  }

  @override
  String lastActivityHoursAgo(int hours) {
    return 'há $hours h';
  }

  @override
  String lastActivityDaysAgo(int days) {
    return 'há $days d';
  }

  @override
  String get categoryStudying => 'Estudos';

  @override
  String get categoryExercises => 'Exercícios';

  @override
  String get categoryReading => 'Leitura';

  @override
  String get categoryHobbies => 'Hobbies';

  @override
  String get itemNounStudying => 'Matéria';

  @override
  String get itemNounExercises => 'Exercício';

  @override
  String get itemNounReading => 'Livro';

  @override
  String get itemNounHobbies => 'Hobby';

  @override
  String get iconLabel => 'Ícone';

  @override
  String get restTimeLabel => 'Tempo de descanso';

  @override
  String restMinutesChip(int minutes) {
    return '$minutes min';
  }

  @override
  String get wallpaperLabel => 'Wallpaper do timer';

  @override
  String addItemButton(String itemNoun) {
    return 'Adicionar $itemNoun';
  }

  @override
  String itemNameHint(String itemNoun) {
    return 'Nome de $itemNoun';
  }

  @override
  String get colorLabel => 'Cor';

  @override
  String get bookThemeLabel => 'Tema do livro';

  @override
  String get estimatedHoursGoalHint => 'Meta estimada (horas)';

  @override
  String get goalPagesHint => 'Meta (páginas)';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get addButton => 'Adicionar';

  @override
  String get createSubjectTitleStudying => 'Nova matéria';

  @override
  String get createSubjectTitleReading => 'Nova leitura';

  @override
  String get createSubjectTitleExercises => 'Nova atividade física';

  @override
  String get createSubjectTitleHobbies => 'Novo hobby';

  @override
  String get createSubjectSubtitleStudying =>
      'Defina uma meta e personalize seu foco';

  @override
  String get createSubjectSubtitleReading =>
      'Acompanhe páginas e personalize sua leitura';

  @override
  String get createSubjectSubtitleExercises =>
      'Configure como você quer acompanhar essa atividade';

  @override
  String get createSubjectSubtitleHobbies =>
      'Configure como você quer acompanhar esse hobby';

  @override
  String get createSubjectBasicSection => 'Informações básicas';

  @override
  String get createSubjectGoalSection => 'Meta';

  @override
  String get createSubjectRoutineSection => 'Rotina';

  @override
  String get createSubjectPersonalizationSection => 'Personalização';

  @override
  String get createSubjectNameLabelStudying => 'Nome da matéria';

  @override
  String get createSubjectNameLabelReading => 'Nome da leitura';

  @override
  String get createSubjectNameLabelExercises => 'Nome da atividade';

  @override
  String get createSubjectNameLabelHobbies => 'Nome do hobby';

  @override
  String get createSubjectNameHintStudying =>
      'Ex.: Biologia, Matemática, Inglês';

  @override
  String get createSubjectNameHintReading =>
      'Ex.: Livro de História, Dom Casmurro';

  @override
  String get createSubjectNameHintExercises =>
      'Ex.: Academia, Corrida, Alongamento';

  @override
  String get createSubjectNameHintHobbies =>
      'Ex.: Violão, Desenho, Programação';

  @override
  String get createSubjectTimeGoalLabel => 'Meta de tempo';

  @override
  String get createSubjectPagesGoalLabel => 'Meta de páginas';

  @override
  String get createSubjectTimeGoalHelp =>
      'Quantas horas você quer acumular no total?';

  @override
  String get createSubjectPagesGoalHelp =>
      'Quantas páginas você quer registrar no total?';

  @override
  String get createSubjectRestLabel => 'Pausa após cada foco';

  @override
  String get createSubjectRestHelp =>
      'O timer sugere uma pausa depois de 25 min de foco.';

  @override
  String get createSubjectPreviewTitle => 'Prévia';

  @override
  String get createSubjectPreviewNoGoal => 'Sem meta definida';

  @override
  String createSubjectPreviewGoal(String goal) {
    return 'Meta: $goal';
  }

  @override
  String createSubjectPreviewRest(int minutes) {
    return 'Pausa: $minutes min';
  }

  @override
  String createSubjectHoursValue(int hours) {
    return '${hours}h';
  }

  @override
  String createSubjectHoursMinutesValue(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String createSubjectColorSemantic(int index) {
    return 'Cor $index';
  }

  @override
  String get createSubjectButtonStudying => 'Criar matéria';

  @override
  String get createSubjectButtonReading => 'Criar leitura';

  @override
  String get createSubjectButtonExercises => 'Criar atividade';

  @override
  String get createSubjectButtonHobbies => 'Criar hobby';

  @override
  String get createSubjectMissingName => 'Digite o nome para continuar';

  @override
  String get createSubjectMissingTimeGoal => 'Defina uma meta de tempo válida';

  @override
  String get createSubjectMissingPagesGoal =>
      'Defina uma meta de páginas válida';

  @override
  String get createSubjectSuccessStudying => 'Matéria criada com sucesso';

  @override
  String get createSubjectSuccessReading => 'Leitura criada com sucesso';

  @override
  String get createSubjectSuccessExercises => 'Atividade criada com sucesso';

  @override
  String get createSubjectSuccessHobbies => 'Hobby criado com sucesso';

  @override
  String pagesProgress(int currentPages, int goalPages) {
    return '$currentPages de $goalPages páginas';
  }

  @override
  String pagesReadOnly(int currentPages) {
    return '$currentPages páginas lidas';
  }

  @override
  String get pagesReadNowHint => 'Páginas lidas agora';

  @override
  String get logPagesButton => 'Registrar páginas';

  @override
  String get notesLabel => 'Anotações';

  @override
  String get notesHint => 'Escreva suas anotações aqui...';

  @override
  String get saveNotesButton => 'Salvar';

  @override
  String durationProgress(String duration, String goalDuration) {
    return '$duration de $goalDuration';
  }

  @override
  String timerTotalLabel(String duration) {
    return 'Total: $duration';
  }

  @override
  String timerNextBreakLabel(String duration) {
    return 'Próxima pausa em $duration';
  }

  @override
  String timerRestingLabel(String duration) {
    return 'Descansando — volta em $duration';
  }

  @override
  String get timerNotificationRunning => 'Sessão de foco em andamento';

  @override
  String get timerNotificationResting => 'Descansando — volta já';

  @override
  String get timerNotificationPaused => 'Pausado';

  @override
  String get timerStateFocusingTitle => 'Foco em andamento';

  @override
  String get timerStateFocusingDescription =>
      'Mantenha o foco. Uma pausa será sugerida em breve.';

  @override
  String get timerStatePausedTitle => 'Timer pausado';

  @override
  String get timerStatePausedDescription => 'Continue quando estiver pronto.';

  @override
  String get timerStateRestingTitle => 'Pausa merecida';

  @override
  String get timerStateRestingDescription =>
      'Beba água ou respire um pouco antes de continuar.';

  @override
  String get timerSessionSavedTitle => 'Sessão registrada';

  @override
  String get timerSessionSavedDescription =>
      'Seu tempo foi adicionado à matéria.';

  @override
  String get timerCurrentFocusLabel => 'Tempo focado agora';

  @override
  String get timerRestTimeLabel => 'Tempo de pausa';

  @override
  String get timerSessionLabel => 'Sessão atual';

  @override
  String timerTotalInSubject(String subjectName) {
    return 'Total em $subjectName';
  }

  @override
  String get timerPauseButton => 'Pausar';

  @override
  String get timerContinueButton => 'Continuar';

  @override
  String get timerContinueFocusButton => 'Continuar';

  @override
  String get timerSkipRestButton => 'Pular pausa';

  @override
  String get timerEndSessionButton => 'Encerrar sessão';

  @override
  String get timerStartAnotherSessionButton => 'Iniciar outra sessão';

  @override
  String get timerSaveReassurance =>
      'O progresso também é salvo ao pausar ou sair.';

  @override
  String timerFocusedValue(String duration) {
    return '$duration focados';
  }

  @override
  String get timerAccumulatedTotalLabel => 'Total acumulado';

  @override
  String get timerBackToSubjectsButton => 'Voltar';

  @override
  String get timerExitDialogTitle => 'Encerrar sessão?';

  @override
  String timerExitDialogContent(String duration, String subjectName) {
    return 'Seu progresso de $duration será salvo em $subjectName.';
  }

  @override
  String get timerExitDialogCancel => 'Continuar';

  @override
  String get timerExitDialogContinueLater => 'Você poderá continuar depois.';

  @override
  String get timerExitDialogConfirm => 'Encerrar';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get editButton => 'Editar';

  @override
  String get nicknameFallback => 'usuario';

  @override
  String get profileSummaryLabel => 'Resumo total';

  @override
  String get profileSummarySinceStartLabel => 'Desde o início';

  @override
  String profileSummaryAccumulatedFocus(Object duration) {
    return '$duration de foco acumulado';
  }

  @override
  String get profileSummaryFocusLabel => 'Tempo total de foco';

  @override
  String get profileSummaryFocusDescription => 'Estudo, exercícios e hobbies';

  @override
  String get statHoursStudied => 'Estudo';

  @override
  String get statHoursExercised => 'Exercício';

  @override
  String get statPagesRead => 'Páginas lidas';

  @override
  String get statTopSubject => 'Mais estudada';

  @override
  String get profileStatTimeEmptyTitle => 'Comece seu primeiro foco';

  @override
  String get profileStatTimeEmptyDescription => 'Seu tempo aparecerá aqui';

  @override
  String get profileStatExerciseEmptyTitle => 'Nenhum exercício ainda';

  @override
  String get profileStatExerciseEmptyDescription =>
      'Registre sua primeira atividade';

  @override
  String get profileStatReadingEmptyTitle => 'Nenhuma página ainda';

  @override
  String get profileStatReadingEmptyDescription =>
      'Registre sua primeira leitura';

  @override
  String get profileTopSubjectEmptyTitle => 'Nenhuma ainda';

  @override
  String get profileTopSubjectEmptyDescription =>
      'Estude uma matéria para destacar aqui';

  @override
  String get profileEmptyTitle => 'Seu progresso começa aqui';

  @override
  String get profileEmptyDescription =>
      'Inicie uma sessão, registre uma leitura ou crie uma meta pela Home para acompanhar sua evolução no HelpOut.';

  @override
  String get profileEmptyGuidance =>
      'Depois disso, seu tempo total, principais atividades e leituras aparecem aqui.';

  @override
  String get profileEmptyStartButton => 'Começar agora';

  @override
  String get profileShortcutsTitle => 'Atalhos';

  @override
  String get profileShortcutCreateSubject => 'Criar matéria';

  @override
  String get profileShortcutCreateGoal => 'Criar meta';

  @override
  String get profileShortcutAddSchedule => 'Adicionar horário';

  @override
  String get profileEvolutionTitle => 'Sua evolução';

  @override
  String profileEvolutionFocus(String duration) {
    return 'Você acumulou $duration de foco.';
  }

  @override
  String profileEvolutionTopSubject(String name) {
    return 'Sua matéria mais estudada é $name.';
  }

  @override
  String profileEvolutionRemaining(String duration) {
    return 'Faltam $duration para sua meta.';
  }

  @override
  String get profileEvolutionGoalReached => 'Você alcançou sua meta de foco!';

  @override
  String get profileAgendaTitle => 'Agenda de hoje';

  @override
  String get profileAgendaEmptyTitle => 'Nenhum horário planejado';

  @override
  String get profileAgendaEmptyDescription =>
      'Adicione blocos para organizar sua rotina.';

  @override
  String get profileAgendaAddButton => 'Adicionar horário';

  @override
  String get profileTopReadingTitle => 'Leituras principais';

  @override
  String get profileTopReadingEmptyTitle => 'Nenhuma leitura registrada';

  @override
  String get profileTopReadingEmptyDescription =>
      'Registre páginas lidas para ver seus principais temas aqui.';

  @override
  String get groupsTitle => 'Grupos';

  @override
  String get groupsSubtitle => 'Compare seu progresso com amigos';

  @override
  String get noGroupSelected => 'Nenhum grupo selecionado ainda.';

  @override
  String get newGroupChip => 'Novo';

  @override
  String get groupHeaderCreateButton => 'Grupo';

  @override
  String get groupsEmptyTitle => 'Nenhum grupo ainda';

  @override
  String get groupsEmptyDescription =>
      'Crie um grupo para comparar seu progresso com amigos e manter a motivação.';

  @override
  String get groupsEmptyButton => 'Criar primeiro grupo';

  @override
  String get you => 'Você';

  @override
  String get mockStudyGroupName => 'Equipe de Estudos';

  @override
  String get mockWorkoutGroupName => 'Grupo de Exercícios';

  @override
  String get periodToday => 'Hoje';

  @override
  String get periodThisWeek => 'Semana';

  @override
  String get periodThisMonth => 'Mês';

  @override
  String get periodDescriptionToday => 'hoje';

  @override
  String get periodDescriptionThisWeek => 'esta semana';

  @override
  String get periodDescriptionThisMonth => 'este mês';

  @override
  String get groupMetricStudying => 'horas de estudo';

  @override
  String get groupMetricDailyGoals => 'dias de metas concluídas';

  @override
  String get groupMetricExercises => 'horas de exercício';

  @override
  String get groupMetricReading => 'páginas lidas';

  @override
  String get groupMetricHobbies => 'horas de hobbies';

  @override
  String groupLeaderboardDescription(String period, String metric) {
    return 'Ranking de $period · medido em $metric';
  }

  @override
  String get leaderboardTitle => 'Ranking';

  @override
  String get currentUserRankTitle => 'Seu desempenho';

  @override
  String currentUserRankValue(String rank, String score) {
    return '$rank lugar · $score';
  }

  @override
  String currentUserRankNextStep(String score) {
    return '$score para subir uma posição';
  }

  @override
  String get currentUserRankLeading => 'Você lidera este ranking.';

  @override
  String get currentUserRankSubtitle => 'sua posição atual';

  @override
  String get leaderboardTopPosition => 'lidera este ranking';

  @override
  String leaderboardDifferenceAhead(String value) {
    return '+$value à frente';
  }

  @override
  String get groupCreatedSuccess => 'Grupo criado com sucesso';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsSubtitle => 'Ajuste sua conta e preferências';

  @override
  String get myProfileFallback => 'Meu Perfil';

  @override
  String get personalProfileLabel => 'Perfil pessoal';

  @override
  String accountDataSubtitle(Object nickname) {
    return '$nickname · dados pessoais e segurança';
  }

  @override
  String get preferencesSection => 'Preferências';

  @override
  String get darkModeLabel => 'Modo escuro';

  @override
  String get darkModeEnabledSubtitle => 'Tema escuro ativado';

  @override
  String get darkModeDisabledSubtitle => 'Usar tema escuro no app';

  @override
  String get accentColorSettingsTitle => 'Cor de destaque';

  @override
  String get accentColorSettingsSubtitle => 'Personalize a aparência do app';

  @override
  String get notificationsLabel => 'Notificações';

  @override
  String get timerNotificationsTitle => 'Notificações do timer';

  @override
  String get notificationsEnabledSubtitle =>
      'Alertas de foco, pausa e progresso';

  @override
  String get notificationsDisabledSubtitle =>
      'Alertas desligados neste dispositivo';

  @override
  String get language => 'Idioma';

  @override
  String get appLanguageSubtitle => 'Idioma do app';

  @override
  String get chooseLanguageTitle => 'Escolher idioma';

  @override
  String languageChangedMessage(String language) {
    return 'Idioma alterado para $language';
  }

  @override
  String get preferenceSavedMessage => 'Preferência salva';

  @override
  String get supportSection => 'Suporte';

  @override
  String get helpSection => 'Ajuda';

  @override
  String get faqLabel => 'Perguntas frequentes';

  @override
  String get faqSettingsSubtitle => 'Dúvidas sobre timer, metas e grupos';

  @override
  String get sendFeedbackTitle => 'Enviar feedback';

  @override
  String get sendFeedbackSubtitle => 'Conte o que pode melhorar';

  @override
  String get feedbackUnavailable => 'Feedback ainda não disponível';

  @override
  String get aboutLabel => 'Sobre';

  @override
  String get aboutSection => 'Sobre';

  @override
  String appVersionValue(String version) {
    return 'Versão $version';
  }

  @override
  String get debugEnvironmentTitle => 'Ambiente';

  @override
  String get debugEnvironmentSubtitle => 'Debug · dados de exemplo ativos';

  @override
  String appVersionLabel(String appTitle, String appVersion) {
    return '$appTitle v$appVersion';
  }

  @override
  String get accountSection => 'Conta';

  @override
  String get sessionSection => 'Sessão';

  @override
  String get logOutLabel => 'Sair';

  @override
  String get logOutSettingsSubtitle => 'Encerrar sessão neste dispositivo';

  @override
  String get logOutDialogTitle => 'Sair da conta?';

  @override
  String get logOutDialogContent =>
      'Você precisará entrar novamente para acessar esta conta neste dispositivo. Seus dados locais de estudo serão mantidos.';

  @override
  String get logOutConfirmButton => 'Sair';

  @override
  String get myProfileTitle => 'Meu Perfil';

  @override
  String get avatarLabel => 'Avatar';

  @override
  String get nameLabel => 'Nome';

  @override
  String get yourNameHint => 'Seu nome';

  @override
  String get nicknameLabel => 'Apelido';

  @override
  String get nicknameHint => 'Como seus amigos te chamam';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get optionalHint => 'Opcional';

  @override
  String get phoneLabel => 'Telefone';

  @override
  String get themeColorLabel => 'Cor do tema';

  @override
  String get saveChangesButton => 'Salvar Alterações';

  @override
  String get profileSavedMessage => 'Perfil salvo';

  @override
  String get faqTitle => 'Perguntas frequentes';

  @override
  String get faqQ1 => 'Como funciona o timer de estudo?';

  @override
  String get faqA1 =>
      'Escolha uma matéria, toque em play, e o timer acompanha sua sessão atual, somando ao tempo total daquela matéria. Toque em pausar a qualquer momento para parar e salvar seu progresso.';

  @override
  String get faqQ2 => 'O que é a contagem de pausa?';

  @override
  String get faqA2 =>
      'Cada sessão segue um ciclo clássico Pomodoro: uma contagem regressiva de 25 minutos até sua próxima pausa. Quando chega a zero, ela simplesmente reinicia — é um lembrete, não uma parada obrigatória.';

  @override
  String get faqQ3 => 'Como adiciono uma nova matéria?';

  @override
  String get faqA3 =>
      'Abra uma categoria a partir da Home, depois toque em \"Adicionar Matéria\" no final da lista. Você pode escolher uma cor e definir uma meta de horas estimada.';

  @override
  String get faqQ4 => 'Como são calculados os grupos e o placar?';

  @override
  String get faqA4 =>
      'Os grupos mostram um placar baseado no tema: horas de foco, dias de metas concluídas ou páginas lidas. Alterne entre Hoje, Semana e Mês para comparar o progresso.';

  @override
  String get faqQ5 => 'Posso mudar o tema de cores do app?';

  @override
  String get faqA5 =>
      'Sim, vá em Configurações > Meu Perfil e escolha qualquer cor de tema. Todo gradiente, botão e destaque no app se atualiza pra combinar, incluindo o modo escuro.';

  @override
  String get createGroupTitle => 'Novo grupo';

  @override
  String get createGroupSubtitle => 'Escolha um tema e convide amigos';

  @override
  String get groupNameLabel => 'Nome do grupo';

  @override
  String get groupNameHint => 'Nome do grupo';

  @override
  String get groupNameExampleHint => 'Ex.: Estudos para concurso';

  @override
  String get groupThemeLabel => 'Tema';

  @override
  String groupThemeSelectedDescription(String metric) {
    return 'Este grupo ranqueia por $metric.';
  }

  @override
  String get inviteFriendsLabel => 'Convidar amigos';

  @override
  String selectedFriendsCount(int count) {
    return '$count selecionados';
  }

  @override
  String get selectAtLeastOneFriend => 'Selecione pelo menos 1 amigo';

  @override
  String get searchFriendHint => 'Buscar amigo';

  @override
  String get loadingFriends => 'Carregando amigos...';

  @override
  String get friendsLoadErrorTitle => 'Não foi possível carregar amigos';

  @override
  String get friendsLoadErrorDescription => 'Tente novamente em instantes.';

  @override
  String get noFriendsAvailableTitle => 'Nenhum amigo disponível';

  @override
  String get noFriendsAvailableDescription =>
      'Adicione amigos antes de criar um grupo.';

  @override
  String get noFriendsFoundTitle => 'Nenhum amigo encontrado';

  @override
  String get noFriendsFoundDescription => 'Tente outro nome.';

  @override
  String get createGroupButton => 'Criar Grupo';

  @override
  String get createGroupMissingName => 'Digite o nome do grupo';

  @override
  String get createGroupMissingTheme => 'Escolha um tema';

  @override
  String get createGroupMissingFriends => 'Selecione pelo menos 1 amigo';

  @override
  String createGroupWithFriendsButton(int count) {
    return 'Criar grupo com $count amigos';
  }

  @override
  String get createGroupRequirementsTitle => 'Para criar:';

  @override
  String get createGroupRequirementName => 'Nome do grupo';

  @override
  String get createGroupRequirementTheme => 'Tema escolhido';

  @override
  String get createGroupRequirementFriends => 'Pelo menos 1 amigo';

  @override
  String get groupPrivacyNote =>
      'Seus amigos verão apenas seu nome, avatar e progresso neste tema.';

  @override
  String metricDaysValue(int value) {
    return '$value dias';
  }

  @override
  String metricPagesValue(int value) {
    return '$value páginas';
  }

  @override
  String get navHome => 'Início';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navGroups => 'Grupos';

  @override
  String get navSettings => 'Config';

  @override
  String get myScheduleCardTitle => 'Sua Agenda';

  @override
  String get myScheduleTitle => 'Sua Agenda';

  @override
  String get noScheduleYet => 'Nenhum horário ainda';

  @override
  String get noScheduleYetDescription =>
      'Toque no botão abaixo para adicionar\nseu primeiro horário';

  @override
  String get addScheduleEntryTitle => 'Adicionar Horário';

  @override
  String get addScheduleEntryButton => 'Adicionar Horário';

  @override
  String get scheduleTitleHint => 'Título';

  @override
  String get startTimeLabel => 'Hora de início';

  @override
  String get endTimeOptionalLabel => 'Hora de fim';

  @override
  String get incompleteScheduleEntryError =>
      'Cadastro incompleto — preencha o título, a hora de início e a hora de fim.';

  @override
  String get endTimeBeforeStartError =>
      'O horário de término deve ser depois do horário de início.';

  @override
  String get nameRequiredError => 'Digite um nome primeiro.';

  @override
  String get groupThemeRequiredError => 'Escolha um tema para o grupo.';

  @override
  String get groupNeedsFriendError =>
      'Convide pelo menos um amigo — um grupo não pode ser criado sozinho.';

  @override
  String get continueWithGoogleButton => 'Continuar com Google';

  @override
  String get continueWithAppleButton => 'Continuar com Apple';

  @override
  String get continueWithPhoneButton => 'Continuar com o celular';

  @override
  String get phoneLoginTitle => 'Entrar';

  @override
  String get phoneLoginSubtitle =>
      'Digite seu número de celular e enviaremos um código de verificação por SMS.';

  @override
  String get sendCodeButton => 'Enviar código';

  @override
  String get otpTitle => 'Verifique seu número';

  @override
  String otpSubtitle(String phone) {
    return 'Digite o código de 6 dígitos que enviamos para $phone.';
  }

  @override
  String get verifyCodeButton => 'Verificar';

  @override
  String get resendCodeButton => 'Reenviar código';

  @override
  String get codeResentMessage => 'Código de verificação enviado';

  @override
  String get invalidCodeError => 'Código inválido. Tente novamente.';

  @override
  String get credentialsTitle => 'Quase lá';

  @override
  String get credentialsSubtitle => 'Conte um pouco sobre você.';

  @override
  String get birthDateHint => 'Data de nascimento';

  @override
  String get finishButton => 'Concluir';
}
