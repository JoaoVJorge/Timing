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
  String get loginSubtitle => 'Inicia sesión para empezar.';

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
    return 'Siguiente: $title a las $time';
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
  String get homeNextScheduleTitle => 'Siguiente';

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
  String get targetDaysHint => 'Objetivo personalizado (días)';

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
  String get categoryStudying => 'Estudiando';

  @override
  String get categoryExercises => 'Ejercicio';

  @override
  String get categoryReading => 'Leyendo';

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
  String get musicSuggestionLabel => 'Sugerencia de música';

  @override
  String get musicSuggestionHint => 'p. ej. Lo-fi beats';

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
  String timerMusicSuggestion(String name) {
    return 'Sugerencia: $name';
  }

  @override
  String get timerNotificationRunning => 'Sesión de concentración en curso';

  @override
  String get timerNotificationResting => 'Descansando — vuelve pronto';

  @override
  String get timerNotificationPaused => 'Pausado';

  @override
  String get profileTitle => 'Tu Perfil';

  @override
  String get profileSubtitleDefault => 'Logros';

  @override
  String profileSubtitleWithName(String userName) {
    return 'Buen trabajo, $userName';
  }

  @override
  String get statHoursStudied => 'Horas estudiadas';

  @override
  String get statTopSubjectFallback => '—';

  @override
  String get statTopSubject => 'Materia principal';

  @override
  String get statHoursExercised => 'Horas de ejercicio';

  @override
  String get statHoursRead => 'Horas leídas';

  @override
  String get mostReadThemes => 'Temas más leídos';

  @override
  String get noReadingYet => 'Lee algo para ver aquí tus temas favoritos.';

  @override
  String get groupsTitle => 'Grupos';

  @override
  String get noGroupSelected => 'Ningún grupo seleccionado todavía.';

  @override
  String get newGroupChip => 'Nuevo grupo';

  @override
  String get periodToday => 'Hoy';

  @override
  String get periodThisWeek => 'Esta semana';

  @override
  String get periodThisMonth => 'Este mes';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get myProfileFallback => 'Mi Perfil';

  @override
  String get preferencesSection => 'Preferencias';

  @override
  String get darkModeLabel => 'Modo oscuro';

  @override
  String get notificationsLabel => 'Notificaciones';

  @override
  String get language => 'Idioma';

  @override
  String get supportSection => 'Soporte';

  @override
  String get faqLabel => 'Preguntas frecuentes';

  @override
  String get aboutLabel => 'Acerca de';

  @override
  String appVersionLabel(String appTitle, String appVersion) {
    return '$appTitle v$appVersion';
  }

  @override
  String get accountSection => 'Cuenta';

  @override
  String get logOutLabel => 'Cerrar sesión';

  @override
  String get logOutDialogTitle => 'Cerrar sesión';

  @override
  String get logOutDialogContent =>
      'Esto borra tu perfil local de este dispositivo. Siempre puedes configurarlo de nuevo.';

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
      'Los grupos muestran una clasificación con las horas estudiadas por todos. Cambia entre Hoy, Esta Semana y Este Mes para ver quién estudió más en ese período.';

  @override
  String get faqQ5 => '¿Puedo cambiar el tema de colores de la app?';

  @override
  String get faqA5 =>
      'Sí, ve a Configuración > Mi Perfil y elige cualquier color de tema. Cada gradiente, botón y detalle de la app se actualiza para combinar, incluido el modo oscuro.';

  @override
  String get createGroupTitle => 'Crear Grupo';

  @override
  String get groupNameHint => 'Nombre del grupo';

  @override
  String get groupThemeLabel => 'Tema';

  @override
  String get inviteFriendsLabel => 'Invitar amigos';

  @override
  String get createGroupButton => 'Crear Grupo';

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
  String get noScheduleYet => 'Todavía no hay horarios — toca para agregar';

  @override
  String get addScheduleEntryTitle => 'Agregar Horario';

  @override
  String get addScheduleEntryButton => 'Agregar Horario';

  @override
  String get scheduleTitleHint => 'Título';

  @override
  String get startTimeLabel => 'Hora de inicio';

  @override
  String get endTimeOptionalLabel => 'Hora de fin (opcional)';

  @override
  String get incompleteScheduleEntryError =>
      'Registro incompleto — completa el título y una hora de inicio válida.';

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
  String get phoneLoginTitle => 'Iniciar sesión';

  @override
  String get phoneLoginSubtitle =>
      'Ingresa tu número de teléfono y te enviaremos un código de verificación por SMS.';

  @override
  String get sendCodeButton => 'Enviar código';

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
  String get codeResentMessage => 'Código de verificación enviado';

  @override
  String get invalidCodeError => 'Código no válido. Inténtalo de nuevo.';

  @override
  String get credentialsTitle => 'Casi listo';

  @override
  String get credentialsSubtitle => 'Cuéntanos un poco sobre ti.';

  @override
  String get birthDateHint => 'Fecha de nacimiento';

  @override
  String get finishButton => 'Finalizar';
}
