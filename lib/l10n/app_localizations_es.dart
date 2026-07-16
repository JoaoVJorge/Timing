// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'HelpOut';

  @override
  String get genericErrorMessage =>
      'Algo salió mal. Inténtalo de nuevo más tarde.';

  @override
  String get loginHeadline => 'Empecemos';

  @override
  String get loginSubtitle =>
      'Inicia sesión para continuar tus estudios y organizar tu rutina.';

  @override
  String get loginNameHint => 'Tu nombre';

  @override
  String get loginButton => 'Empecemos';

  @override
  String get homeGreetingDefault => 'Hola';

  @override
  String homeGreetingWithName(String userName) {
    return 'Hola, $userName';
  }

  @override
  String get homeSubtitle => '¿Qué haremos hoy?';

  @override
  String homeSubtitleFocusedToday(String duration) {
    return 'Ya te enfocaste $duration hoy';
  }

  @override
  String homeSubtitleNextSchedule(String title, String time) {
    return 'Agenda: $title a las $time';
  }

  @override
  String get homeSubtitleStart => 'Comienza tu primera sesión de enfoque';

  @override
  String get homeTasksSection => 'Metas diarias';

  @override
  String get homeCategoriesSection => 'Actividades';

  @override
  String get homeActionContinueEyebrow => 'Continuar ahora';

  @override
  String get homeActionContinueButton => 'Continuar';

  @override
  String get homeActionStartEyebrow => 'Comenzar enfoque';

  @override
  String get homeActionStartButton => 'Comenzar';

  @override
  String get homeActionSuggestedMeta => 'Tu materia con más tiempo';

  @override
  String get homeActionCreateBody =>
      'Crea tu primera materia para iniciar una sesión de enfoque.';

  @override
  String get homeActionCreateButton => 'Crear materia';

  @override
  String get homeSummaryTitle => 'Resumen de hoy';

  @override
  String get homeSummaryFocus => 'Enfoque';

  @override
  String get homeSummaryGoals => 'Metas';

  @override
  String get homeSummaryPages => 'Páginas';

  @override
  String get homeSummarySessions => 'Sesiones';

  @override
  String homeGoalsProgress(int done, int total) {
    return '$done de $total hechas';
  }

  @override
  String get homeCategoryEmpty => 'Nada aún';

  @override
  String get homeNextScheduleTitle => 'Agenda';

  @override
  String get homeNextScheduleEmpty => 'Sin horario hoy';

  @override
  String get homeNextScheduleAdd => 'Agregar horario';

  @override
  String get addTaskButton => 'Añadir meta';

  @override
  String get createTaskTitle => 'Nueva meta';

  @override
  String get taskNameHint => 'Nombre de la meta';

  @override
  String get targetDaysLabel => 'Objetivo (días)';

  @override
  String targetDaysChip(int days) {
    return '$days días';
  }

  @override
  String get targetDaysHint => 'Objetivo personalizado';

  @override
  String taskDaysProgress(int completed, int target) {
    return '$completed/$target días';
  }

  @override
  String get taskCompletedLabel => '¡Completada!';

  @override
  String get lastActivityLabel => 'Última actividad';

  @override
  String get lastActivityNone => 'Nada aún — ¡empieza algo!';

  @override
  String get lastActivityJustNow => 'justo ahora';

  @override
  String lastActivityMinutesAgo(int minutes) {
    return 'hace $minutes min';
  }

  @override
  String lastActivityHoursAgo(int hours) {
    return 'hace $hours h';
  }

  @override
  String lastActivityDaysAgo(int days) {
    return 'hace $days d';
  }

  @override
  String get categoryStudying => 'Estudios';

  @override
  String get categoryExercises => 'Ejercicio';

  @override
  String get categoryReading => 'Lectura';

  @override
  String get categoryHobbies => 'Hobbies';

  @override
  String get itemNounStudying => 'Materia';

  @override
  String get itemNounExercises => 'Ejercicio';

  @override
  String get itemNounReading => 'Libro';

  @override
  String get itemNounHobbies => 'Hobby';

  @override
  String get iconLabel => 'Icono';

  @override
  String get restTimeLabel => 'Tiempo de descanso';

  @override
  String restMinutesChip(int minutes) {
    return '$minutes min';
  }

  @override
  String get timeUnitHoursSuffix => 'h';

  @override
  String get timeUnitMinutesSuffix => 'min';

  @override
  String get wallpaperLabel => 'Fondo del timer';

  @override
  String addItemButton(String itemNoun) {
    return 'Añadir $itemNoun';
  }

  @override
  String itemNameHint(String itemNoun) {
    return 'Nombre de $itemNoun';
  }

  @override
  String get colorLabel => 'Color';

  @override
  String get bookThemeLabel => 'Tema del libro';

  @override
  String get estimatedHoursGoalHint => 'Meta estimada (horas)';

  @override
  String get goalPagesHint => 'Meta (páginas)';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get addButton => 'Añadir';

  @override
  String get createSubjectTitleStudying => 'Nueva materia';

  @override
  String get createSubjectTitleReading => 'Nueva lectura';

  @override
  String get createSubjectTitleExercises => 'Nueva actividad física';

  @override
  String get createSubjectTitleHobbies => 'Nuevo hobby';

  @override
  String get createSubjectSubtitleStudying =>
      'Define una meta y personaliza tu enfoque';

  @override
  String get createSubjectSubtitleReading =>
      'Registra páginas y personaliza tu lectura';

  @override
  String get createSubjectSubtitleExercises =>
      'Configura cómo quieres seguir esta actividad';

  @override
  String get createSubjectSubtitleHobbies =>
      'Configura cómo quieres seguir este hobby';

  @override
  String get createSubjectBasicSection => 'Información básica';

  @override
  String get createSubjectGoalSection => 'Meta';

  @override
  String get createSubjectRoutineSection => 'Rutina';

  @override
  String get createSubjectPersonalizationSection => 'Personalización';

  @override
  String get createSubjectNameLabelStudying => 'Nombre de la materia';

  @override
  String get createSubjectNameLabelReading => 'Nombre de la lectura';

  @override
  String get createSubjectNameLabelExercises => 'Nombre de la actividad';

  @override
  String get createSubjectNameLabelHobbies => 'Nombre del hobby';

  @override
  String get createSubjectNameHintStudying =>
      'Ej.: Biología, Matemáticas, Inglés';

  @override
  String get createSubjectNameHintReading =>
      'Ej.: Libro de Historia, Dom Casmurro';

  @override
  String get createSubjectNameHintExercises =>
      'Ej.: Gimnasio, Carrera, Estiramiento';

  @override
  String get createSubjectNameHintHobbies =>
      'Ej.: Guitarra, Dibujo, Programación';

  @override
  String get createSubjectTimeGoalLabel => 'Meta de tiempo';

  @override
  String get createSubjectPagesGoalLabel => 'Meta de páginas';

  @override
  String get createSubjectTimeGoalHelp =>
      '¿Cuántas horas quieres acumular en total?';

  @override
  String get createSubjectPagesGoalHelp =>
      '¿Cuántas páginas quieres registrar en total?';

  @override
  String get createSubjectRestLabel => 'Pausa después de cada enfoque';

  @override
  String get createSubjectRestHelp =>
      'El timer sugiere una pausa después de 25 min de enfoque.';

  @override
  String get customRestMinutesHint => 'Pausa personalizada (min)';

  @override
  String get createSubjectPreviewTitle => 'Vista previa';

  @override
  String get createSubjectPreviewNoGoal => 'Sin meta definida';

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
    return 'Color $index';
  }

  @override
  String get createSubjectButtonStudying => 'Crear materia';

  @override
  String get createSubjectButtonReading => 'Crear lectura';

  @override
  String get createSubjectButtonExercises => 'Crear actividad';

  @override
  String get createSubjectButtonHobbies => 'Crear hobby';

  @override
  String get createSubjectMissingName => 'Escribe el nombre para continuar';

  @override
  String get createSubjectMissingTimeGoal => 'Define una meta de tiempo válida';

  @override
  String get createSubjectMissingPagesGoal =>
      'Define una meta de páginas válida';

  @override
  String get createSubjectSuccessStudying => 'Materia creada correctamente';

  @override
  String get createSubjectSuccessReading => 'Lectura creada correctamente';

  @override
  String get createSubjectSuccessExercises => 'Actividad creada correctamente';

  @override
  String get createSubjectSuccessHobbies => 'Hobby creado correctamente';

  @override
  String pagesProgress(int currentPages, int goalPages) {
    return '$currentPages de $goalPages páginas';
  }

  @override
  String pagesReadOnly(int currentPages) {
    return '$currentPages páginas leídas';
  }

  @override
  String get pagesReadNowHint => 'Páginas leídas ahora';

  @override
  String get logPagesButton => 'Registrar páginas';

  @override
  String get notesLabel => 'Notas';

  @override
  String get notesHint => 'Escribe tus notas aquí...';

  @override
  String get saveNotesButton => 'Guardar';

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
    return 'Próximo descanso en $duration';
  }

  @override
  String timerRestingLabel(String duration) {
    return 'Descansando — vuelve en $duration';
  }

  @override
  String get timerNotificationRunning => 'Sesión de concentración en curso';

  @override
  String get timerNotificationResting => 'Descansando — vuelve pronto';

  @override
  String get timerNotificationPaused => 'Pausado';

  @override
  String get timerStateFocusingTitle => 'Enfoque en curso';

  @override
  String get timerStateFocusingDescription =>
      'Mantén el enfoque. Pronto se sugerirá una pausa.';

  @override
  String get timerStatePausedTitle => 'Timer pausado';

  @override
  String get timerStatePausedDescription => 'Continúa cuando estés listo.';

  @override
  String get timerStateRestingTitle => 'Pausa merecida';

  @override
  String get timerStateRestingDescription =>
      'Bebe agua o respira un poco antes de continuar.';

  @override
  String get timerSessionSavedTitle => 'Sesión registrada';

  @override
  String get timerSessionSavedDescription =>
      'Tu tiempo se agregó a la materia.';

  @override
  String get timerCurrentFocusLabel => 'Tiempo enfocado ahora';

  @override
  String get timerRestTimeLabel => 'Tiempo de pausa';

  @override
  String get timerSessionLabel => 'Sesión actual';

  @override
  String timerTotalInSubject(String subjectName) {
    return 'Total en $subjectName';
  }

  @override
  String get timerPauseButton => 'Pausar';

  @override
  String get timerContinueButton => 'Continuar';

  @override
  String get timerContinueFocusButton => 'Continuar';

  @override
  String get timerSkipRestButton => 'Saltar pausa';

  @override
  String get timerEndSessionButton => 'Cerrar sesión';

  @override
  String get timerStartAnotherSessionButton => 'Iniciar otra sesión';

  @override
  String get timerSaveReassurance =>
      'El progreso también se guarda al pausar o salir.';

  @override
  String timerFocusedValue(String duration) {
    return '$duration enfocados';
  }

  @override
  String get timerAccumulatedTotalLabel => 'Total acumulado';

  @override
  String get timerBackToSubjectsButton => 'Volver';

  @override
  String get timerExitDialogTitle => '¿Cerrar sesión?';

  @override
  String timerExitDialogContent(String duration, String subjectName) {
    return 'Tu progreso de $duration se guardará en $subjectName.';
  }

  @override
  String get timerExitDialogCancel => 'Continuar';

  @override
  String get timerExitDialogContinueLater => 'Podrás continuar después.';

  @override
  String get timerExitDialogConfirm => 'Cerrar';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get editButton => 'Editar';

  @override
  String get nicknameFallback => 'usuario';

  @override
  String get profileSummaryLabel => 'Resumen total';

  @override
  String get profileSummarySinceStartLabel => 'Desde el inicio';

  @override
  String profileSummaryAccumulatedFocus(Object duration) {
    return '$duration de enfoque acumulado';
  }

  @override
  String get profileSummaryFocusLabel => 'Tiempo total de enfoque';

  @override
  String get profileSummaryFocusDescription => 'Estudio, ejercicio y hobbies';

  @override
  String get statHoursStudied => 'Estudio';

  @override
  String get statHoursExercised => 'Ejercicio';

  @override
  String get statPagesRead => 'Páginas leídas';

  @override
  String get statTopSubject => 'Más estudiada';

  @override
  String get profileStatTimeEmptyTitle => 'Comienza tu primer enfoque';

  @override
  String get profileStatTimeEmptyDescription => 'Tu tiempo aparecerá aquí';

  @override
  String get profileStatExerciseEmptyTitle => 'Aún sin ejercicio';

  @override
  String get profileStatExerciseEmptyDescription =>
      'Registra tu primera actividad';

  @override
  String get profileStatReadingEmptyTitle => 'Aún sin páginas';

  @override
  String get profileStatReadingEmptyDescription =>
      'Registra tu primera lectura';

  @override
  String get profileTopSubjectEmptyTitle => 'Aún ninguna';

  @override
  String get profileTopSubjectEmptyDescription =>
      'Estudia una materia para destacarla aquí';

  @override
  String get profileEmptyTitle => 'Tu progreso empieza aquí';

  @override
  String get profileEmptyDescription =>
      'Inicia una sesión, registra una lectura o crea una meta desde Inicio para seguir tu evolución en HelpOut.';

  @override
  String get profileEmptyGuidance =>
      'Después de eso, tu tiempo total, actividades principales y lecturas destacadas aparecerán aquí.';

  @override
  String get profileEmptyStartButton => 'Empezar ahora';

  @override
  String get profileShortcutsTitle => 'Atajos';

  @override
  String get profileShortcutCreateSubject => 'Crear materia';

  @override
  String get profileShortcutCreateGoal => 'Crear meta';

  @override
  String get profileShortcutAddSchedule => 'Agregar horario';

  @override
  String get profileEvolutionTitle => 'Tu progreso';

  @override
  String profileEvolutionFocus(String duration) {
    return 'Acumulaste $duration de enfoque.';
  }

  @override
  String profileEvolutionTopSubject(String name) {
    return 'Tu materia más estudiada es $name.';
  }

  @override
  String profileEvolutionRemaining(String duration) {
    return 'Te faltan $duration para tu meta.';
  }

  @override
  String get profileEvolutionGoalReached => '¡Alcanzaste tu meta de enfoque!';

  @override
  String get profileAgendaTitle => 'Agenda de hoy';

  @override
  String get profileAgendaEmptyTitle => 'Sin horarios planeados';

  @override
  String get profileAgendaEmptyDescription =>
      'Agrega bloques para organizar tu rutina.';

  @override
  String get profileAgendaAddButton => 'Agregar horario';

  @override
  String get profileTopReadingTitle => 'Lecturas principales';

  @override
  String get profileTopReadingEmptyTitle => 'Sin lecturas registradas';

  @override
  String get profileTopReadingEmptyDescription =>
      'Registra páginas leídas para ver aquí tus temas principales.';

  @override
  String get groupsTitle => 'Grupos';

  @override
  String get groupsSubtitle => 'Compara tu progreso con amigos';

  @override
  String get noGroupSelected => 'Ningún grupo seleccionado todavía.';

  @override
  String get newGroupChip => 'Nuevo';

  @override
  String get groupHeaderCreateButton => 'Grupo';

  @override
  String get groupsEmptyTitle => 'Aún no hay grupos';

  @override
  String get groupsEmptyDescription =>
      'Crea un grupo para comparar tu progreso con amigos y mantener la motivación.';

  @override
  String get groupsEmptyButton => 'Crear primer grupo';

  @override
  String get you => 'Tú';

  @override
  String get mockStudyGroupName => 'Equipo de Estudio';

  @override
  String get mockWorkoutGroupName => 'Grupo de Ejercicios';

  @override
  String get periodToday => 'Hoy';

  @override
  String get periodThisWeek => 'Semana';

  @override
  String get periodThisMonth => 'Mes';

  @override
  String get periodDescriptionToday => 'hoy';

  @override
  String get periodDescriptionThisWeek => 'esta semana';

  @override
  String get periodDescriptionThisMonth => 'este mes';

  @override
  String get groupMetricStudying => 'horas de estudio';

  @override
  String get groupMetricDailyGoals => 'días de metas completadas';

  @override
  String get groupMetricExercises => 'horas de ejercicio';

  @override
  String get groupMetricReading => 'páginas leídas';

  @override
  String get groupMetricHobbies => 'horas de hobbies';

  @override
  String groupLeaderboardDescription(String period, String metric) {
    return 'Ranking de $period · medido en $metric';
  }

  @override
  String get leaderboardTitle => 'Ranking';

  @override
  String get currentUserRankTitle => 'Tu desempeño';

  @override
  String currentUserRankValue(String rank, String score) {
    return '$rank lugar · $score';
  }

  @override
  String currentUserRankNextStep(String score) {
    return '$score para subir una posición';
  }

  @override
  String get currentUserRankLeading => 'Lideras este ranking.';

  @override
  String get currentUserRankSubtitle => 'tu posición actual';

  @override
  String get leaderboardTopPosition => 'lidera este ranking';

  @override
  String leaderboardDifferenceAhead(String value) {
    return '+$value por delante';
  }

  @override
  String get groupCreatedSuccess => 'Grupo creado correctamente';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsSubtitle => 'Ajusta tu cuenta y preferencias';

  @override
  String get myProfileFallback => 'Mi Perfil';

  @override
  String get personalProfileLabel => 'Perfil personal';

  @override
  String accountDataSubtitle(Object nickname) {
    return '$nickname · datos personales y seguridad';
  }

  @override
  String get preferencesSection => 'Preferencias';

  @override
  String get darkModeLabel => 'Modo oscuro';

  @override
  String get darkModeEnabledSubtitle => 'Tema oscuro activado';

  @override
  String get darkModeDisabledSubtitle => 'Usar tema oscuro en la app';

  @override
  String get accentColorSettingsTitle => 'Color destacado';

  @override
  String get accentColorSettingsSubtitle =>
      'Personaliza la apariencia de la app';

  @override
  String get notificationsLabel => 'Notificaciones';

  @override
  String get timerNotificationsTitle => 'Notificaciones del timer';

  @override
  String get notificationsEnabledSubtitle =>
      'Alertas de enfoque, pausa y progreso';

  @override
  String get notificationsDisabledSubtitle =>
      'Alertas apagadas en este dispositivo';

  @override
  String get language => 'Idioma';

  @override
  String get appLanguageSubtitle => 'Idioma de la app';

  @override
  String get chooseLanguageTitle => 'Elegir idioma';

  @override
  String languageChangedMessage(String language) {
    return 'Idioma cambiado a $language';
  }

  @override
  String get preferenceSavedMessage => 'Preferencia guardada';

  @override
  String get supportSection => 'Soporte';

  @override
  String get helpSection => 'Ayuda';

  @override
  String get faqLabel => 'Preguntas frecuentes';

  @override
  String get faqSettingsSubtitle => 'Dudas sobre timer, metas y grupos';

  @override
  String get sendFeedbackTitle => 'Enviar feedback';

  @override
  String get sendFeedbackSubtitle => 'Cuéntanos qué puede mejorar';

  @override
  String get feedbackUnavailable => 'Feedback aún no disponible';

  @override
  String get aboutLabel => 'Acerca de';

  @override
  String get aboutSection => 'Acerca de';

  @override
  String appVersionValue(String version) {
    return 'Versión $version';
  }

  @override
  String get debugEnvironmentTitle => 'Ambiente';

  @override
  String get debugEnvironmentSubtitle => 'Debug · datos de ejemplo activos';

  @override
  String appVersionLabel(String appTitle, String appVersion) {
    return '$appTitle v$appVersion';
  }

  @override
  String get accountSection => 'Cuenta';

  @override
  String get sessionSection => 'Sesión';

  @override
  String get logOutLabel => 'Cerrar sesión';

  @override
  String get logOutSettingsSubtitle => 'Cerrar sesión en este dispositivo';

  @override
  String get logOutDialogTitle => '¿Cerrar sesión?';

  @override
  String get logOutDialogContent =>
      'Tendrás que iniciar sesión de nuevo para acceder a esta cuenta en este dispositivo. Tus datos locales de estudio se mantendrán.';

  @override
  String get logOutConfirmButton => 'Cerrar sesión';

  @override
  String get myProfileTitle => 'Mi Perfil';

  @override
  String get avatarLabel => 'Avatar';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get yourNameHint => 'Tu nombre';

  @override
  String get nicknameLabel => 'Apodo';

  @override
  String get nicknameHint => 'Cómo te llaman tus amigos';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get optionalHint => 'Opcional';

  @override
  String get phoneLabel => 'Número de teléfono';

  @override
  String get themeColorLabel => 'Color del tema';

  @override
  String get saveChangesButton => 'Guardar Cambios';

  @override
  String get profileSavedMessage => 'Perfil guardado';

  @override
  String get faqTitle => 'Preguntas frecuentes';

  @override
  String get faqQ1 => '¿Cómo funciona el temporizador de estudio?';

  @override
  String get faqA1 =>
      'Elige una materia, pulsa play, y el temporizador registra tu sesión actual, sumándola al tiempo total de esa materia. Pulsa pausa en cualquier momento para detenerte y guardar tu progreso.';

  @override
  String get faqQ2 => '¿Qué es la cuenta regresiva del descanso?';

  @override
  String get faqA2 =>
      'Cada sesión sigue un ciclo Pomodoro clásico: una cuenta regresiva de 25 minutos hasta tu próximo descanso. Cuando llega a cero, simplemente se reinicia; es un recordatorio, no una parada obligatoria.';

  @override
  String get faqQ3 => '¿Cómo agrego una nueva materia?';

  @override
  String get faqA3 =>
      'Abre una categoría desde el Inicio y luego pulsa \"Añadir Materia\" al final de la lista. Puedes elegir un color y fijar una meta estimada de horas.';

  @override
  String get faqQ4 => '¿Cómo se calculan los grupos y la clasificación?';

  @override
  String get faqA4 =>
      'Los grupos muestran una clasificación basada en el tema: horas de enfoque, días de metas completadas o páginas leídas. Cambia entre Hoy, Semana y Mes para comparar el progreso.';

  @override
  String get faqQ5 => '¿Puedo cambiar el tema de colores de la app?';

  @override
  String get faqA5 =>
      'Sí, ve a Configuración > Mi Perfil y elige cualquier color de tema. Cada gradiente, botón y detalle de la app se actualiza para combinar, incluido el modo oscuro.';

  @override
  String get createGroupTitle => 'Nuevo grupo';

  @override
  String get createGroupSubtitle => 'Elige un tema e invita amigos';

  @override
  String get groupNameLabel => 'Nombre del grupo';

  @override
  String get groupNameHint => 'Nombre del grupo';

  @override
  String get groupNameExampleHint => 'Ej.: Estudio para examen';

  @override
  String get groupThemeLabel => 'Tema';

  @override
  String groupThemeSelectedDescription(String metric) {
    return 'Este grupo clasifica por $metric.';
  }

  @override
  String get inviteFriendsLabel => 'Invitar amigos';

  @override
  String selectedFriendsCount(int count) {
    return '$count seleccionados';
  }

  @override
  String get selectAtLeastOneFriend => 'Selecciona al menos 1 amigo';

  @override
  String get searchFriendHint => 'Buscar amigo';

  @override
  String get loadingFriends => 'Cargando amigos...';

  @override
  String get friendsLoadErrorTitle => 'No se pudieron cargar amigos';

  @override
  String get friendsLoadErrorDescription => 'Inténtalo de nuevo en un momento.';

  @override
  String get noFriendsAvailableTitle => 'No hay amigos disponibles';

  @override
  String get noFriendsAvailableDescription =>
      'Agrega amigos antes de crear un grupo.';

  @override
  String get noFriendsFoundTitle => 'No se encontró ningún amigo';

  @override
  String get noFriendsFoundDescription => 'Prueba con otro nombre.';

  @override
  String get createGroupButton => 'Crear Grupo';

  @override
  String get createGroupMissingName => 'Escribe el nombre del grupo';

  @override
  String get createGroupMissingTheme => 'Elige un tema';

  @override
  String get createGroupMissingFriends => 'Selecciona al menos 1 amigo';

  @override
  String createGroupWithFriendsButton(int count) {
    return 'Crear grupo con $count amigos';
  }

  @override
  String get createGroupRequirementsTitle => 'Para crear:';

  @override
  String get createGroupRequirementName => 'Nombre del grupo';

  @override
  String get createGroupRequirementTheme => 'Tema elegido';

  @override
  String get createGroupRequirementFriends => 'Al menos 1 amigo';

  @override
  String get groupPrivacyNote =>
      'Tus amigos solo verán tu nombre, avatar y progreso en este tema.';

  @override
  String metricDaysValue(int value) {
    return '$value días';
  }

  @override
  String metricPagesValue(int value) {
    return '$value páginas';
  }

  @override
  String get navHome => 'Inicio';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navGroups => 'Grupos';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get myScheduleCardTitle => 'Tu Agenda';

  @override
  String get myScheduleTitle => 'Tu Agenda';

  @override
  String get noScheduleYet => 'Todavía no hay horarios';

  @override
  String get noScheduleYetDescription =>
      'Toca el botón de abajo para agregar\ntu primer horario';

  @override
  String get addScheduleEntryTitle => 'Agregar Horario';

  @override
  String get addScheduleEntryButton => 'Agregar Horario';

  @override
  String get scheduleInfoSection => 'Información';

  @override
  String get scheduleWhenSection => '¿Cuándo?';

  @override
  String get scheduleColorSection => 'Color del horario';

  @override
  String get schedulePreviewSection => 'Vista previa';

  @override
  String scheduleDurationLabel(String duration) {
    return 'Duración: $duration';
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
  String get startTimeLabel => 'Hora de inicio';

  @override
  String get endTimeOptionalLabel => 'Hora de fin';

  @override
  String get incompleteScheduleEntryError =>
      'Registro incompleto — completa el título, la hora de inicio y la hora de fin.';

  @override
  String get endTimeBeforeStartError =>
      'La hora de término debe ser posterior a la de inicio.';

  @override
  String get nameRequiredError => 'Ingresa un nombre primero.';

  @override
  String get groupThemeRequiredError => 'Elige un tema para tu grupo.';

  @override
  String get groupNeedsFriendError =>
      'Invita al menos a un amigo — un grupo no puede crearse solo.';

  @override
  String get continueWithGoogleButton => 'Continuar con Google';

  @override
  String get continueWithAppleButton => 'Continuar con Apple';

  @override
  String get continueWithPhoneButton => 'Continuar con el teléfono';

  @override
  String get phoneLoginTitle => 'Tu número';

  @override
  String get phoneLoginSubtitle =>
      'Ingresa tu teléfono para recibir un código de acceso.';

  @override
  String get sendCodeButton => 'Enviar código';

  @override
  String get phoneSecurityNote =>
      'Puedes usar tu número para entrar de forma segura.';

  @override
  String get phoneCountryCodeBrazil => '+55';

  @override
  String get phoneNumberInputHint => '(11) 99999-9999';

  @override
  String get useSocialLoginButton => 'Usar Google o Apple';

  @override
  String get otpTitle => 'Verifica tu número';

  @override
  String otpSubtitle(String phone) {
    return 'Ingresa el código de 6 dígitos que enviamos a $phone.';
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
  String get editPhoneNumberButton => 'Editar número';

  @override
  String get codeResentMessage => 'Código de verificación enviado';

  @override
  String get invalidCodeError => 'Código no válido. Inténtalo de nuevo.';

  @override
  String get credentialsTitle => 'Crea tu perfil';

  @override
  String get credentialsSubtitle =>
      'Cuéntanos un poco sobre ti para personalizar tu experiencia.';

  @override
  String get birthDateHint => 'Fecha de nacimiento';

  @override
  String get profileEditableLaterNote => 'Podrás editar esto después.';

  @override
  String get finishButton => 'Finalizar';
}
