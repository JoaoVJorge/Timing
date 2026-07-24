// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'HelpOut';

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
      'Der Timer schlägt nach 25 Minuten Fokus eine Pause vor.';

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
  String get profileTitle => 'Reise';

  @override
  String get profileSubtitle =>
      'Verfolgen Sie Ihren Fortschritt und wichtige Meilensteine';

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
      'Starten Sie eine Sitzung, protokollieren Sie Lesevorgänge oder legen Sie von zu Hause aus ein Ziel fest, um Ihre Entwicklung in HelpOut zu verfolgen.';

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
      'Jede Sitzung folgt einem klassischen Pomodoro-Zyklus: einem 25-minütigen Countdown bis zur nächsten Pause. Wenn der Wert Null erreicht, wird er einfach zurückgesetzt. Es handelt sich um eine Erinnerung und nicht um einen harten Stopp.';

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
  String get navProfile => 'Reise';

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
}
