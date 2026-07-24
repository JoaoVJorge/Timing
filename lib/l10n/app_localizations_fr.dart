// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'HelpOut';

  @override
  String get genericErrorMessage =>
      'Quelque chose s\'est mal passé. Veuillez réessayer plus tard.';

  @override
  String get loginHeadline => 'Commençons';

  @override
  String get loginSubtitle =>
      'Connectez-vous pour continuer à étudier et organiser votre routine.';

  @override
  String get loginNameHint => 'Votre nom';

  @override
  String get loginButton => 'Commençons';

  @override
  String get homeGreetingDefault => 'Bonjour';

  @override
  String homeGreetingWithName(String userName) {
    return 'Bonjour, $userName';
  }

  @override
  String get homeSubtitle => 'A quoi s’attaque-t-on aujourd’hui ?';

  @override
  String homeSubtitleFocusedToday(String duration) {
    return 'Vous avez concentré votre attention sur $duration aujourd\'hui';
  }

  @override
  String homeSubtitleNextSchedule(String title, String time) {
    return 'Ordre du jour : $title à $time';
  }

  @override
  String get homeSubtitleStart =>
      'Commencez votre première séance de concentration';

  @override
  String get homeTasksSection => 'Objectifs quotidiens';

  @override
  String get homeCategoriesSection => 'Activités';

  @override
  String get homeActionContinueEyebrow => 'Continuer maintenant';

  @override
  String get homeActionContinueButton => 'Continuer';

  @override
  String get homeActionStartEyebrow => 'Commencer à se concentrer';

  @override
  String get homeActionStartButton => 'Commencer';

  @override
  String get homeActionSuggestedMeta => 'Votre sujet le plus suivi';

  @override
  String get homeActionCreateBody =>
      'Créez votre premier sujet pour démarrer une session de mise au point.';

  @override
  String get homeActionCreateButton => 'Créer un sujet';

  @override
  String get homeSummaryTitle => 'Le résumé du jour';

  @override
  String get homeSummaryFocus => 'Concentrez-vous';

  @override
  String get homeSummaryGoals => 'Objectifs';

  @override
  String get homeSummaryPages => 'Pages';

  @override
  String get homeSummarySessions => 'Séances';

  @override
  String homeGoalsProgress(int done, int total) {
    return '$done sur $total terminé';
  }

  @override
  String get homeCategoryEmpty => 'Rien pour l\'instant';

  @override
  String get homeNextScheduleTitle => 'Ordre du jour';

  @override
  String get homeTodayAgendaTitle => 'L\'ordre du jour d\'aujourd\'hui';

  @override
  String get homeNextScheduleEmpty => 'Pas d\'horaire aujourd\'hui';

  @override
  String get homeNextScheduleAdd => 'Ajouter un horaire';

  @override
  String get addTaskButton => 'Ajouter un objectif';

  @override
  String get createTaskTitle => 'Nouvel objectif';

  @override
  String get taskNameHint => 'Nom de l\'objectif';

  @override
  String get targetDaysLabel => 'Cible (jours)';

  @override
  String targetDaysChip(int days) {
    return '$days jours';
  }

  @override
  String get targetDaysHint => 'Cible personnalisée';

  @override
  String taskDaysProgress(int completed, int target) {
    return '$completed/$target jours';
  }

  @override
  String get taskCompletedLabel => 'C\'est fait !';

  @override
  String get lastActivityLabel => 'Dernière activité';

  @override
  String get lastActivityNone =>
      'Rien pour l\'instant : commencez quelque chose !';

  @override
  String get lastActivityJustNow => 'juste maintenant';

  @override
  String lastActivityMinutesAgo(int minutes) {
    return 'Il y a $minutes min';
  }

  @override
  String lastActivityHoursAgo(int hours) {
    return '$hours h il y a';
  }

  @override
  String lastActivityDaysAgo(int days) {
    return 'il y a $days j';
  }

  @override
  String get categoryStudying => 'Études';

  @override
  String get categoryExercises => 'Faire de l\'exercice';

  @override
  String get categoryReading => 'Lecture';

  @override
  String get categoryHobbies => 'Loisirs';

  @override
  String get itemNounStudying => 'Sujet';

  @override
  String get itemNounExercises => 'Exercice';

  @override
  String get itemNounReading => 'Livre';

  @override
  String get itemNounHobbies => 'Passe-temps';

  @override
  String get iconLabel => 'Icône';

  @override
  String get restTimeLabel => 'Temps de repos';

  @override
  String restMinutesChip(int minutes) {
    return '$minutes min';
  }

  @override
  String get timeUnitHoursSuffix => 'h';

  @override
  String get timeUnitMinutesSuffix => 'min';

  @override
  String get wallpaperLabel => 'Fond d\'écran de la minuterie';

  @override
  String addItemButton(String itemNoun) {
    return 'Ajouter $itemNoun';
  }

  @override
  String itemNameHint(String itemNoun) {
    return 'Nom $itemNoun';
  }

  @override
  String get colorLabel => 'Couleur';

  @override
  String get bookThemeLabel => 'Thème du livre';

  @override
  String get estimatedHoursGoalHint => 'Objectif en minutes';

  @override
  String get goalPagesHint => 'Objectif (pages)';

  @override
  String get cancelButton => 'Annuler';

  @override
  String get confirmButton => 'Confirmer';

  @override
  String get addButton => 'Ajouter';

  @override
  String get createSubjectTitleStudying => 'Nouveau sujet';

  @override
  String get createSubjectTitleReading => 'Nouvelle lecture';

  @override
  String get createSubjectTitleExercises => 'Nouvel entraînement';

  @override
  String get createSubjectTitleHobbies => 'Nouveau passe-temps';

  @override
  String get createSubjectSubtitleStudying =>
      'Fixez-vous un objectif et personnalisez votre concentration';

  @override
  String get createSubjectSubtitleReading =>
      'Suivez les pages et personnalisez votre lecture';

  @override
  String get createSubjectSubtitleExercises =>
      'Choisissez comment vous souhaitez suivre cette activité';

  @override
  String get createSubjectSubtitleHobbies =>
      'Choisissez comment vous souhaitez suivre ce passe-temps';

  @override
  String get createSubjectBasicSection => 'Informations de base';

  @override
  String get createSubjectGoalSection => 'Objectif';

  @override
  String get createSubjectRoutineSection => 'Routine';

  @override
  String get createSubjectPersonalizationSection => 'Personnalisation';

  @override
  String get createSubjectNameLabelStudying => 'Nom du sujet';

  @override
  String get createSubjectNameLabelReading => 'Lecture du nom';

  @override
  String get createSubjectNameLabelExercises => 'Nom de l\'activité';

  @override
  String get createSubjectNameLabelHobbies => 'Nom du passe-temps';

  @override
  String get createSubjectNameHintStudying =>
      'Ex. : Biologie, Mathématiques, Anglais';

  @override
  String get createSubjectNameHintReading =>
      'Ex. : Livre d\'histoire, Dom Casmurro';

  @override
  String get createSubjectNameHintExercises =>
      'Ex. : Gym, course à pied, étirements';

  @override
  String get createSubjectNameHintHobbies =>
      'Ex. : Guitare, Dessin, Programmation';

  @override
  String get createSubjectTimeGoalLabel => 'Objectif de concentration';

  @override
  String get createSubjectPagesGoalLabel => 'Objectif de la page';

  @override
  String get createSubjectTimeGoalHelp =>
      'Combien de minutes souhaitez-vous vous concentrer ?';

  @override
  String get createSubjectPagesGoalHelp =>
      'Combien de pages souhaitez-vous connecter au total ?';

  @override
  String get createSubjectRestLabel => 'Pause après chaque focus';

  @override
  String get createSubjectRestHelp =>
      'Le timer propose une pause après 25 min de concentration.';

  @override
  String get customRestMinutesHint => 'Pause personnalisée (min)';

  @override
  String get createSubjectPreviewTitle => 'Aperçu';

  @override
  String get createSubjectPreviewNoGoal => 'Aucun objectif fixé';

  @override
  String createSubjectPreviewGoal(String goal) {
    return 'Objectif : $goal';
  }

  @override
  String createSubjectPreviewRest(int minutes) {
    return 'Pause : $minutes min';
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
    return '$value pages';
  }

  @override
  String createSubjectColorSemantic(int index) {
    return 'Couleur $index';
  }

  @override
  String get createSubjectButtonStudying => 'Créer un sujet';

  @override
  String get createSubjectButtonReading => 'Créer une lecture';

  @override
  String get createSubjectButtonExercises => 'Créer une activité';

  @override
  String get createSubjectButtonHobbies => 'Créer un passe-temps';

  @override
  String get createSubjectMissingName => 'Entrez un nom pour continuer';

  @override
  String get createSubjectMissingTimeGoal =>
      'Fixez-vous un objectif de concentration valide';

  @override
  String get createSubjectMissingPagesGoal =>
      'Définir un objectif de page valide';

  @override
  String get createSubjectSuccessStudying => 'Sujet créé avec succès';

  @override
  String get createSubjectSuccessReading => 'Lecture créée avec succès';

  @override
  String get createSubjectSuccessExercises => 'Activité créée avec succès';

  @override
  String get createSubjectSuccessHobbies => 'Hobby créé avec succès';

  @override
  String pagesProgress(int currentPages, int goalPages) {
    return 'Pages $currentPages sur $goalPages';
  }

  @override
  String pagesReadOnly(int currentPages) {
    return '$currentPages pages lues';
  }

  @override
  String get pagesReadNowHint => 'Pages lues maintenant';

  @override
  String get logPagesButton => 'Pages de journal';

  @override
  String get notesLabel => 'Remarques';

  @override
  String get notesHint => 'Écrivez vos notes ici...';

  @override
  String get saveNotesButton => 'Enregistrer';

  @override
  String get addNotesPageTooltip => 'Ajouter une page';

  @override
  String notesPageCounter(int currentPage, int pageCount) {
    return 'Page $currentPage sur $pageCount';
  }

  @override
  String durationProgress(String duration, String goalDuration) {
    return '$duration sur $goalDuration';
  }

  @override
  String timerTotalLabel(String duration) {
    return 'Total : $duration';
  }

  @override
  String timerNextBreakLabel(String duration) {
    return 'Prochaine pause dans $duration';
  }

  @override
  String timerRestingLabel(String duration) {
    return 'Repos - de retour dans $duration';
  }

  @override
  String get timerNotificationRunning => 'Séance de focus en cours';

  @override
  String get timerNotificationResting => 'Repos - de retour bientôt';

  @override
  String get timerNotificationPaused => 'En pause';

  @override
  String get timerStateFocusingTitle => 'Mise au point en cours';

  @override
  String get timerStateFocusingDescription =>
      'Restez concentré. Une pause sera proposée prochainement.';

  @override
  String get timerStatePausedTitle => 'Minuterie en pause';

  @override
  String get timerStatePausedDescription => 'Continuez lorsque vous êtes prêt.';

  @override
  String get timerStateRestingTitle => 'Pause bien méritée';

  @override
  String get timerStateRestingDescription =>
      'Buvez de l\'eau ou respirez un peu avant de continuer.';

  @override
  String get timerSessionSavedTitle => 'Session enregistrée';

  @override
  String get timerSessionSavedDescription =>
      'Votre temps a été ajouté au sujet.';

  @override
  String get timerCurrentFocusLabel => 'Temps concentré maintenant';

  @override
  String get timerRestTimeLabel => 'Temps de pause';

  @override
  String get timerSessionLabel => 'Session en cours';

  @override
  String timerTotalInSubject(String subjectName) {
    return 'Total dans $subjectName';
  }

  @override
  String get timerPauseButton => 'Pause';

  @override
  String get timerContinueButton => 'Continuer';

  @override
  String get timerContinueFocusButton => 'Continuer';

  @override
  String get timerSkipRestButton => 'Sauter la pause';

  @override
  String get timerEndSessionButton => 'Fin de séance';

  @override
  String get timerStartAnotherSessionButton => 'Démarrer une autre session';

  @override
  String get timerSaveReassurance =>
      'La progression est également enregistrée lorsque vous faites une pause ou quittez.';

  @override
  String timerFocusedValue(String duration) {
    return '$duration concentré';
  }

  @override
  String get timerAccumulatedTotalLabel => 'Total cumulé';

  @override
  String get timerBackToSubjectsButton => 'Retour';

  @override
  String get timerExitDialogTitle => 'Fin de séance ?';

  @override
  String timerExitDialogContent(String duration, String subjectName) {
    return 'Votre progression $duration sera enregistrée dans $subjectName.';
  }

  @override
  String get timerExitDialogCancel => 'Continuer';

  @override
  String get timerExitDialogContinueLater =>
      'Vous pourrez continuer plus tard.';

  @override
  String get timerExitDialogConfirm => 'Fin';

  @override
  String get profileTitle => 'Voyage';

  @override
  String get profileSubtitle => 'Suivez vos progrès et les étapes clés';

  @override
  String get editButton => 'Modifier';

  @override
  String get nicknameFallback => 'utilisateur';

  @override
  String get profileSummaryLabel => 'Résumé total';

  @override
  String get profileSummarySinceStartLabel => 'Depuis le début';

  @override
  String profileSummaryAccumulatedFocus(Object duration) {
    return '$duration de concentration accumulée';
  }

  @override
  String get profileSummaryFocusLabel => 'Temps de mise au point total';

  @override
  String get profileSummaryFocusDescription => 'Études, exercice et loisirs';

  @override
  String get statHoursStudied => 'Étudier';

  @override
  String get statHoursExercised => 'Exercice';

  @override
  String get statPagesRead => 'Pages lues';

  @override
  String get statTopSubject => 'Les plus étudiés';

  @override
  String get profileStatTimeEmptyTitle =>
      'Commencez votre première concentration';

  @override
  String get profileStatTimeEmptyDescription => 'Votre temps s\'affichera ici';

  @override
  String get profileStatExerciseEmptyTitle => 'Pas encore d\'exercice';

  @override
  String get profileStatExerciseEmptyDescription =>
      'Enregistrez votre première activité';

  @override
  String get profileStatReadingEmptyTitle => 'Aucune page pour l\'instant';

  @override
  String get profileStatReadingEmptyDescription =>
      'Enregistrez votre première lecture';

  @override
  String get profileTopSubjectEmptyTitle => 'Aucun pour l\'instant';

  @override
  String get profileTopSubjectEmptyDescription =>
      'Étudier un sujet pour le présenter ici';

  @override
  String get profileEmptyTitle => 'Votre progression commence ici';

  @override
  String get profileEmptyDescription =>
      'Démarrez une session, enregistrez des lectures ou définissez un objectif depuis l\'accueil pour suivre votre évolution dans HelpOut.';

  @override
  String get profileEmptyGuidance =>
      'Après cela, votre temps total, vos principales activités et les points forts de vos lectures apparaîtront ici.';

  @override
  String get profileEmptyStartButton => 'Commencez maintenant';

  @override
  String get profileShortcutsTitle => 'Raccourcis';

  @override
  String get profileShortcutCreateSubject => 'Créer un sujet';

  @override
  String get profileShortcutCreateGoal => 'Créer un objectif';

  @override
  String get profileShortcutAddSchedule => 'Ajouter un horaire';

  @override
  String get profileEvolutionTitle => 'Votre progression';

  @override
  String profileEvolutionFocus(String duration) {
    return 'Vous avez accumulé $duration de concentration.';
  }

  @override
  String profileEvolutionTopSubject(String name) {
    return 'Votre sujet le plus étudié est $name.';
  }

  @override
  String profileEvolutionRemaining(String duration) {
    return 'Vous êtes à $duration de votre objectif.';
  }

  @override
  String get profileEvolutionGoalReached =>
      'Vous avez atteint votre objectif de concentration !';

  @override
  String get profileProgressSectionTitle => 'Votre progression';

  @override
  String get profileAchievementsTitle => 'Réalisations';

  @override
  String get profileSeeHistory => 'Voir l\'historique';

  @override
  String get profileSeeAll => 'Voir tout';

  @override
  String get profileAchievementFirstUnlocked => '1ère réalisation';

  @override
  String get profileAchievementGoalStarted => 'Objectif commencé';

  @override
  String get profileAchievementsStartHint => 'Commencez à gagner des succès';

  @override
  String get profileAchievementFirstFocus => 'Premier focus';

  @override
  String get profileAchievementStudyStarted => 'Étude commencée';

  @override
  String get profileAchievementReadingStarted => 'La lecture a commencé';

  @override
  String get profileAchievementLocked => 'Verrouillé';

  @override
  String get periodFiveDays => '5 jours';

  @override
  String get periodWeek => '1 semaine';

  @override
  String get periodMonth => '1 mois';

  @override
  String get periodTotal => 'Total';

  @override
  String get profileAgendaTitle => 'Le programme d\'aujourd\'hui';

  @override
  String get profileAgendaEmptyTitle => 'Aucun planning prévu';

  @override
  String get profileAgendaEmptyDescription =>
      'Ajoutez des blocs pour organiser votre routine.';

  @override
  String get profileAgendaAddButton => 'Ajouter un horaire';

  @override
  String get profileTopReadingTitle => 'Meilleures lectures';

  @override
  String get profileTopReadingEmptyTitle => 'Aucune lecture enregistrée';

  @override
  String get profileTopReadingEmptyDescription =>
      'Pages de journal lues pour voir vos principaux thèmes ici.';

  @override
  String get groupsTitle => 'Groupes';

  @override
  String get groupsSubtitle => 'Comparez vos progrès avec vos amis';

  @override
  String get noGroupSelected => 'Aucun groupe sélectionné pour l\'instant.';

  @override
  String get newGroupChip => 'Nouveau';

  @override
  String get groupHeaderCreateButton => 'Groupe';

  @override
  String get groupsEmptyTitle => 'Aucun groupe pour l\'instant';

  @override
  String get groupsEmptyDescription =>
      'Créez un groupe pour comparer les progrès avec vos amis et maintenir l’élan.';

  @override
  String get groupsEmptyButton => 'Créer le premier groupe';

  @override
  String get you => 'Vous';

  @override
  String get mockStudyGroupName => 'Equipe d\'étude';

  @override
  String get mockWorkoutGroupName => 'Équipe d\'entraînement';

  @override
  String get periodToday => 'Aujourd\'hui';

  @override
  String get periodThisWeek => 'Semaine';

  @override
  String get periodThisMonth => 'Mois';

  @override
  String get periodDescriptionToday => 'aujourd\'hui';

  @override
  String get periodDescriptionThisWeek => 'cette semaine';

  @override
  String get periodDescriptionThisMonth => 'ce mois-ci';

  @override
  String get groupMetricStudying => 'heures d\'étude';

  @override
  String get groupMetricDailyGoals => 'jours d\'objectif terminés';

  @override
  String get groupMetricExercises => 'heures d\'exercice';

  @override
  String get groupMetricReading => 'pages lues';

  @override
  String get groupMetricHobbies => 'heures de passe-temps';

  @override
  String groupLeaderboardDescription(String period, String metric) {
    return 'Classement pour $period · mesuré en $metric';
  }

  @override
  String get leaderboardTitle => 'Classement';

  @override
  String get currentUserRankTitle => 'Votre prestation';

  @override
  String currentUserRankValue(String rank, String score) {
    return '$rank lieu · $score';
  }

  @override
  String currentUserRankNextStep(String score) {
    return '$score pour gravir une position';
  }

  @override
  String get currentUserRankLeading => 'Vous êtes en tête de ce classement.';

  @override
  String get currentUserRankSubtitle => 'votre position actuelle';

  @override
  String get leaderboardTopPosition => 'en tête de ce classement';

  @override
  String leaderboardDifferenceAhead(String value) {
    return '+$value en avance';
  }

  @override
  String get groupCreatedSuccess => 'Groupe créé avec succès';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsSubtitle => 'Ajustez votre compte et vos préférences';

  @override
  String get myProfileFallback => 'Mon profil';

  @override
  String get personalProfileLabel => 'Profil personnel';

  @override
  String accountDataSubtitle(Object nickname) {
    return '$nickname · données personnelles et sécurité';
  }

  @override
  String get preferencesSection => 'Préférences';

  @override
  String get darkModeLabel => 'Mode sombre';

  @override
  String get darkModeEnabledSubtitle => 'Le thème sombre est activé';

  @override
  String get darkModeDisabledSubtitle =>
      'Utilisez le thème sombre dans l\'application';

  @override
  String get accentColorSettingsTitle => 'Couleur d\'accentuation';

  @override
  String get accentColorSettingsSubtitle =>
      'Personnalisez l\'apparence de l\'application';

  @override
  String get notificationsLabel => 'Notifications';

  @override
  String get timerNotificationsTitle => 'Notifications de minuterie';

  @override
  String get notificationsEnabledSubtitle =>
      'Alertes de concentration, de pause et de progression';

  @override
  String get notificationsDisabledSubtitle =>
      'Les alertes sont désactivées sur cet appareil';

  @override
  String get language => 'Langue';

  @override
  String get appLanguageSubtitle => 'Langue de l\'application';

  @override
  String get automaticLanguageLabel => 'Automatique';

  @override
  String get chooseLanguageTitle => 'Choisir la langue';

  @override
  String languageChangedMessage(String language) {
    return 'Langue modifiée en $language';
  }

  @override
  String get preferenceSavedMessage => 'Préférence enregistrée';

  @override
  String get supportSection => 'Assistance';

  @override
  String get helpSection => 'Aide';

  @override
  String get faqLabel => 'FAQ';

  @override
  String get faqSettingsSubtitle =>
      'Questions sur le chronomètre, les objectifs et les groupes';

  @override
  String get sendFeedbackTitle => 'Envoyer des commentaires';

  @override
  String get sendFeedbackSubtitle => 'Dites-nous ce qui pourrait être mieux';

  @override
  String get feedbackUnavailable =>
      'Les commentaires ne sont pas encore disponibles';

  @override
  String get aboutLabel => 'À propos';

  @override
  String get aboutSection => 'À propos';

  @override
  String appVersionValue(String version) {
    return 'Version$version';
  }

  @override
  String get debugEnvironmentTitle => 'Environnement';

  @override
  String get debugEnvironmentSubtitle =>
      'Débogage · exemples de données actifs';

  @override
  String appVersionLabel(String appTitle, String appVersion) {
    return '$appTitle v$appVersion';
  }

  @override
  String get accountSection => 'Compte';

  @override
  String get sessionSection => 'Séance';

  @override
  String get logOutLabel => 'Se déconnecter';

  @override
  String get logOutSettingsSubtitle => 'Terminer la session sur cet appareil';

  @override
  String get logOutDialogTitle => 'Se déconnecter ?';

  @override
  String get logOutDialogContent =>
      'Vous devrez vous reconnecter pour accéder à ce compte sur cet appareil. Les données de votre étude locale seront conservées.';

  @override
  String get logOutConfirmButton => 'Se déconnecter';

  @override
  String get myProfileTitle => 'Mon profil';

  @override
  String get avatarLabel => 'avatar';

  @override
  String get nameLabel => 'Nom';

  @override
  String get yourNameHint => 'Votre nom';

  @override
  String get nicknameLabel => 'Surnom';

  @override
  String get nicknameHint => 'Quels amis t\'appellent';

  @override
  String get emailLabel => 'Courriel';

  @override
  String get optionalHint => 'Facultatif';

  @override
  String get phoneLabel => 'Numéro de téléphone';

  @override
  String get themeColorLabel => 'Couleur du thème';

  @override
  String get saveChangesButton => 'Enregistrer les modifications';

  @override
  String get profileSavedMessage => 'Profil enregistré';

  @override
  String get profilePhotoSelectLabel => 'Ajouter une photo';

  @override
  String get profilePhotoRemoveLabel => 'Supprimer la photo';

  @override
  String get faqTitle => 'FAQ';

  @override
  String get faqQ1 => 'Comment fonctionne le minuteur d\'étude ?';

  @override
  String get faqA1 =>
      'Choisissez un sujet, appuyez sur Lecture et le minuteur suit votre session en cours tout en l\'ajoutant à la durée totale de ce sujet. Appuyez sur pause à tout moment pour arrêter et enregistrer votre progression.';

  @override
  String get faqQ2 => 'Qu\'est-ce que le compte à rebours des pauses ?';

  @override
  String get faqA2 =>
      'Chaque séance suit un cycle Pomodoro classique : un compte à rebours de 25 minutes jusqu\'à votre prochaine pause. Lorsqu\'il atteint zéro, il se réinitialise simplement, c\'est un rappel, pas un arrêt brutal.';

  @override
  String get faqQ3 => 'Comment ajouter un nouveau sujet ?';

  @override
  String get faqA3 =>
      'Ouvrez une catégorie depuis Accueil, puis appuyez sur « Ajouter un sujet » au bas de la liste. Vous pouvez choisir une couleur et définir un objectif d’heures estimé pour celle-ci.';

  @override
  String get faqQ4 =>
      'Comment les groupes et le classement sont-ils calculés ?';

  @override
  String get faqA4 =>
      'Les groupes affichent un tableau de bord basé sur le thème du groupe : heures de concentration, jours d\'objectifs atteints ou pages lues. Basculez entre Aujourd’hui, Semaine et Mois pour comparer les progrès.';

  @override
  String get faqQ5 =>
      'Puis-je modifier le thème de couleur de l\'application ?';

  @override
  String get faqA5 =>
      'Oui, accédez à Paramètres > Mon profil et choisissez n\'importe quelle couleur de thème. Chaque dégradé, bouton et surbrillance de l\'application est mis à jour pour y correspondre, y compris le mode sombre.';

  @override
  String get createGroupTitle => 'Nouveau groupe';

  @override
  String get createGroupSubtitle => 'Choisissez un thème et invitez des amis';

  @override
  String get groupNameLabel => 'Nom du groupe';

  @override
  String get groupNameHint => 'Nom du groupe';

  @override
  String get groupNameExampleHint => 'Ex. : équipe d\'étude de l\'examen';

  @override
  String get groupThemeLabel => 'Thème';

  @override
  String groupThemeSelectedDescription(String metric) {
    return 'Ce groupe est classé par $metric.';
  }

  @override
  String get inviteFriendsLabel => 'Inviter des amis';

  @override
  String selectedFriendsCount(int count) {
    return '$count sélectionné';
  }

  @override
  String get selectAtLeastOneFriend => 'Sélectionnez au moins 1 ami';

  @override
  String get searchFriendHint => 'Rechercher un ami';

  @override
  String get loadingFriends => 'Chargement des amis...';

  @override
  String get friendsLoadErrorTitle => 'Impossible de charger les amis';

  @override
  String get friendsLoadErrorDescription => 'Réessayez dans un instant.';

  @override
  String get noFriendsAvailableTitle => 'Aucun ami disponible';

  @override
  String get noFriendsAvailableDescription =>
      'Ajoutez des amis avant de créer un groupe.';

  @override
  String get noFriendsFoundTitle => 'Aucun ami trouvé';

  @override
  String get noFriendsFoundDescription => 'Essayez un autre nom.';

  @override
  String get createGroupButton => 'Créer un groupe';

  @override
  String get createGroupMissingName => 'Entrez le nom du groupe';

  @override
  String get createGroupMissingTheme => 'Choisissez un thème';

  @override
  String get createGroupMissingFriends => 'Sélectionnez au moins 1 ami';

  @override
  String createGroupWithFriendsButton(int count) {
    return 'Créer un groupe avec des amis $count';
  }

  @override
  String get createGroupRequirementsTitle => 'Pour créer :';

  @override
  String get createGroupRequirementName => 'Nom du groupe';

  @override
  String get createGroupRequirementTheme => 'Thème choisi';

  @override
  String get createGroupRequirementFriends => 'Au moins 1 ami';

  @override
  String get groupPrivacyNote =>
      'Vos amis ne verront que votre nom, votre avatar et votre progression dans ce thème.';

  @override
  String metricDaysValue(int value) {
    return '$value jours';
  }

  @override
  String metricPagesValue(int value) {
    return '$value pages';
  }

  @override
  String get navHome => 'Accueil';

  @override
  String get navProfile => 'Voyage';

  @override
  String get navGroups => 'Groupes';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get myScheduleCardTitle => 'Mon emploi du temps';

  @override
  String get myScheduleTitle => 'Mon emploi du temps';

  @override
  String get noScheduleYet => 'Pas encore d\'horaire';

  @override
  String get noScheduleYetDescription =>
      'Appuyez sur le bouton ci-dessous pour ajouter\nvotre premier emploi du temps';

  @override
  String get addScheduleEntryTitle => 'Ajouter une entrée de planification';

  @override
  String get addScheduleEntryButton => 'Ajouter une entrée';

  @override
  String get scheduleInfoSection => 'Informations';

  @override
  String get scheduleWhenSection => 'Quand ?';

  @override
  String get scheduleColorSection => 'Couleur du calendrier';

  @override
  String get schedulePreviewSection => 'Aperçu';

  @override
  String scheduleDurationLabel(String duration) {
    return 'Durée : $duration';
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
  String get scheduleTitleHint => 'Titre';

  @override
  String get startTimeLabel => 'Heure de début';

  @override
  String get endTimeOptionalLabel => 'Heure de fin';

  @override
  String get incompleteScheduleEntryError =>
      'Entrée incomplète : indiquez le titre, l\'heure de début et l\'heure de fin.';

  @override
  String get endTimeBeforeStartError =>
      'L\'heure de fin doit être postérieure à l\'heure de début.';

  @override
  String get nameRequiredError => 'Veuillez d\'abord saisir un nom.';

  @override
  String get groupThemeRequiredError =>
      'Choisissez un thème pour votre groupe.';

  @override
  String get groupNeedsFriendError =>
      'Invitez au moins un ami : un groupe ne peut pas être créé seul.';

  @override
  String get continueWithGoogleButton => 'Continuer avec Google';

  @override
  String get continueWithAppleButton => 'Continuer avec Apple';

  @override
  String get continueWithPhoneButton => 'Continuer avec le numéro de téléphone';

  @override
  String get phoneLoginTitle => 'Votre numéro';

  @override
  String get phoneLoginSubtitle =>
      'Entrez votre numéro de téléphone pour recevoir un code d\'accès.';

  @override
  String get sendCodeButton => 'Envoyer le code';

  @override
  String get phoneSecurityNote =>
      'Vous pouvez utiliser votre numéro pour vous connecter en toute sécurité.';

  @override
  String get selectCountryTitle => 'Sélectionnez votre pays';

  @override
  String get searchCountryHint => 'Rechercher un pays';

  @override
  String get otpCodeExpired =>
      'Code expiré. Renvoyez pour en obtenir un nouveau.';

  @override
  String get otpTitle => 'Vérifiez votre numéro';

  @override
  String otpSubtitle(String phone) {
    return 'Entrez le code à 6 chiffres que nous avons envoyé à $phone.';
  }

  @override
  String get verifyCodeButton => 'Vérifier';

  @override
  String get resendCodeButton => 'Renvoyer le code';

  @override
  String otpCodeValidFor(String time) {
    return 'Code valable pour $time';
  }

  @override
  String get codeResentMessage => 'Code de vérification envoyé';

  @override
  String get invalidCodeError => 'Code invalide. Veuillez réessayer.';

  @override
  String get credentialsTitle => 'Créez votre profil';

  @override
  String get credentialsSubtitle =>
      'Parlez-nous un peu de vous pour personnaliser votre expérience.';

  @override
  String get birthDateHint => 'Date de naissance';

  @override
  String get profileEditableLaterNote => 'Vous pourrez le modifier plus tard.';

  @override
  String get finishButton => 'Terminer';
}
