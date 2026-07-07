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
  String get homeGreetingDefault => 'Vamos Começar';

  @override
  String homeGreetingWithName(String userName) {
    return 'Vamos Começar, $userName';
  }

  @override
  String get homeSubtitle => 'O que vamos fazer hoje?';

  @override
  String get homeTasksSection => 'Metas diárias';

  @override
  String get homeCategoriesSection => 'Seu tempo';

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
  String get targetDaysHint => 'Alvo personalizado (dias)';

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
  String get categoryStudying => 'Estudando';

  @override
  String get categoryExercises => 'Exercícios';

  @override
  String get categoryReading => 'Lendo';

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
  String get musicSuggestionLabel => 'Sugestão de música';

  @override
  String get musicSuggestionHint => 'ex.: Lo-fi beats';

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
  String timerMusicSuggestion(String name) {
    return 'Sugestão: $name';
  }

  @override
  String get timerNotificationRunning => 'Sessão de foco em andamento';

  @override
  String get timerNotificationResting => 'Descansando — volta já';

  @override
  String get timerNotificationPaused => 'Pausado';

  @override
  String get profileTitle => 'Seu Perfil';

  @override
  String get profileSubtitleDefault => 'Conquistas';

  @override
  String profileSubtitleWithName(String userName) {
    return 'Mandou bem, $userName';
  }

  @override
  String get statHoursStudied => 'Horas estudadas';

  @override
  String get statTopSubjectFallback => '—';

  @override
  String get statTopSubject => 'Matéria principal';

  @override
  String get statHoursExercised => 'Horas de exercício';

  @override
  String get statHoursRead => 'Horas lidas';

  @override
  String get mostReadThemes => 'Temas mais lidos';

  @override
  String get noReadingYet => 'Leia algo para ver seus temas favoritos aqui.';

  @override
  String get groupsTitle => 'Grupos';

  @override
  String get noGroupSelected => 'Nenhum grupo selecionado ainda.';

  @override
  String get newGroupChip => 'Novo grupo';

  @override
  String get periodToday => 'Hoje';

  @override
  String get periodThisWeek => 'Esta semana';

  @override
  String get periodThisMonth => 'Este mês';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get myProfileFallback => 'Meu Perfil';

  @override
  String get preferencesSection => 'Preferências';

  @override
  String get darkModeLabel => 'Modo escuro';

  @override
  String get notificationsLabel => 'Notificações';

  @override
  String get language => 'Idioma';

  @override
  String get supportSection => 'Suporte';

  @override
  String get faqLabel => 'Perguntas frequentes';

  @override
  String get aboutLabel => 'Sobre';

  @override
  String appVersionLabel(String appTitle, String appVersion) {
    return '$appTitle v$appVersion';
  }

  @override
  String get accountSection => 'Conta';

  @override
  String get logOutLabel => 'Sair';

  @override
  String get logOutDialogTitle => 'Sair';

  @override
  String get logOutDialogContent =>
      'Isso apaga seu perfil local deste dispositivo. Você pode configurá-lo novamente quando quiser.';

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
      'Os grupos mostram um placar com as horas estudadas por todo mundo. Alterne entre Hoje, Esta Semana e Este Mês para ver quem estudou mais naquele período.';

  @override
  String get faqQ5 => 'Posso mudar o tema de cores do app?';

  @override
  String get faqA5 =>
      'Sim, vá em Configurações > Meu Perfil e escolha qualquer cor de tema. Todo gradiente, botão e destaque no app se atualiza pra combinar, incluindo o modo escuro.';

  @override
  String get createGroupTitle => 'Criar Grupo';

  @override
  String get groupNameHint => 'Nome do grupo';

  @override
  String get groupThemeLabel => 'Tema';

  @override
  String get inviteFriendsLabel => 'Convidar amigos';

  @override
  String get createGroupButton => 'Criar Grupo';

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
  String get noScheduleYet => 'Nenhum horário ainda — toque para adicionar';

  @override
  String get addScheduleEntryTitle => 'Adicionar Horário';

  @override
  String get addScheduleEntryButton => 'Adicionar Horário';

  @override
  String get scheduleTitleHint => 'Título';

  @override
  String get startTimeLabel => 'Hora de início';

  @override
  String get endTimeOptionalLabel => 'Hora de fim (opcional)';

  @override
  String get incompleteScheduleEntryError =>
      'Cadastro incompleto — preencha o título e um horário de início válido.';

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
