// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Timing';

  @override
  String get genericErrorMessage =>
      'Etwas ist schief gelaufen. Bitte versuchen Sie es später noch einmal.';

  @override
  String get loginHeadline => 'Fangen wir an';

  @override
  String get loginSubtitle =>
      'Melden Sie sich an, um weiter zu lernen und Ihren Tagesablauf zu organisieren.';

  @override
  String get loginNameHint => 'Dein Name';

  @override
  String get loginButton => 'Fangen wir an';

  @override
  String get homeGreetingDefault => 'Hallo';

  @override
  String homeGreetingWithName(String userName) {
    return 'Hallo, $userName';
  }

  @override
  String get homeSubtitle => 'Was packen wir heute an?';

  @override
  String homeSubtitleFocusedToday(String duration) {
    return 'Sie haben heute $duration fokussiert';
  }

  @override
  String homeSubtitleNextSchedule(String title, String time) {
    return 'Agenda: $title und $time';
  }

  @override
  String get homeSubtitleStart => 'Beginnen Sie Ihre erste Fokussitzung';

  @override
  String get homeTasksSection => 'Tägliche Ziele';

  @override
  String get homeCategoriesSection => 'Aktivitäten';

  @override
  String get homeActionContinueEyebrow => 'Fahren Sie jetzt fort';

  @override
  String get homeActionContinueButton => 'Weiter';

  @override
  String get homeActionStartEyebrow => 'Beginnen Sie mit der Konzentration';

  @override
  String get homeActionStartButton => 'Starten';

  @override
  String get homeActionSuggestedMeta => 'Ihr am häufigsten verfolgtes Thema';

  @override
  String get homeActionCreateBody =>
      'Erstellen Sie Ihr erstes Thema, um eine Fokussitzung zu starten.';

  @override
  String get homeActionCreateButton => 'Betreff erstellen';

  @override
  String get homeSummaryTitle => 'Die heutige Zusammenfassung';

  @override
  String get homeSummaryFocus => 'Konzentrieren Sie sich';

  @override
  String get homeSummaryGoals => 'Ziele';

  @override
  String get homeSummaryPages => 'Seiten';

  @override
  String get homeSummarySessions => 'Sitzungen';

  @override
  String homeGoalsProgress(int done, int total) {
    return '$done von $total fertig';
  }

  @override
  String get homeCategoryEmpty => 'Noch nichts';

  @override
  String get homeNextScheduleTitle => 'Tagesordnung';

  @override
  String get homeTodayAgendaTitle => 'Die heutige Tagesordnung';

  @override
  String get homeNextScheduleEmpty => 'Heute gibt es keinen Zeitplan';

  @override
  String get homeNextScheduleAdd => 'Zeitplan hinzufügen';

  @override
  String get addTaskButton => 'Ziel hinzufügen';

  @override
  String get createTaskTitle => 'Neues Ziel';

  @override
  String get taskNameHint => 'Zielname';

  @override
  String get targetDaysLabel => 'Ziel (Tage)';

  @override
  String targetDaysChip(int days) {
    return '$days Tage';
  }

  @override
  String get targetDaysHint => 'Benutzerdefiniertes Ziel';

  @override
  String taskDaysProgress(int completed, int target) {
    return '$completed/$target Tage';
  }

  @override
  String get taskCompletedLabel => 'Fertig!';

  @override
  String get lastActivityLabel => 'Letzte Aktivität';

  @override
  String get lastActivityNone => 'Noch nichts – fangen Sie etwas an!';

  @override
  String get lastActivityJustNow => 'gerade jetzt';

  @override
  String lastActivityMinutesAgo(int minutes) {
    return 'Vor $minutes Min';
  }

  @override
  String lastActivityHoursAgo(int hours) {
    return 'Vor $hours h';
  }

  @override
  String lastActivityDaysAgo(int days) {
    return 'Vor $days d';
  }

  @override
  String get categoryStudying => 'Studien';

  @override
  String get categoryExercises => 'Trainieren';

  @override
  String get categoryReading => 'Lesen';

  @override
  String get categoryHobbies => 'Hobbys';

  @override
  String get itemNounStudying => 'Betreff';

  @override
  String get itemNounExercises => 'Übung';

  @override
  String get itemNounReading => 'Buch';

  @override
  String get itemNounHobbies => 'Hobby';

  @override
  String get iconLabel => 'Symbol';

  @override
  String get restTimeLabel => 'Ruhezeit';

  @override
  String restMinutesChip(int minutes) {
    return '$minutes min';
  }

  @override
  String get timeUnitHoursSuffix => 'h';

  @override
  String get timeUnitMinutesSuffix => 'min';

  @override
  String get wallpaperLabel => 'Timer-Hintergrundbild';

  @override
  String addItemButton(String itemNoun) {
    return 'Fügen Sie $itemNoun hinzu';
  }

  @override
  String itemNameHint(String itemNoun) {
    return '$itemNoun-Name';
  }

  @override
  String get colorLabel => 'Farbe';

  @override
  String get bookThemeLabel => 'Buchthema';

  @override
  String get estimatedHoursGoalHint => 'Ziel in wenigen Minuten';

  @override
  String get goalPagesHint => 'Ziel (Seiten)';

  @override
  String get cancelButton => 'Abbrechen';

  @override
  String get confirmButton => 'Bestätigen';

  @override
  String get addButton => 'Hinzufügen';

  @override
  String get createSubjectTitleStudying => 'Neues Thema';

  @override
  String get createSubjectTitleReading => 'Neue Lektüre';

  @override
  String get createSubjectTitleExercises => 'Neues Training';

  @override
  String get createSubjectTitleHobbies => 'Neues Hobby';

  @override
  String get createSubjectSubtitleStudying =>
      'Setzen Sie sich ein Ziel und personalisieren Sie Ihren Fokus';

  @override
  String get createSubjectSubtitleReading =>
      'Verfolgen Sie Seiten und personalisieren Sie Ihre Lektüre';

  @override
  String get createSubjectSubtitleExercises =>
      'Wählen Sie aus, wie Sie diese Aktivität verfolgen möchten';

  @override
  String get createSubjectSubtitleHobbies =>
      'Wählen Sie aus, wie Sie dieses Hobby verfolgen möchten';

  @override
  String get createSubjectBasicSection => 'Grundlegende Informationen';

  @override
  String get createSubjectGoalSection => 'Ziel';

  @override
  String get createSubjectRoutineSection => 'Routine';

  @override
  String get createSubjectPersonalizationSection => 'Personalisierung';

  @override
  String get createSubjectNameLabelStudying => 'Betreffname';

  @override
  String get createSubjectNameLabelReading => 'Namen lesen';

  @override
  String get createSubjectNameLabelExercises => 'Aktivitätsname';

  @override
  String get createSubjectNameLabelHobbies => 'Hobbyname';

  @override
  String get createSubjectNameHintStudying =>
      'Bsp.: Biologie, Mathematik, Englisch';

  @override
  String get createSubjectNameHintReading =>
      'Bsp.: Geschichtsbuch, Dom Casmurro';

  @override
  String get createSubjectNameHintExercises =>
      'Bsp.: Fitnessstudio, Laufen, Stretching';

  @override
  String get createSubjectNameHintHobbies =>
      'Bsp.: Gitarre, Zeichnen, Programmieren';

  @override
  String get createSubjectTimeGoalLabel => 'Fokusziel';

  @override
  String get createSubjectPagesGoalLabel => 'Seitenziel';

  @override
  String get createSubjectTimeGoalHelp =>
      'Auf wie viele Minuten möchten Sie sich konzentrieren?';

  @override
  String get createSubjectPagesGoalHelp =>
      'Wie viele Seiten möchten Sie insgesamt anmelden?';

  @override
  String get createSubjectRestLabel => 'Machen Sie nach jedem Fokus eine Pause';

  @override
  String get createSubjectRestHelp =>
      'Der Timer schlägt nach 30 Minuten Fokus eine Pause vor.';

  @override
  String get customRestMinutesHint => 'Benutzerdefinierte Pause (Min.)';

  @override
  String get createSubjectPreviewTitle => 'Vorschau';

  @override
  String get createSubjectPreviewNoGoal => 'Kein Ziel gesetzt';

  @override
  String createSubjectPreviewGoal(String goal) {
    return 'Ziel: $goal';
  }

  @override
  String createSubjectPreviewRest(int minutes) {
    return 'Pause: $minutes min';
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
  String createSubjectPagesValue(int value) {
    return '$value Seiten';
  }

  @override
  String createSubjectColorSemantic(int index) {
    return 'Farbe $index';
  }

  @override
  String get createSubjectButtonStudying => 'Betreff erstellen';

  @override
  String get createSubjectButtonReading => 'Lektüre schaffen';

  @override
  String get createSubjectButtonExercises => 'Aktivität erstellen';

  @override
  String get createSubjectButtonHobbies => 'Hobby erstellen';

  @override
  String get createSubjectMissingName =>
      'Geben Sie einen Namen ein, um fortzufahren';

  @override
  String get createSubjectMissingTimeGoal =>
      'Legen Sie ein gültiges Fokusziel fest';

  @override
  String get createSubjectMissingPagesGoal =>
      'Legen Sie ein gültiges Seitenziel fest';

  @override
  String get createSubjectSuccessStudying => 'Betreff erfolgreich erstellt';

  @override
  String get createSubjectSuccessReading => 'Lesung erfolgreich erstellt';

  @override
  String get createSubjectSuccessExercises => 'Aktivität erfolgreich erstellt';

  @override
  String get createSubjectSuccessHobbies => 'Hobby erfolgreich erstellt';

  @override
  String pagesProgress(int currentPages, int goalPages) {
    return '$currentPages von $goalPages Seiten';
  }

  @override
  String pagesReadOnly(int currentPages) {
    return '$currentPages Seiten gelesen';
  }

  @override
  String get pagesReadNowHint => 'Seiten jetzt gelesen';

  @override
  String get logPagesButton => 'Protokollseiten';

  @override
  String get notesLabel => 'Notizen';

  @override
  String get notesHint => 'Schreiben Sie hier Ihre Notizen...';

  @override
  String get saveNotesButton => 'Speichern';

  @override
  String get addNotesPageTooltip => 'Seite hinzufügen';

  @override
  String notesPageCounter(int currentPage, int pageCount) {
    return 'Seite $currentPage von $pageCount';
  }

  @override
  String durationProgress(String duration, String goalDuration) {
    return '$duration von $goalDuration';
  }

  @override
  String timerTotalLabel(String duration) {
    return 'Gesamt: $duration';
  }

  @override
  String timerNextBreakLabel(String duration) {
    return 'Nächste Pause in $duration';
  }

  @override
  String timerRestingLabel(String duration) {
    return 'Ausruhen – zurück in $duration';
  }

  @override
  String get timerNotificationRunning => 'Fokussitzung läuft';

  @override
  String get timerNotificationResting => 'Ausruhen – bald zurück';

  @override
  String get timerNotificationPaused => 'Angehalten';

  @override
  String get timerStateFocusingTitle => 'Fokus im Gange';

  @override
  String get timerStateFocusingDescription =>
      'Behalten Sie Ihren Fokus. Eine Pause wird bald vorgeschlagen.';

  @override
  String get timerStatePausedTitle => 'Timer angehalten';

  @override
  String get timerStatePausedDescription =>
      'Fahren Sie fort, wenn Sie bereit sind.';

  @override
  String get timerStateRestingTitle => 'Wohlverdiente Pause';

  @override
  String get timerStateRestingDescription =>
      'Trinken Sie Wasser oder atmen Sie ein wenig, bevor Sie fortfahren.';

  @override
  String get timerSessionSavedTitle => 'Sitzung protokolliert';

  @override
  String get timerSessionSavedDescription =>
      'Ihre Zeit wurde dem Betreff hinzugefügt.';

  @override
  String get timerCurrentFocusLabel => 'Konzentrierte Zeit jetzt';

  @override
  String get timerRestTimeLabel => 'Pausenzeit';

  @override
  String get timerSessionLabel => 'Aktuelle Sitzung';

  @override
  String timerTotalInSubject(String subjectName) {
    return 'Gesamt in $subjectName';
  }

  @override
  String get timerPauseButton => 'Pause';

  @override
  String get timerContinueButton => 'Weiter';

  @override
  String get timerContinueFocusButton => 'Weiter';

  @override
  String get timerSkipRestButton => 'Pause überspringen';

  @override
  String get timerEndSessionButton => 'Sitzung beenden';

  @override
  String get timerStartAnotherSessionButton =>
      'Starten Sie eine weitere Sitzung';

  @override
  String get timerSaveReassurance =>
      'Der Fortschritt wird auch gespeichert, wenn Sie pausieren oder gehen.';

  @override
  String timerFocusedValue(String duration) {
    return '$duration fokussiert';
  }

  @override
  String get timerAccumulatedTotalLabel => 'Kumulierte Summe';

  @override
  String get timerBackToSubjectsButton => 'Zurück';

  @override
  String get timerExitDialogTitle => 'Sitzung beenden?';

  @override
  String timerExitDialogContent(String duration, String subjectName) {
    return 'Ihr $duration-Fortschritt wird in $subjectName gespeichert.';
  }

  @override
  String get timerExitDialogCancel => 'Weiter';

  @override
  String get timerExitDialogContinueLater => 'Sie können später fortfahren.';

  @override
  String get timerExitDialogConfirm => 'Ende';

  @override
  String get editButton => 'Bearbeiten';

  @override
  String get nicknameFallback => 'Benutzer';

  @override
  String get profileSummaryLabel => 'Gesamtzusammenfassung';

  @override
  String get profileSummarySinceStartLabel => 'Von Anfang an';

  @override
  String profileSummaryAccumulatedFocus(Object duration) {
    return '$duration des akkumulierten Fokus';
  }

  @override
  String get profileSummaryFocusLabel => 'Gesamte Fokuszeit';

  @override
  String get profileSummaryFocusDescription =>
      'Lernen, Sport treiben und Hobbys';

  @override
  String get statHoursStudied => 'Studieren';

  @override
  String get statHoursExercised => 'Übung';

  @override
  String get statPagesRead => 'Seiten gelesen';

  @override
  String get statTopSubject => 'Am meisten studiert';

  @override
  String get profileStatTimeEmptyTitle => 'Beginnen Sie mit Ihrem ersten Fokus';

  @override
  String get profileStatTimeEmptyDescription => 'Ihre Zeit wird hier angezeigt';

  @override
  String get profileStatExerciseEmptyTitle => 'Noch keine Übung';

  @override
  String get profileStatExerciseEmptyDescription =>
      'Protokollieren Sie Ihre erste Aktivität';

  @override
  String get profileStatReadingEmptyTitle => 'Noch keine Seiten';

  @override
  String get profileStatReadingEmptyDescription =>
      'Protokollieren Sie Ihre erste Lesung';

  @override
  String get profileTopSubjectEmptyTitle => 'Noch keine';

  @override
  String get profileTopSubjectEmptyDescription =>
      'Studieren Sie ein Thema, um es hier vorzustellen';

  @override
  String get profileEmptyTitle => 'Ihr Fortschritt beginnt hier';

  @override
  String get profileEmptyDescription =>
      'Starten Sie eine Sitzung, protokollieren Sie Lesevorgänge oder legen Sie von zu Hause aus ein Ziel fest, um Ihre Entwicklung in Timing zu verfolgen.';

  @override
  String get profileEmptyGuidance =>
      'Danach werden hier Ihre Gesamtzeit, Top-Aktivitäten und Lese-Highlights angezeigt.';

  @override
  String get profileEmptyStartButton => 'Beginnen Sie jetzt';

  @override
  String get profileShortcutsTitle => 'Verknüpfungen';

  @override
  String get profileShortcutCreateSubject => 'Betreff erstellen';

  @override
  String get profileShortcutCreateGoal => 'Ziel erstellen';

  @override
  String get profileShortcutAddSchedule => 'Zeitplan hinzufügen';

  @override
  String get profileEvolutionTitle => 'Ihr Fortschritt';

  @override
  String profileEvolutionFocus(String duration) {
    return 'Sie haben $duration Fokus angesammelt.';
  }

  @override
  String profileEvolutionTopSubject(String name) {
    return 'Ihr am häufigsten studiertes Fach ist $name.';
  }

  @override
  String profileEvolutionRemaining(String duration) {
    return 'Sie sind $duration von Ihrem Ziel entfernt.';
  }

  @override
  String get profileEvolutionGoalReached => 'Sie haben Ihr Fokusziel erreicht!';

  @override
  String get profileProgressSectionTitle => 'Ihr Fortschritt';

  @override
  String get profileAchievementsTitle => 'Erfolge';

  @override
  String get profileSeeHistory => 'Siehe Geschichte';

  @override
  String get profileSeeAll => 'Alle anzeigen';

  @override
  String get profileAchievementFirstUnlocked => '1. Erfolg';

  @override
  String get profileAchievementGoalStarted => 'Ziel gestartet';

  @override
  String get profileAchievementsStartHint =>
      'Fangen Sie an, Erfolge zu erzielen';

  @override
  String get profileAchievementFirstFocus => 'Erster Fokus';

  @override
  String get profileAchievementStudyStarted => 'Das Studium hat begonnen';

  @override
  String get profileAchievementReadingStarted => 'Das Lesen begann';

  @override
  String get profileAchievementLocked => 'Gesperrt';

  @override
  String get periodFiveDays => '5 Tage';

  @override
  String get periodWeek => '1 Woche';

  @override
  String get periodMonth => '1 Monat';

  @override
  String get periodTotal => 'Insgesamt';

  @override
  String get profileAgendaTitle => 'Der heutige Zeitplan';

  @override
  String get profileAgendaEmptyTitle => 'Kein Zeitplan geplant';

  @override
  String get profileAgendaEmptyDescription =>
      'Fügen Sie Blöcke hinzu, um Ihre Routine zu organisieren.';

  @override
  String get profileAgendaAddButton => 'Zeitplan hinzufügen';

  @override
  String get profileTopReadingTitle => 'Top Lektüre';

  @override
  String get profileTopReadingEmptyTitle => 'Keine Lesung protokolliert';

  @override
  String get profileTopReadingEmptyDescription =>
      'Lesen Sie die Protokollseiten, um hier Ihre Top-Themen zu sehen.';

  @override
  String get groupsTitle => 'Gruppen';

  @override
  String get groupsSubtitle => 'Vergleichen Sie Ihre Fortschritte mit Freunden';

  @override
  String get noGroupSelected => 'Noch keine Gruppe ausgewählt.';

  @override
  String get newGroupChip => 'Neu';

  @override
  String get groupHeaderCreateButton => 'Gruppe';

  @override
  String get groupsEmptyTitle => 'Noch keine Gruppen';

  @override
  String get groupsEmptyDescription =>
      'Erstellen Sie eine Gruppe, um Fortschritte mit Freunden zu vergleichen und den Schwung aufrechtzuerhalten.';

  @override
  String get groupsEmptyButton => 'Erstellen Sie die erste Gruppe';

  @override
  String get you => 'Du';

  @override
  String get mockStudyGroupName => 'Studienkommando';

  @override
  String get mockWorkoutGroupName => 'Workout-Crew';

  @override
  String get periodToday => 'Heute';

  @override
  String get periodThisWeek => 'Woche';

  @override
  String get periodThisMonth => 'Monat';

  @override
  String get periodDescriptionToday => 'heute';

  @override
  String get periodDescriptionThisWeek => 'diese Woche';

  @override
  String get periodDescriptionThisMonth => 'diesen Monat';

  @override
  String get groupMetricStudying => 'Lernstunden';

  @override
  String get groupMetricDailyGoals => 'abgeschlossene Zieltage';

  @override
  String get groupMetricExercises => 'Übungsstunden';

  @override
  String get groupMetricReading => 'Seiten gelesen';

  @override
  String get groupMetricHobbies => 'Hobbystunden';

  @override
  String groupLeaderboardDescription(String period, String metric) {
    return 'Ranking für $period · gemessen in $metric';
  }

  @override
  String get leaderboardTitle => 'Rangliste';

  @override
  String get currentUserRankTitle => 'Ihre Leistung';

  @override
  String currentUserRankValue(String rank, String score) {
    return '$rank Platz · $score';
  }

  @override
  String currentUserRankNextStep(String score) {
    return '$score, um eine Position aufzusteigen';
  }

  @override
  String get currentUserRankLeading => 'Sie führen dieses Ranking an.';

  @override
  String get currentUserRankSubtitle => 'Ihre aktuelle Position';

  @override
  String get leaderboardTopPosition => 'führt dieses Ranking an';

  @override
  String leaderboardDifferenceAhead(String value) {
    return '+$value voraus';
  }

  @override
  String get groupCreatedSuccess => 'Gruppe erfolgreich erstellt';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSubtitle =>
      'Passen Sie Ihr Konto und Ihre Einstellungen an';

  @override
  String get myProfileFallback => 'Mein Profil';

  @override
  String get personalProfileLabel => 'Persönliches Profil';

  @override
  String accountDataSubtitle(Object nickname) {
    return '$nickname · persönliche Daten und Sicherheit';
  }

  @override
  String get preferencesSection => 'Präferenzen';

  @override
  String get darkModeLabel => 'Dunkler Modus';

  @override
  String get darkModeEnabledSubtitle => 'Dunkles Thema ist aktiviert';

  @override
  String get darkModeDisabledSubtitle =>
      'Verwenden Sie das dunkle Thema in der App';

  @override
  String get accentColorSettingsTitle => 'Akzentfarbe';

  @override
  String get accentColorSettingsSubtitle =>
      'Personalisieren Sie das Erscheinungsbild der App';

  @override
  String get notificationsLabel => 'Benachrichtigungen';

  @override
  String get timerNotificationsTitle => 'Timer-Benachrichtigungen';

  @override
  String get notificationsEnabledSubtitle =>
      'Fokus-, Pausen- und Fortschrittswarnungen';

  @override
  String get notificationsDisabledSubtitle =>
      'Auf diesem Gerät sind Benachrichtigungen deaktiviert';

  @override
  String get language => 'Sprache';

  @override
  String get appLanguageSubtitle => 'App-Sprache';

  @override
  String get automaticLanguageLabel => 'Automatisch';

  @override
  String get chooseLanguageTitle => 'Sprache wählen';

  @override
  String languageChangedMessage(String language) {
    return 'Die Sprache wurde in $language geändert';
  }

  @override
  String get preferenceSavedMessage => 'Präferenz gespeichert';

  @override
  String get supportSection => 'Unterstützung';

  @override
  String get helpSection => 'Hilfe';

  @override
  String get faqLabel => 'FAQ';

  @override
  String get faqSettingsSubtitle => 'Fragen zu Timer, Zielen und Gruppen';

  @override
  String get sendFeedbackTitle => 'Feedback senden';

  @override
  String get sendFeedbackSubtitle => 'Sagen Sie uns, was besser sein könnte';

  @override
  String get feedbackUnavailable => 'Es liegt noch kein Feedback vor';

  @override
  String get aboutLabel => 'Über';

  @override
  String get aboutSection => 'Über';

  @override
  String appVersionValue(String version) {
    return 'Version $version';
  }

  @override
  String get debugEnvironmentTitle => 'Umwelt';

  @override
  String get debugEnvironmentSubtitle => 'Debug · Beispieldaten aktiv';

  @override
  String appVersionLabel(String appTitle, String appVersion) {
    return '$appTitle v$appVersion';
  }

  @override
  String get accountSection => 'Konto';

  @override
  String get sessionSection => 'Sitzung';

  @override
  String get logOutLabel => 'Abmelden';

  @override
  String get logOutSettingsSubtitle =>
      'Beenden Sie die Sitzung auf diesem Gerät';

  @override
  String get logOutDialogTitle => 'Abmelden?';

  @override
  String get logOutDialogContent =>
      'Sie müssen sich erneut anmelden, um auf diesem Gerät auf dieses Konto zuzugreifen. Ihre lokalen Studiendaten bleiben erhalten.';

  @override
  String get logOutConfirmButton => 'Abmelden';

  @override
  String get myProfileTitle => 'Mein Profil';

  @override
  String get avatarLabel => 'Avatar';

  @override
  String get nameLabel => 'Name';

  @override
  String get yourNameHint => 'Dein Name';

  @override
  String get nicknameLabel => 'Spitzname';

  @override
  String get nicknameHint => 'Wie Freunde dich nennen';

  @override
  String get emailLabel => 'E-Mail';

  @override
  String get optionalHint => 'Optional';

  @override
  String get phoneLabel => 'Telefonnummer';

  @override
  String get themeColorLabel => 'Themenfarbe';

  @override
  String get saveChangesButton => 'Änderungen speichern';

  @override
  String get profileSavedMessage => 'Profil gespeichert';

  @override
  String get profilePhotoSelectLabel => 'Foto hinzufügen';

  @override
  String get profilePhotoRemoveLabel => 'Foto entfernen';

  @override
  String get faqTitle => 'FAQ';

  @override
  String get faqQ1 => 'Wie funktioniert der Lerntimer?';

  @override
  String get faqA1 =>
      'Wählen Sie ein Thema aus, tippen Sie auf „Wiedergabe“ und der Timer verfolgt Ihre aktuelle Sitzung und addiert sie zur Gesamtzeit dieses Themas. Tippen Sie jederzeit auf „Pause“, um anzuhalten und Ihren Fortschritt zu speichern.';

  @override
  String get faqQ2 => 'Was ist der Pausen-Countdown?';

  @override
  String get faqA2 =>
      'Jede Sitzung folgt einem Fokuszyklus: einem 30-minütigen Countdown bis zur nächsten Pause. Wenn der Wert Null erreicht, wird er einfach zurückgesetzt. Es handelt sich um eine Erinnerung und nicht um einen harten Stopp.';

  @override
  String get faqQ3 => 'Wie füge ich einen neuen Betreff hinzu?';

  @override
  String get faqA3 =>
      'Öffnen Sie auf der Startseite eine Kategorie und tippen Sie dann unten in der Liste auf „Betreff hinzufügen“. Sie können eine Farbe auswählen und ein geschätztes Stundenziel dafür festlegen.';

  @override
  String get faqQ4 => 'Wie werden Gruppen und die Bestenliste berechnet?';

  @override
  String get faqA4 =>
      'Gruppen zeigen eine Anzeigetafel basierend auf dem Thema der Gruppe: Fokusstunden, erreichte Zieltage oder gelesene Seiten. Wechseln Sie zwischen Heute, Woche und Monat, um den Fortschritt zu vergleichen.';

  @override
  String get faqQ5 => 'Kann ich das Farbthema der App ändern?';

  @override
  String get faqA5 =>
      'Ja, gehen Sie zu Einstellungen > Mein Profil und wählen Sie eine beliebige Designfarbe aus. Jeder Farbverlauf, jede Schaltfläche und jede Hervorhebung in der App wird entsprechend aktualisiert, einschließlich des Dunkelmodus.';

  @override
  String get createGroupTitle => 'Neue Gruppe';

  @override
  String get createGroupSubtitle =>
      'Wählen Sie ein Thema und laden Sie Freunde ein';

  @override
  String get groupNameLabel => 'Gruppenname';

  @override
  String get groupNameHint => 'Gruppenname';

  @override
  String get groupNameExampleHint => 'Bsp.: Prüfungsteam';

  @override
  String get groupThemeLabel => 'Thema';

  @override
  String groupThemeSelectedDescription(String metric) {
    return 'Diese Gruppe wird nach $metric eingestuft.';
  }

  @override
  String get inviteFriendsLabel => 'Freunde einladen';

  @override
  String selectedFriendsCount(int count) {
    return '$count ausgewählt';
  }

  @override
  String get selectAtLeastOneFriend => 'Wählen Sie mindestens 1 Freund aus';

  @override
  String get searchFriendHint => 'Freund suchen';

  @override
  String get loadingFriends => 'Freunde werden geladen...';

  @override
  String get friendsLoadErrorTitle => 'Freunde konnten nicht geladen werden';

  @override
  String get friendsLoadErrorDescription =>
      'Versuchen Sie es gleich noch einmal.';

  @override
  String get noFriendsAvailableTitle => 'Keine Freunde verfügbar';

  @override
  String get noFriendsAvailableDescription =>
      'Fügen Sie Freunde hinzu, bevor Sie eine Gruppe erstellen.';

  @override
  String get noFriendsFoundTitle => 'Kein Freund gefunden';

  @override
  String get noFriendsFoundDescription =>
      'Versuchen Sie es mit einem anderen Namen.';

  @override
  String get createGroupButton => 'Gruppe erstellen';

  @override
  String get createGroupMissingName => 'Geben Sie den Gruppennamen ein';

  @override
  String get createGroupMissingTheme => 'Wählen Sie ein Thema';

  @override
  String get createGroupMissingFriends => 'Wählen Sie mindestens 1 Freund aus';

  @override
  String createGroupWithFriendsButton(int count) {
    return 'Erstelle eine Gruppe mit $count-Freunden';
  }

  @override
  String get createGroupRequirementsTitle => 'So erstellen Sie:';

  @override
  String get createGroupRequirementName => 'Gruppenname';

  @override
  String get createGroupRequirementTheme => 'Thema gewählt';

  @override
  String get createGroupRequirementFriends => 'Mindestens 1 Freund';

  @override
  String get groupPrivacyNote =>
      'Deine Freunde sehen in diesem Theme nur deinen Namen, deinen Avatar und deinen Fortschritt.';

  @override
  String metricDaysValue(int value) {
    return '$value Tage';
  }

  @override
  String metricPagesValue(int value) {
    return '$value Seiten';
  }

  @override
  String get navHome => 'Zuhause';

  @override
  String get navGroups => 'Gruppen';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get myScheduleCardTitle => 'Mein Zeitplan';

  @override
  String get myScheduleTitle => 'Mein Zeitplan';

  @override
  String get noScheduleYet => 'Noch kein Zeitplan';

  @override
  String get noScheduleYetDescription =>
      'Tippen Sie zum Hinzufügen auf die Schaltfläche unten\nIhr erster Zeitplan';

  @override
  String get addScheduleEntryTitle => 'Zeitplaneintrag hinzufügen';

  @override
  String get addScheduleEntryButton => 'Eintrag hinzufügen';

  @override
  String get scheduleInfoSection => 'Informationen';

  @override
  String get scheduleWhenSection => 'Wann?';

  @override
  String get scheduleColorSection => 'Farbe planen';

  @override
  String get schedulePreviewSection => 'Vorschau';

  @override
  String scheduleDurationLabel(String duration) {
    return 'Dauer: $duration';
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
  String get scheduleTitleHint => 'Titel';

  @override
  String get startTimeLabel => 'Startzeit';

  @override
  String get endTimeOptionalLabel => 'Endzeit';

  @override
  String get incompleteScheduleEntryError =>
      'Unvollständiger Eintrag – geben Sie den Titel, die Startzeit und die Endzeit ein.';

  @override
  String get endTimeBeforeStartError =>
      'Die Endzeit muss später als die Startzeit liegen.';

  @override
  String get nameRequiredError => 'Bitte geben Sie zunächst einen Namen ein.';

  @override
  String get groupThemeRequiredError => 'Wählen Sie ein Thema für Ihre Gruppe.';

  @override
  String get groupNeedsFriendError =>
      'Laden Sie mindestens einen Freund ein – eine Gruppe kann nicht alleine erstellt werden.';

  @override
  String get continueWithGoogleButton => 'Weiter mit Google';

  @override
  String get continueWithAppleButton => 'Weiter mit Apple';

  @override
  String get continueWithPhoneButton => 'Weiter mit Telefonnummer';

  @override
  String get phoneLoginTitle => 'Ihre Nummer';

  @override
  String get phoneLoginSubtitle =>
      'Geben Sie Ihre Telefonnummer ein, um einen Zugangscode zu erhalten.';

  @override
  String get sendCodeButton => 'Code senden';

  @override
  String get phoneSecurityNote =>
      'Mit Ihrer Nummer können Sie sich sicher anmelden.';

  @override
  String get selectCountryTitle => 'Wählen Sie Ihr Land aus';

  @override
  String get searchCountryHint => 'Land suchen';

  @override
  String get otpCodeExpired =>
      'Code abgelaufen. Senden Sie es erneut, um ein neues zu erhalten.';

  @override
  String get otpTitle => 'Bestätigen Sie Ihre Nummer';

  @override
  String otpSubtitle(String phone) {
    return 'Geben Sie den 6-stelligen Code ein, den wir an $phone gesendet haben.';
  }

  @override
  String get verifyCodeButton => 'Überprüfen';

  @override
  String get resendCodeButton => 'Code erneut senden';

  @override
  String otpCodeValidFor(String time) {
    return 'Code gültig für $time';
  }

  @override
  String get codeResentMessage => 'Bestätigungscode gesendet';

  @override
  String get invalidCodeError =>
      'Ungültiger Code. Bitte versuchen Sie es erneut.';

  @override
  String get credentialsTitle => 'Erstellen Sie Ihr Profil';

  @override
  String get credentialsSubtitle =>
      'Erzählen Sie uns etwas über sich, um Ihr Erlebnis individuell zu gestalten.';

  @override
  String get birthDateHint => 'Geburtsdatum';

  @override
  String get profileEditableLaterNote => 'Sie können dies später bearbeiten.';

  @override
  String get finishButton => 'Fertig';

  @override
  String get navProgress => 'Fortschritt';

  @override
  String get progressTitle => 'Fortschritt';

  @override
  String get progressSubtitle => 'Alles, was du bisher geschafft hast';

  @override
  String get progressPeriodDay => 'Tag';

  @override
  String get progressPeriodWeek => 'Woche';

  @override
  String get progressPeriodMonth => 'Monat';

  @override
  String get progressFocusResultLabel => 'Fokus in diesem Zeitraum';

  @override
  String progressComparisonMore(String value) {
    return '$value mehr als im vorherigen Zeitraum';
  }

  @override
  String progressComparisonLess(String value) {
    return '$value weniger als im vorherigen Zeitraum';
  }

  @override
  String get progressComparisonSame => 'Genauso wie im vorherigen Zeitraum';

  @override
  String get progressComparisonFirst => 'Deine ersten Daten in diesem Zeitraum';

  @override
  String get progressStatExercises => 'Übungen';

  @override
  String get progressStatGoalsDone => 'Erledigte Ziele';

  @override
  String get progressDistributionTitle => 'Nach Aktivität';

  @override
  String homeTodayInline(String focus, int pages, int goals) {
    return 'Heute: $focus Fokus · $pages Seiten · $goals Ziele';
  }

  @override
  String get homePlanDayTitle => 'Meinen Tag planen';

  @override
  String get homePlanDaySubtitle => 'Tagesziele und Wochenplan';

  @override
  String get groupsFriendsTitle => 'Freunde';

  @override
  String get groupsFriendsSubtitle => 'Anfragen, Einladungen und dein Code';

  @override
  String groupMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mitglieder',
      one: '1 Mitglied',
    );
    return '$_temp0';
  }

  @override
  String get createScheduleEntryButton => 'Termin erstellen';

  @override
  String get scheduleEntryMissingFields =>
      'Titel, Beginn und Ende ausfüllen, um fortzufahren';

  @override
  String timerSessionCounter(int current, int total) {
    return 'Fokus $current von $total';
  }

  @override
  String get timerExitBackToFocus => 'Zurück zum Fokus';

  @override
  String get timerExitSaveAndEnd => 'Speichern und beenden';

  @override
  String get notesSavedNow => 'Gerade gespeichert';

  @override
  String get notesSaving => 'Wird gespeichert …';

  @override
  String get dailyGoalsPendingSection => 'Offen';

  @override
  String get dailyGoalsCompletedSection => 'Erledigt';

  @override
  String get dailyGoalsEmptyTitle => 'Noch keine Ziele für heute';

  @override
  String get dailyGoalsEmptyDescription =>
      'Schreib oben ein Ziel oder wähle einen Vorschlag, um den Tag zu starten.';

  @override
  String achievementProgressValue(String current, String total) {
    return '$current von $total';
  }

  @override
  String get categoryEmptyTitle => 'Hier ist noch nichts';

  @override
  String get categoryEmptyDescription =>
      'Erstelle dein erstes Element, um deine Fokuszeit zu erfassen.';

  @override
  String get scheduleEmptyExampleLabel => 'Beispiel';

  @override
  String get progressAchievementsNextTitle => 'Nächster Erfolg';

  @override
  String get achievementFocusHourTitle => '1 Stunde Fokus';

  @override
  String get achievementSessionsTitle => '5 abgeschlossene Sitzungen';

  @override
  String get achievementStreakTitle => '7 Tage in Folge';

  @override
  String get achievementReaderTitle => '100 gelesene Seiten';

  @override
  String get achievementGoalStartedTitle => 'Erstes Ziel gestartet';

  @override
  String unitMinutesShort(int value) {
    return '$value Min.';
  }

  @override
  String unitSessions(int value) {
    return '$value Sitzungen';
  }

  @override
  String unitDays(int value) {
    return '$value Tage';
  }

  @override
  String currentUserRankNextStepNamed(String score, String name) {
    return '$score bis zu $name';
  }

  @override
  String get timerKeepAwakeNote =>
      'Der Bildschirm bleibt während der Sitzung an';

  @override
  String scheduleWeekLabel(String date) {
    return 'Woche vom $date';
  }

  @override
  String get daysSuffix => 'Tage';

  @override
  String get createTaskSubtitle =>
      'Richte ein Tagesziel ein, um deinen Fortschritt zu verfolgen';

  @override
  String get createTaskSequenceTypeLabel => 'Sequenztyp';

  @override
  String get createTaskSequenceIntenseLabel => 'Intensiv';

  @override
  String get createTaskSequenceIntenseDescription =>
      'Keine Aussetzer. Wenn du einen Tag verpasst, wird deine Serie zurückgesetzt.';

  @override
  String get createTaskSequenceCasualLabel => 'Locker';

  @override
  String get createTaskSequenceCasualDescription =>
      'Flexibler. Verpasste Tage setzen deine Serie nicht zurück.';

  @override
  String get targetDaysInfinite => 'Unbegrenzt';

  @override
  String get deleteConfirmationDefaultTypeName => 'Element';

  @override
  String deleteConfirmationTitle(String typeName) {
    return '$typeName löschen?';
  }

  @override
  String deleteConfirmationContent(String itemName) {
    return 'Du bist dabei, \"$itemName\" zu löschen. Diese Aktion kann nicht rückgängig gemacht werden.';
  }

  @override
  String deleteConfirmationHistoryWarning(String typeName) {
    return 'Der Verlauf von $typeName wird ebenfalls entfernt.';
  }

  @override
  String homeDaySummaryFocusValue(String focus) {
    return '$focus Fokus';
  }

  @override
  String homeDaySummaryGoalsValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ziele',
      one: '1 Ziel',
    );
    return '$_temp0';
  }

  @override
  String get profilePhotoSourceTitle => 'Profilfoto';

  @override
  String get profilePhotoSourceSubtitle =>
      'W?hle aus, wie du dein Foto aktualisieren m?chtest';

  @override
  String get photoCameraLabel => 'Foto aufnehmen';

  @override
  String get photoGalleryLabel => 'Aus Galerie w?hlen';

  @override
  String get removePhotoDialogTitle => 'Foto entfernen?';

  @override
  String get removePhotoDialogContent =>
      'Dein Avatar wird wieder im Profil angezeigt.';

  @override
  String get friendRequestsReceivedTab => 'Anfragen';

  @override
  String get friendRequestsSentTab => 'Einladungen';

  @override
  String hobbyPracticeMinutes(int minutes) {
    return '$minutes Min. ?bung';
  }

  @override
  String get hobbyViewStatistics => 'Statistiken anzeigen';

  @override
  String get hobbyEdit => 'Hobby bearbeiten';

  @override
  String get pinToStart => 'An Start anheften';

  @override
  String get hobbyDelete => 'Hobby l?schen';

  @override
  String get deleteActionCannotBeUndone =>
      'Diese Aktion kann nicht r?ckg?ngig gemacht werden.';

  @override
  String get joinGroupTitle => 'Gruppe beitreten';

  @override
  String get joinGroupInviteCodeLabel => 'Einladungscode';

  @override
  String get joinGroupCodeHint => 'Code eingeben';

  @override
  String get joinGroupButton => 'Gruppe beitreten';

  @override
  String get joinGroupError => 'Dieser Gruppe konnte nicht beigetreten werden.';

  @override
  String get scheduleDayEventsTitle => 'Termine des Tages';

  @override
  String get dailyGoalsNoGoalsYetTitle => 'Noch kein Ziel';

  @override
  String get dailyGoalsNoGoalsYetDescription =>
      'F?ge dein erstes Ziel hinzu, um den Tag zu organisieren und Erfolge zu verfolgen.';

  @override
  String get dailyGoalsSuggestionsTitle => 'Vorschl?ge f?r den Anfang';

  @override
  String get dailyGoalsSuggestionStudy => '30 min lernen';

  @override
  String get dailyGoalsSuggestionRead => '10 Seiten lesen';

  @override
  String get dailyGoalsSuggestionTrain => 'Trainieren';

  @override
  String get goalTypeName => 'Ziel';

  @override
  String get missedYesterdayDialogTitle => 'Hast du es gestern erledigt?';

  @override
  String missedYesterdayDialogContent(String taskName) {
    return 'Du hast \"$taskName\" gestern nicht erfasst. Hast du es wirklich verpasst?';
  }

  @override
  String get missedYesterdayMissedButton => 'Ja, ich habe es verpasst';

  @override
  String get missedYesterdayCompletedButton => 'Ich habe es erledigt';

  @override
  String get scheduleTitleRequiredError => 'Titel ausf?llen, um fortzufahren';

  @override
  String get scheduleActiveFromLabel => 'Beginnt';

  @override
  String get scheduleActiveUntilLabel => 'Endet';

  @override
  String get selectDateTitle => 'Datum ausw?hlen';

  @override
  String get selectDateHint => 'Tippe auf einen Tag, um ihn auszuw?hlen';

  @override
  String get addFriendTitle => 'Freund hinzuf?gen';

  @override
  String get friendCodeNotFound =>
      'Wir konnten keinen Benutzer mit diesem Code finden.';

  @override
  String get friendInviteCodeTitle => 'Einladungscode';

  @override
  String get friendInviteCodeFieldLabel => 'Code eingeben oder einf?gen';

  @override
  String get friendInviteCodeFieldHint => 'Wie ABCDE12345';

  @override
  String get pasteButton => 'Einf?gen';

  @override
  String get searchCodeButton => 'Code suchen';

  @override
  String get friendUserFoundTitle => 'Benutzer gefunden';

  @override
  String get friendFoundByCode => 'Per Code gefunden';

  @override
  String get sentLabel => 'Gesendet';

  @override
  String get friendHowItWorksTitle => 'So funktioniert es';

  @override
  String get friendHowItWorksStepOne => 'Bitte deinen Freund um den Code';

  @override
  String get friendHowItWorksStepTwo =>
      'F?ge den Code ein, um das Profil zu finden';

  @override
  String get friendHowItWorksStepThree => 'Sende die Anfrage zum Hinzuf?gen';

  @override
  String get myCodeLabel => 'Mein Code';

  @override
  String get yourInviteCodeLabel => 'Dein Einladungscode';

  @override
  String yourFriendsTitle(int count) {
    return 'Deine Freunde ($count)';
  }

  @override
  String get seeAllButton => 'Alle anzeigen';

  @override
  String get onlineLabel => 'Online';

  @override
  String minutesAgoShort(int minutes) {
    return 'Vor $minutes Min.';
  }

  @override
  String get friendsEmptyTitle => 'Du hast noch keine Freunde';

  @override
  String get friendsEmptySubtitle =>
      'Suche oben nach Personen oder teile deinen Einladungscode.';

  @override
  String get shareCodeButton => 'Code teilen';

  @override
  String get codeCopiedMessage => 'Code kopiert';

  @override
  String get friendRequestSentMessage => 'Anfrage gesendet';

  @override
  String get joinedGroupMessage => 'Du bist der Gruppe beigetreten';

  @override
  String get friendTypeName => 'Freund';

  @override
  String shareInviteCodeMessage(String code) {
    return 'F?ge mich auf HelpOut mit meinem Code hinzu: $code';
  }

  @override
  String groupInvitesTitle(int count) {
    return 'Gruppeneinladungen ($count)';
  }

  @override
  String groupInvitedBy(String inviter) {
    return '$inviter hat dich eingeladen';
  }

  @override
  String get acceptButton => 'Annehmen';

  @override
  String get declineButton => 'Ablehnen';

  @override
  String get friendsTitle => 'Freunde';

  @override
  String get friendRequestsReceivedPageTitle => 'Anfragen';

  @override
  String get friendRequestsSentPageTitle => 'Einladungen';

  @override
  String friendRequestsReceivedSection(int count) {
    return 'Erhalten ($count)';
  }

  @override
  String friendRequestsSentSection(int count) {
    return 'Gesendet ($count)';
  }

  @override
  String get friendMutualFriendsSample => '3 gemeinsame Freunde';

  @override
  String get pendingLabel => 'Ausstehend';

  @override
  String get friendRequestsIncomingEmptyTitle => 'Keine erhaltenen Anfragen';

  @override
  String get friendRequestsSentEmptyTitle => 'Keine gesendeten Einladungen';

  @override
  String get friendRequestsIncomingEmptySubtitle => 'Anfragen erscheinen hier.';

  @override
  String get friendRequestsSentEmptySubtitle =>
      'Deine gesendeten Einladungen erscheinen hier.';

  @override
  String get friendRequestsSafetyNotice =>
      'Akzeptiere nur Personen, die du kennst und denen du vertraust.';

  @override
  String get categoryEmptyStudyingTitle => 'Noch kein Fach';

  @override
  String get categoryEmptyExercisesTitle => 'Noch keine ?bung';

  @override
  String get categoryEmptyReadingTitle => 'Noch keine Lekt?re';

  @override
  String get categoryEmptyHobbiesTitle => 'Noch kein Hobby';

  @override
  String get categoryEmptyStudyingDescription =>
      'F?ge dein erstes Fach hinzu, um dein Lernen zu organisieren und deinen Fokus zu erfassen.';

  @override
  String get categoryEmptyExercisesDescription =>
      'F?ge deine erste ?bung hinzu, um Training, Einheiten und Fortschritt zu verfolgen.';

  @override
  String get categoryEmptyReadingDescription =>
      'F?ge deine erste Lekt?re hinzu, um Seiten, Zeit und Fortschritt zu erfassen.';

  @override
  String get categoryEmptyHobbiesDescription =>
      'F?ge dein erstes Hobby hinzu, um ?bung zu erfassen und dranzubleiben.';

  @override
  String get categorySuggestionStudyingOne => 'Mathematik';

  @override
  String get categorySuggestionStudyingTwo => 'Englisch';

  @override
  String get categorySuggestionStudyingThree => 'Schreiben';

  @override
  String get categorySuggestionExercisesOne => 'Laufen';

  @override
  String get categorySuggestionExercisesTwo => 'Kraft';

  @override
  String get categorySuggestionExercisesThree => 'Dehnen';

  @override
  String get categorySuggestionReadingOne => 'Roman';

  @override
  String get categorySuggestionReadingTwo => 'Fachbuch';

  @override
  String get categorySuggestionReadingThree => 'Artikel';

  @override
  String get categorySuggestionHobbiesOne => 'Gitarre';

  @override
  String get categorySuggestionHobbiesTwo => 'Zeichnen';

  @override
  String get categorySuggestionHobbiesThree => 'Kochen';

  @override
  String get pagesAbbreviation => 'S.';

  @override
  String get loginSecurityNote => 'Deine Daten sind gesch?tzt und sicher.';

  @override
  String get nextBreakDurationLabel => 'Dauer der n?chsten Pause';

  @override
  String timerReadingExitContent(String duration, String subjectName) {
    return 'Du hast $duration gelesen. Gib ein, wie viele Seiten du in $subjectName gelesen hast.';
  }

  @override
  String get appleSignInIncompleteMessage =>
      'Mit Apple anmelden ist noch nicht vollst?ndig.';

  @override
  String get activityTypeLabel => 'Aktivit?tstyp';

  @override
  String get activityTypeDailyLabel => 'T?glich';

  @override
  String get activityTypeDailyDescription =>
      'Erneuert sich jeden Tag. Die Aktivit?t ist morgens wieder verf?gbar.';

  @override
  String get activityTypePermanentLabel => 'Permanent';

  @override
  String get activityTypePermanentDescription =>
      'Bleibt aktiv, bis du sie abschlie?t. Danach wird sie als erledigt markiert.';

  @override
  String get pagesSuffix => 'Seiten';

  @override
  String get updatedSuccessfullyMessage => 'Erfolgreich aktualisiert';

  @override
  String get focusSessionCountLabel => 'Fokussitzungen';

  @override
  String get groupEditingComingSoon => 'Gruppenbearbeitung kommt bald.';

  @override
  String get leftGroupMessage => 'Du hast die Gruppe verlassen.';

  @override
  String get groupImageSourceTitle => 'Bild senden';

  @override
  String get groupImageSourceSubtitle =>
      'W?hle aus, wie du das Bild senden m?chtest';

  @override
  String get deleteButton => 'Löschen';

  @override
  String get manageMembersTitle => 'Mitglieder verwalten';

  @override
  String get groupLeaderLabel => 'Leiter';

  @override
  String get groupLeaderRoleLabel => 'Gruppenleiter';

  @override
  String get groupMemberRoleLabel => 'Mitglied';

  @override
  String get groupMembersLabel => 'Mitglieder';

  @override
  String get groupActionsLabel => 'Gruppenaktionen';

  @override
  String get goalsTabLabel => 'Ziele';

  @override
  String get chatTabLabel => 'Chat';

  @override
  String get groupGoalTitle => 'Gruppenziel';

  @override
  String get groupMainRuleTitle => 'Hauptregel';

  @override
  String get groupNextMilestoneTitle => 'N?chster Meilenstein';

  @override
  String groupMembersProgressValue(int current, int total) {
    return '$current/$total Mitglieder';
  }

  @override
  String get groupNextMilestoneDescription =>
      'um das Abzeichen \"Totaler Fokus\" freizuschalten';

  @override
  String get groupActivityLabel => 'Gruppenaktivit?t';

  @override
  String groupActivityReachedGoal(int reached, int total) {
    return '$reached/$total haben das Ziel erreicht';
  }

  @override
  String get groupNoImagesTitle => 'Noch keine Bilder';

  @override
  String get groupNoImagesDescription => 'Sende das erste Gruppenbild.';

  @override
  String get groupSendImageButton => 'Bild senden';

  @override
  String get groupSendingImage => 'Bild wird gesendet...';

  @override
  String get editGroupLabel => 'Gruppe bearbeiten';

  @override
  String get leaveGroupLabel => 'Gruppe verlassen';

  @override
  String groupDescription(String metric) {
    return '$metric teilen und gemeinsam Herausforderungen meistern.';
  }

  @override
  String groupsFriendsSubtitleWithCount(int groupCount) {
    return 'Anfragen, Einladungen und $groupCount in Gruppen';
  }

  @override
  String groupGoalKeepMetric(String metric) {
    return '$metric jeden Tag beibehalten';
  }

  @override
  String groupGoalDescription(String metric) {
    return 'Jedes Mitglied sollte Fortschritt in $metric erfassen, um die Gruppenserie fortzusetzen.';
  }

  @override
  String groupRuleDescription(String metric) {
    return 'Erfasse mindestens eine Aktivit?t mit $metric pro Tag. Die Serie zu halten st?rkt die Gruppe.';
  }

  @override
  String get joinWithCodeButton => 'Ich habe einen Einladungscode';

  @override
  String get groupsBenefitsHeader => 'In einer Gruppe kannst du:';

  @override
  String groupParticipantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Teilnehmer',
      one: '1 Teilnehmer',
    );
    return '$_temp0';
  }

  @override
  String groupMembersCompletedToday(int completed, int total) {
    return '$completed/$total Mitglieder haben heute abgeschlossen';
  }

  @override
  String get addMemberButton => 'Mitglied hinzuf?gen';

  @override
  String get groupCollectiveProgressTitle => 'Gemeinsamer Fortschritt';

  @override
  String get currentUserRankCompleteFirstGoal =>
      'Schlie?e dein erstes Ziel ab, um in die Rangliste zu kommen.';

  @override
  String get currentUserRankTiedLead => 'Gleichstand an der Spitze.';

  @override
  String get currentUserRankTiedFirstLabel => 'Gleichstand auf Platz 1';

  @override
  String rankLabel(int rank) {
    return '$rank.';
  }

  @override
  String get homeScheduleRoutineSubtitle =>
      'Kommende Zeiten und w?chentliche Routine';

  @override
  String get homeNextCommitmentTitle => 'N?chster Termin';

  @override
  String get todayLabel => 'Heute';

  @override
  String get statisticsTitle => 'Statistiken';

  @override
  String get studiedTimeLabel => 'Gelernte Zeit';

  @override
  String get readingTimeLabel => 'Lesezeit';

  @override
  String get totalPagesReadLabel => 'Seiten gesamt';

  @override
  String get pagesReadTodayLabel => 'Seiten heute';

  @override
  String get goalLabel => 'Ziel';

  @override
  String get sessionsLabel => 'Sitzungen';

  @override
  String get restLabel => 'Pause';

  @override
  String get comparativesTitle => 'Vergleiche';

  @override
  String get overviewTitle => '?bersicht';

  @override
  String get studiedUnit => 'gelernt';

  @override
  String get readPagesUnit => 'gelesen';

  @override
  String get versusLastMonth => 'vs letzten Monat';

  @override
  String get versusLastWeek => 'vs letzte Woche';

  @override
  String get noPreviousPeriodComparison =>
      'Kein vorheriger Zeitraum zum Vergleichen';

  @override
  String get noTimeLabel => 'Ohne Uhrzeit';

  @override
  String untilTimeLabel(String time) {
    return 'Bis $time';
  }

  @override
  String get achievementsUnlockedSuffix => ' /50 freigeschaltet';

  @override
  String get currentLevelLabel => 'Aktuelles Level';

  @override
  String get allAchievementsUnlockedLabel => 'Alles freigeschaltet';

  @override
  String get nextUnlockLabel => 'N?chster Erfolg';

  @override
  String get allAchievementsUnlockedDescription =>
      'Du hast alles freigeschaltet.';

  @override
  String xpToGo(int xp) {
    return 'Noch $xp XP';
  }

  @override
  String levelLabel(int level) {
    return 'Level $level';
  }

  @override
  String get allFilterLabel => 'Alle';

  @override
  String get unlockedFilterLabel => 'Freigeschaltet';

  @override
  String get lockedFilterLabel => 'Gesperrt';

  @override
  String get selectCategoryTooltip => 'Kategorie ausw?hlen';

  @override
  String get allCategoriesLabel => 'Alle Kategorien';

  @override
  String get byCategoryLabel => 'Nach Kategorie';

  @override
  String get allLevelsTitle => 'Alle Level';

  @override
  String get allLevelsDescription =>
      'Schalte Erfolge frei, um im Rang aufzusteigen.';

  @override
  String levelPlusLabel(int level) {
    return 'Level $level+';
  }

  @override
  String get currentLabel => 'Aktuell';

  @override
  String rankTierLearner(String tier) {
    return '$tier-Lernender';
  }

  @override
  String get achievementCategoryFocus => 'Fokus';

  @override
  String get achievementCategoryStudy => 'Lernen';

  @override
  String get achievementCategoryReading => 'Lesen';

  @override
  String get achievementCategoryGoals => 'Ziele';

  @override
  String get achievementCategoryLifestyle => 'Lifestyle';

  @override
  String get achievement1Title => 'Erster Fokus';

  @override
  String get achievement1Description => 'Schlie?e deine erste Fokussitzung ab';

  @override
  String get achievement2Title => '25-Minuten-Start';

  @override
  String get achievement2Description => 'Fokussiere dich 25 Minuten lang';

  @override
  String get achievement3Title => '1 Stunde Fokus';

  @override
  String get achievement3Description => 'Fokussiere dich 1 Stunde lang';

  @override
  String get achievement4Title => 'Tiefe Arbeit';

  @override
  String get achievement4Description => 'Erreiche 2 Stunden Fokus';

  @override
  String get achievement5Title => 'Keine Ablenkungen';

  @override
  String get achievement5Description => 'Schlie?e 3 Fokussitzungen ab';

  @override
  String get achievement6Title => 'Fokusmarathon';

  @override
  String get achievement6Description => 'Erreiche 10 Stunden Fokus';

  @override
  String get achievement7Title => 'Fr?haufsteher';

  @override
  String get achievement7Description => 'Erfasse Fokus an 5 Tagen';

  @override
  String get achievement8Title => 'Nachteule';

  @override
  String get achievement8Description => 'Schlie?e 10 Fokussitzungen ab';

  @override
  String get achievement9Title => 'Fokusserie';

  @override
  String get achievement9Description => 'Erfasse Fokus an 7 Tagen';

  @override
  String get achievement10Title => 'Fokusmeister';

  @override
  String get achievement10Description => 'Erreiche 25 Stunden Fokus';

  @override
  String get achievement11Title => 'Lernen begonnen';

  @override
  String get achievement11Description => 'Erstelle deinen ersten Lerneintrag';

  @override
  String get achievement12Title => '3 Sitzungen';

  @override
  String get achievement12Description => 'Schlie?e 3 Sitzungen ab';

  @override
  String get achievement13Title => '5 Sitzungen';

  @override
  String get achievement13Description => 'Schlie?e 5 Sitzungen ab';

  @override
  String get achievement14Title => '10 Sitzungen';

  @override
  String get achievement14Description => 'Schlie?e 10 Sitzungen ab';

  @override
  String get achievement15Title => 'F?cherentdecker';

  @override
  String get achievement15Description => 'Lerne mindestens ein Fach';

  @override
  String get achievement16Title => 'Wiederholungsheld';

  @override
  String get achievement16Description => 'Erreiche 5 Stunden Lernen';

  @override
  String get achievement17Title => 'Quiz beendet';

  @override
  String get achievement17Description => 'Schlie?e 15 Sitzungen ab';

  @override
  String get achievement18Title => 'Lernplaner';

  @override
  String get achievement18Description => 'Erstelle ein Fokusziel';

  @override
  String get achievement19Title => 'Pr?fungsbereit';

  @override
  String get achievement19Description => 'Erreiche 20 Stunden Lernen';

  @override
  String get achievement20Title => 'Studentenmodus';

  @override
  String get achievement20Description => 'Erreiche 50 Stunden Lernen';

  @override
  String get achievement21Title => 'Erste Seite';

  @override
  String get achievement21Description => 'Lies deine erste Seite';

  @override
  String get achievement22Title => '10 Seiten';

  @override
  String get achievement22Description => 'Lies 10 Seiten';

  @override
  String get achievement23Title => '25 Seiten';

  @override
  String get achievement23Description => 'Lies 25 Seiten';

  @override
  String get achievement24Title => '50 Seiten';

  @override
  String get achievement24Description => 'Lies 50 Seiten';

  @override
  String get achievement25Title => '100 Seiten';

  @override
  String get achievement25Description => 'Lies 100 Seiten';

  @override
  String get achievement26Title => 'Kapitel abgeschlossen';

  @override
  String get achievement26Description => 'Lies 150 Seiten';

  @override
  String get achievement27Title => 'Wochenendleser';

  @override
  String get achievement27Description => 'Lies 250 Seiten';

  @override
  String get achievement28Title => 'T?glicher Leser';

  @override
  String get achievement28Description => 'Lies 300 Seiten';

  @override
  String get achievement29Title => 'B?cherfreund';

  @override
  String get achievement29Description => 'Lies 500 Seiten';

  @override
  String get achievement30Title => 'Bibliothekslegende';

  @override
  String get achievement30Description => 'Lies 1000 Seiten';

  @override
  String get achievement31Title => 'Erstes Ziel';

  @override
  String get achievement31Description => 'Erstelle dein erstes Ziel';

  @override
  String get achievement32Title => 'Ziel erreicht';

  @override
  String get achievement32Description => 'Schlie?e ein Ziel ab';

  @override
  String get achievement33Title => 'Alle Ziele erledigt';

  @override
  String get achievement33Description => 'Schlie?e heute alle Ziele ab';

  @override
  String get achievement34Title => 'Morgenroutine';

  @override
  String get achievement34Description => 'Schlie?e Ziele an 3 Tagen ab';

  @override
  String get achievement35Title => 'Ausgeglichener Tag';

  @override
  String get achievement35Description => 'Schlie?e Ziele an 5 Tagen ab';

  @override
  String get achievement36Title => 'Gewohnheitsbauer';

  @override
  String get achievement36Description => 'Schlie?e Ziele an 10 Tagen ab';

  @override
  String get achievement37Title => 'Perfekter Tag';

  @override
  String get achievement37Description => 'Schlie?e Ziele an 15 Tagen ab';

  @override
  String get achievement38Title => 'Comeback';

  @override
  String get achievement38Description => 'Schlie?e Ziele an 20 Tagen ab';

  @override
  String get achievement39Title => 'Konstanzstern';

  @override
  String get achievement39Description => 'Schlie?e Ziele an 30 Tagen ab';

  @override
  String get achievement40Title => 'Unaufhaltsam';

  @override
  String get achievement40Description => 'Schlie?e Ziele an 50 Tagen ab';

  @override
  String get achievement41Title => 'Erste Gruppe';

  @override
  String get achievement41Description => 'Tritt einer Lerngruppe bei';

  @override
  String get achievement42Title => 'Teamspieler';

  @override
  String get achievement42Description => 'Miss dich mit Freunden';

  @override
  String get achievement43Title => 'Hilfsbereiter Freund';

  @override
  String get achievement43Description =>
      'Hilf einem Freund, konstant zu bleiben';

  @override
  String get achievement44Title => 'Herausforderung gewonnen';

  @override
  String get achievement44Description => 'Gewinne eine Herausforderung';

  @override
  String get achievement45Title => 'Training gestartet';

  @override
  String get achievement45Description => 'Erfasse Fokus beim Training';

  @override
  String get achievement46Title => '30-Minuten-Workout';

  @override
  String get achievement46Description => 'Trainiere 30 Minuten lang';

  @override
  String get achievement47Title => 'Hobbyzeit';

  @override
  String get achievement47Description => 'Erfasse Fokus bei einem Hobby';

  @override
  String get achievement48Title => 'Kreativer Funke';

  @override
  String get achievement48Description => 'Erreiche 30 Minuten Hobbys';

  @override
  String get achievement49Title => 'Wochenendk?mpfer';

  @override
  String get achievement49Description => 'Erreiche 2 Stunden Training';

  @override
  String get achievement50Title => 'Erfolgsj?ger';

  @override
  String get achievement50Description => 'Schalte 25 Erfolge frei';

  @override
  String get rankTierPaper => 'Papier';

  @override
  String get rankTierWood => 'Holz';

  @override
  String get rankTierStone => 'Stein';

  @override
  String get rankTierCopper => 'Kupfer';

  @override
  String get rankTierBronze => 'Bronze';

  @override
  String get rankTierIron => 'Eisen';

  @override
  String get rankTierSilver => 'Silber';

  @override
  String get rankTierGold => 'Gold';

  @override
  String get rankTierPlatinum => 'Platin';

  @override
  String get rankTierAmethyst => 'Amethyst';

  @override
  String get rankTierEmerald => 'Smaragd';

  @override
  String get rankTierDiamond => 'Diamant';

  @override
  String get rankTierObsidian => 'Obsidian';

  @override
  String get rankTierAdamantium => 'Adamantium';

  @override
  String get rankTierMithril => 'Mithril';

  @override
  String get concentrationModeTitle => 'Fokusmodus';

  @override
  String get concentrationModeSubtitle =>
      'W?hle, welche Fokussitzungen das Verlassen der App blockieren.';

  @override
  String get concentrationStudyTitle => 'Lernen';

  @override
  String get concentrationStudySubtitle =>
      'Volle Konzentration auf dein Lernen.';

  @override
  String get concentrationExercisesTitle => '?bungen';

  @override
  String get concentrationExercisesSubtitle =>
      'Bleib bei deinem Training konzentriert.';

  @override
  String get concentrationReadingTitle => 'Lesen';

  @override
  String get concentrationReadingSubtitle => 'Tauche in deine Lekt?re ein.';

  @override
  String get concentrationHobbiesTitle => 'Hobbys';

  @override
  String get concentrationHobbiesSubtitle => 'Genie?e deine Hobbys mit Fokus.';

  @override
  String get createGroupDescriptionLabel => 'Beschreibung';

  @override
  String get createGroupDescriptionHint =>
      'Beschreibe die Gruppe und ihr Ziel.';

  @override
  String get createGroupThemeMetricDescription =>
      'Dieses Thema legt die Ranglistenmetrik fest.';

  @override
  String get createGroupActivityTypeDescription =>
      'Jedes Mitglied erh?lt eine Kopie zum Verfolgen.';

  @override
  String get createGroupActivityNameLabel => 'Aktivit?tsname';

  @override
  String get createGroupActivityNameHint => 'z. B. Analysis I';

  @override
  String get createGroupGoalTypeLabel => 'Zieltyp';

  @override
  String get createGroupGoalTypeTotal => 'Gesamt';

  @override
  String get createGroupGoalTypeDaily => 'T?glich';

  @override
  String get createGroupDaysGoalLabel => 'Tageziel';

  @override
  String get createGroupPagesGoalLabel => 'Seitenziel';

  @override
  String get createGroupTimeGoalMinutesLabel => 'Zeitziel (min)';

  @override
  String get createGroupSummaryTitle => 'Gruppenzusammenfassung';

  @override
  String get createGroupActivitySummaryLabel => 'Aktivit?t';

  @override
  String get createGroupGuestsLabel => 'G?ste';

  @override
  String get timerTotalTodayLabel => 'Heute gesamt';

  @override
  String get timerEndActionLabel => 'Beenden';

  @override
  String get createGroupActivityStepSubtitle =>
      'Wähle die Aktivität, die alle in der Gruppe machen.';

  @override
  String get createGroupFriendsStepSubtitle =>
      'Lade mindestens 1 Freund zum Mitmachen ein.';

  @override
  String get createGroupSummaryStepSubtitle =>
      'Überprüfe die Angaben vor dem Erstellen.';

  @override
  String get createGroupStepInformation => 'Informationen';

  @override
  String get createGroupStepActivity => 'Aktivität';

  @override
  String get createGroupStepFriends => 'Freunde';

  @override
  String get createGroupStepSummary => 'Zusammenfassung';

  @override
  String get createGroupDaysGoalHint => 'Z. B. 30';

  @override
  String get createGroupPagesGoalHint => 'Z. B. 10';

  @override
  String get createGroupMinutesGoalHint => 'Z. B. 30';

  @override
  String get createGroupAddFriendsPromptTitle => 'Jemanden nicht gefunden?';

  @override
  String get createGroupAddFriendsPromptDescription =>
      'Füge mehr Freunde hinzu, um sie einladen zu können.';

  @override
  String get createGroupContinueButton => 'Weiter';

  @override
  String get createGroupActivitySummaryDaily => 'Tägliches Ziel';

  @override
  String createGroupActivitySummaryGoalDays(String days) {
    return 'Ziel • $days Tage';
  }

  @override
  String createGroupActivitySummaryReading(String pages) {
    return 'Lesen • $pages Seiten';
  }

  @override
  String createGroupActivitySummaryTime(String category, String minutes) {
    return '$category • $minutes Min.';
  }

  @override
  String get createGroupActivityRequiredError =>
      'Wähle eine Aktivität für die Gruppe.';

  @override
  String get createGroupActivityNameRequiredError =>
      'Gib der Aktivität einen Namen.';

  @override
  String get createGroupActivityGoalInvalidError =>
      'Lege ein gültiges Ziel fest.';

  @override
  String get createGroupActivityMissingError =>
      'Lege die Aktivität der Gruppe fest.';

  @override
  String get timerBackTooltip => 'Zurück';

  @override
  String get timerRestMessageTitle => 'Ruh dich etwas aus';

  @override
  String get timerFocusLabel => 'Fokus';

  @override
  String get timerReadingLabel => 'Lesen';

  @override
  String get timerPauseLabel => 'Pause';

  @override
  String get timerReadingTimeLabel => 'Lesezeit';

  @override
  String timerTotalOfLabel(String duration) {
    return 'von $duration';
  }

  @override
  String get timerCurrentPagesLabel => 'Aktuelle Seiten';

  @override
  String get timerNotesLabel => 'Notizen';

  @override
  String get concentrationModeSheetDescription =>
      'Wenn aktiviert, hilft dir die App, während der Aktivität konzentriert zu bleiben, bis du pausierst oder beendest.';
}
