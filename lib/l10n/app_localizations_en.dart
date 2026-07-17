// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HelpOut';

  @override
  String get genericErrorMessage =>
      'Something went wrong. Please try again later.';

  @override
  String get loginHeadline => 'Let\'s begin';

  @override
  String get loginSubtitle =>
      'Sign in to keep studying and organize your routine.';

  @override
  String get loginNameHint => 'Your name';

  @override
  String get loginButton => 'Let\'s Start';

  @override
  String get homeGreetingDefault => 'Hello';

  @override
  String homeGreetingWithName(String userName) {
    return 'Hello, $userName';
  }

  @override
  String get homeSubtitle => 'What are we tackling today?';

  @override
  String homeSubtitleFocusedToday(String duration) {
    return 'You\'ve focused $duration today';
  }

  @override
  String homeSubtitleNextSchedule(String title, String time) {
    return 'Agenda: $title at $time';
  }

  @override
  String get homeSubtitleStart => 'Start your first focus session';

  @override
  String get homeTasksSection => 'Daily goals';

  @override
  String get homeCategoriesSection => 'Activities';

  @override
  String get homeActionContinueEyebrow => 'Continue now';

  @override
  String get homeActionContinueButton => 'Continue';

  @override
  String get homeActionStartEyebrow => 'Start focus';

  @override
  String get homeActionStartButton => 'Start';

  @override
  String get homeActionSuggestedMeta => 'Your most-tracked subject';

  @override
  String get homeActionCreateBody =>
      'Create your first subject to start a focus session.';

  @override
  String get homeActionCreateButton => 'Create subject';

  @override
  String get homeSummaryTitle => 'Today\'s summary';

  @override
  String get homeSummaryFocus => 'Focus';

  @override
  String get homeSummaryGoals => 'Goals';

  @override
  String get homeSummaryPages => 'Pages';

  @override
  String get homeSummarySessions => 'Sessions';

  @override
  String homeGoalsProgress(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get homeCategoryEmpty => 'Nothing yet';

  @override
  String get homeNextScheduleTitle => 'Agenda';

  @override
  String get homeTodayAgendaTitle => 'Today\'s agenda';

  @override
  String get homeNextScheduleEmpty => 'No schedule today';

  @override
  String get homeNextScheduleAdd => 'Add schedule';

  @override
  String get addTaskButton => 'Add goal';

  @override
  String get createTaskTitle => 'New goal';

  @override
  String get taskNameHint => 'Goal name';

  @override
  String get targetDaysLabel => 'Target (days)';

  @override
  String targetDaysChip(int days) {
    return '$days days';
  }

  @override
  String get targetDaysHint => 'Custom target';

  @override
  String taskDaysProgress(int completed, int target) {
    return '$completed/$target days';
  }

  @override
  String get taskCompletedLabel => 'Done!';

  @override
  String get lastActivityLabel => 'Last activity';

  @override
  String get lastActivityNone => 'Nothing yet — start something!';

  @override
  String get lastActivityJustNow => 'just now';

  @override
  String lastActivityMinutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String lastActivityHoursAgo(int hours) {
    return '$hours h ago';
  }

  @override
  String lastActivityDaysAgo(int days) {
    return '$days d ago';
  }

  @override
  String get categoryStudying => 'Studies';

  @override
  String get categoryExercises => 'Exercising';

  @override
  String get categoryReading => 'Reading';

  @override
  String get categoryHobbies => 'Hobbies';

  @override
  String get itemNounStudying => 'Subject';

  @override
  String get itemNounExercises => 'Exercise';

  @override
  String get itemNounReading => 'Book';

  @override
  String get itemNounHobbies => 'Hobby';

  @override
  String get iconLabel => 'Icon';

  @override
  String get restTimeLabel => 'Rest time';

  @override
  String restMinutesChip(int minutes) {
    return '$minutes min';
  }

  @override
  String get timeUnitHoursSuffix => 'h';

  @override
  String get timeUnitMinutesSuffix => 'min';

  @override
  String get wallpaperLabel => 'Timer wallpaper';

  @override
  String addItemButton(String itemNoun) {
    return 'Add $itemNoun';
  }

  @override
  String itemNameHint(String itemNoun) {
    return '$itemNoun name';
  }

  @override
  String get colorLabel => 'Color';

  @override
  String get bookThemeLabel => 'Book theme';

  @override
  String get estimatedHoursGoalHint => 'Estimated hours (goal)';

  @override
  String get goalPagesHint => 'Goal (pages)';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get confirmButton => 'Confirm';

  @override
  String get addButton => 'Add';

  @override
  String get createSubjectTitleStudying => 'New subject';

  @override
  String get createSubjectTitleReading => 'New reading';

  @override
  String get createSubjectTitleExercises => 'New workout';

  @override
  String get createSubjectTitleHobbies => 'New hobby';

  @override
  String get createSubjectSubtitleStudying =>
      'Set a goal and personalize your focus';

  @override
  String get createSubjectSubtitleReading =>
      'Track pages and personalize your reading';

  @override
  String get createSubjectSubtitleExercises =>
      'Choose how you want to track this activity';

  @override
  String get createSubjectSubtitleHobbies =>
      'Choose how you want to track this hobby';

  @override
  String get createSubjectBasicSection => 'Basic information';

  @override
  String get createSubjectGoalSection => 'Goal';

  @override
  String get createSubjectRoutineSection => 'Routine';

  @override
  String get createSubjectPersonalizationSection => 'Personalization';

  @override
  String get createSubjectNameLabelStudying => 'Subject name';

  @override
  String get createSubjectNameLabelReading => 'Reading name';

  @override
  String get createSubjectNameLabelExercises => 'Activity name';

  @override
  String get createSubjectNameLabelHobbies => 'Hobby name';

  @override
  String get createSubjectNameHintStudying => 'Ex.: Biology, Math, English';

  @override
  String get createSubjectNameHintReading => 'Ex.: History book, Dom Casmurro';

  @override
  String get createSubjectNameHintExercises => 'Ex.: Gym, Running, Stretching';

  @override
  String get createSubjectNameHintHobbies =>
      'Ex.: Guitar, Drawing, Programming';

  @override
  String get createSubjectTimeGoalLabel => 'Time goal';

  @override
  String get createSubjectPagesGoalLabel => 'Page goal';

  @override
  String get createSubjectTimeGoalHelp =>
      'How many hours do you want to accumulate in total?';

  @override
  String get createSubjectPagesGoalHelp =>
      'How many pages do you want to log in total?';

  @override
  String get createSubjectRestLabel => 'Break after each focus';

  @override
  String get createSubjectRestHelp =>
      'The timer suggests a break after 25 min of focus.';

  @override
  String get customRestMinutesHint => 'Custom break (min)';

  @override
  String get createSubjectPreviewTitle => 'Preview';

  @override
  String get createSubjectPreviewNoGoal => 'No goal set';

  @override
  String createSubjectPreviewGoal(String goal) {
    return 'Goal: $goal';
  }

  @override
  String createSubjectPreviewRest(int minutes) {
    return 'Break: $minutes min';
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
  String get createSubjectButtonStudying => 'Create subject';

  @override
  String get createSubjectButtonReading => 'Create reading';

  @override
  String get createSubjectButtonExercises => 'Create activity';

  @override
  String get createSubjectButtonHobbies => 'Create hobby';

  @override
  String get createSubjectMissingName => 'Enter a name to continue';

  @override
  String get createSubjectMissingTimeGoal => 'Set a valid time goal';

  @override
  String get createSubjectMissingPagesGoal => 'Set a valid page goal';

  @override
  String get createSubjectSuccessStudying => 'Subject created successfully';

  @override
  String get createSubjectSuccessReading => 'Reading created successfully';

  @override
  String get createSubjectSuccessExercises => 'Activity created successfully';

  @override
  String get createSubjectSuccessHobbies => 'Hobby created successfully';

  @override
  String pagesProgress(int currentPages, int goalPages) {
    return '$currentPages of $goalPages pages';
  }

  @override
  String pagesReadOnly(int currentPages) {
    return '$currentPages pages read';
  }

  @override
  String get pagesReadNowHint => 'Pages read now';

  @override
  String get logPagesButton => 'Log pages';

  @override
  String get notesLabel => 'Notes';

  @override
  String get notesHint => 'Write your notes here...';

  @override
  String get saveNotesButton => 'Save';

  @override
  String durationProgress(String duration, String goalDuration) {
    return '$duration of $goalDuration';
  }

  @override
  String timerTotalLabel(String duration) {
    return 'Total: $duration';
  }

  @override
  String timerNextBreakLabel(String duration) {
    return 'Next break in $duration';
  }

  @override
  String timerRestingLabel(String duration) {
    return 'Resting — back in $duration';
  }

  @override
  String get timerNotificationRunning => 'Focus session in progress';

  @override
  String get timerNotificationResting => 'Resting — back soon';

  @override
  String get timerNotificationPaused => 'Paused';

  @override
  String get timerStateFocusingTitle => 'Focus in progress';

  @override
  String get timerStateFocusingDescription =>
      'Keep your focus. A break will be suggested soon.';

  @override
  String get timerStatePausedTitle => 'Timer paused';

  @override
  String get timerStatePausedDescription => 'Continue when you\'re ready.';

  @override
  String get timerStateRestingTitle => 'Well-earned break';

  @override
  String get timerStateRestingDescription =>
      'Drink water or breathe a little before continuing.';

  @override
  String get timerSessionSavedTitle => 'Session logged';

  @override
  String get timerSessionSavedDescription =>
      'Your time was added to the subject.';

  @override
  String get timerCurrentFocusLabel => 'Focused time now';

  @override
  String get timerRestTimeLabel => 'Break time';

  @override
  String get timerSessionLabel => 'Current session';

  @override
  String timerTotalInSubject(String subjectName) {
    return 'Total in $subjectName';
  }

  @override
  String get timerPauseButton => 'Pause';

  @override
  String get timerContinueButton => 'Continue';

  @override
  String get timerContinueFocusButton => 'Continue';

  @override
  String get timerSkipRestButton => 'Skip break';

  @override
  String get timerEndSessionButton => 'End session';

  @override
  String get timerStartAnotherSessionButton => 'Start another session';

  @override
  String get timerSaveReassurance =>
      'Progress is also saved when you pause or leave.';

  @override
  String timerFocusedValue(String duration) {
    return '$duration focused';
  }

  @override
  String get timerAccumulatedTotalLabel => 'Accumulated total';

  @override
  String get timerBackToSubjectsButton => 'Back';

  @override
  String get timerExitDialogTitle => 'End session?';

  @override
  String timerExitDialogContent(String duration, String subjectName) {
    return 'Your $duration progress will be saved in $subjectName.';
  }

  @override
  String get timerExitDialogCancel => 'Continue';

  @override
  String get timerExitDialogContinueLater => 'You can continue later.';

  @override
  String get timerExitDialogConfirm => 'End';

  @override
  String get profileTitle => 'Profile';

  @override
  String get editButton => 'Edit';

  @override
  String get nicknameFallback => 'user';

  @override
  String get profileSummaryLabel => 'Total summary';

  @override
  String get profileSummarySinceStartLabel => 'Since the beginning';

  @override
  String profileSummaryAccumulatedFocus(Object duration) {
    return '$duration of accumulated focus';
  }

  @override
  String get profileSummaryFocusLabel => 'Total focus time';

  @override
  String get profileSummaryFocusDescription => 'Studying, exercise and hobbies';

  @override
  String get statHoursStudied => 'Studying';

  @override
  String get statHoursExercised => 'Exercise';

  @override
  String get statPagesRead => 'Pages read';

  @override
  String get statTopSubject => 'Most studied';

  @override
  String get profileStatTimeEmptyTitle => 'Start your first focus';

  @override
  String get profileStatTimeEmptyDescription => 'Your time will show up here';

  @override
  String get profileStatExerciseEmptyTitle => 'No exercise yet';

  @override
  String get profileStatExerciseEmptyDescription => 'Log your first activity';

  @override
  String get profileStatReadingEmptyTitle => 'No pages yet';

  @override
  String get profileStatReadingEmptyDescription => 'Log your first reading';

  @override
  String get profileTopSubjectEmptyTitle => 'None yet';

  @override
  String get profileTopSubjectEmptyDescription =>
      'Study a subject to feature it here';

  @override
  String get profileEmptyTitle => 'Your progress starts here';

  @override
  String get profileEmptyDescription =>
      'Start a session, log some reading or set a goal from Home to track your evolution in HelpOut.';

  @override
  String get profileEmptyGuidance =>
      'After that, your total time, top activities and reading highlights will appear here.';

  @override
  String get profileEmptyStartButton => 'Start now';

  @override
  String get profileShortcutsTitle => 'Shortcuts';

  @override
  String get profileShortcutCreateSubject => 'Create subject';

  @override
  String get profileShortcutCreateGoal => 'Create goal';

  @override
  String get profileShortcutAddSchedule => 'Add schedule';

  @override
  String get profileEvolutionTitle => 'Your progress';

  @override
  String profileEvolutionFocus(String duration) {
    return 'You\'ve accumulated $duration of focus.';
  }

  @override
  String profileEvolutionTopSubject(String name) {
    return 'Your most studied subject is $name.';
  }

  @override
  String profileEvolutionRemaining(String duration) {
    return 'You\'re $duration away from your goal.';
  }

  @override
  String get profileEvolutionGoalReached => 'You\'ve reached your focus goal!';

  @override
  String get profileAgendaTitle => 'Today\'s schedule';

  @override
  String get profileAgendaEmptyTitle => 'No schedule planned';

  @override
  String get profileAgendaEmptyDescription =>
      'Add blocks to organize your routine.';

  @override
  String get profileAgendaAddButton => 'Add schedule';

  @override
  String get profileTopReadingTitle => 'Top reading';

  @override
  String get profileTopReadingEmptyTitle => 'No reading logged';

  @override
  String get profileTopReadingEmptyDescription =>
      'Log pages read to see your top themes here.';

  @override
  String get groupsTitle => 'Groups';

  @override
  String get groupsSubtitle => 'Compare your progress with friends';

  @override
  String get noGroupSelected => 'No group selected yet.';

  @override
  String get newGroupChip => 'New';

  @override
  String get groupHeaderCreateButton => 'Group';

  @override
  String get groupsEmptyTitle => 'No groups yet';

  @override
  String get groupsEmptyDescription =>
      'Create a group to compare progress with friends and keep the momentum going.';

  @override
  String get groupsEmptyButton => 'Create first group';

  @override
  String get you => 'You';

  @override
  String get mockStudyGroupName => 'Study Squad';

  @override
  String get mockWorkoutGroupName => 'Workout Crew';

  @override
  String get periodToday => 'Today';

  @override
  String get periodThisWeek => 'Week';

  @override
  String get periodThisMonth => 'Month';

  @override
  String get periodDescriptionToday => 'today';

  @override
  String get periodDescriptionThisWeek => 'this week';

  @override
  String get periodDescriptionThisMonth => 'this month';

  @override
  String get groupMetricStudying => 'study hours';

  @override
  String get groupMetricDailyGoals => 'completed goal days';

  @override
  String get groupMetricExercises => 'exercise hours';

  @override
  String get groupMetricReading => 'pages read';

  @override
  String get groupMetricHobbies => 'hobby hours';

  @override
  String groupLeaderboardDescription(String period, String metric) {
    return 'Ranking for $period · measured in $metric';
  }

  @override
  String get leaderboardTitle => 'Ranking';

  @override
  String get currentUserRankTitle => 'Your performance';

  @override
  String currentUserRankValue(String rank, String score) {
    return '$rank place · $score';
  }

  @override
  String currentUserRankNextStep(String score) {
    return '$score to climb one position';
  }

  @override
  String get currentUserRankLeading => 'You\'re leading this ranking.';

  @override
  String get currentUserRankSubtitle => 'your current position';

  @override
  String get leaderboardTopPosition => 'leading this ranking';

  @override
  String leaderboardDifferenceAhead(String value) {
    return '+$value ahead';
  }

  @override
  String get groupCreatedSuccess => 'Group created successfully';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Adjust your account and preferences';

  @override
  String get myProfileFallback => 'My Profile';

  @override
  String get personalProfileLabel => 'Personal profile';

  @override
  String accountDataSubtitle(Object nickname) {
    return '$nickname · personal data and security';
  }

  @override
  String get preferencesSection => 'Preferences';

  @override
  String get darkModeLabel => 'Dark mode';

  @override
  String get darkModeEnabledSubtitle => 'Dark theme is on';

  @override
  String get darkModeDisabledSubtitle => 'Use the dark theme in the app';

  @override
  String get accentColorSettingsTitle => 'Accent color';

  @override
  String get accentColorSettingsSubtitle => 'Personalize the app appearance';

  @override
  String get notificationsLabel => 'Notifications';

  @override
  String get timerNotificationsTitle => 'Timer notifications';

  @override
  String get notificationsEnabledSubtitle => 'Focus, break and progress alerts';

  @override
  String get notificationsDisabledSubtitle => 'Alerts are off on this device';

  @override
  String get language => 'Language';

  @override
  String get appLanguageSubtitle => 'App language';

  @override
  String get chooseLanguageTitle => 'Choose language';

  @override
  String languageChangedMessage(String language) {
    return 'Language changed to $language';
  }

  @override
  String get preferenceSavedMessage => 'Preference saved';

  @override
  String get supportSection => 'Support';

  @override
  String get helpSection => 'Help';

  @override
  String get faqLabel => 'FAQ';

  @override
  String get faqSettingsSubtitle => 'Questions about timer, goals and groups';

  @override
  String get sendFeedbackTitle => 'Send feedback';

  @override
  String get sendFeedbackSubtitle => 'Tell us what could be better';

  @override
  String get feedbackUnavailable => 'Feedback is not available yet';

  @override
  String get aboutLabel => 'About';

  @override
  String get aboutSection => 'About';

  @override
  String appVersionValue(String version) {
    return 'Version $version';
  }

  @override
  String get debugEnvironmentTitle => 'Environment';

  @override
  String get debugEnvironmentSubtitle => 'Debug · sample data active';

  @override
  String appVersionLabel(String appTitle, String appVersion) {
    return '$appTitle v$appVersion';
  }

  @override
  String get accountSection => 'Account';

  @override
  String get sessionSection => 'Session';

  @override
  String get logOutLabel => 'Log out';

  @override
  String get logOutSettingsSubtitle => 'End the session on this device';

  @override
  String get logOutDialogTitle => 'Log out?';

  @override
  String get logOutDialogContent =>
      'You will need to sign in again to access this account on this device. Your local study data will be kept.';

  @override
  String get logOutConfirmButton => 'Log out';

  @override
  String get myProfileTitle => 'My Profile';

  @override
  String get avatarLabel => 'Avatar';

  @override
  String get nameLabel => 'Name';

  @override
  String get yourNameHint => 'Your name';

  @override
  String get nicknameLabel => 'Nickname';

  @override
  String get nicknameHint => 'What friends call you';

  @override
  String get emailLabel => 'Email';

  @override
  String get optionalHint => 'Optional';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get themeColorLabel => 'Theme color';

  @override
  String get saveChangesButton => 'Save Changes';

  @override
  String get profileSavedMessage => 'Profile saved';

  @override
  String get faqTitle => 'FAQ';

  @override
  String get faqQ1 => 'How does the study timer work?';

  @override
  String get faqA1 =>
      'Pick a subject, tap play, and the timer tracks your current session while adding it to that subject\'s total time. Tap pause any time to stop and save your progress.';

  @override
  String get faqQ2 => 'What is the break countdown?';

  @override
  String get faqA2 =>
      'Each session follows a classic Pomodoro cycle: a 25 minute countdown to your next break. When it reaches zero it simply resets, it\'s a reminder, not a hard stop.';

  @override
  String get faqQ3 => 'How do I add a new subject?';

  @override
  String get faqA3 =>
      'Open a category from Home, then tap \"Add Subject\" at the bottom of the list. You can pick a color and set an estimated hours goal for it.';

  @override
  String get faqQ4 => 'How are groups and the leaderboard calculated?';

  @override
  String get faqA4 =>
      'Groups show a scoreboard based on the group\'s theme: focus hours, completed goal days or pages read. Switch between Today, Week and Month to compare progress.';

  @override
  String get faqQ5 => 'Can I change the app\'s color theme?';

  @override
  String get faqA5 =>
      'Yes, go to Settings > My Profile and pick any theme color. Every gradient, button and highlight across the app updates to match it, including dark mode.';

  @override
  String get createGroupTitle => 'New group';

  @override
  String get createGroupSubtitle => 'Choose a theme and invite friends';

  @override
  String get groupNameLabel => 'Group name';

  @override
  String get groupNameHint => 'Group name';

  @override
  String get groupNameExampleHint => 'Ex.: Exam study crew';

  @override
  String get groupThemeLabel => 'Theme';

  @override
  String groupThemeSelectedDescription(String metric) {
    return 'This group ranks by $metric.';
  }

  @override
  String get inviteFriendsLabel => 'Invite friends';

  @override
  String selectedFriendsCount(int count) {
    return '$count selected';
  }

  @override
  String get selectAtLeastOneFriend => 'Select at least 1 friend';

  @override
  String get searchFriendHint => 'Search friend';

  @override
  String get loadingFriends => 'Loading friends...';

  @override
  String get friendsLoadErrorTitle => 'Could not load friends';

  @override
  String get friendsLoadErrorDescription => 'Try again in a moment.';

  @override
  String get noFriendsAvailableTitle => 'No friends available';

  @override
  String get noFriendsAvailableDescription =>
      'Add friends before creating a group.';

  @override
  String get noFriendsFoundTitle => 'No friend found';

  @override
  String get noFriendsFoundDescription => 'Try another name.';

  @override
  String get createGroupButton => 'Create Group';

  @override
  String get createGroupMissingName => 'Enter the group name';

  @override
  String get createGroupMissingTheme => 'Choose a theme';

  @override
  String get createGroupMissingFriends => 'Select at least 1 friend';

  @override
  String createGroupWithFriendsButton(int count) {
    return 'Create group with $count friends';
  }

  @override
  String get createGroupRequirementsTitle => 'To create:';

  @override
  String get createGroupRequirementName => 'Group name';

  @override
  String get createGroupRequirementTheme => 'Theme chosen';

  @override
  String get createGroupRequirementFriends => 'At least 1 friend';

  @override
  String get groupPrivacyNote =>
      'Your friends will only see your name, avatar and progress in this theme.';

  @override
  String metricDaysValue(int value) {
    return '$value days';
  }

  @override
  String metricPagesValue(int value) {
    return '$value pages';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navProfile => 'Profile';

  @override
  String get navGroups => 'Groups';

  @override
  String get navSettings => 'Settings';

  @override
  String get myScheduleCardTitle => 'My Schedule';

  @override
  String get myScheduleTitle => 'My Schedule';

  @override
  String get noScheduleYet => 'No schedule yet';

  @override
  String get noScheduleYetDescription =>
      'Tap the button below to add\nyour first schedule';

  @override
  String get addScheduleEntryTitle => 'Add Schedule Entry';

  @override
  String get addScheduleEntryButton => 'Add Entry';

  @override
  String get scheduleInfoSection => 'Information';

  @override
  String get scheduleWhenSection => 'When?';

  @override
  String get scheduleColorSection => 'Schedule color';

  @override
  String get schedulePreviewSection => 'Preview';

  @override
  String scheduleDurationLabel(String duration) {
    return 'Duration: $duration';
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
  String get scheduleTitleHint => 'Title';

  @override
  String get startTimeLabel => 'Start time';

  @override
  String get endTimeOptionalLabel => 'End time';

  @override
  String get incompleteScheduleEntryError =>
      'Incomplete entry — fill in the title, start time and end time.';

  @override
  String get endTimeBeforeStartError =>
      'End time must be later than the start time.';

  @override
  String get nameRequiredError => 'Please enter a name first.';

  @override
  String get groupThemeRequiredError => 'Pick a theme for your group.';

  @override
  String get groupNeedsFriendError =>
      'Invite at least one friend — a group can\'t be created alone.';

  @override
  String get continueWithGoogleButton => 'Continue with Google';

  @override
  String get continueWithAppleButton => 'Continue with Apple';

  @override
  String get continueWithPhoneButton => 'Continue with phone number';

  @override
  String get phoneLoginTitle => 'Your number';

  @override
  String get phoneLoginSubtitle =>
      'Enter your phone number to receive an access code.';

  @override
  String get sendCodeButton => 'Send code';

  @override
  String get phoneSecurityNote =>
      'You can use your number to sign in securely.';

  @override
  String get selectCountryTitle => 'Select your country';

  @override
  String get searchCountryHint => 'Search country';

  @override
  String get otpCodeExpired => 'Code expired. Resend to get a new one.';

  @override
  String get otpTitle => 'Verify your number';

  @override
  String otpSubtitle(String phone) {
    return 'Enter the 6-digit code we sent to $phone.';
  }

  @override
  String get verifyCodeButton => 'Verify';

  @override
  String get resendCodeButton => 'Resend code';

  @override
  String otpCodeValidFor(String time) {
    return 'Code valid for $time';
  }

  @override
  String get codeResentMessage => 'Verification code sent';

  @override
  String get invalidCodeError => 'Invalid code. Please try again.';

  @override
  String get credentialsTitle => 'Create your profile';

  @override
  String get credentialsSubtitle =>
      'Tell us a bit about yourself to personalize your experience.';

  @override
  String get birthDateHint => 'Date of birth';

  @override
  String get profileEditableLaterNote => 'You can edit this later.';

  @override
  String get finishButton => 'Finish';
}
