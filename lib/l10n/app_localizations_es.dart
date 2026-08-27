// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Timing';

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
  String get homeTodayAgendaTitle => 'Agenda de hoy';

  @override
  String get homeNextScheduleEmpty => 'Sin compromisos hoy';

  @override
  String get homeNextScheduleAdd => 'Agregar compromiso';

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
  String get estimatedHoursGoalHint => 'Duración en minutos';

  @override
  String get createSubjectTotalHoursGoalHint => 'Tiempo total en horas';

  @override
  String get goalPagesHint => 'Meta (páginas)';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get confirmButton => 'Confirmar';

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
  String get createSubjectTimeGoalLabel => 'Duración de cada sección';

  @override
  String get createSubjectTotalTimeGoalLabel =>
      '¿Cuánto tiempo quieres estudiar en total?';

  @override
  String get createSubjectTotalTimeGoalLabelStudying =>
      '¿Cuánto tiempo quieres estudiar en total?';

  @override
  String get createSubjectTotalTimeGoalLabelExercises =>
      '¿Cuánto tiempo quieres ejercitarte en total?';

  @override
  String get createSubjectTotalTimeGoalLabelHobbies =>
      '¿Cuánto tiempo quieres practicar en total?';

  @override
  String get createSubjectPagesGoalLabel => 'Meta de páginas';

  @override
  String get createSubjectTimeGoalHelp => '¿Cuántos minutos quieres enfocarte?';

  @override
  String get createSubjectPagesGoalHelp =>
      '¿Cuántas páginas quieres registrar en total?';

  @override
  String get createSubjectRestLabel => 'Duración de las pausas';

  @override
  String get createSubjectRestHelp =>
      'El timer sugiere una pausa después de 30 min de enfoque.';

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
    return '${hours}h $minutes min';
  }

  @override
  String createSubjectPagesValue(int value) {
    return '$value páginas';
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
  String get createSubjectMissingTimeGoal =>
      'Define una meta de enfoque válida';

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
  String get addNotesPageTooltip => 'Añadir página';

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
      'Inicia una sesión, registra una lectura o crea una meta desde Inicio para seguir tu evolución en Timing.';

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
  String get profileProgressSectionTitle => 'Tu progreso';

  @override
  String get profileAchievementsTitle => 'Logros';

  @override
  String get profileSeeHistory => 'Ver historial';

  @override
  String get profileSeeAll => 'Ver todos';

  @override
  String get profileAchievementFirstUnlocked => '1ª conquista';

  @override
  String get profileAchievementGoalStarted => 'Meta iniciada';

  @override
  String get profileAchievementsStartHint => 'Empieza para conseguir logros';

  @override
  String get profileAchievementFirstFocus => 'Primer enfoque';

  @override
  String get profileAchievementStudyStarted => 'Estudios iniciados';

  @override
  String get profileAchievementReadingStarted => 'Lectura iniciada';

  @override
  String get profileAchievementLocked => 'Bloqueado';

  @override
  String get periodFiveDays => '5 días';

  @override
  String get periodWeek => '1 semana';

  @override
  String get periodMonth => '1 mes';

  @override
  String get periodTotal => 'Total';

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
  String get appLanguageSubtitle =>
      'Elige el idioma usado en menús, mensajes y textos de la app. El cambio se aplica a toda la interfaz.';

  @override
  String get automaticLanguageLabel => 'Automático';

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
  String get linkedAccountsSection => 'Inicios conectados';

  @override
  String get linkedAccountsSubtitle =>
      'Usa Google y Apple para acceder a esta misma cuenta.';

  @override
  String get linkGoogleAccountTitle => 'Asociar Google';

  @override
  String get linkGoogleAccountSubtitle => 'Entrar con Google en esta cuenta';

  @override
  String get linkAppleAccountTitle => 'Asociar Apple';

  @override
  String get linkAppleAccountSubtitle => 'Entrar con Apple en esta cuenta';

  @override
  String get authProviderConnected => 'Conectado';

  @override
  String get linkAuthProviderStarted =>
      'Finaliza el inicio de sesión para asociar la cuenta.';

  @override
  String get linkAuthProviderFailure =>
      'No se pudo iniciar la asociación. Revisa el proveedor y el vínculo manual en Supabase.';

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
  String get profilePhotoSelectLabel => 'Agregar foto';

  @override
  String get profilePhotoRemoveLabel => 'Quitar foto';

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
      'Cada sesión sigue un ciclo de enfoque: una cuenta regresiva de 30 minutos hasta tu próximo descanso. Cuando llega a cero, simplemente se reinicia; es un recordatorio, no una parada obligatoria.';

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
  String get navGroups => 'Grupos';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get myScheduleCardTitle => 'Tu Agenda';

  @override
  String get myScheduleTitle => 'Tu Agenda';

  @override
  String get noScheduleYet => 'Todavía no hay compromisos';

  @override
  String get noScheduleYetDescription =>
      'Toca el botón de abajo para agregar\ntu primer compromiso';

  @override
  String get addScheduleEntryTitle => 'Agregar compromiso';

  @override
  String get addScheduleEntryButton => 'Agregar compromiso';

  @override
  String get scheduleInfoSection => 'Información';

  @override
  String get scheduleWhenSection => '¿Cuándo?';

  @override
  String get scheduleColorSection => 'Color del compromiso';

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
  String get selectCountryTitle => 'Selecciona el país';

  @override
  String get searchCountryHint => 'Buscar país';

  @override
  String get otpCodeExpired =>
      'Código expirado. Reenvíalo para recibir uno nuevo.';

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

  @override
  String get navProgress => 'Progreso';

  @override
  String get progressTitle => 'Progreso';

  @override
  String get progressSubtitle => 'Todo lo que ya hiciste';

  @override
  String get progressPeriodDay => 'Día';

  @override
  String get progressPeriodWeek => 'Semana';

  @override
  String get progressPeriodMonth => 'Mes';

  @override
  String get progressFocusResultLabel => 'Enfoque en este período';

  @override
  String progressComparisonMore(String value) {
    return '$value más que en el período anterior';
  }

  @override
  String progressComparisonLess(String value) {
    return '$value menos que en el período anterior';
  }

  @override
  String get progressComparisonSame => 'Igual que el período anterior';

  @override
  String get progressComparisonFirst => 'Tus primeros datos en este período';

  @override
  String get progressStatExercises => 'Ejercicios';

  @override
  String get progressStatLongestGoal => 'Meta más larga';

  @override
  String get progressStatMainReading => 'Lectura principal';

  @override
  String get progressStatGoalsDone => 'Metas cumplidas';

  @override
  String get progressDistributionTitle => 'Por actividad';

  @override
  String homeTodayInline(String focus, int pages, int goals) {
    return 'Hoy: $focus de enfoque · $pages páginas · $goals metas';
  }

  @override
  String get homePlanDayTitle => 'Planear mi día';

  @override
  String get homePlanDaySubtitle => 'Metas diarias y agenda semanal';

  @override
  String get groupsFriendsTitle => 'Amigos';

  @override
  String get groupsFriendsSubtitle => 'Solicitudes, invitaciones y tu código';

  @override
  String groupMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros',
      one: '1 miembro',
    );
    return '$_temp0';
  }

  @override
  String get createScheduleEntryButton => 'Crear compromiso';

  @override
  String get scheduleEntryMissingFields =>
      'Completa título, inicio y fin para continuar';

  @override
  String timerSessionCounter(int current, int total) {
    return 'Enfoque $current de $total';
  }

  @override
  String get timerExitBackToFocus => 'Volver al enfoque';

  @override
  String get timerExitSaveAndEnd => 'Guardar y terminar';

  @override
  String get notesSavedNow => 'Guardado ahora';

  @override
  String get notesSaving => 'Guardando…';

  @override
  String get dailyGoalsPendingSection => 'Pendientes';

  @override
  String get dailyGoalsCompletedSection => 'Completadas';

  @override
  String get dailyGoalsEmptyTitle => 'Aún no hay metas para hoy';

  @override
  String get dailyGoalsEmptyDescription =>
      'Escribe una meta arriba o elige una sugerencia para empezar el día.';

  @override
  String achievementProgressValue(String current, String total) {
    return '$current de $total';
  }

  @override
  String get categoryEmptyTitle => 'Nada por aquí todavía';

  @override
  String get categoryEmptyDescription =>
      'Crea tu primer elemento para empezar a registrar tu enfoque.';

  @override
  String get scheduleEmptyExampleLabel => 'Ejemplo';

  @override
  String get progressAchievementsNextTitle => 'Próximo logro';

  @override
  String get achievementFocusHourTitle => '1 hora de enfoque';

  @override
  String get achievementSessionsTitle => '5 sesiones completadas';

  @override
  String get achievementStreakTitle => '7 días seguidos';

  @override
  String get achievementReaderTitle => '100 páginas leídas';

  @override
  String get achievementGoalStartedTitle => 'Primera meta iniciada';

  @override
  String unitMinutesShort(int value) {
    return '$value min';
  }

  @override
  String unitSessions(int value) {
    return '$value sesiones';
  }

  @override
  String unitDays(int value) {
    return '$value días';
  }

  @override
  String currentUserRankNextStepNamed(String score, String name) {
    return '$score para alcanzar a $name';
  }

  @override
  String get timerKeepAwakeNote =>
      'La pantalla permanece encendida durante la sesión';

  @override
  String scheduleWeekLabel(String date) {
    return 'Semana del $date';
  }

  @override
  String get daysSuffix => 'días';

  @override
  String get createTaskSubtitle =>
      'Configura una meta diaria para seguir tu progreso';

  @override
  String get createTaskSequenceTypeLabel => 'Tipo de secuencia';

  @override
  String get createTaskSequenceIntenseLabel => 'Intensa';

  @override
  String get createTaskSequenceIntenseDescription =>
      'No permite fallos. Si pierdes un día, tu secuencia se reinicia.';

  @override
  String get createTaskSequenceCasualLabel => 'Casual';

  @override
  String get createTaskSequenceCasualDescription =>
      'Más flexible. Los días perdidos no reinician tu secuencia.';

  @override
  String get targetDaysInfinite => 'Infinito';

  @override
  String get deleteConfirmationDefaultTypeName => 'elemento';

  @override
  String deleteConfirmationTitle(String typeName) {
    return '¿Eliminar $typeName?';
  }

  @override
  String deleteConfirmationContent(String itemName) {
    return 'Estás por eliminar \"$itemName\". Esta acción no se puede deshacer.';
  }

  @override
  String deleteConfirmationHistoryWarning(String typeName) {
    return 'El historial de este $typeName también se eliminará.';
  }

  @override
  String homeDaySummaryFocusValue(String focus) {
    return '$focus enfoque';
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
      'Elige cómo deseas actualizar tu foto';

  @override
  String get photoCameraLabel => 'Tomar foto';

  @override
  String get photoGalleryLabel => 'Elegir de la galería';

  @override
  String get removePhotoDialogTitle => '?Quitar foto?';

  @override
  String get removePhotoDialogContent =>
      'Tu avatar volverá a aparecer en el perfil.';

  @override
  String get friendRequestsReceivedTab => 'Solicitudes';

  @override
  String get friendRequestsSentTab => 'Invitaciones';

  @override
  String hobbyPracticeMinutes(int minutes) {
    return '$minutes min de práctica';
  }

  @override
  String get hobbyViewStatistics => 'Ver estadísticas';

  @override
  String get hobbyEdit => 'Editar hobby';

  @override
  String get pinToStart => 'Fijar al inicio';

  @override
  String get hobbyDelete => 'Eliminar hobby';

  @override
  String get deleteActionCannotBeUndone => 'Esta acción no se puede deshacer.';

  @override
  String get joinGroupTitle => 'Unirse a un grupo';

  @override
  String get joinGroupInviteCodeLabel => 'Código de invitación';

  @override
  String get joinGroupCodeHint => 'Escribe el código';

  @override
  String get joinGroupButton => 'Unirme al grupo';

  @override
  String get joinGroupError => 'No fue posible unirse a este grupo.';

  @override
  String get scheduleDayEventsTitle => 'Agenda del día';

  @override
  String get dailyGoalsNoGoalsYetTitle => 'Ninguna meta todavía';

  @override
  String get dailyGoalsNoGoalsYetDescription =>
      'Agrega tu primera meta para organizar el día y seguir tus logros.';

  @override
  String get dailyGoalsSuggestionsTitle => 'Sugerencias para empezar';

  @override
  String get dailyGoalsSuggestionStudy => 'Estudiar 30 min';

  @override
  String get dailyGoalsSuggestionRead => 'Leer 10 páginas';

  @override
  String get dailyGoalsSuggestionTrain => 'Entrenar';

  @override
  String get goalTypeName => 'meta';

  @override
  String get missedYesterdayDialogTitle => '?La completaste ayer?';

  @override
  String missedYesterdayDialogContent(String taskName) {
    return 'No registraste \"$taskName\" ayer. ?Realmente no la concluiste?';
  }

  @override
  String get missedYesterdayMissedButton => 'S?, no la conclu?';

  @override
  String get missedYesterdayCompletedButton => 'La conclu?';

  @override
  String get scheduleTitleRequiredError => 'Completa el título para continuar';

  @override
  String get scheduleActiveFromLabel => 'Comienza';

  @override
  String get scheduleActiveUntilLabel => 'Termina';

  @override
  String get selectDateTitle => 'Seleccionar fecha';

  @override
  String get selectDateHint => 'Elige un día en el calendario';

  @override
  String get addFriendTitle => 'Agregar amigo';

  @override
  String get friendCodeNotFound =>
      'No encontramos ningún usuario con este código.';

  @override
  String get friendInviteCodeTitle => 'Código de invitación';

  @override
  String get friendInviteCodeFieldLabel => 'Escribe o pega el código';

  @override
  String get friendInviteCodeFieldHint => 'Como ABCDE12345';

  @override
  String get pasteButton => 'Pegar';

  @override
  String get searchCodeButton => 'Buscar código';

  @override
  String get friendUserFoundTitle => 'Usuario encontrado';

  @override
  String get friendFoundByCode => 'Encontrado por código';

  @override
  String get sentLabel => 'Enviado';

  @override
  String get friendHowItWorksTitle => 'Cómo funciona';

  @override
  String get friendHowItWorksStepOne => 'Pide el código a tu amigo';

  @override
  String get friendHowItWorksStepTwo =>
      'Pega el código para encontrar el perfil';

  @override
  String get friendHowItWorksStepThree => 'Envía la solicitud para agregar';

  @override
  String get myCodeLabel => 'Mi código';

  @override
  String get yourInviteCodeLabel => 'Tu código de invitación';

  @override
  String yourFriendsTitle(int count) {
    return 'Tus amigos ($count)';
  }

  @override
  String get seeAllButton => 'Ver todos';

  @override
  String get onlineLabel => 'Online';

  @override
  String minutesAgoShort(int minutes) {
    return 'Hace $minutes min';
  }

  @override
  String get friendsEmptyTitle => 'Aún no tienes amigos';

  @override
  String get friendsEmptySubtitle =>
      'Busca personas arriba o comparte tu código de invitación.';

  @override
  String get shareCodeButton => 'Compartir código';

  @override
  String get codeCopiedMessage => 'Código copiado';

  @override
  String get friendRequestSentMessage => 'Solicitud enviada';

  @override
  String get joinedGroupMessage => 'Te uniste al grupo';

  @override
  String get friendTypeName => 'amigo';

  @override
  String shareInviteCodeMessage(String code) {
    return 'Agrégame en Timing con mi código: $code';
  }

  @override
  String groupInvitesTitle(int count) {
    return 'Invitaciones a grupos ($count)';
  }

  @override
  String groupInvitedBy(String inviter) {
    return '$inviter te invit?';
  }

  @override
  String get acceptButton => 'Aceptar';

  @override
  String get declineButton => 'Rechazar';

  @override
  String get friendsTitle => 'Amigos';

  @override
  String get friendRequestsReceivedPageTitle => 'Solicitudes';

  @override
  String get friendRequestsSentPageTitle => 'Invitaciones';

  @override
  String friendRequestsReceivedSection(int count) {
    return 'Recibidas ($count)';
  }

  @override
  String friendRequestsSentSection(int count) {
    return 'Enviadas ($count)';
  }

  @override
  String get friendMutualFriendsSample => '3 amigos en común';

  @override
  String get pendingLabel => 'Pendiente';

  @override
  String get friendRequestsIncomingEmptyTitle => 'Ninguna solicitud recibida';

  @override
  String get friendRequestsSentEmptyTitle => 'Ninguna invitación enviada';

  @override
  String get friendRequestsIncomingEmptySubtitle =>
      'Las solicitudes aparecerán aquí.';

  @override
  String get friendRequestsSentEmptySubtitle =>
      'Tus invitaciones enviadas aparecerán aquí.';

  @override
  String get friendRequestsSafetyNotice =>
      'Acepta solo personas que conoces y confías.';

  @override
  String get categoryEmptyStudyingTitle => 'Ninguna materia todavía';

  @override
  String get categoryEmptyExercisesTitle => 'Ningún ejercicio todavía';

  @override
  String get categoryEmptyReadingTitle => 'Ninguna lectura todavía';

  @override
  String get categoryEmptyHobbiesTitle => 'Ningún hobby todavía';

  @override
  String get categoryEmptyStudyingDescription =>
      'Agrega tu primera materia para organizar tus estudios y registrar tu enfoque.';

  @override
  String get categoryEmptyExercisesDescription =>
      'Agrega tu primer ejercicio para seguir entrenamientos, sesiones y progreso.';

  @override
  String get categoryEmptyReadingDescription =>
      'Agrega tu primera lectura para registrar páginas, tiempo y progreso.';

  @override
  String get categoryEmptyHobbiesDescription =>
      'Agrega tu primer hobby para registrar práctica y mantener constancia.';

  @override
  String get categorySuggestionStudyingOne => 'Matemáticas';

  @override
  String get categorySuggestionStudyingTwo => 'Inglés';

  @override
  String get categorySuggestionStudyingThree => 'Redacción';

  @override
  String get categorySuggestionExercisesOne => 'Carrera';

  @override
  String get categorySuggestionExercisesTwo => 'Fuerza';

  @override
  String get categorySuggestionExercisesThree => 'Estiramiento';

  @override
  String get categorySuggestionReadingOne => 'Novela';

  @override
  String get categorySuggestionReadingTwo => 'Técnico';

  @override
  String get categorySuggestionReadingThree => 'Artículos';

  @override
  String get categorySuggestionHobbiesOne => 'Guitarra';

  @override
  String get categorySuggestionHobbiesTwo => 'Dibujo';

  @override
  String get categorySuggestionHobbiesThree => 'Cocina';

  @override
  String get pagesAbbreviation => 'págs';

  @override
  String get loginSecurityNote => 'Tus datos están protegidos y seguros.';

  @override
  String get nextBreakDurationLabel => 'Duración del próximo descanso';

  @override
  String timerReadingExitContent(String duration, String subjectName) {
    return 'Leíste durante $duration. Informa cuántas páginas leíste en $subjectName.';
  }

  @override
  String get appleSignInIncompleteMessage =>
      'Iniciar sesión con Apple aún no está completo.';

  @override
  String get activityTypeLabel => 'Tipo de actividad';

  @override
  String get activityTypeDailyLabel => 'Diaria';

  @override
  String get activityTypeDailyDescription =>
      'Usa secciones de enfoque con pausas y define cuántas sesiones quieres completar por día.';

  @override
  String get activityTypeDailyDescriptionStudying =>
      'Usa secciones de estudio con pausas y define cuántas sesiones quieres completar por día.';

  @override
  String get activityTypeDailyDescriptionExercises =>
      'Usa secciones de ejercicio con pausas y define cuántas sesiones quieres completar por día.';

  @override
  String get activityTypeDailyDescriptionHobbies =>
      'Usa secciones de práctica con pausas y define cuántas sesiones quieres completar por día.';

  @override
  String get activityTypePermanentLabel => 'Permanente';

  @override
  String get activityTypePermanentDescription =>
      'Define el tiempo total de estudio. La actividad permanece activa hasta completarla.';

  @override
  String get activityTypePermanentDescriptionStudying =>
      'Define el tiempo total de estudio. La actividad permanece activa hasta completarla.';

  @override
  String get activityTypePermanentDescriptionExercises =>
      'Define el tiempo total de ejercicio. La actividad permanece activa hasta completarla.';

  @override
  String get activityTypePermanentDescriptionHobbies =>
      'Define el tiempo total de práctica. La actividad permanece activa hasta completarla.';

  @override
  String get pagesSuffix => 'páginas';

  @override
  String get updatedSuccessfullyMessage => 'Actualizado correctamente';

  @override
  String get focusSessionCountLabel => 'Cantidad de sesiones';

  @override
  String get subjectSectionDurationDescription =>
      'Cuánto dura cada sección de enfoque antes de una pausa o finalización.';

  @override
  String get subjectSessionCountDescription =>
      'Cuántas secciones de enfoque quieres completar por día.';

  @override
  String get subjectRestDurationDescription =>
      'Cuánto dura cada pausa entre secciones de enfoque.';

  @override
  String get groupEditingComingSoon => 'Edición del grupo próximamente.';

  @override
  String get leftGroupMessage => 'Saliste del grupo.';

  @override
  String get groupImageSourceTitle => 'Enviar imagen';

  @override
  String get groupImageSourceSubtitle => 'Elige cómo deseas enviar la imagen';

  @override
  String get deleteButton => 'Eliminar';

  @override
  String get manageMembersTitle => 'Gestionar miembros';

  @override
  String get groupLeaderLabel => 'Líder';

  @override
  String get groupLeaderRoleLabel => 'Líder del grupo';

  @override
  String get groupMemberRoleLabel => 'Miembro';

  @override
  String get groupMembersLabel => 'Miembros';

  @override
  String get groupActionsLabel => 'Acciones del grupo';

  @override
  String get goalsTabLabel => 'Datos';

  @override
  String get chatTabLabel => 'Chat';

  @override
  String get groupGoalTitle => 'Meta del grupo';

  @override
  String get groupMainRuleTitle => 'Regla principal';

  @override
  String get groupNextMilestoneTitle => 'Próximo hito';

  @override
  String groupMembersProgressValue(int current, int total) {
    return '$current/$total miembros';
  }

  @override
  String get groupNextMilestoneDescription =>
      'para desbloquear la insignia \"Enfoque Total\"';

  @override
  String get groupActivityLabel => 'Actividad del grupo';

  @override
  String groupActivityReachedGoal(int reached, int total) {
    return '$reached/$total alcanzaron la meta';
  }

  @override
  String get groupActivityFocusDataLabel => 'Enfoque';

  @override
  String get groupActivityPauseDataLabel => 'Pausa';

  @override
  String get groupActivitySessionsDataLabel => 'Sesiones';

  @override
  String get groupGoalTargetDataLabel => 'Duración objetivo';

  @override
  String get groupGoalCurrentDayDataLabel => 'Día de la meta';

  @override
  String get groupActivityPendingUsersTitle => 'Usuarios pendientes';

  @override
  String get groupActivityAllCompletedToday =>
      'Todos completaron la actividad hoy.';

  @override
  String get groupNoImagesTitle => 'Aún no hay imágenes';

  @override
  String get groupNoImagesDescription => 'Envía la primera imagen del grupo.';

  @override
  String get groupSendImageButton => 'Enviar imagen';

  @override
  String get groupSendingImage => 'Enviando imagen...';

  @override
  String get editGroupLabel => 'Editar grupo';

  @override
  String get leaveGroupLabel => 'Salir del grupo';

  @override
  String groupDescription(String metric) {
    return 'Ranking por $metric. Sigue avanzando con tu grupo.';
  }

  @override
  String groupsFriendsSubtitleWithCount(int groupCount) {
    return 'Solicitudes, invitaciones y $groupCount en grupos';
  }

  @override
  String groupGoalKeepMetric(String metric) {
    return 'Mantener $metric todos los días';
  }

  @override
  String groupGoalDescription(String metric) {
    return 'Cada participante registra $metric para mantener activa la racha del grupo.';
  }

  @override
  String groupRuleDescription(String metric) {
    return 'Registra al menos una entrada de $metric por día para fortalecer la racha del grupo.';
  }

  @override
  String get joinWithCodeButton => 'Tengo un código de invitación';

  @override
  String get groupsBenefitsHeader => 'En un grupo puedes:';

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
    return '$completed/$total miembros completaron hoy';
  }

  @override
  String get addMemberButton => 'Añadir miembro';

  @override
  String get groupCollectiveProgressTitle => 'Progreso colectivo';

  @override
  String get dailyLabel => 'Diaria';

  @override
  String get completedLabel => 'Completado';

  @override
  String groupActivityCompletedCount(int completed, int total) {
    return '$completed de $total completaron';
  }

  @override
  String groupMissingParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltan $count participantes para completar la meta',
      one: 'Falta 1 participante para completar la meta',
      zero: 'Todos completaron la meta',
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
    return 'Completaron ($count)';
  }

  @override
  String groupPendingMembersTitle(int count) {
    return 'Pendientes ($count)';
  }

  @override
  String get groupNoCompletedMembersTitle => 'Nadie completó aún';

  @override
  String get groupNoCompletedMembersSubtitle =>
      '¡Sé el primero en completar la meta!';

  @override
  String get groupStatisticsTitle => 'Estadísticas del grupo';

  @override
  String get groupStreakStatLabel => 'Racha del grupo';

  @override
  String get groupTodayTotalStatLabel => 'Tiempo total hoy';

  @override
  String get groupPeriodTotalStatLabel => 'Total del período';

  @override
  String get groupCompletedSessionsStatLabel => 'Sesiones completadas';

  @override
  String get groupParticipantsStatLabel => 'Participante en el grupo';

  @override
  String get currentUserRankCompleteFirstGoal =>
      'Completa tu primera meta para entrar al ranking.';

  @override
  String get currentUserRankTiedLead => 'Empate en el liderazgo.';

  @override
  String get currentUserRankTiedFirstLabel => 'Empate en 1.º';

  @override
  String rankLabel(int rank) {
    return '$rank.º';
  }

  @override
  String get homeScheduleRoutineSubtitle =>
      'Próximos horarios y rutina semanal';

  @override
  String get homeNextCommitmentTitle => 'Próximo evento';

  @override
  String get todayLabel => 'Hoy';

  @override
  String get statisticsTitle => 'Estadísticas';

  @override
  String get studiedTimeLabel => 'Tiempo estudiado';

  @override
  String get readingTimeLabel => 'Tiempo leído';

  @override
  String get totalPagesReadLabel => 'Total de páginas';

  @override
  String get pagesReadTodayLabel => 'Páginas hoy';

  @override
  String get goalLabel => 'Meta';

  @override
  String get sessionsLabel => 'Sesiones';

  @override
  String get restLabel => 'Descanso';

  @override
  String get comparativesTitle => 'Comparativos';

  @override
  String get overviewTitle => 'Visión general';

  @override
  String get studiedUnit => 'estudiados';

  @override
  String get readPagesUnit => 'leídas';

  @override
  String get versusLastMonth => 'vs mes pasado';

  @override
  String get versusLastWeek => 'vs semana pasada';

  @override
  String get noPreviousPeriodComparison => 'Sin período anterior para comparar';

  @override
  String get noTimeLabel => 'Sin horario';

  @override
  String untilTimeLabel(String time) {
    return 'Hasta $time';
  }

  @override
  String get achievementsUnlockedSuffix => ' /50 desbloqueados';

  @override
  String get currentLevelLabel => 'Nivel actual';

  @override
  String get allAchievementsUnlockedLabel => 'Todo desbloqueado';

  @override
  String get nextUnlockLabel => 'Próximo logro';

  @override
  String get allAchievementsUnlockedDescription => 'Desbloqueaste todo.';

  @override
  String xpToGo(int xp) {
    return 'Faltan $xp XP';
  }

  @override
  String levelLabel(int level) {
    return 'Nivel $level';
  }

  @override
  String get allFilterLabel => 'Todos';

  @override
  String get unlockedFilterLabel => 'Desbloqueados';

  @override
  String get lockedFilterLabel => 'Bloqueados';

  @override
  String get selectCategoryTooltip => 'Seleccionar categoría';

  @override
  String get allCategoriesLabel => 'Todas las categorías';

  @override
  String get byCategoryLabel => 'Por categoría';

  @override
  String get allLevelsTitle => 'Todos los niveles';

  @override
  String get allLevelsDescription => 'Desbloquea logros para subir de nivel.';

  @override
  String levelPlusLabel(int level) {
    return 'Nivel $level+';
  }

  @override
  String get currentLabel => 'Actual';

  @override
  String rankTierLearner(String tier) {
    return 'Aprendiz $tier';
  }

  @override
  String get achievementCategoryFocus => 'Enfoque';

  @override
  String get achievementCategoryStudy => 'Estudio';

  @override
  String get achievementCategoryReading => 'Lectura';

  @override
  String get achievementCategoryGoals => 'Metas';

  @override
  String get achievementCategoryLifestyle => 'Estilo de vida';

  @override
  String get achievement1Title => 'Primer enfoque';

  @override
  String get achievement1Description => 'Completa tu primera sesión de enfoque';

  @override
  String get achievement2Title => 'Inicio de 25 min';

  @override
  String get achievement2Description => 'Enfócate durante 25 minutos';

  @override
  String get achievement3Title => '1 hora de enfoque';

  @override
  String get achievement3Description => 'Enfócate durante 1 hora';

  @override
  String get achievement4Title => 'Enfoque profundo';

  @override
  String get achievement4Description => 'Alcanza 2 horas de enfoque';

  @override
  String get achievement5Title => 'Cero distracciones';

  @override
  String get achievement5Description => 'Completa 3 sesiones de enfoque';

  @override
  String get achievement6Title => 'Maratón de enfoque';

  @override
  String get achievement6Description => 'Alcanza 10 horas de enfoque';

  @override
  String get achievement7Title => 'Madrugador';

  @override
  String get achievement7Description => 'Registra enfoque en 5 días';

  @override
  String get achievement8Title => 'Nocturno';

  @override
  String get achievement8Description => 'Completa 10 sesiones de enfoque';

  @override
  String get achievement9Title => 'Racha de enfoque';

  @override
  String get achievement9Description => 'Registra enfoque en 7 días';

  @override
  String get achievement10Title => 'Maestro del enfoque';

  @override
  String get achievement10Description => 'Alcanza 25 horas de enfoque';

  @override
  String get achievement11Title => 'Estudio iniciado';

  @override
  String get achievement11Description => 'Crea tu primer registro de estudio';

  @override
  String get achievement12Title => '3 sesiones';

  @override
  String get achievement12Description => 'Completa 3 sesiones';

  @override
  String get achievement13Title => '5 sesiones';

  @override
  String get achievement13Description => 'Completa 5 sesiones';

  @override
  String get achievement14Title => '10 sesiones';

  @override
  String get achievement14Description => 'Completa 10 sesiones';

  @override
  String get achievement15Title => 'Explorador de materias';

  @override
  String get achievement15Description => 'Estudia al menos una materia';

  @override
  String get achievement16Title => 'Héroe de revisión';

  @override
  String get achievement16Description => 'Alcanza 5 horas estudiando';

  @override
  String get achievement17Title => 'Quiz finalizado';

  @override
  String get achievement17Description => 'Completa 15 sesiones';

  @override
  String get achievement18Title => 'Planificador de estudios';

  @override
  String get achievement18Description => 'Crea una meta de enfoque';

  @override
  String get achievement19Title => 'Listo para el examen';

  @override
  String get achievement19Description => 'Alcanza 20 horas estudiando';

  @override
  String get achievement20Title => 'Modo estudiante';

  @override
  String get achievement20Description => 'Alcanza 50 horas estudiando';

  @override
  String get achievement21Title => 'Primera página';

  @override
  String get achievement21Description => 'Lee tu primera página';

  @override
  String get achievement22Title => '10 páginas';

  @override
  String get achievement22Description => 'Lee 10 páginas';

  @override
  String get achievement23Title => '25 páginas';

  @override
  String get achievement23Description => 'Lee 25 páginas';

  @override
  String get achievement24Title => '50 páginas';

  @override
  String get achievement24Description => 'Lee 50 páginas';

  @override
  String get achievement25Title => '100 páginas';

  @override
  String get achievement25Description => 'Lee 100 páginas';

  @override
  String get achievement26Title => 'Capítulo completo';

  @override
  String get achievement26Description => 'Lee 150 páginas';

  @override
  String get achievement27Title => 'Lector de fin de semana';

  @override
  String get achievement27Description => 'Lee 250 páginas';

  @override
  String get achievement28Title => 'Lector diario';

  @override
  String get achievement28Description => 'Lee 300 páginas';

  @override
  String get achievement29Title => 'Lector dedicado';

  @override
  String get achievement29Description => 'Lee 500 páginas';

  @override
  String get achievement30Title => 'Leyenda de biblioteca';

  @override
  String get achievement30Description => 'Lee 1000 páginas';

  @override
  String get achievement31Title => 'Primera meta';

  @override
  String get achievement31Description => 'Crea tu primera meta';

  @override
  String get achievement32Title => 'Meta lograda';

  @override
  String get achievement32Description => 'Completa una meta';

  @override
  String get achievement33Title => 'Todas las metas hechas';

  @override
  String get achievement33Description => 'Termina todas las metas hoy';

  @override
  String get achievement34Title => 'Rutina de mañana';

  @override
  String get achievement34Description => 'Completa metas en 3 días';

  @override
  String get achievement35Title => 'Día equilibrado';

  @override
  String get achievement35Description => 'Completa metas en 5 días';

  @override
  String get achievement36Title => 'Constructor de hábito';

  @override
  String get achievement36Description => 'Completa metas en 10 días';

  @override
  String get achievement37Title => 'Día perfecto';

  @override
  String get achievement37Description => 'Completa metas en 15 días';

  @override
  String get achievement38Title => 'Regreso';

  @override
  String get achievement38Description => 'Completa metas en 20 días';

  @override
  String get achievement39Title => 'Estrella constante';

  @override
  String get achievement39Description => 'Completa metas en 30 días';

  @override
  String get achievement40Title => 'Imparable';

  @override
  String get achievement40Description => 'Completa metas en 50 días';

  @override
  String get achievement41Title => 'Primer grupo';

  @override
  String get achievement41Description => 'Únete a un grupo de estudio';

  @override
  String get achievement42Title => 'Jugador de equipo';

  @override
  String get achievement42Description => 'Compite con amigos';

  @override
  String get achievement43Title => 'Amigo servicial';

  @override
  String get achievement43Description => 'Ayuda a un amigo a ser constante';

  @override
  String get achievement44Title => 'Ganador de desafío';

  @override
  String get achievement44Description => 'Gana un desafío';

  @override
  String get achievement45Title => 'Ejercicio iniciado';

  @override
  String get achievement45Description => 'Registra enfoque en ejercicio';

  @override
  String get achievement46Title => 'Entreno de 30 min';

  @override
  String get achievement46Description => 'Haz ejercicio durante 30 minutos';

  @override
  String get achievement47Title => 'Hora del hobby';

  @override
  String get achievement47Description => 'Registra enfoque en hobby';

  @override
  String get achievement48Title => 'Chispa creativa';

  @override
  String get achievement48Description => 'Alcanza 30 minutos en hobbies';

  @override
  String get achievement49Title => 'Guerrero de fin de semana';

  @override
  String get achievement49Description => 'Alcanza 2 horas de ejercicio';

  @override
  String get achievement50Title => 'Cazador de logros';

  @override
  String get achievement50Description => 'Desbloquea 25 logros';

  @override
  String get achievementUnlockedNotificationTitle => 'Logro desbloqueado';

  @override
  String get rankTierPaper => 'Papel';

  @override
  String get rankTierWood => 'Madera';

  @override
  String get rankTierStone => 'Piedra';

  @override
  String get rankTierCopper => 'Cobre';

  @override
  String get rankTierBronze => 'Bronce';

  @override
  String get rankTierIron => 'Hierro';

  @override
  String get rankTierSilver => 'Plata';

  @override
  String get rankTierGold => 'Oro';

  @override
  String get rankTierPlatinum => 'Platino';

  @override
  String get rankTierAmethyst => 'Amatista';

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
  String get concentrationModeTitle => 'Modo de concentración';

  @override
  String get concentrationModeSubtitle =>
      'Elige qué sesiones bloquean la salida de la app.';

  @override
  String get concentrationStudyTitle => 'Estudio';

  @override
  String get concentrationStudySubtitle => 'Enfoque total en tus estudios.';

  @override
  String get concentrationExercisesTitle => 'Ejercicios';

  @override
  String get concentrationExercisesSubtitle =>
      'Concéntrate en tus entrenamientos.';

  @override
  String get concentrationReadingTitle => 'Lectura';

  @override
  String get concentrationReadingSubtitle => 'Sumérgete en tus lecturas.';

  @override
  String get concentrationHobbiesTitle => 'Hobbies';

  @override
  String get concentrationHobbiesSubtitle =>
      'Disfruta tus hobbies con enfoque.';

  @override
  String get createGroupDescriptionLabel => 'Descripción';

  @override
  String get createGroupDescriptionHint =>
      'Describe el grupo y cuál es su objetivo.';

  @override
  String get createGroupThemeMetricDescription =>
      'Este tema define la métrica del ranking.';

  @override
  String get createGroupActivityTypeDescription =>
      'Cada integrante recibe una copia para hacer seguimiento.';

  @override
  String get createGroupActivityNameLabel => 'Nombre de la actividad';

  @override
  String get createGroupActivityNameHint => 'Ej: Cálculo I';

  @override
  String get createGroupGoalTypeLabel => 'Tipo de meta';

  @override
  String get createGroupGoalTypeTotal => 'Total';

  @override
  String get createGroupGoalTypeDaily => 'Diaria';

  @override
  String get createGroupDaysGoalLabel => 'Meta de días';

  @override
  String get createGroupPagesGoalLabel => 'Meta de páginas';

  @override
  String get createGroupTimeGoalMinutesLabel => 'Meta de tiempo (min)';

  @override
  String get createGroupSummaryTitle => 'Resumen del grupo';

  @override
  String get createGroupActivitySummaryLabel => 'Actividad';

  @override
  String get createGroupGuestsLabel => 'Invitados';

  @override
  String get timerTotalTodayLabel => 'Total hoy';

  @override
  String get timerEndActionLabel => 'Finalizar';

  @override
  String get createGroupActivityStepSubtitle =>
      'Elige la actividad que todos en el grupo harán.';

  @override
  String get createGroupFriendsStepSubtitle =>
      'Invita al menos a 1 amigo para participar.';

  @override
  String get createGroupSummaryStepSubtitle =>
      'Revisa los datos antes de crear.';

  @override
  String get createGroupStepInformation => 'Información';

  @override
  String get createGroupStepActivity => 'Actividad';

  @override
  String get createGroupStepFriends => 'Amigos';

  @override
  String get createGroupStepSummary => 'Resumen';

  @override
  String get createGroupDaysGoalHint => 'Ej: 30';

  @override
  String get createGroupPagesGoalHint => 'Ej: 10';

  @override
  String get createGroupMinutesGoalHint => 'Ej: 30';

  @override
  String get createGroupAddFriendsPromptTitle => '¿No encontraste a alguien?';

  @override
  String get createGroupAddFriendsPromptDescription =>
      'Agrega más amigos para poder invitarlos.';

  @override
  String get createGroupContinueButton => 'Continuar';

  @override
  String get createGroupActivitySummaryDaily => 'Meta diaria';

  @override
  String createGroupActivitySummaryGoalDays(String days) {
    return 'Meta • $days días';
  }

  @override
  String createGroupActivitySummaryReading(String pages) {
    return 'Lectura • $pages páginas';
  }

  @override
  String createGroupActivitySummaryTime(String category, String minutes) {
    return '$category • $minutes min';
  }

  @override
  String get createGroupActivityRequiredError =>
      'Elige una actividad para el grupo.';

  @override
  String get createGroupActivityNameRequiredError =>
      'Dale un nombre a la actividad.';

  @override
  String get createGroupActivityGoalInvalidError => 'Define una meta válida.';

  @override
  String get createGroupActivityMissingError =>
      'Define la actividad del grupo.';

  @override
  String get timerBackTooltip => 'Volver';

  @override
  String get timerRestMessageTitle => 'Descansa un poco';

  @override
  String get timerFocusLabel => 'Enfoque';

  @override
  String get timerReadingLabel => 'Lectura';

  @override
  String get timerPauseLabel => 'Pausa';

  @override
  String get timerReadingTimeLabel => 'tiempo de lectura';

  @override
  String timerTotalOfLabel(String duration) {
    return 'de $duration';
  }

  @override
  String get timerCurrentPagesLabel => 'Páginas actuales';

  @override
  String get timerNotesLabel => 'Notas';

  @override
  String get concentrationModeSheetDescription =>
      'Cuando está activado, la app te ayuda a mantenerte concentrado durante la actividad hasta que pauses o finalices.';

  @override
  String get timerFocusLockWarning =>
      'El modo de concentración está activo. Termina o pausa la sesión para salir.';

  @override
  String timerProgressSemanticLabel(int percent) {
    return 'Progreso: $percent%';
  }

  @override
  String homeStreakLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días seguidos',
      one: '$count día seguido',
    );
    return '$_temp0';
  }

  @override
  String homeCategoryEmptyValue(String item) {
    return 'Agrega $item para empezar';
  }

  @override
  String get groupInvitesNoFriendsTitle => 'No hay amigos disponibles';

  @override
  String get groupInvitesNoFriendsDescription =>
      'Agrega amigos antes de invitar a más personas a este grupo.';

  @override
  String get groupInvitationsReceivedEmptyTitle => 'No recibiste invitaciones';

  @override
  String get groupInvitationsReceivedEmptyDescription =>
      'Cuando alguien te invite a un grupo, aparecerá aquí.';

  @override
  String get groupInvitationsSentEmptyTitle => 'No enviaste invitaciones';

  @override
  String get groupInvitationsSentEmptyDescription =>
      'Las invitaciones que envíes para unirse a un grupo aparecerán aquí.';

  @override
  String get swipeHintDismissLabel => 'Entendido';

  @override
  String get dailyGoalSwipeHintTitle => 'Gestos de la meta';

  @override
  String get dailyGoalSwipeHintMessage =>
      'Desliza una meta para editarla o eliminarla. Algunas acciones pueden estar bloqueadas para metas de grupo.';

  @override
  String get activitySwipeHintTitle => 'Gestos de la actividad';

  @override
  String get activitySwipeHintMessage =>
      'Desliza una actividad para ver notas, datos, editarla o eliminarla. Algunas acciones pueden estar bloqueadas para elementos de grupo.';

  @override
  String get groupGoalEditBlockedMessage =>
      'Esta meta pertenece a un grupo. Edítala desde el grupo para cambiarla.';

  @override
  String get groupGoalDeleteBlockedMessage =>
      'Esta meta pertenece a un grupo. Sal del grupo para eliminarla.';

  @override
  String get groupActivityEditBlockedMessage =>
      'Esta actividad pertenece a un grupo. Edítala desde el grupo para cambiarla.';

  @override
  String get groupActivityDeleteBlockedMessage =>
      'Esta actividad pertenece a un grupo. Sal del grupo para eliminarla.';

  @override
  String get groupUpdatedSuccess => 'Grupo actualizado correctamente';

  @override
  String get groupInviteCanceledMessage => 'Invitación cancelada.';

  @override
  String get groupInviteSentMessage => 'Invitación enviada.';

  @override
  String get timerReadingReminderBody =>
      'Completaste otros 30 minutos de lectura.';

  @override
  String get timerHobbyFinishedBody => 'Práctica de hobby completada.';

  @override
  String get timerFocusFinishedBody => 'Sesión completada. Hora de descansar.';

  @override
  String get timerRestFinishedBody => 'Comenzó una nueva sesión.';

  @override
  String get timerSessionFinishedBody => 'Actividad completada.';

  @override
  String get timerBackgroundSuffix => 'App en segundo plano';

  @override
  String get timerBreakStatLabel => 'Pausa';

  @override
  String get timerSessionEndedTitle => 'Sesión finalizada';

  @override
  String timerSessionEndedMessage(String subjectName) {
    return 'Tu enfoque en $subjectName se guardó correctamente.';
  }

  @override
  String get createSubjectPauseDurationHint => 'Duración de la pausa';

  @override
  String get groupInvitationsTitle => 'Invitaciones';

  @override
  String groupInvitationFrom(String inviter) {
    return 'Invitación de $inviter';
  }

  @override
  String get groupsLoadErrorTitle => 'No se pudieron cargar los grupos';

  @override
  String get groupsLoadErrorDescription =>
      'La conexión tardó más de lo esperado. Tus grupos pueden seguir existiendo, pero no pudimos cargarlos ahora.';

  @override
  String get personalInformationTitle => 'Información personal';

  @override
  String get editGroupInfoSection => 'Información del grupo';

  @override
  String get createGroupFocusGoalLabel => 'Meta de concentración';

  @override
  String get connectedAccountsSection => 'Cuentas conectadas';

  @override
  String get contactSection => 'Contacto';

  @override
  String get receivedTab => 'Recibidas';

  @override
  String invitedPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas invitadas',
      one: '1 persona invitada',
    );
    return '$_temp0';
  }

  @override
  String get inviteMembersTitle => 'Invitar miembros';

  @override
  String get invitedLabel => 'Invitado';

  @override
  String get selectButton => 'Seleccionar';

  @override
  String get cancelInviteConfirmTitle => '¿Cancelar invitación?';

  @override
  String get inviteFriendConfirmTitle => '¿Invitar amigo?';

  @override
  String cancelInviteConfirmMessage(String friendName) {
    return '¿Cancelar la invitación enviada a $friendName?';
  }

  @override
  String inviteFriendConfirmMessage(String friendName, String groupName) {
    return '¿Invitar a $friendName a $groupName?';
  }

  @override
  String get cancelInviteButton => 'Cancelar invitación';

  @override
  String get inviteButton => 'Invitar';

  @override
  String get retryButton => 'Intentar de nuevo';

  @override
  String get timerSessionEndedConfirm => 'Todo listo';
}
