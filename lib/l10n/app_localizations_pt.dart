// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Timing';

  @override
  String get genericErrorMessage =>
      'Algo deu errado. Tente novamente mais tarde.';

  @override
  String get loginHeadline => 'Vamos começar';

  @override
  String get loginSubtitle =>
      'Entre para continuar seus estudos e organizar sua rotina.';

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
  String get homeTodayAgendaTitle => 'Agenda de hoje';

  @override
  String get homeNextScheduleEmpty => 'Nenhum compromisso hoje';

  @override
  String get homeNextScheduleAdd => 'Adicionar compromisso';

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
  String get timeUnitHoursSuffix => 'h';

  @override
  String get timeUnitMinutesSuffix => 'min';

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
  String get estimatedHoursGoalHint => 'Duração em minutos';

  @override
  String get createSubjectTotalHoursGoalHint => 'Tempo total em horas';

  @override
  String get goalPagesHint => 'Meta (páginas)';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get confirmButton => 'Confirmar';

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
  String get createSubjectTimeGoalLabel => 'Duração de cada seção';

  @override
  String get createSubjectTotalTimeGoalLabel =>
      'Quanto tempo você quer estudar no total?';

  @override
  String get createSubjectTotalTimeGoalLabelStudying =>
      'Quanto tempo você quer estudar no total?';

  @override
  String get createSubjectTotalTimeGoalLabelExercises =>
      'Quanto tempo você quer se exercitar no total?';

  @override
  String get createSubjectTotalTimeGoalLabelHobbies =>
      'Quanto tempo você quer praticar no total?';

  @override
  String get createSubjectPagesGoalLabel => 'Meta de páginas';

  @override
  String get createSubjectTimeGoalHelp => 'Quantos minutos você quer focar?';

  @override
  String get createSubjectPagesGoalHelp =>
      'Quantas páginas você quer registrar no total?';

  @override
  String get createSubjectRestLabel => 'Duração das pausas';

  @override
  String get createSubjectRestHelp =>
      'O timer sugere uma pausa depois de 30 min de foco.';

  @override
  String get customRestMinutesHint => 'Pausa personalizada (min)';

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
    return '${hours}h $minutes min';
  }

  @override
  String createSubjectPagesValue(int value) {
    return '$value páginas';
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
  String get createSubjectMissingTimeGoal => 'Defina uma meta de foco válida';

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
  String get addNotesPageTooltip => 'Adicionar página';

  @override
  String notesPageCounter(int currentPage, int pageCount) {
    return 'Página $currentPage de $pageCount';
  }

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
  String get editButton => 'Editar';

  @override
  String get nicknameFallback => 'usuário';

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
      'Inicie uma sessão, registre uma leitura ou crie uma meta pela Home para acompanhar sua evolução no Timing.';

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
  String get profileProgressSectionTitle => 'Seu progresso';

  @override
  String get profileAchievementsTitle => 'Conquistas';

  @override
  String get profileSeeHistory => 'Ver histórico';

  @override
  String get profileSeeAll => 'Ver todas';

  @override
  String get profileAchievementFirstUnlocked => '1ª conquista';

  @override
  String get profileAchievementGoalStarted => 'Meta iniciada';

  @override
  String get profileAchievementsStartHint => 'Comece para adquirir conquistas';

  @override
  String get profileAchievementFirstFocus => 'Primeiro foco';

  @override
  String get profileAchievementStudyStarted => 'Estudos iniciados';

  @override
  String get profileAchievementReadingStarted => 'Leitura iniciada';

  @override
  String get profileAchievementLocked => 'Bloqueada';

  @override
  String get periodFiveDays => '5 dias';

  @override
  String get periodWeek => '1 semana';

  @override
  String get periodMonth => '1 mês';

  @override
  String get periodTotal => 'Total';

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
  String get appLanguageSubtitle =>
      'Escolha o idioma usado nos menus, mensagens e textos do app. A alteração é aplicada à interface inteira.';

  @override
  String get automaticLanguageLabel => 'Automático';

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
  String get linkedAccountsSection => 'Login conectado';

  @override
  String get linkedAccountsSubtitle =>
      'Use Google e Apple para acessar esta mesma conta.';

  @override
  String get linkGoogleAccountTitle => 'Associar Google';

  @override
  String get linkGoogleAccountSubtitle => 'Entrar com Google nesta conta';

  @override
  String get linkAppleAccountTitle => 'Associar Apple';

  @override
  String get linkAppleAccountSubtitle => 'Entrar com Apple nesta conta';

  @override
  String get authProviderConnected => 'Conectado';

  @override
  String get linkAuthProviderStarted =>
      'Finalize o login para associar a conta.';

  @override
  String get linkAuthProviderFailure =>
      'Não foi possível iniciar a associação. Verifique o provedor e o vínculo manual no Supabase.';

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
  String get profilePhotoSelectLabel => 'Adicionar foto';

  @override
  String get profilePhotoRemoveLabel => 'Remover foto';

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
      'Cada sessão segue um ciclo de foco: uma contagem regressiva de 30 minutos até sua próxima pausa. Quando chega a zero, ela simplesmente reinicia — é um lembrete, não uma parada obrigatória.';

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
  String get navGroups => 'Grupos';

  @override
  String get navSettings => 'Config';

  @override
  String get myScheduleCardTitle => 'Sua Agenda';

  @override
  String get myScheduleTitle => 'Sua Agenda';

  @override
  String get noScheduleYet => 'Nenhum compromisso ainda';

  @override
  String get noScheduleYetDescription =>
      'Toque no botão abaixo para adicionar\nseu primeiro compromisso';

  @override
  String get addScheduleEntryTitle => 'Adicionar compromisso';

  @override
  String get addScheduleEntryButton => 'Adicionar compromisso';

  @override
  String get scheduleInfoSection => 'Informações';

  @override
  String get scheduleWhenSection => 'Quando?';

  @override
  String get scheduleColorSection => 'Cor do compromisso';

  @override
  String get schedulePreviewSection => 'Prévia';

  @override
  String scheduleDurationLabel(String duration) {
    return 'Duração: $duration';
  }

  @override
  String scheduleDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String scheduleDurationHours(int hours) {
    return '${hours}h';
  }

  @override
  String scheduleDurationHoursMinutes(int hours, int minutes) {
    return '${hours}h $minutes min';
  }

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
  String get phoneLoginTitle => 'Seu número';

  @override
  String get phoneLoginSubtitle =>
      'Digite seu telefone para receber um código de acesso.';

  @override
  String get sendCodeButton => 'Enviar código';

  @override
  String get phoneSecurityNote =>
      'Você pode usar seu número para entrar com segurança.';

  @override
  String get selectCountryTitle => 'Selecione o país';

  @override
  String get searchCountryHint => 'Buscar país';

  @override
  String get otpCodeExpired => 'Código expirado. Reenvie para receber um novo.';

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
  String otpCodeValidFor(String time) {
    return 'Código válido por $time';
  }

  @override
  String get codeResentMessage => 'Código de verificação enviado';

  @override
  String get invalidCodeError => 'Código inválido. Tente novamente.';

  @override
  String get credentialsTitle => 'Crie seu perfil';

  @override
  String get credentialsSubtitle =>
      'Conte um pouco sobre você para personalizar sua experiência.';

  @override
  String get birthDateHint => 'Data de nascimento';

  @override
  String get profileEditableLaterNote => 'Você poderá editar isso depois.';

  @override
  String get finishButton => 'Concluir';

  @override
  String get navProgress => 'Progresso';

  @override
  String get progressTitle => 'Progresso';

  @override
  String get progressSubtitle => 'Tudo o que você já fez';

  @override
  String get progressPeriodDay => 'Dia';

  @override
  String get progressPeriodWeek => 'Semana';

  @override
  String get progressPeriodMonth => 'Mês';

  @override
  String get progressFocusResultLabel => 'Foco neste período';

  @override
  String progressComparisonMore(String value) {
    return '$value a mais que no período anterior';
  }

  @override
  String progressComparisonLess(String value) {
    return '$value a menos que no período anterior';
  }

  @override
  String get progressComparisonSame => 'Igual ao período anterior';

  @override
  String get progressComparisonFirst => 'Seus primeiros dados neste período';

  @override
  String get progressStatExercises => 'Exercícios';

  @override
  String get progressStatLongestGoal => 'Meta mais longa';

  @override
  String get progressStatMainReading => 'Principal leitura';

  @override
  String get progressStatGoalsDone => 'Metas concluídas';

  @override
  String get progressDistributionTitle => 'Por atividade';

  @override
  String homeTodayInline(String focus, int pages, int goals) {
    return 'Hoje: $focus de foco · $pages páginas · $goals metas';
  }

  @override
  String get homePlanDayTitle => 'Planejar meu dia';

  @override
  String get homePlanDaySubtitle => 'Metas diárias e agenda semanal';

  @override
  String get groupsFriendsTitle => 'Amigos';

  @override
  String get groupsFriendsSubtitle => 'Solicitações, convites e seu código';

  @override
  String groupMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membros',
      one: '1 membro',
    );
    return '$_temp0';
  }

  @override
  String get createScheduleEntryButton => 'Criar compromisso';

  @override
  String get scheduleEntryMissingFields =>
      'Preencha título, início e término para continuar';

  @override
  String timerSessionCounter(int current, int total) {
    return 'Foco $current de $total';
  }

  @override
  String get timerExitBackToFocus => 'Voltar ao foco';

  @override
  String get timerExitSaveAndEnd => 'Salvar e encerrar';

  @override
  String get notesSavedNow => 'Salvo agora';

  @override
  String get notesSaving => 'Salvando…';

  @override
  String get dailyGoalsPendingSection => 'Pendentes';

  @override
  String get dailyGoalsCompletedSection => 'Concluídas';

  @override
  String get dailyGoalsEmptyTitle => 'Nenhuma meta para hoje ainda';

  @override
  String get dailyGoalsEmptyDescription =>
      'Escreva uma meta acima ou escolha uma sugestão para começar o dia.';

  @override
  String achievementProgressValue(String current, String total) {
    return '$current de $total';
  }

  @override
  String get categoryEmptyTitle => 'Nada por aqui ainda';

  @override
  String get categoryEmptyDescription =>
      'Crie o primeiro item para começar a registrar seu foco.';

  @override
  String get scheduleEmptyExampleLabel => 'Exemplo';

  @override
  String get progressAchievementsNextTitle => 'Próxima conquista';

  @override
  String get achievementFocusHourTitle => '1 hora de foco';

  @override
  String get achievementSessionsTitle => '5 sessões concluídas';

  @override
  String get achievementStreakTitle => '7 dias seguidos';

  @override
  String get achievementReaderTitle => '100 páginas lidas';

  @override
  String get achievementGoalStartedTitle => 'Primeira meta iniciada';

  @override
  String unitMinutesShort(int value) {
    return '$value min';
  }

  @override
  String unitSessions(int value) {
    return '$value sessões';
  }

  @override
  String unitDays(int value) {
    return '$value dias';
  }

  @override
  String currentUserRankNextStepNamed(String score, String name) {
    return '$score para alcançar $name';
  }

  @override
  String get timerKeepAwakeNote => 'A tela fica ligada durante a sessão';

  @override
  String scheduleWeekLabel(String date) {
    return 'Semana de $date';
  }

  @override
  String get daysSuffix => 'dias';

  @override
  String get createTaskSubtitle =>
      'Configure uma meta diária para acompanhar seu progresso';

  @override
  String get createTaskSequenceTypeLabel => 'Tipo de sequência';

  @override
  String get createTaskSequenceIntenseLabel => 'Intensa';

  @override
  String get createTaskSequenceIntenseDescription =>
      'Não permite falhas. Se você perder um dia, sua sequência será reiniciada.';

  @override
  String get createTaskSequenceCasualLabel => 'Casual';

  @override
  String get createTaskSequenceCasualDescription =>
      'Mais flexível. Dias perdidos não reiniciam sua sequência.';

  @override
  String get targetDaysInfinite => 'Infinito';

  @override
  String get deleteConfirmationDefaultTypeName => 'item';

  @override
  String deleteConfirmationTitle(String typeName) {
    return 'Excluir $typeName?';
  }

  @override
  String deleteConfirmationContent(String itemName) {
    return 'Você está prestes a excluir \"$itemName\". Esta ação não poderá ser desfeita.';
  }

  @override
  String deleteConfirmationHistoryWarning(String typeName) {
    return 'O histórico deste $typeName também será removido.';
  }

  @override
  String homeDaySummaryFocusValue(String focus) {
    return '$focus foco';
  }

  @override
  String homeDaySummaryGoalsValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count metas',
      one: '1 meta',
    );
    return '$_temp0';
  }

  @override
  String get profilePhotoSourceTitle => 'Foto de perfil';

  @override
  String get profilePhotoSourceSubtitle =>
      'Escolha como deseja atualizar sua foto';

  @override
  String get photoCameraLabel => 'Tirar foto';

  @override
  String get photoGalleryLabel => 'Escolher da galeria';

  @override
  String get removePhotoDialogTitle => 'Remover foto?';

  @override
  String get removePhotoDialogContent =>
      'Seu avatar voltará a aparecer no perfil.';

  @override
  String get friendRequestsReceivedTab => 'Solicitações';

  @override
  String get friendRequestsSentTab => 'Convites';

  @override
  String hobbyPracticeMinutes(int minutes) {
    return '$minutes min de prática';
  }

  @override
  String get hobbyViewStatistics => 'Ver estatísticas';

  @override
  String get hobbyViewNotes => 'Ver notas';

  @override
  String get hobbyEdit => 'Editar hobby';

  @override
  String get pinToStart => 'Fixar no início';

  @override
  String get hobbyDelete => 'Excluir hobby';

  @override
  String get deleteActionCannotBeUndone => 'Esta ação não pode ser desfeita.';

  @override
  String get joinGroupTitle => 'Entrar em grupo';

  @override
  String get joinGroupInviteCodeLabel => 'Código de convite';

  @override
  String get joinGroupCodeHint => 'Digite o código';

  @override
  String get joinGroupButton => 'Entrar no grupo';

  @override
  String get joinGroupError => 'Não foi possível entrar nesse grupo.';

  @override
  String get scheduleDayEventsTitle => 'Agenda do dia';

  @override
  String get dailyGoalsNoGoalsYetTitle => 'Nenhuma meta ainda';

  @override
  String get dailyGoalsNoGoalsYetDescription =>
      'Adicione sua primeira meta para organizar o dia e acompanhar suas conquistas.';

  @override
  String get dailyGoalsSuggestionsTitle => 'Sugestões para começar';

  @override
  String get dailyGoalsSuggestionStudy => 'Estudar 30 min';

  @override
  String get dailyGoalsSuggestionRead => 'Ler 10 páginas';

  @override
  String get dailyGoalsSuggestionTrain => 'Treinar';

  @override
  String get goalTypeName => 'meta';

  @override
  String get missedYesterdayDialogTitle => 'Você fez essa meta ontem?';

  @override
  String missedYesterdayDialogContent(String taskName) {
    return 'Você não marcou \"$taskName\" ontem. Se tiver feito, podemos registrar agora.';
  }

  @override
  String get missedYesterdayMissedButton => 'Não fiz';

  @override
  String get missedYesterdayCompletedButton => 'Fiz ontem';

  @override
  String get missedYesterdayMultiTitle => 'Quais você fez ontem?';

  @override
  String get missedYesterdayMultiContent =>
      'Você não marcou algumas metas ontem. Selecione as que você concluiu.';

  @override
  String get missedYesterdayMultiConfirmButton => 'Confirmar';

  @override
  String get scheduleTitleRequiredError => 'Preencha o título para continuar';

  @override
  String get scheduleActiveFromLabel => 'Começa em';

  @override
  String get scheduleActiveUntilLabel => 'Termina em';

  @override
  String get selectDateTitle => 'Selecionar data';

  @override
  String get selectDateHint => 'Escolha um dia no calendário';

  @override
  String get addFriendTitle => 'Adicionar amigo';

  @override
  String get friendCodeNotFound =>
      'Não encontramos nenhum usuário com este código.';

  @override
  String get friendInviteCodeTitle => 'Código de convite';

  @override
  String get friendInviteCodeFieldLabel => 'Digite ou cole o código';

  @override
  String get friendInviteCodeFieldHint => 'Como ABCDE12345';

  @override
  String get pasteButton => 'Colar';

  @override
  String get searchCodeButton => 'Buscar código';

  @override
  String get friendUserFoundTitle => 'Usuário encontrado';

  @override
  String get friendFoundByCode => 'Encontrado pelo código';

  @override
  String get sentLabel => 'Enviado';

  @override
  String get friendHowItWorksTitle => 'Como funciona';

  @override
  String get friendHowItWorksStepOne => 'Peça o código ao seu amigo';

  @override
  String get friendHowItWorksStepTwo => 'Cole o código para encontrar o perfil';

  @override
  String get friendHowItWorksStepThree => 'Envie a solicitação para adicionar';

  @override
  String get myCodeLabel => 'Meu código';

  @override
  String get yourInviteCodeLabel => 'Seu código de convite';

  @override
  String yourFriendsTitle(int count) {
    return 'Seus amigos ($count)';
  }

  @override
  String get seeAllButton => 'Ver todos';

  @override
  String get onlineLabel => 'Online';

  @override
  String get offlineLabel => 'Offline';

  @override
  String get friendsEmptyTitle => 'Você ainda não tem amigos';

  @override
  String get friendsEmptySubtitle =>
      'Busque pessoas acima ou compartilhe seu código de convite.';

  @override
  String get shareCodeButton => 'Compartilhar código';

  @override
  String get codeCopiedMessage => 'Código copiado';

  @override
  String get friendRequestSentMessage => 'Solicitação enviada';

  @override
  String get joinedGroupMessage => 'Você entrou no grupo';

  @override
  String get friendTypeName => 'amigo';

  @override
  String shareInviteCodeMessage(String code) {
    return 'Me adicione no Timing com meu código: $code';
  }

  @override
  String groupInvitesTitle(int count) {
    return 'Convites de grupo ($count)';
  }

  @override
  String groupInvitedBy(String inviter) {
    return '$inviter convidou voc?';
  }

  @override
  String get acceptButton => 'Aceitar';

  @override
  String get declineButton => 'Recusar';

  @override
  String get friendsTitle => 'Amigos';

  @override
  String get friendRequestsReceivedPageTitle => 'Solicitações';

  @override
  String get friendRequestsSentPageTitle => 'Convites';

  @override
  String friendRequestsReceivedSection(int count) {
    return 'Recebidas ($count)';
  }

  @override
  String friendRequestsSentSection(int count) {
    return 'Enviadas ($count)';
  }

  @override
  String get friendMutualFriendsSample => '3 amigos em comum';

  @override
  String get pendingLabel => 'Pendente';

  @override
  String get friendRequestsIncomingEmptyTitle => 'Nenhuma solicitação recebida';

  @override
  String get friendRequestsSentEmptyTitle => 'Nenhum convite enviado';

  @override
  String get friendRequestsIncomingEmptySubtitle =>
      'As solicitações aparecerão aqui.';

  @override
  String get friendRequestsSentEmptySubtitle =>
      'Seus convites enviados aparecerão aqui.';

  @override
  String get friendRequestsSafetyNotice =>
      'Aceite apenas pessoas que você conhece e confia.';

  @override
  String get categoryEmptyStudyingTitle => 'Nenhuma matéria ainda';

  @override
  String get categoryEmptyExercisesTitle => 'Nenhum exercício ainda';

  @override
  String get categoryEmptyReadingTitle => 'Nenhuma leitura ainda';

  @override
  String get categoryEmptyHobbiesTitle => 'Nenhum hobby ainda';

  @override
  String get categoryEmptyStudyingDescription =>
      'Adicione sua primeira matéria para organizar seus estudos e registrar seu foco.';

  @override
  String get categoryEmptyExercisesDescription =>
      'Adicione seu primeiro exercício para acompanhar treinos, sessões e evolução.';

  @override
  String get categoryEmptyReadingDescription =>
      'Adicione sua primeira leitura para registrar páginas, tempo e progresso.';

  @override
  String get categoryEmptyHobbiesDescription =>
      'Adicione seu primeiro hobby para registrar prática e manter constância.';

  @override
  String get categorySuggestionStudyingOne => 'Matemática';

  @override
  String get categorySuggestionStudyingTwo => 'Inglês';

  @override
  String get categorySuggestionStudyingThree => 'Redação';

  @override
  String get categorySuggestionExercisesOne => 'Corrida';

  @override
  String get categorySuggestionExercisesTwo => 'Musculação';

  @override
  String get categorySuggestionExercisesThree => 'Alongamento';

  @override
  String get categorySuggestionReadingOne => 'Romance';

  @override
  String get categorySuggestionReadingTwo => 'Técnico';

  @override
  String get categorySuggestionReadingThree => 'Artigos';

  @override
  String get categorySuggestionHobbiesOne => 'Violão';

  @override
  String get categorySuggestionHobbiesTwo => 'Desenho';

  @override
  String get categorySuggestionHobbiesThree => 'Culinária';

  @override
  String get pagesAbbreviation => 'págs';

  @override
  String get loginSecurityNote => 'Seus dados estão protegidos e seguros.';

  @override
  String get nextBreakDurationLabel => 'Duração da próxima pausa';

  @override
  String timerReadingExitContent(String duration, String subjectName) {
    return 'Você leu por $duration. Informe quantas páginas foram lidas em $subjectName.';
  }

  @override
  String get appleSignInIncompleteMessage =>
      'Entrar com Apple ainda não está completo.';

  @override
  String get activityTypeLabel => 'Frequência da atividade';

  @override
  String get activityTypeDailyLabel => 'Diária';

  @override
  String get activityTypeDailyDescription =>
      'Use seções de foco com pausas e defina quantas sessões quer cumprir por dia.';

  @override
  String get activityTypeDailyDescriptionStudying =>
      'Use seções de estudo com pausas e defina quantas sessões quer cumprir por dia.';

  @override
  String get activityTypeDailyDescriptionExercises =>
      'Use seções de exercício com pausas e defina quantas sessões quer cumprir por dia.';

  @override
  String get activityTypeDailyDescriptionHobbies =>
      'Use seções de prática com pausas e defina quantas sessões quer cumprir por dia.';

  @override
  String get activityTypePermanentLabel => 'Permanente';

  @override
  String get activityTypePermanentDescription =>
      'Defina o tempo total de estudo. A atividade permanece ativa até você concluir tudo.';

  @override
  String get activityTypePermanentDescriptionStudying =>
      'Defina o tempo total de estudo. A atividade permanece ativa até você concluir tudo.';

  @override
  String get activityTypePermanentDescriptionExercises =>
      'Defina o tempo total de exercício. A atividade permanece ativa até você concluir tudo.';

  @override
  String get activityTypePermanentDescriptionHobbies =>
      'Defina o tempo total de prática. A atividade permanece ativa até você concluir tudo.';

  @override
  String get pagesSuffix => 'páginas';

  @override
  String get updatedSuccessfullyMessage => 'Atualizado com sucesso';

  @override
  String get focusSessionCountLabel => 'Quantidade de sessões';

  @override
  String get subjectSectionDurationDescription =>
      'Quanto tempo dura cada seção de foco antes de uma pausa ou conclusão.';

  @override
  String get subjectSessionCountDescription =>
      'Quantas seções de foco você quer cumprir por dia.';

  @override
  String get subjectRestDurationDescription =>
      'Quanto tempo dura cada pausa entre as seções de foco.';

  @override
  String get groupEditingComingSoon => 'Edição de grupo em breve.';

  @override
  String get leftGroupMessage => 'Você saiu do grupo.';

  @override
  String get groupImageSourceTitle => 'Enviar imagem';

  @override
  String get groupImageSourceSubtitle => 'Escolha como deseja enviar a imagem';

  @override
  String get deleteButton => 'Excluir';

  @override
  String get manageMembersTitle => 'Gerenciar membros';

  @override
  String get groupLeaderLabel => 'Líder';

  @override
  String get groupLeaderRoleLabel => 'Líder do grupo';

  @override
  String get groupMemberRoleLabel => 'Membro';

  @override
  String get groupMembersLabel => 'Membros';

  @override
  String get groupActionsLabel => 'Ações do grupo';

  @override
  String get goalsTabLabel => 'Dados';

  @override
  String get chatTabLabel => 'Chat';

  @override
  String get groupGoalTitle => 'Meta do grupo';

  @override
  String get groupMainRuleTitle => 'Regra principal';

  @override
  String get groupNextMilestoneTitle => 'Próximo marco';

  @override
  String groupMembersProgressValue(int current, int total) {
    return '$current/$total membros';
  }

  @override
  String get groupNextMilestoneDescription =>
      'para liberar o selo \"Foco Total\"';

  @override
  String get groupActivityLabel => 'Atividade do grupo';

  @override
  String groupActivityReachedGoal(int reached, int total) {
    return '$reached/$total atingiram a meta';
  }

  @override
  String get groupActivityFocusDataLabel => 'Foco';

  @override
  String get groupActivityPauseDataLabel => 'Pausa';

  @override
  String get groupActivitySessionsDataLabel => 'Sessões';

  @override
  String get groupGoalTargetDataLabel => 'Tempo alvo';

  @override
  String get groupGoalCurrentDayDataLabel => 'Dia da meta';

  @override
  String get groupActivityPendingUsersTitle => 'Usuários pendentes';

  @override
  String get groupActivityAllCompletedToday =>
      'Todos concluíram a atividade hoje.';

  @override
  String get groupNoImagesTitle => 'Nenhuma imagem ainda';

  @override
  String get groupNoImagesDescription => 'Envie a primeira imagem do grupo.';

  @override
  String get groupSendImageButton => 'Enviar imagem';

  @override
  String get groupSendingImage => 'Enviando imagem...';

  @override
  String get editGroupLabel => 'Editar grupo';

  @override
  String get leaveGroupLabel => 'Sair do grupo';

  @override
  String groupDescription(String metric) {
    return 'Ranking por $metric. Continue evoluindo com o grupo.';
  }

  @override
  String groupsFriendsSubtitleWithCount(int groupCount) {
    return 'Solicitações, convites e $groupCount em grupos';
  }

  @override
  String groupGoalKeepMetric(String metric) {
    return 'Manter $metric todos os dias';
  }

  @override
  String groupGoalDescription(String metric) {
    return 'Cada participante registra $metric para manter a sequência do grupo ativa.';
  }

  @override
  String groupRuleDescription(String metric) {
    return 'Registre pelo menos uma entrada de $metric por dia para fortalecer a sequência do grupo.';
  }

  @override
  String get joinWithCodeButton => 'Tenho um código de convite';

  @override
  String get groupsBenefitsHeader => 'Em um grupo você pode:';

  @override
  String groupParticipantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participantes',
      one: '1 participante',
    );
    return '$_temp0';
  }

  @override
  String groupMembersCompletedToday(int completed, int total) {
    return '$completed/$total membros concluíram hoje';
  }

  @override
  String get addMemberButton => 'Adicionar membro';

  @override
  String get groupCollectiveProgressTitle => 'Progresso coletivo';

  @override
  String get dailyLabel => 'Diária';

  @override
  String get completedLabel => 'Concluído';

  @override
  String groupActivityCompletedCount(int completed, int total) {
    return '$completed de $total concluíram';
  }

  @override
  String groupMissingParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltam $count participantes para completar a meta',
      one: 'Falta 1 participante para completar a meta',
      zero: 'Todos completaram a meta',
    );
    return '$_temp0';
  }

  @override
  String groupParticipantsDataTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Participantes ($count)',
      one: 'Participantes (1)',
    );
    return '$_temp0';
  }

  @override
  String groupCompletedMembersTitle(int count) {
    return 'Concluíram ($count)';
  }

  @override
  String groupPendingMembersTitle(int count) {
    return 'Pendentes ($count)';
  }

  @override
  String get groupNoCompletedMembersTitle => 'Ninguém concluiu ainda';

  @override
  String get groupNoCompletedMembersSubtitle =>
      'Seja o primeiro a completar a meta!';

  @override
  String get groupStatisticsTitle => 'Estatísticas do grupo';

  @override
  String get groupStreakStatLabel => 'Sequência do grupo';

  @override
  String get groupTodayTotalStatLabel => 'Tempo total hoje';

  @override
  String get groupPeriodTotalStatLabel => 'Total no período';

  @override
  String get groupCompletedSessionsStatLabel => 'Sessões concluídas';

  @override
  String get groupParticipantsStatLabel => 'Participante no grupo';

  @override
  String get currentUserRankCompleteFirstGoal =>
      'Conclua sua primeira meta para entrar no ranking.';

  @override
  String get currentUserRankTiedLead => 'Empate na liderança.';

  @override
  String get currentUserRankTiedFirstLabel => 'Empate em 1º';

  @override
  String rankLabel(int rank) {
    return '$rankº';
  }

  @override
  String get homeScheduleRoutineSubtitle =>
      'Próximos horários e rotina semanal';

  @override
  String get homeNextCommitmentTitle => 'Próximo compromisso';

  @override
  String get todayLabel => 'Hoje';

  @override
  String get statisticsTitle => 'Estatísticas';

  @override
  String get studiedTimeLabel => 'Tempo estudado';

  @override
  String get readingTimeLabel => 'Tempo lido';

  @override
  String get totalPagesReadLabel => 'Total de páginas';

  @override
  String get pagesReadTodayLabel => 'Páginas hoje';

  @override
  String get goalLabel => 'Meta';

  @override
  String get sessionsLabel => 'Sessões';

  @override
  String get restLabel => 'Descanso';

  @override
  String get comparativesTitle => 'Comparativos';

  @override
  String get overviewTitle => 'Visão geral';

  @override
  String get studiedUnit => 'estudados';

  @override
  String get readPagesUnit => 'lidas';

  @override
  String get versusLastMonth => 'vs mês passado';

  @override
  String get versusLastWeek => 'vs semana passada';

  @override
  String get noPreviousPeriodComparison => 'Sem período anterior para comparar';

  @override
  String get noTimeLabel => 'Sem horário';

  @override
  String untilTimeLabel(String time) {
    return 'Até $time';
  }

  @override
  String get achievementsUnlockedSuffix => ' /50 desbloqueadas';

  @override
  String get currentLevelLabel => 'Nível atual';

  @override
  String get allAchievementsUnlockedLabel => 'Tudo desbloqueado';

  @override
  String get nextUnlockLabel => 'Próxima conquista';

  @override
  String get allAchievementsUnlockedDescription => 'Você desbloqueou tudo.';

  @override
  String xpToGo(int xp) {
    return 'Faltam $xp XP';
  }

  @override
  String levelLabel(int level) {
    return 'Nível $level';
  }

  @override
  String get allFilterLabel => 'Todas';

  @override
  String get unlockedFilterLabel => 'Desbloqueadas';

  @override
  String get lockedFilterLabel => 'Bloqueadas';

  @override
  String get selectCategoryTooltip => 'Selecionar categoria';

  @override
  String get allCategoriesLabel => 'Todas as categorias';

  @override
  String get byCategoryLabel => 'Por categoria';

  @override
  String get allLevelsTitle => 'Todos os níveis';

  @override
  String get allLevelsDescription =>
      'Desbloqueie conquistas para subir de nível.';

  @override
  String levelPlusLabel(int level) {
    return 'Nível $level+';
  }

  @override
  String get currentLabel => 'Atual';

  @override
  String rankTierLearner(String tier) {
    return 'Aprendiz $tier';
  }

  @override
  String get achievementCategoryFocus => 'Foco';

  @override
  String get achievementCategoryStudy => 'Estudo';

  @override
  String get achievementCategoryReading => 'Leitura';

  @override
  String get achievementCategoryGoals => 'Metas';

  @override
  String get achievementCategoryLifestyle => 'Estilo de vida';

  @override
  String get achievement1Title => 'Primeiro foco';

  @override
  String get achievement1Description => 'Conclua sua primeira sessão de foco';

  @override
  String get achievement2Title => 'Começo de 25 min';

  @override
  String get achievement2Description => 'Foque por 25 minutos';

  @override
  String get achievement3Title => '1 hora de foco';

  @override
  String get achievement3Description => 'Foque por 1 hora';

  @override
  String get achievement4Title => 'Foco profundo';

  @override
  String get achievement4Description => 'Alcance 2 horas de foco';

  @override
  String get achievement5Title => 'Zero distrações';

  @override
  String get achievement5Description => 'Conclua 3 sessões de foco';

  @override
  String get achievement6Title => 'Maratona de foco';

  @override
  String get achievement6Description => 'Alcance 10 horas de foco';

  @override
  String get achievement7Title => 'Madrugador';

  @override
  String get achievement7Description => 'Registre foco em 5 dias';

  @override
  String get achievement8Title => 'Coruja da noite';

  @override
  String get achievement8Description => 'Conclua 10 sessões de foco';

  @override
  String get achievement9Title => 'Sequência de foco';

  @override
  String get achievement9Description => 'Registre foco em 7 dias';

  @override
  String get achievement10Title => 'Mestre do foco';

  @override
  String get achievement10Description => 'Alcance 25 horas de foco';

  @override
  String get achievement11Title => 'Estudo iniciado';

  @override
  String get achievement11Description => 'Crie seu primeiro registro de estudo';

  @override
  String get achievement12Title => '3 sessões';

  @override
  String get achievement12Description => 'Conclua 3 sessões';

  @override
  String get achievement13Title => '5 sessões';

  @override
  String get achievement13Description => 'Conclua 5 sessões';

  @override
  String get achievement14Title => '10 sessões';

  @override
  String get achievement14Description => 'Conclua 10 sessões';

  @override
  String get achievement15Title => 'Explorador de matérias';

  @override
  String get achievement15Description => 'Estude pelo menos uma matéria';

  @override
  String get achievement16Title => 'Herói da revisão';

  @override
  String get achievement16Description => 'Alcance 5 horas estudando';

  @override
  String get achievement17Title => 'Quiz finalizado';

  @override
  String get achievement17Description => 'Conclua 15 sessões';

  @override
  String get achievement18Title => 'Planejador de estudos';

  @override
  String get achievement18Description => 'Crie uma meta de foco';

  @override
  String get achievement19Title => 'Pronto para prova';

  @override
  String get achievement19Description => 'Alcance 20 horas estudando';

  @override
  String get achievement20Title => 'Modo estudante';

  @override
  String get achievement20Description => 'Alcance 50 horas estudando';

  @override
  String get achievement21Title => 'Primeira página';

  @override
  String get achievement21Description => 'Leia sua primeira página';

  @override
  String get achievement22Title => '10 páginas';

  @override
  String get achievement22Description => 'Leia 10 páginas';

  @override
  String get achievement23Title => '25 páginas';

  @override
  String get achievement23Description => 'Leia 25 páginas';

  @override
  String get achievement24Title => '50 páginas';

  @override
  String get achievement24Description => 'Leia 50 páginas';

  @override
  String get achievement25Title => '100 páginas';

  @override
  String get achievement25Description => 'Leia 100 páginas';

  @override
  String get achievement26Title => 'Capítulo completo';

  @override
  String get achievement26Description => 'Leia 150 páginas';

  @override
  String get achievement27Title => 'Leitor de fim de semana';

  @override
  String get achievement27Description => 'Leia 250 páginas';

  @override
  String get achievement28Title => 'Leitor diário';

  @override
  String get achievement28Description => 'Leia 300 páginas';

  @override
  String get achievement29Title => 'Leitor dedicado';

  @override
  String get achievement29Description => 'Leia 500 páginas';

  @override
  String get achievement30Title => 'Lenda da biblioteca';

  @override
  String get achievement30Description => 'Leia 1000 páginas';

  @override
  String get achievement31Title => 'Primeira meta';

  @override
  String get achievement31Description => 'Crie sua primeira meta';

  @override
  String get achievement32Title => 'Meta vencida';

  @override
  String get achievement32Description => 'Conclua uma meta';

  @override
  String get achievement33Title => 'Todas as metas feitas';

  @override
  String get achievement33Description => 'Finalize todas as metas hoje';

  @override
  String get achievement34Title => 'Rotina da manhã';

  @override
  String get achievement34Description => 'Conclua metas em 3 dias';

  @override
  String get achievement35Title => 'Dia equilibrado';

  @override
  String get achievement35Description => 'Conclua metas em 5 dias';

  @override
  String get achievement36Title => 'Construtor de hábito';

  @override
  String get achievement36Description => 'Conclua metas em 10 dias';

  @override
  String get achievement37Title => 'Dia perfeito';

  @override
  String get achievement37Description => 'Conclua metas em 15 dias';

  @override
  String get achievement38Title => 'Retomada';

  @override
  String get achievement38Description => 'Conclua metas em 20 dias';

  @override
  String get achievement39Title => 'Estrela da constância';

  @override
  String get achievement39Description => 'Conclua metas em 30 dias';

  @override
  String get achievement40Title => 'Imparável';

  @override
  String get achievement40Description => 'Conclua metas em 50 dias';

  @override
  String get achievement41Title => 'Primeiro grupo';

  @override
  String get achievement41Description => 'Entre em um grupo de estudos';

  @override
  String get achievement42Title => 'Jogador em equipe';

  @override
  String get achievement42Description => 'Compita com amigos';

  @override
  String get achievement43Title => 'Amigo prestativo';

  @override
  String get achievement43Description => 'Ajude um amigo a manter constância';

  @override
  String get achievement44Title => 'Vencedor de desafio';

  @override
  String get achievement44Description => 'Vença um desafio';

  @override
  String get achievement45Title => 'Exercício iniciado';

  @override
  String get achievement45Description => 'Registre foco em exercício';

  @override
  String get achievement46Title => 'Treino de 30 min';

  @override
  String get achievement46Description => 'Exercite-se por 30 minutos';

  @override
  String get achievement47Title => 'Hora do hobby';

  @override
  String get achievement47Description => 'Registre foco em hobby';

  @override
  String get achievement48Title => 'Faísca criativa';

  @override
  String get achievement48Description => 'Alcance 30 minutos em hobbies';

  @override
  String get achievement49Title => 'Guerreiro do fim de semana';

  @override
  String get achievement49Description => 'Alcance 2 horas se exercitando';

  @override
  String get achievement50Title => 'Caçador de conquistas';

  @override
  String get achievement50Description => 'Desbloqueie 25 conquistas';

  @override
  String get achievementUnlockedDialogTitle => 'Conquista desbloqueada!';

  @override
  String get achievementUnlockedDialogMessage =>
      'Continue assim, seu progresso importa!';

  @override
  String get achievementLockedDialogTitle => 'Conquista bloqueada';

  @override
  String get achievementLockedDialogMessage =>
      'Continue avançando para desbloquear esta conquista.';

  @override
  String get achievementUnlockedNotificationTitle => 'Conquista desbloqueada';

  @override
  String get rankTierPaper => 'Papel';

  @override
  String get rankTierWood => 'Madeira';

  @override
  String get rankTierStone => 'Pedra';

  @override
  String get rankTierCopper => 'Cobre';

  @override
  String get rankTierBronze => 'Bronze';

  @override
  String get rankTierIron => 'Ferro';

  @override
  String get rankTierSilver => 'Prata';

  @override
  String get rankTierGold => 'Ouro';

  @override
  String get rankTierPlatinum => 'Platina';

  @override
  String get rankTierAmethyst => 'Ametista';

  @override
  String get rankTierEmerald => 'Esmeralda';

  @override
  String get rankTierDiamond => 'Diamante';

  @override
  String get rankTierObsidian => 'Obsidiana';

  @override
  String get rankTierAdamantium => 'Adamantium';

  @override
  String get rankTierMithril => 'Mithril';

  @override
  String get concentrationModeTitle => 'Modo de concentração';

  @override
  String get concentrationModeSubtitle =>
      'Escolha quais sessões bloqueiam a saída do app.';

  @override
  String get concentrationStudyTitle => 'Estudo';

  @override
  String get concentrationStudySubtitle => 'Foco total nos seus estudos.';

  @override
  String get concentrationExercisesTitle => 'Exercícios';

  @override
  String get concentrationExercisesSubtitle => 'Concentre-se nos seus treinos.';

  @override
  String get concentrationReadingTitle => 'Leitura';

  @override
  String get concentrationReadingSubtitle => 'Mergulhe nas suas leituras.';

  @override
  String get concentrationHobbiesTitle => 'Hobbies';

  @override
  String get concentrationHobbiesSubtitle => 'Aproveite seus hobbies com foco.';

  @override
  String get createGroupDescriptionLabel => 'Descrição';

  @override
  String get createGroupDescriptionHint =>
      'Descreva o grupo e qual é o objetivo dele.';

  @override
  String get createGroupThemeMetricDescription =>
      'Este tema define a métrica do ranking.';

  @override
  String get createGroupActivityTypeDescription =>
      'Cada integrante recebe uma cópia para acompanhar.';

  @override
  String get createGroupActivityNameLabel => 'Nome da atividade';

  @override
  String get createGroupActivityNameHint => 'Ex: Cálculo I';

  @override
  String get createGroupGoalTypeLabel => 'Tipo de meta';

  @override
  String get createGroupGoalTypeTotal => 'Total';

  @override
  String get createGroupGoalTypeDaily => 'Diária';

  @override
  String get createGroupDaysGoalLabel => 'Meta de dias';

  @override
  String get createGroupPagesGoalLabel => 'Meta de páginas';

  @override
  String get createGroupTimeGoalMinutesLabel => 'Meta de tempo (min)';

  @override
  String get createGroupSummaryTitle => 'Resumo do grupo';

  @override
  String get createGroupActivitySummaryLabel => 'Atividade';

  @override
  String get createGroupGuestsLabel => 'Convidados';

  @override
  String get timerTotalTodayLabel => 'Total hoje';

  @override
  String get timerEndActionLabel => 'Encerrar';

  @override
  String get createGroupActivityStepSubtitle =>
      'Escolha a atividade que todos do grupo vão fazer.';

  @override
  String get createGroupFriendsStepSubtitle =>
      'Convide pelo menos 1 amigo para participar.';

  @override
  String get createGroupSummaryStepSubtitle =>
      'Revise os dados antes de criar.';

  @override
  String get createGroupStepInformation => 'Informações';

  @override
  String get createGroupStepActivity => 'Atividade';

  @override
  String get createGroupStepFriends => 'Amigos';

  @override
  String get createGroupStepSummary => 'Resumo';

  @override
  String get createGroupDaysGoalHint => 'Ex: 30';

  @override
  String get createGroupPagesGoalHint => 'Ex: 10';

  @override
  String get createGroupMinutesGoalHint => 'Ex: 30';

  @override
  String get createGroupAddFriendsPromptTitle => 'Não encontrou alguém?';

  @override
  String get createGroupAddFriendsPromptDescription =>
      'Adicione mais amigos para poder convidar.';

  @override
  String get createGroupContinueButton => 'Continuar';

  @override
  String get createGroupActivitySummaryDaily => 'Meta diária';

  @override
  String createGroupActivitySummaryGoalDays(String days) {
    return 'Meta • $days dias';
  }

  @override
  String createGroupActivitySummaryReading(String pages) {
    return 'Leitura • $pages páginas';
  }

  @override
  String createGroupActivitySummaryTime(String category, String minutes) {
    return '$category • $minutes min';
  }

  @override
  String get createGroupActivityRequiredError =>
      'Escolha uma atividade para o grupo.';

  @override
  String get createGroupActivityNameRequiredError =>
      'Dê um nome para a atividade.';

  @override
  String get createGroupActivityGoalInvalidError => 'Defina uma meta válida.';

  @override
  String get createGroupActivityMissingError => 'Defina a atividade do grupo.';

  @override
  String get timerBackTooltip => 'Voltar';

  @override
  String get timerRestMessageTitle => 'Descanse um pouco';

  @override
  String get timerFocusLabel => 'Foco';

  @override
  String get timerReadingLabel => 'Leitura';

  @override
  String get timerPauseLabel => 'Pausa';

  @override
  String get timerReadingTimeLabel => 'tempo de leitura';

  @override
  String timerTotalOfLabel(String duration) {
    return 'de $duration';
  }

  @override
  String get timerCurrentPagesLabel => 'Páginas atuais';

  @override
  String get timerNotesLabel => 'Notas';

  @override
  String get concentrationModeSheetDescription =>
      'Quando ativado, o app ajuda você a se manter concentrado durante a atividade até pausar ou finalizar.';

  @override
  String get timerFocusLockWarning =>
      'Modo de concentração ativo. Termine ou pause a sessão para sair.';

  @override
  String timerProgressSemanticLabel(int percent) {
    return 'Progresso: $percent%';
  }

  @override
  String homeStreakLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias seguidos',
      one: '$count dia seguido',
    );
    return '$_temp0';
  }

  @override
  String homeCategoryEmptyValue(String item) {
    return 'Adicione $item para começar';
  }

  @override
  String get groupInvitesNoFriendsTitle => 'Nenhum amigo disponível';

  @override
  String get groupInvitesNoFriendsDescription =>
      'Adicione amigos antes de convidar mais pessoas para este grupo.';

  @override
  String get groupInvitationsReceivedEmptyTitle => 'Nenhum convite recebido';

  @override
  String get groupInvitationsReceivedEmptyDescription =>
      'Quando alguém convidar você para um grupo, aparece aqui.';

  @override
  String get groupInvitationsSentEmptyTitle => 'Nenhum convite enviado';

  @override
  String get groupInvitationsSentEmptyDescription =>
      'Os convites que você enviar para alguém entrar em um grupo aparecem aqui.';

  @override
  String get swipeHintDismissLabel => 'Entendi';

  @override
  String get dailyGoalSwipeHintTitle => 'Gestos da meta';

  @override
  String get dailyGoalSwipeHintMessage =>
      'Arraste uma meta para editar ou apagar. Metas de grupo podem ter algumas ações bloqueadas.';

  @override
  String get activitySwipeHintTitle => 'Gestos da atividade';

  @override
  String get activitySwipeHintMessage =>
      'Arraste uma atividade para ver notas, dados, editar ou apagar. Itens de grupo podem ter algumas ações bloqueadas.';

  @override
  String get groupGoalEditBlockedMessage =>
      'Esta meta é de um grupo. Edite pelo grupo para alterar.';

  @override
  String get groupGoalDeleteBlockedMessage =>
      'Esta meta é de um grupo. Saia do grupo para removê-la.';

  @override
  String get groupActivityEditBlockedMessage =>
      'Esta atividade é de um grupo. Edite pelo grupo para alterar.';

  @override
  String get groupActivityDeleteBlockedMessage =>
      'Esta atividade é de um grupo. Saia do grupo para removê-la.';

  @override
  String get groupUpdatedSuccess => 'Grupo atualizado com sucesso';

  @override
  String get groupInviteCanceledMessage => 'Convite cancelado.';

  @override
  String get groupInviteSentMessage => 'Convite enviado.';

  @override
  String get timerReadingReminderBody =>
      'Mais 30 minutos de leitura concluídos.';

  @override
  String get timerHobbyFinishedBody => 'Prática de hobby concluída.';

  @override
  String get timerFocusFinishedBody =>
      'Intervalo de foco concluído. O timer continua.';

  @override
  String get timerRestFinishedBody => 'Nova sessão iniciada.';

  @override
  String get timerSessionFinishedBody => 'Atividade concluída.';

  @override
  String get timerBackgroundSuffix => 'App em segundo plano';

  @override
  String get timerBreakStatLabel => 'Pausa';

  @override
  String get timerSessionEndedTitle => 'Sessão encerrada';

  @override
  String timerSessionEndedMessage(String subjectName) {
    return 'Seu foco em $subjectName foi salvo com sucesso.';
  }

  @override
  String get createSubjectPauseDurationHint => 'Duração da pausa';

  @override
  String get groupInvitationsTitle => 'Convites';

  @override
  String groupInvitationFrom(String inviter) {
    return 'Convite de $inviter';
  }

  @override
  String get groupsLoadErrorTitle => 'Não foi possível carregar os grupos';

  @override
  String get groupsLoadErrorDescription =>
      'A conexão demorou mais do que o esperado. Seus grupos podem existir, mas não conseguimos buscar agora.';

  @override
  String get personalInformationTitle => 'Informações pessoais';

  @override
  String get editGroupInfoSection => 'Informações do grupo';

  @override
  String get createGroupFocusGoalLabel => 'Meta de foco';

  @override
  String get connectedAccountsSection => 'Contas conectadas';

  @override
  String get contactSection => 'Contato';

  @override
  String get receivedTab => 'Recebidos';

  @override
  String invitedPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas convidadas',
      one: '1 pessoa convidada',
    );
    return '$_temp0';
  }

  @override
  String get inviteMembersTitle => 'Convidar membros';

  @override
  String get invitedLabel => 'Convidado';

  @override
  String get selectButton => 'Selecionar';

  @override
  String get cancelInviteConfirmTitle => 'Cancelar convite?';

  @override
  String get inviteFriendConfirmTitle => 'Convidar amigo?';

  @override
  String cancelInviteConfirmMessage(String friendName) {
    return 'Deseja cancelar o convite enviado para $friendName?';
  }

  @override
  String inviteFriendConfirmMessage(String friendName, String groupName) {
    return 'Deseja convidar $friendName para $groupName?';
  }

  @override
  String get cancelInviteButton => 'Cancelar convite';

  @override
  String get inviteButton => 'Convidar';

  @override
  String get retryButton => 'Tentar novamente';

  @override
  String get timerSessionEndedConfirm => 'Tudo certo';
}
