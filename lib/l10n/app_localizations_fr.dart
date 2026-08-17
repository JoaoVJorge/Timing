// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Timing';

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
  String get homeNextScheduleEmpty => 'Aucun rendez-vous aujourd\'hui';

  @override
  String get homeNextScheduleAdd => 'Ajouter un rendez-vous';

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
  String get estimatedHoursGoalHint => 'Durée en minutes';

  @override
  String get createSubjectTotalHoursGoalHint => 'Temps total en heures';

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
  String get createSubjectTimeGoalLabel => 'Durée de chaque section';

  @override
  String get createSubjectTotalTimeGoalLabel =>
      'Combien de temps voulez-vous étudier au total ?';

  @override
  String get createSubjectTotalTimeGoalLabelStudying =>
      'Combien de temps voulez-vous étudier au total ?';

  @override
  String get createSubjectTotalTimeGoalLabelExercises =>
      'Combien de temps voulez-vous faire de l\'exercice au total ?';

  @override
  String get createSubjectTotalTimeGoalLabelHobbies =>
      'Combien de temps voulez-vous pratiquer au total ?';

  @override
  String get createSubjectPagesGoalLabel => 'Objectif de la page';

  @override
  String get createSubjectTimeGoalHelp =>
      'Combien de minutes souhaitez-vous vous concentrer ?';

  @override
  String get createSubjectPagesGoalHelp =>
      'Combien de pages souhaitez-vous connecter au total ?';

  @override
  String get createSubjectRestLabel => 'Durée des pauses';

  @override
  String get createSubjectRestHelp =>
      'Le timer propose une pause après 30 min de concentration.';

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
    return '${hours}h $minutes min';
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
      'Démarrez une session, enregistrez des lectures ou définissez un objectif depuis l\'accueil pour suivre votre évolution dans Timing.';

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
  String get linkedAccountsSection => 'Connexions liées';

  @override
  String get linkedAccountsSubtitle =>
      'Utilisez Google et Apple pour accéder à ce même compte.';

  @override
  String get linkGoogleAccountTitle => 'Associer Google';

  @override
  String get linkGoogleAccountSubtitle =>
      'Se connecter avec Google sur ce compte';

  @override
  String get linkAppleAccountTitle => 'Associer Apple';

  @override
  String get linkAppleAccountSubtitle =>
      'Se connecter avec Apple sur ce compte';

  @override
  String get authProviderConnected => 'Connecté';

  @override
  String get linkAuthProviderStarted =>
      'Terminez la connexion pour associer le compte.';

  @override
  String get linkAuthProviderFailure =>
      'Impossible de démarrer l\'association. Vérifiez le fournisseur et l\'association manuelle dans Supabase.';

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
      'Chaque séance suit un cycle de concentration : un compte à rebours de 30 minutes jusqu\'à votre prochaine pause. Lorsqu\'il atteint zéro, il se réinitialise simplement, c\'est un rappel, pas un arrêt brutal.';

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
  String get navGroups => 'Groupes';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get myScheduleCardTitle => 'Mon emploi du temps';

  @override
  String get myScheduleTitle => 'Mon emploi du temps';

  @override
  String get noScheduleYet => 'Aucun rendez-vous pour le moment';

  @override
  String get noScheduleYetDescription =>
      'Appuyez sur le bouton ci-dessous pour ajouter\nvotre premier rendez-vous';

  @override
  String get addScheduleEntryTitle => 'Ajouter un rendez-vous';

  @override
  String get addScheduleEntryButton => 'Ajouter un rendez-vous';

  @override
  String get scheduleInfoSection => 'Informations';

  @override
  String get scheduleWhenSection => 'Quand ?';

  @override
  String get scheduleColorSection => 'Couleur du rendez-vous';

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

  @override
  String get navProgress => 'Progression';

  @override
  String get progressTitle => 'Progression';

  @override
  String get progressSubtitle => 'Tout ce que vous avez déjà fait';

  @override
  String get progressPeriodDay => 'Jour';

  @override
  String get progressPeriodWeek => 'Semaine';

  @override
  String get progressPeriodMonth => 'Mois';

  @override
  String get progressFocusResultLabel => 'Concentration sur cette période';

  @override
  String progressComparisonMore(String value) {
    return '$value de plus que la période précédente';
  }

  @override
  String progressComparisonLess(String value) {
    return '$value de moins que la période précédente';
  }

  @override
  String get progressComparisonSame => 'Identique à la période précédente';

  @override
  String get progressComparisonFirst =>
      'Vos premières données sur cette période';

  @override
  String get progressStatExercises => 'Exercices';

  @override
  String get progressStatLongestGoal => 'Objectif le plus long';

  @override
  String get progressStatMainReading => 'Lecture principale';

  @override
  String get progressStatGoalsDone => 'Objectifs atteints';

  @override
  String get progressDistributionTitle => 'Par activité';

  @override
  String homeTodayInline(String focus, int pages, int goals) {
    return 'Aujourd\'hui : $focus de focus · $pages pages · $goals objectifs';
  }

  @override
  String get homePlanDayTitle => 'Planifier ma journée';

  @override
  String get homePlanDaySubtitle =>
      'Objectifs quotidiens et agenda hebdomadaire';

  @override
  String get groupsFriendsTitle => 'Amis';

  @override
  String get groupsFriendsSubtitle => 'Demandes, invitations et votre code';

  @override
  String groupMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres',
      one: '1 membre',
    );
    return '$_temp0';
  }

  @override
  String get createScheduleEntryButton => 'Créer le rendez-vous';

  @override
  String get scheduleEntryMissingFields =>
      'Renseignez le titre, le début et la fin pour continuer';

  @override
  String timerSessionCounter(int current, int total) {
    return 'Focus $current sur $total';
  }

  @override
  String get timerExitBackToFocus => 'Revenir au focus';

  @override
  String get timerExitSaveAndEnd => 'Enregistrer et terminer';

  @override
  String get notesSavedNow => 'Enregistré à l\'instant';

  @override
  String get notesSaving => 'Enregistrement…';

  @override
  String get dailyGoalsPendingSection => 'En cours';

  @override
  String get dailyGoalsCompletedSection => 'Terminés';

  @override
  String get dailyGoalsEmptyTitle => 'Aucun objectif pour aujourd\'hui';

  @override
  String get dailyGoalsEmptyDescription =>
      'Écrivez un objectif ci-dessus ou choisissez une suggestion pour commencer la journée.';

  @override
  String achievementProgressValue(String current, String total) {
    return '$current sur $total';
  }

  @override
  String get categoryEmptyTitle => 'Rien ici pour l\'instant';

  @override
  String get categoryEmptyDescription =>
      'Créez votre premier élément pour commencer à suivre votre concentration.';

  @override
  String get scheduleEmptyExampleLabel => 'Exemple';

  @override
  String get progressAchievementsNextTitle => 'Prochain succès';

  @override
  String get achievementFocusHourTitle => '1 heure de concentration';

  @override
  String get achievementSessionsTitle => '5 sessions terminées';

  @override
  String get achievementStreakTitle => '7 jours d\'affilée';

  @override
  String get achievementReaderTitle => '100 pages lues';

  @override
  String get achievementGoalStartedTitle => 'Premier objectif lancé';

  @override
  String unitMinutesShort(int value) {
    return '$value min';
  }

  @override
  String unitSessions(int value) {
    return '$value sessions';
  }

  @override
  String unitDays(int value) {
    return '$value jours';
  }

  @override
  String currentUserRankNextStepNamed(String score, String name) {
    return '$score pour rattraper $name';
  }

  @override
  String get timerKeepAwakeNote => 'L\'écran reste allumé pendant la session';

  @override
  String scheduleWeekLabel(String date) {
    return 'Semaine du $date';
  }

  @override
  String get daysSuffix => 'jours';

  @override
  String get createTaskSubtitle =>
      'Configurez un objectif quotidien pour suivre vos progrès';

  @override
  String get createTaskSequenceTypeLabel => 'Type de série';

  @override
  String get createTaskSequenceIntenseLabel => 'Intense';

  @override
  String get createTaskSequenceIntenseDescription =>
      'Aucun oubli. Si vous manquez un jour, votre série repart à zéro.';

  @override
  String get createTaskSequenceCasualLabel => 'Flexible';

  @override
  String get createTaskSequenceCasualDescription =>
      'Plus flexible. Les jours manqués ne réinitialisent pas votre série.';

  @override
  String get targetDaysInfinite => 'Infini';

  @override
  String get deleteConfirmationDefaultTypeName => 'élément';

  @override
  String deleteConfirmationTitle(String typeName) {
    return 'Supprimer $typeName ?';
  }

  @override
  String deleteConfirmationContent(String itemName) {
    return 'Vous êtes sur le point de supprimer \"$itemName\". Cette action est irréversible.';
  }

  @override
  String deleteConfirmationHistoryWarning(String typeName) {
    return 'L\'historique de $typeName sera également supprimé.';
  }

  @override
  String homeDaySummaryFocusValue(String focus) {
    return '$focus focus';
  }

  @override
  String homeDaySummaryGoalsValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count objectifs',
      one: '1 objectif',
    );
    return '$_temp0';
  }

  @override
  String get profilePhotoSourceTitle => 'Photo de profil';

  @override
  String get profilePhotoSourceSubtitle =>
      'Choisissez comment mettre à jour votre photo';

  @override
  String get photoCameraLabel => 'Prendre une photo';

  @override
  String get photoGalleryLabel => 'Choisir dans la galerie';

  @override
  String get removePhotoDialogTitle => 'Supprimer la photo ?';

  @override
  String get removePhotoDialogContent =>
      'Votre avatar réapparaîtra sur le profil.';

  @override
  String get friendRequestsReceivedTab => 'Demandes';

  @override
  String get friendRequestsSentTab => 'Invitations';

  @override
  String hobbyPracticeMinutes(int minutes) {
    return '$minutes min de pratique';
  }

  @override
  String get hobbyViewStatistics => 'Voir les statistiques';

  @override
  String get hobbyEdit => 'Modifier le hobby';

  @override
  String get pinToStart => 'Épingler au début';

  @override
  String get hobbyDelete => 'Supprimer le hobby';

  @override
  String get deleteActionCannotBeUndone => 'Cette action est irréversible.';

  @override
  String get joinGroupTitle => 'Rejoindre un groupe';

  @override
  String get joinGroupInviteCodeLabel => 'Code d’invitation';

  @override
  String get joinGroupCodeHint => 'Saisissez le code';

  @override
  String get joinGroupButton => 'Rejoindre le groupe';

  @override
  String get joinGroupError => 'Impossible de rejoindre ce groupe.';

  @override
  String get scheduleDayEventsTitle => 'Agenda du jour';

  @override
  String get dailyGoalsNoGoalsYetTitle => 'Aucun objectif pour l’instant';

  @override
  String get dailyGoalsNoGoalsYetDescription =>
      'Ajoutez votre premier objectif pour organiser la journée et suivre vos réussites.';

  @override
  String get dailyGoalsSuggestionsTitle => 'Suggestions pour commencer';

  @override
  String get dailyGoalsSuggestionStudy => 'Étudier 30 min';

  @override
  String get dailyGoalsSuggestionRead => 'Lire 10 pages';

  @override
  String get dailyGoalsSuggestionTrain => 'S’entraîner';

  @override
  String get goalTypeName => 'objectif';

  @override
  String get missedYesterdayDialogTitle => 'L?avez-vous termin? hier ?';

  @override
  String missedYesterdayDialogContent(String taskName) {
    return 'Vous n?avez pas enregistr? \"$taskName\" hier. L?avez-vous vraiment manqu? ?';
  }

  @override
  String get missedYesterdayMissedButton => 'Oui, je l?ai manqu?';

  @override
  String get missedYesterdayCompletedButton => 'Je l?ai termin?';

  @override
  String get scheduleTitleRequiredError => 'Ajoutez un titre pour continuer';

  @override
  String get scheduleActiveFromLabel => 'Débute';

  @override
  String get scheduleActiveUntilLabel => 'Se termine';

  @override
  String get selectDateTitle => 'Sélectionner une date';

  @override
  String get selectDateHint => 'Choisissez un jour dans le calendrier';

  @override
  String get addFriendTitle => 'Ajouter un ami';

  @override
  String get friendCodeNotFound =>
      'Nous n’avons trouvé aucun utilisateur avec ce code.';

  @override
  String get friendInviteCodeTitle => 'Code d’invitation';

  @override
  String get friendInviteCodeFieldLabel => 'Saisissez ou collez le code';

  @override
  String get friendInviteCodeFieldHint => 'Comme ABCDE12345';

  @override
  String get pasteButton => 'Coller';

  @override
  String get searchCodeButton => 'Rechercher le code';

  @override
  String get friendUserFoundTitle => 'Utilisateur trouv?';

  @override
  String get friendFoundByCode => 'Trouvé par code';

  @override
  String get sentLabel => 'Envoy?';

  @override
  String get friendHowItWorksTitle => 'Comment ça marche';

  @override
  String get friendHowItWorksStepOne => 'Demandez le code à votre ami';

  @override
  String get friendHowItWorksStepTwo => 'Collez le code pour trouver le profil';

  @override
  String get friendHowItWorksStepThree => 'Envoyez la demande pour l’ajouter';

  @override
  String get myCodeLabel => 'Mon code';

  @override
  String get yourInviteCodeLabel => 'Votre code d’invitation';

  @override
  String yourFriendsTitle(int count) {
    return 'Vos amis ($count)';
  }

  @override
  String get seeAllButton => 'Voir tout';

  @override
  String get onlineLabel => 'En ligne';

  @override
  String minutesAgoShort(int minutes) {
    return 'Il y a $minutes min';
  }

  @override
  String get friendsEmptyTitle => 'Vous n’avez pas encore d’amis';

  @override
  String get friendsEmptySubtitle =>
      'Recherchez des personnes ci-dessus ou partagez votre code d’invitation.';

  @override
  String get shareCodeButton => 'Partager le code';

  @override
  String get codeCopiedMessage => 'Code copi?';

  @override
  String get friendRequestSentMessage => 'Demande envoyée';

  @override
  String get joinedGroupMessage => 'Vous avez rejoint le groupe';

  @override
  String get friendTypeName => 'ami';

  @override
  String shareInviteCodeMessage(String code) {
    return 'Ajoutez-moi sur Timing avec mon code : $code';
  }

  @override
  String groupInvitesTitle(int count) {
    return 'Invitations de groupe ($count)';
  }

  @override
  String groupInvitedBy(String inviter) {
    return '$inviter vous a invit?';
  }

  @override
  String get acceptButton => 'Accepter';

  @override
  String get declineButton => 'Refuser';

  @override
  String get friendsTitle => 'Amis';

  @override
  String get friendRequestsReceivedPageTitle => 'Demandes';

  @override
  String get friendRequestsSentPageTitle => 'Invitations';

  @override
  String friendRequestsReceivedSection(int count) {
    return 'Reçues ($count)';
  }

  @override
  String friendRequestsSentSection(int count) {
    return 'Envoyées ($count)';
  }

  @override
  String get friendMutualFriendsSample => '3 amis en commun';

  @override
  String get pendingLabel => 'En attente';

  @override
  String get friendRequestsIncomingEmptyTitle => 'Aucune demande reçue';

  @override
  String get friendRequestsSentEmptyTitle => 'Aucune invitation envoyée';

  @override
  String get friendRequestsIncomingEmptySubtitle =>
      'Les demandes apparaîtront ici.';

  @override
  String get friendRequestsSentEmptySubtitle =>
      'Vos invitations envoyées apparaîtront ici.';

  @override
  String get friendRequestsSafetyNotice =>
      'N’acceptez que les personnes que vous connaissez et en qui vous avez confiance.';

  @override
  String get categoryEmptyStudyingTitle => 'Aucune matière pour l’instant';

  @override
  String get categoryEmptyExercisesTitle => 'Aucun exercice pour l’instant';

  @override
  String get categoryEmptyReadingTitle => 'Aucune lecture pour l’instant';

  @override
  String get categoryEmptyHobbiesTitle => 'Aucun hobby pour l’instant';

  @override
  String get categoryEmptyStudyingDescription =>
      'Ajoutez votre première matière pour organiser vos études et suivre votre concentration.';

  @override
  String get categoryEmptyExercisesDescription =>
      'Ajoutez votre premier exercice pour suivre vos entraînements, séances et progrès.';

  @override
  String get categoryEmptyReadingDescription =>
      'Ajoutez votre première lecture pour suivre les pages, le temps et les progrès.';

  @override
  String get categoryEmptyHobbiesDescription =>
      'Ajoutez votre premier hobby pour suivre votre pratique et garder le rythme.';

  @override
  String get categorySuggestionStudyingOne => 'Mathématiques';

  @override
  String get categorySuggestionStudyingTwo => 'Anglais';

  @override
  String get categorySuggestionStudyingThree => 'Rédaction';

  @override
  String get categorySuggestionExercisesOne => 'Course';

  @override
  String get categorySuggestionExercisesTwo => 'Renforcement';

  @override
  String get categorySuggestionExercisesThree => 'Étirements';

  @override
  String get categorySuggestionReadingOne => 'Roman';

  @override
  String get categorySuggestionReadingTwo => 'Technique';

  @override
  String get categorySuggestionReadingThree => 'Articles';

  @override
  String get categorySuggestionHobbiesOne => 'Guitare';

  @override
  String get categorySuggestionHobbiesTwo => 'Dessin';

  @override
  String get categorySuggestionHobbiesThree => 'Cuisine';

  @override
  String get pagesAbbreviation => 'p.';

  @override
  String get loginSecurityNote => 'Vos données sont protégées et sécurisées.';

  @override
  String get nextBreakDurationLabel => 'Durée de la prochaine pause';

  @override
  String timerReadingExitContent(String duration, String subjectName) {
    return 'Vous avez lu pendant $duration. Indiquez combien de pages vous avez lues dans $subjectName.';
  }

  @override
  String get appleSignInIncompleteMessage =>
      'La connexion avec Apple n’est pas encore terminée.';

  @override
  String get activityTypeLabel => 'Type d’activité';

  @override
  String get activityTypeDailyLabel => 'Quotidienne';

  @override
  String get activityTypeDailyDescription =>
      'Utilisez des sections de focus avec des pauses et définissez combien de séances terminer chaque jour.';

  @override
  String get activityTypeDailyDescriptionStudying =>
      'Utilisez des sections d\'étude avec des pauses et définissez combien de séances terminer chaque jour.';

  @override
  String get activityTypeDailyDescriptionExercises =>
      'Utilisez des sections d\'exercice avec des pauses et définissez combien de séances terminer chaque jour.';

  @override
  String get activityTypeDailyDescriptionHobbies =>
      'Utilisez des sections de pratique avec des pauses et définissez combien de séances terminer chaque jour.';

  @override
  String get activityTypePermanentLabel => 'Permanente';

  @override
  String get activityTypePermanentDescription =>
      'Définissez le temps total d\'étude. L’activité reste active jusqu’à ce qu’elle soit terminée.';

  @override
  String get activityTypePermanentDescriptionStudying =>
      'Définissez le temps total d\'étude. L’activité reste active jusqu’à ce qu’elle soit terminée.';

  @override
  String get activityTypePermanentDescriptionExercises =>
      'Définissez le temps total d\'exercice. L’activité reste active jusqu’à ce qu’elle soit terminée.';

  @override
  String get activityTypePermanentDescriptionHobbies =>
      'Définissez le temps total de pratique. L’activité reste active jusqu’à ce qu’elle soit terminée.';

  @override
  String get pagesSuffix => 'pages';

  @override
  String get updatedSuccessfullyMessage => 'Mis à jour';

  @override
  String get focusSessionCountLabel => 'Nombre de séances';

  @override
  String get subjectSectionDurationDescription =>
      'Durée de chaque séance de concentration avant une pause ou la fin.';

  @override
  String get subjectSessionCountDescription =>
      'Nombre de séances de concentration à terminer par jour.';

  @override
  String get subjectRestDurationDescription =>
      'Durée de chaque pause entre les séances de concentration.';

  @override
  String get groupEditingComingSoon =>
      'Modification du groupe bientôt disponible.';

  @override
  String get leftGroupMessage => 'Vous avez quitté le groupe.';

  @override
  String get groupImageSourceTitle => 'Envoyer une image';

  @override
  String get groupImageSourceSubtitle => 'Choisissez comment envoyer l’image';

  @override
  String get deleteButton => 'Supprimer';

  @override
  String get manageMembersTitle => 'Gérer les membres';

  @override
  String get groupLeaderLabel => 'Chef';

  @override
  String get groupLeaderRoleLabel => 'Chef du groupe';

  @override
  String get groupMemberRoleLabel => 'Membre';

  @override
  String get groupMembersLabel => 'Membres';

  @override
  String get groupActionsLabel => 'Actions du groupe';

  @override
  String get goalsTabLabel => 'Données';

  @override
  String get chatTabLabel => 'Chat';

  @override
  String get groupGoalTitle => 'Objectif du groupe';

  @override
  String get groupMainRuleTitle => 'Règle principale';

  @override
  String get groupNextMilestoneTitle => 'Prochain jalon';

  @override
  String groupMembersProgressValue(int current, int total) {
    return '$current/$total membres';
  }

  @override
  String get groupNextMilestoneDescription =>
      'pour d?bloquer le badge ? Focus total ?';

  @override
  String get groupActivityLabel => 'Activité du groupe';

  @override
  String groupActivityReachedGoal(int reached, int total) {
    return '$reached/$total ont atteint l’objectif';
  }

  @override
  String get groupActivityFocusDataLabel => 'Focus';

  @override
  String get groupActivityPauseDataLabel => 'Pause';

  @override
  String get groupActivitySessionsDataLabel => 'Sessions';

  @override
  String get groupActivityPendingUsersTitle => 'Utilisateurs en attente';

  @override
  String get groupActivityAllCompletedToday =>
      'Tout le monde a terminé l’activité aujourd’hui.';

  @override
  String get groupNoImagesTitle => 'Aucune image pour l’instant';

  @override
  String get groupNoImagesDescription => 'Envoyez la première image du groupe.';

  @override
  String get groupSendImageButton => 'Envoyer une image';

  @override
  String get groupSendingImage => 'Envoi de l’image...';

  @override
  String get editGroupLabel => 'Modifier le groupe';

  @override
  String get leaveGroupLabel => 'Quitter le groupe';

  @override
  String groupDescription(String metric) {
    return 'Classement par $metric. Continuez à progresser avec le groupe.';
  }

  @override
  String groupsFriendsSubtitleWithCount(int groupCount) {
    return 'Demandes, invitations et $groupCount dans des groupes';
  }

  @override
  String groupGoalKeepMetric(String metric) {
    return 'Maintenir $metric chaque jour';
  }

  @override
  String groupGoalDescription(String metric) {
    return 'Chaque membre enregistre $metric pour maintenir la série du groupe.';
  }

  @override
  String groupRuleDescription(String metric) {
    return 'Enregistrez au moins une entrée de $metric par jour pour renforcer la série du groupe.';
  }

  @override
  String get joinWithCodeButton => 'J’ai un code d’invitation';

  @override
  String get groupsBenefitsHeader => 'Dans un groupe, vous pouvez :';

  @override
  String groupParticipantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participants',
      one: '1 participant',
    );
    return '$_temp0';
  }

  @override
  String groupMembersCompletedToday(int completed, int total) {
    return '$completed/$total membres ont terminé aujourd’hui';
  }

  @override
  String get addMemberButton => 'Ajouter un membre';

  @override
  String get groupCollectiveProgressTitle => 'Progression collective';

  @override
  String get dailyLabel => 'Quotidienne';

  @override
  String get completedLabel => 'Terminé';

  @override
  String groupActivityCompletedCount(int completed, int total) {
    return '$completed sur $total ont terminé';
  }

  @override
  String groupMissingParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il manque $count participants pour terminer l’objectif',
      one: 'Il manque 1 participant pour terminer l’objectif',
      zero: 'Tout le monde a terminé l’objectif',
    );
    return '$_temp0';
  }

  @override
  String groupParticipantsDataTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Participants ($count)',
      one: 'Participants (1)',
    );
    return '$_temp0';
  }

  @override
  String groupCompletedMembersTitle(int count) {
    return 'Ont terminé ($count)';
  }

  @override
  String groupPendingMembersTitle(int count) {
    return 'En attente ($count)';
  }

  @override
  String get groupNoCompletedMembersTitle => 'Personne n’a encore terminé';

  @override
  String get groupNoCompletedMembersSubtitle =>
      'Soyez le premier à terminer l’objectif !';

  @override
  String get groupStatisticsTitle => 'Statistiques du groupe';

  @override
  String get groupStreakStatLabel => 'Série du groupe';

  @override
  String get groupTodayTotalStatLabel => 'Temps total aujourd’hui';

  @override
  String get groupPeriodTotalStatLabel => 'Total de la période';

  @override
  String get groupCompletedSessionsStatLabel => 'Sessions terminées';

  @override
  String get groupParticipantsStatLabel => 'Participant dans le groupe';

  @override
  String get currentUserRankCompleteFirstGoal =>
      'Terminez votre premier objectif pour entrer dans le classement.';

  @override
  String get currentUserRankTiedLead => 'À égalité en tête.';

  @override
  String get currentUserRankTiedFirstLabel => 'À égalité en 1re place';

  @override
  String rankLabel(int rank) {
    return '${rank}e';
  }

  @override
  String get homeScheduleRoutineSubtitle =>
      'Prochains créneaux et routine hebdomadaire';

  @override
  String get homeNextCommitmentTitle => 'À venir';

  @override
  String get todayLabel => 'Aujourd’hui';

  @override
  String get statisticsTitle => 'Statistiques';

  @override
  String get studiedTimeLabel => 'Temps ?tudi?';

  @override
  String get readingTimeLabel => 'Temps de lecture';

  @override
  String get totalPagesReadLabel => 'Total des pages';

  @override
  String get pagesReadTodayLabel => 'Pages aujourd’hui';

  @override
  String get goalLabel => 'Objectif';

  @override
  String get sessionsLabel => 'Sessions';

  @override
  String get restLabel => 'Pause';

  @override
  String get comparativesTitle => 'Comparatifs';

  @override
  String get overviewTitle => 'Vue d’ensemble';

  @override
  String get studiedUnit => 'étudiés';

  @override
  String get readPagesUnit => 'lues';

  @override
  String get versusLastMonth => 'vs mois dernier';

  @override
  String get versusLastWeek => 'vs semaine dernière';

  @override
  String get noPreviousPeriodComparison =>
      'Aucune période précédente à comparer';

  @override
  String get noTimeLabel => 'Sans horaire';

  @override
  String untilTimeLabel(String time) {
    return 'Jusqu’à $time';
  }

  @override
  String get achievementsUnlockedSuffix => ' /50 débloqués';

  @override
  String get currentLevelLabel => 'Niveau actuel';

  @override
  String get allAchievementsUnlockedLabel => 'Tout est débloqué';

  @override
  String get nextUnlockLabel => 'Prochain succès';

  @override
  String get allAchievementsUnlockedDescription => 'Vous avez tout débloqué.';

  @override
  String xpToGo(int xp) {
    return 'Encore $xp XP';
  }

  @override
  String levelLabel(int level) {
    return 'Niveau $level';
  }

  @override
  String get allFilterLabel => 'Tous';

  @override
  String get unlockedFilterLabel => 'Débloqués';

  @override
  String get lockedFilterLabel => 'Verrouillés';

  @override
  String get selectCategoryTooltip => 'Sélectionner une catégorie';

  @override
  String get allCategoriesLabel => 'Toutes les catégories';

  @override
  String get byCategoryLabel => 'Par catégorie';

  @override
  String get allLevelsTitle => 'Tous les niveaux';

  @override
  String get allLevelsDescription =>
      'Débloquez des succès pour gravir les rangs.';

  @override
  String levelPlusLabel(int level) {
    return 'Niveau $level+';
  }

  @override
  String get currentLabel => 'Actuel';

  @override
  String rankTierLearner(String tier) {
    return 'Apprenti $tier';
  }

  @override
  String get achievementCategoryFocus => 'Focus';

  @override
  String get achievementCategoryStudy => 'Étude';

  @override
  String get achievementCategoryReading => 'Lecture';

  @override
  String get achievementCategoryGoals => 'Objectifs';

  @override
  String get achievementCategoryLifestyle => 'Mode de vie';

  @override
  String get achievement1Title => 'Premier focus';

  @override
  String get achievement1Description =>
      'Terminez votre première session de focus';

  @override
  String get achievement2Title => 'Départ de 25 min';

  @override
  String get achievement2Description => 'Concentrez-vous pendant 25 minutes';

  @override
  String get achievement3Title => '1 heure de focus';

  @override
  String get achievement3Description => 'Concentrez-vous pendant 1 heure';

  @override
  String get achievement4Title => 'Travail profond';

  @override
  String get achievement4Description => 'Atteignez 2 heures de focus';

  @override
  String get achievement5Title => 'Zéro distraction';

  @override
  String get achievement5Description => 'Terminez 3 sessions de focus';

  @override
  String get achievement6Title => 'Marathon de focus';

  @override
  String get achievement6Description => 'Atteignez 10 heures de focus';

  @override
  String get achievement7Title => 'Lève-tôt';

  @override
  String get achievement7Description => 'Enregistrez du focus pendant 5 jours';

  @override
  String get achievement8Title => 'Couche-tard';

  @override
  String get achievement8Description => 'Terminez 10 sessions de focus';

  @override
  String get achievement9Title => 'Série de focus';

  @override
  String get achievement9Description => 'Enregistrez du focus pendant 7 jours';

  @override
  String get achievement10Title => 'Maître du focus';

  @override
  String get achievement10Description => 'Atteignez 25 heures de focus';

  @override
  String get achievement11Title => 'Étude commencée';

  @override
  String get achievement11Description =>
      'Créez votre premier enregistrement d’étude';

  @override
  String get achievement12Title => '3 sessions';

  @override
  String get achievement12Description => 'Terminez 3 sessions';

  @override
  String get achievement13Title => '5 sessions';

  @override
  String get achievement13Description => 'Terminez 5 sessions';

  @override
  String get achievement14Title => '10 sessions';

  @override
  String get achievement14Description => 'Terminez 10 sessions';

  @override
  String get achievement15Title => 'Explorateur de matières';

  @override
  String get achievement15Description => 'Étudiez au moins une matière';

  @override
  String get achievement16Title => 'Héros de révision';

  @override
  String get achievement16Description => 'Atteignez 5 heures d’étude';

  @override
  String get achievement17Title => 'Quiz finalisé';

  @override
  String get achievement17Description => 'Terminez 15 sessions';

  @override
  String get achievement18Title => 'Planificateur d’études';

  @override
  String get achievement18Description => 'Créez un objectif de focus';

  @override
  String get achievement19Title => 'Prêt pour l’examen';

  @override
  String get achievement19Description => 'Atteignez 20 heures d’étude';

  @override
  String get achievement20Title => 'Mode étudiant';

  @override
  String get achievement20Description => 'Atteignez 50 heures d’étude';

  @override
  String get achievement21Title => 'Première page';

  @override
  String get achievement21Description => 'Lisez votre première page';

  @override
  String get achievement22Title => '10 pages';

  @override
  String get achievement22Description => 'Lisez 10 pages';

  @override
  String get achievement23Title => '25 pages';

  @override
  String get achievement23Description => 'Lisez 25 pages';

  @override
  String get achievement24Title => '50 pages';

  @override
  String get achievement24Description => 'Lisez 50 pages';

  @override
  String get achievement25Title => '100 pages';

  @override
  String get achievement25Description => 'Lisez 100 pages';

  @override
  String get achievement26Title => 'Chapitre terminé';

  @override
  String get achievement26Description => 'Lisez 150 pages';

  @override
  String get achievement27Title => 'Lecteur du week-end';

  @override
  String get achievement27Description => 'Lisez 250 pages';

  @override
  String get achievement28Title => 'Lecteur quotidien';

  @override
  String get achievement28Description => 'Lisez 300 pages';

  @override
  String get achievement29Title => 'Lecteur assidu';

  @override
  String get achievement29Description => 'Lisez 500 pages';

  @override
  String get achievement30Title => 'Légende de la bibliothèque';

  @override
  String get achievement30Description => 'Lisez 1000 pages';

  @override
  String get achievement31Title => 'Premier objectif';

  @override
  String get achievement31Description => 'Créez votre premier objectif';

  @override
  String get achievement32Title => 'Objectif atteint';

  @override
  String get achievement32Description => 'Terminez un objectif';

  @override
  String get achievement33Title => 'Tous les objectifs terminés';

  @override
  String get achievement33Description =>
      'Terminez tous les objectifs aujourd’hui';

  @override
  String get achievement34Title => 'Routine du matin';

  @override
  String get achievement34Description =>
      'Terminez des objectifs pendant 3 jours';

  @override
  String get achievement35Title => 'Journée équilibrée';

  @override
  String get achievement35Description =>
      'Terminez des objectifs pendant 5 jours';

  @override
  String get achievement36Title => 'Bâtisseur d’habitude';

  @override
  String get achievement36Description =>
      'Terminez des objectifs pendant 10 jours';

  @override
  String get achievement37Title => 'Journée parfaite';

  @override
  String get achievement37Description =>
      'Terminez des objectifs pendant 15 jours';

  @override
  String get achievement38Title => 'Reprise';

  @override
  String get achievement38Description =>
      'Terminez des objectifs pendant 20 jours';

  @override
  String get achievement39Title => 'Étoile de constance';

  @override
  String get achievement39Description =>
      'Terminez des objectifs pendant 30 jours';

  @override
  String get achievement40Title => 'Inarrêtable';

  @override
  String get achievement40Description =>
      'Terminez des objectifs pendant 50 jours';

  @override
  String get achievement41Title => 'Premier groupe';

  @override
  String get achievement41Description => 'Rejoignez un groupe d’étude';

  @override
  String get achievement42Title => 'Joueur d’équipe';

  @override
  String get achievement42Description => 'Affrontez vos amis';

  @override
  String get achievement43Title => 'Ami serviable';

  @override
  String get achievement43Description => 'Aidez un ami à rester constant';

  @override
  String get achievement44Title => 'Vainqueur du défi';

  @override
  String get achievement44Description => 'Gagnez un défi';

  @override
  String get achievement45Title => 'Exercice commencé';

  @override
  String get achievement45Description => 'Enregistrez du focus en exercice';

  @override
  String get achievement46Title => 'Entraînement de 30 min';

  @override
  String get achievement46Description =>
      'Faites de l’exercice pendant 30 minutes';

  @override
  String get achievement47Title => 'Moment hobby';

  @override
  String get achievement47Description => 'Enregistrez du focus en hobby';

  @override
  String get achievement48Title => 'Étincelle créative';

  @override
  String get achievement48Description => 'Atteignez 30 minutes de hobbies';

  @override
  String get achievement49Title => 'Guerrier du week-end';

  @override
  String get achievement49Description => 'Atteignez 2 heures d’exercice';

  @override
  String get achievement50Title => 'Chasseur de succès';

  @override
  String get achievement50Description => 'Débloquez 25 succès';

  @override
  String get achievementUnlockedNotificationTitle => 'Succès débloqué';

  @override
  String get rankTierPaper => 'Papier';

  @override
  String get rankTierWood => 'Bois';

  @override
  String get rankTierStone => 'Pierre';

  @override
  String get rankTierCopper => 'Cuivre';

  @override
  String get rankTierBronze => 'Bronze';

  @override
  String get rankTierIron => 'Fer';

  @override
  String get rankTierSilver => 'Argent';

  @override
  String get rankTierGold => 'Or';

  @override
  String get rankTierPlatinum => 'Platine';

  @override
  String get rankTierAmethyst => 'Améthyste';

  @override
  String get rankTierEmerald => 'Émeraude';

  @override
  String get rankTierDiamond => 'Diamant';

  @override
  String get rankTierObsidian => 'Obsidienne';

  @override
  String get rankTierAdamantium => 'Adamantium';

  @override
  String get rankTierMithril => 'Mithril';

  @override
  String get concentrationModeTitle => 'Mode de concentration';

  @override
  String get concentrationModeSubtitle =>
      'Choisissez les sessions qui bloquent la sortie de l’app.';

  @override
  String get concentrationStudyTitle => 'Étude';

  @override
  String get concentrationStudySubtitle => 'Focus total sur vos études.';

  @override
  String get concentrationExercisesTitle => 'Exercices';

  @override
  String get concentrationExercisesSubtitle =>
      'Restez concentré sur vos entraînements.';

  @override
  String get concentrationReadingTitle => 'Lecture';

  @override
  String get concentrationReadingSubtitle => 'Plongez dans vos lectures.';

  @override
  String get concentrationHobbiesTitle => 'Hobbies';

  @override
  String get concentrationHobbiesSubtitle =>
      'Profitez de vos hobbies avec concentration.';

  @override
  String get createGroupDescriptionLabel => 'Description';

  @override
  String get createGroupDescriptionHint =>
      'Décrivez le groupe et son objectif.';

  @override
  String get createGroupThemeMetricDescription =>
      'Ce thème définit la métrique du classement.';

  @override
  String get createGroupActivityTypeDescription =>
      'Chaque membre reçoit une copie à suivre.';

  @override
  String get createGroupActivityNameLabel => 'Nom de l?activit?';

  @override
  String get createGroupActivityNameHint => 'Ex : Calcul I';

  @override
  String get createGroupGoalTypeLabel => 'Type d’objectif';

  @override
  String get createGroupGoalTypeTotal => 'Total';

  @override
  String get createGroupGoalTypeDaily => 'Quotidien';

  @override
  String get createGroupDaysGoalLabel => 'Objectif de jours';

  @override
  String get createGroupPagesGoalLabel => 'Objectif de pages';

  @override
  String get createGroupTimeGoalMinutesLabel => 'Objectif de temps (min)';

  @override
  String get createGroupSummaryTitle => 'Résumé du groupe';

  @override
  String get createGroupActivitySummaryLabel => 'Activité';

  @override
  String get createGroupGuestsLabel => 'Invités';

  @override
  String get timerTotalTodayLabel => 'Total aujourd’hui';

  @override
  String get timerEndActionLabel => 'Terminer';

  @override
  String get createGroupActivityStepSubtitle =>
      'Choisissez l\'activité que tout le groupe fera.';

  @override
  String get createGroupFriendsStepSubtitle =>
      'Invitez au moins 1 ami à participer.';

  @override
  String get createGroupSummaryStepSubtitle =>
      'Vérifiez les informations avant de créer.';

  @override
  String get createGroupStepInformation => 'Informations';

  @override
  String get createGroupStepActivity => 'Activité';

  @override
  String get createGroupStepFriends => 'Amis';

  @override
  String get createGroupStepSummary => 'Résumé';

  @override
  String get createGroupDaysGoalHint => 'Ex : 30';

  @override
  String get createGroupPagesGoalHint => 'Ex : 10';

  @override
  String get createGroupMinutesGoalHint => 'Ex : 30';

  @override
  String get createGroupAddFriendsPromptTitle =>
      'Vous n\'avez trouvé personne ?';

  @override
  String get createGroupAddFriendsPromptDescription =>
      'Ajoutez plus d\'amis pour pouvoir les inviter.';

  @override
  String get createGroupContinueButton => 'Continuer';

  @override
  String get createGroupActivitySummaryDaily => 'Objectif quotidien';

  @override
  String createGroupActivitySummaryGoalDays(String days) {
    return 'Objectif • $days jours';
  }

  @override
  String createGroupActivitySummaryReading(String pages) {
    return 'Lecture • $pages pages';
  }

  @override
  String createGroupActivitySummaryTime(String category, String minutes) {
    return '$category • $minutes min';
  }

  @override
  String get createGroupActivityRequiredError =>
      'Choisissez une activité pour le groupe.';

  @override
  String get createGroupActivityNameRequiredError =>
      'Donnez un nom à l\'activité.';

  @override
  String get createGroupActivityGoalInvalidError =>
      'Définissez un objectif valide.';

  @override
  String get createGroupActivityMissingError =>
      'Définissez l\'activité du groupe.';

  @override
  String get timerBackTooltip => 'Retour';

  @override
  String get timerRestMessageTitle => 'Reposez-vous un peu';

  @override
  String get timerFocusLabel => 'Focus';

  @override
  String get timerReadingLabel => 'Lecture';

  @override
  String get timerPauseLabel => 'Pause';

  @override
  String get timerReadingTimeLabel => 'temps de lecture';

  @override
  String timerTotalOfLabel(String duration) {
    return 'de $duration';
  }

  @override
  String get timerCurrentPagesLabel => 'Pages actuelles';

  @override
  String get timerNotesLabel => 'Notes';

  @override
  String get concentrationModeSheetDescription =>
      'Une fois activé, l’app vous aide à rester concentré pendant l’activité jusqu’à la pause ou la fin.';

  @override
  String get timerFocusLockWarning =>
      'Le mode de concentration est actif. Terminez ou mettez la session en pause pour quitter.';

  @override
  String timerProgressSemanticLabel(int percent) {
    return 'Progression : $percent %';
  }

  @override
  String homeStreakLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours d’affilée',
      one: '$count jour d’affilée',
    );
    return '$_temp0';
  }
}
