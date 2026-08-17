// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Timing';

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
  String get homeNextScheduleEmpty => 'No appointments today';

  @override
  String get homeNextScheduleAdd => 'Add appointment';

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
  String get estimatedHoursGoalHint => 'Duration in minutes';

  @override
  String get createSubjectTotalHoursGoalHint => 'Total time in hours';

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
  String get createSubjectTimeGoalLabel => 'Duration of each section';

  @override
  String get createSubjectTotalTimeGoalLabel =>
      'How long do you want to study in total?';

  @override
  String get createSubjectTotalTimeGoalLabelStudying =>
      'How long do you want to study in total?';

  @override
  String get createSubjectTotalTimeGoalLabelExercises =>
      'How long do you want to exercise in total?';

  @override
  String get createSubjectTotalTimeGoalLabelHobbies =>
      'How long do you want to practice in total?';

  @override
  String get createSubjectPagesGoalLabel => 'Page goal';

  @override
  String get createSubjectTimeGoalHelp =>
      'How many minutes do you want to focus?';

  @override
  String get createSubjectPagesGoalHelp =>
      'How many pages do you want to log in total?';

  @override
  String get createSubjectRestLabel => 'Break duration';

  @override
  String get createSubjectRestHelp =>
      'The timer suggests a break after 30 min of focus.';

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
    return '${hours}h $minutes min';
  }

  @override
  String createSubjectPagesValue(int value) {
    return '$value pages';
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
  String get createSubjectMissingTimeGoal => 'Set a valid focus goal';

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
  String get addNotesPageTooltip => 'Add page';

  @override
  String notesPageCounter(int currentPage, int pageCount) {
    return 'Page $currentPage of $pageCount';
  }

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
      'Start a session, log some reading or set a goal from Home to track your evolution in Timing.';

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
  String get profileProgressSectionTitle => 'Your progress';

  @override
  String get profileAchievementsTitle => 'Achievements';

  @override
  String get profileSeeHistory => 'See history';

  @override
  String get profileSeeAll => 'See all';

  @override
  String get profileAchievementFirstUnlocked => '1st achievement';

  @override
  String get profileAchievementGoalStarted => 'Goal started';

  @override
  String get profileAchievementsStartHint => 'Start to earn achievements';

  @override
  String get profileAchievementFirstFocus => 'First focus';

  @override
  String get profileAchievementStudyStarted => 'Study started';

  @override
  String get profileAchievementReadingStarted => 'Reading started';

  @override
  String get profileAchievementLocked => 'Locked';

  @override
  String get periodFiveDays => '5 days';

  @override
  String get periodWeek => '1 week';

  @override
  String get periodMonth => '1 month';

  @override
  String get periodTotal => 'Total';

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
  String get automaticLanguageLabel => 'Automatic';

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
  String get linkedAccountsSection => 'Connected sign-ins';

  @override
  String get linkedAccountsSubtitle =>
      'Use Google and Apple to access this same account.';

  @override
  String get linkGoogleAccountTitle => 'Link Google';

  @override
  String get linkGoogleAccountSubtitle => 'Sign in with Google on this account';

  @override
  String get linkAppleAccountTitle => 'Link Apple';

  @override
  String get linkAppleAccountSubtitle => 'Sign in with Apple on this account';

  @override
  String get authProviderConnected => 'Connected';

  @override
  String get linkAuthProviderStarted => 'Finish sign-in to link the account.';

  @override
  String get linkAuthProviderFailure =>
      'Could not start account linking. Check the provider and manual linking in Supabase.';

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
  String get profilePhotoSelectLabel => 'Add photo';

  @override
  String get profilePhotoRemoveLabel => 'Remove photo';

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
      'Each session follows a focus cycle: a 30 minute countdown to your next break. When it reaches zero it simply resets, it\'s a reminder, not a hard stop.';

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
  String get navGroups => 'Groups';

  @override
  String get navSettings => 'Settings';

  @override
  String get myScheduleCardTitle => 'My Schedule';

  @override
  String get myScheduleTitle => 'My Schedule';

  @override
  String get noScheduleYet => 'No appointments yet';

  @override
  String get noScheduleYetDescription =>
      'Tap the button below to add\nyour first appointment';

  @override
  String get addScheduleEntryTitle => 'Add Appointment';

  @override
  String get addScheduleEntryButton => 'Add Appointment';

  @override
  String get scheduleInfoSection => 'Information';

  @override
  String get scheduleWhenSection => 'When?';

  @override
  String get scheduleColorSection => 'Appointment color';

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

  @override
  String get navProgress => 'Progress';

  @override
  String get progressTitle => 'Progress';

  @override
  String get progressSubtitle => 'Everything you have done so far';

  @override
  String get progressPeriodDay => 'Day';

  @override
  String get progressPeriodWeek => 'Week';

  @override
  String get progressPeriodMonth => 'Month';

  @override
  String get progressFocusResultLabel => 'Focus in this period';

  @override
  String progressComparisonMore(String value) {
    return '$value more than the previous period';
  }

  @override
  String progressComparisonLess(String value) {
    return '$value less than the previous period';
  }

  @override
  String get progressComparisonSame => 'Same as the previous period';

  @override
  String get progressComparisonFirst => 'Your first data for this period';

  @override
  String get progressStatExercises => 'Exercises';

  @override
  String get progressStatLongestGoal => 'Longest goal';

  @override
  String get progressStatMainReading => 'Main reading';

  @override
  String get progressStatGoalsDone => 'Goals done';

  @override
  String get progressDistributionTitle => 'By activity';

  @override
  String homeTodayInline(String focus, int pages, int goals) {
    return 'Today: $focus focus · $pages pages · $goals goals';
  }

  @override
  String get homePlanDayTitle => 'Plan my day';

  @override
  String get homePlanDaySubtitle => 'Daily goals and weekly schedule';

  @override
  String get groupsFriendsTitle => 'Friends';

  @override
  String get groupsFriendsSubtitle => 'Requests, invites and your code';

  @override
  String groupMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String get createScheduleEntryButton => 'Create appointment';

  @override
  String get scheduleEntryMissingFields =>
      'Fill in the title, start and end time to continue';

  @override
  String timerSessionCounter(int current, int total) {
    return 'Focus $current of $total';
  }

  @override
  String get timerExitBackToFocus => 'Back to focus';

  @override
  String get timerExitSaveAndEnd => 'Save and end';

  @override
  String get notesSavedNow => 'Saved just now';

  @override
  String get notesSaving => 'Saving…';

  @override
  String get dailyGoalsPendingSection => 'Pending';

  @override
  String get dailyGoalsCompletedSection => 'Completed';

  @override
  String get dailyGoalsEmptyTitle => 'No goals for today yet';

  @override
  String get dailyGoalsEmptyDescription =>
      'Write a goal above or pick one of the suggestions to start your day.';

  @override
  String achievementProgressValue(String current, String total) {
    return '$current of $total';
  }

  @override
  String get categoryEmptyTitle => 'Nothing here yet';

  @override
  String get categoryEmptyDescription =>
      'Create your first item to start tracking focus time.';

  @override
  String get scheduleEmptyExampleLabel => 'Example';

  @override
  String get progressAchievementsNextTitle => 'Next achievement';

  @override
  String get achievementFocusHourTitle => '1 hour of focus';

  @override
  String get achievementSessionsTitle => '5 completed sessions';

  @override
  String get achievementStreakTitle => '7-day streak';

  @override
  String get achievementReaderTitle => '100 pages read';

  @override
  String get achievementGoalStartedTitle => 'First goal started';

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
    return '$value days';
  }

  @override
  String currentUserRankNextStepNamed(String score, String name) {
    return '$score to reach $name';
  }

  @override
  String get timerKeepAwakeNote => 'The screen stays on during the session';

  @override
  String scheduleWeekLabel(String date) {
    return 'Week of $date';
  }

  @override
  String get daysSuffix => 'days';

  @override
  String get createTaskSubtitle =>
      'Set a daily goal and keep track of your progress';

  @override
  String get createTaskSequenceTypeLabel => 'Sequence type';

  @override
  String get createTaskSequenceIntenseLabel => 'Intense';

  @override
  String get createTaskSequenceIntenseDescription =>
      'No misses. If you lose one day, your sequence resets.';

  @override
  String get createTaskSequenceCasualLabel => 'Casual';

  @override
  String get createTaskSequenceCasualDescription =>
      'More flexible. Missed days do not reset your sequence.';

  @override
  String get targetDaysInfinite => 'Infinite';

  @override
  String get deleteConfirmationDefaultTypeName => 'item';

  @override
  String deleteConfirmationTitle(String typeName) {
    return 'Delete $typeName?';
  }

  @override
  String deleteConfirmationContent(String itemName) {
    return 'You are about to delete \"$itemName\". This action cannot be undone.';
  }

  @override
  String deleteConfirmationHistoryWarning(String typeName) {
    return 'This $typeName history will also be removed.';
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
      other: '$count goals',
      one: '1 goal',
    );
    return '$_temp0';
  }

  @override
  String get profilePhotoSourceTitle => 'Profile photo';

  @override
  String get profilePhotoSourceSubtitle =>
      'Choose how you want to update your photo';

  @override
  String get photoCameraLabel => 'Take photo';

  @override
  String get photoGalleryLabel => 'Choose from gallery';

  @override
  String get removePhotoDialogTitle => 'Remove photo?';

  @override
  String get removePhotoDialogContent =>
      'Your avatar will show on the profile again.';

  @override
  String get friendRequestsReceivedTab => 'Requests';

  @override
  String get friendRequestsSentTab => 'Invites';

  @override
  String hobbyPracticeMinutes(int minutes) {
    return '$minutes min of practice';
  }

  @override
  String get hobbyViewStatistics => 'View statistics';

  @override
  String get hobbyEdit => 'Edit hobby';

  @override
  String get pinToStart => 'Pin to start';

  @override
  String get hobbyDelete => 'Delete hobby';

  @override
  String get deleteActionCannotBeUndone => 'This action cannot be undone.';

  @override
  String get joinGroupTitle => 'Join group';

  @override
  String get joinGroupInviteCodeLabel => 'Invite code';

  @override
  String get joinGroupCodeHint => 'Enter the code';

  @override
  String get joinGroupButton => 'Join group';

  @override
  String get joinGroupError => 'Could not join this group.';

  @override
  String get scheduleDayEventsTitle => 'Schedule for the day';

  @override
  String get dailyGoalsNoGoalsYetTitle => 'No goals yet';

  @override
  String get dailyGoalsNoGoalsYetDescription =>
      'Add your first goal to organize the day and track your wins.';

  @override
  String get dailyGoalsSuggestionsTitle => 'Suggestions to start';

  @override
  String get dailyGoalsSuggestionStudy => 'Study 30 min';

  @override
  String get dailyGoalsSuggestionRead => 'Read 10 pages';

  @override
  String get dailyGoalsSuggestionTrain => 'Train';

  @override
  String get goalTypeName => 'goal';

  @override
  String get missedYesterdayDialogTitle => 'Did you complete it yesterday?';

  @override
  String missedYesterdayDialogContent(String taskName) {
    return 'You did not register \"$taskName\" yesterday. Did you really miss it?';
  }

  @override
  String get missedYesterdayMissedButton => 'Yes, I missed it';

  @override
  String get missedYesterdayCompletedButton => 'I completed it';

  @override
  String get scheduleTitleRequiredError => 'Fill in the title to continue';

  @override
  String get scheduleActiveFromLabel => 'Starts';

  @override
  String get scheduleActiveUntilLabel => 'Ends';

  @override
  String get selectDateTitle => 'Select date';

  @override
  String get selectDateHint => 'Choose a day in the calendar';

  @override
  String get addFriendTitle => 'Add friend';

  @override
  String get friendCodeNotFound => 'We could not find a user with this code.';

  @override
  String get friendInviteCodeTitle => 'Invite code';

  @override
  String get friendInviteCodeFieldLabel => 'Type or paste the code';

  @override
  String get friendInviteCodeFieldHint => 'Like ABCDE12345';

  @override
  String get pasteButton => 'Paste';

  @override
  String get searchCodeButton => 'Search code';

  @override
  String get friendUserFoundTitle => 'User found';

  @override
  String get friendFoundByCode => 'Found by code';

  @override
  String get sentLabel => 'Sent';

  @override
  String get friendHowItWorksTitle => 'How it works';

  @override
  String get friendHowItWorksStepOne => 'Ask your friend for their code';

  @override
  String get friendHowItWorksStepTwo => 'Paste the code to find the profile';

  @override
  String get friendHowItWorksStepThree => 'Send the request to add them';

  @override
  String get myCodeLabel => 'My code';

  @override
  String get yourInviteCodeLabel => 'Your invite code';

  @override
  String yourFriendsTitle(int count) {
    return 'Your friends ($count)';
  }

  @override
  String get seeAllButton => 'View all';

  @override
  String get onlineLabel => 'Online';

  @override
  String minutesAgoShort(int minutes) {
    return '$minutes min ago';
  }

  @override
  String get friendsEmptyTitle => 'You do not have friends yet';

  @override
  String get friendsEmptySubtitle =>
      'Search people above or share your invite code.';

  @override
  String get shareCodeButton => 'Share code';

  @override
  String get codeCopiedMessage => 'Code copied';

  @override
  String get friendRequestSentMessage => 'Request sent';

  @override
  String get joinedGroupMessage => 'You joined the group';

  @override
  String get friendTypeName => 'friend';

  @override
  String shareInviteCodeMessage(String code) {
    return 'Add me on Timing with my code: $code';
  }

  @override
  String groupInvitesTitle(int count) {
    return 'Group invites ($count)';
  }

  @override
  String groupInvitedBy(String inviter) {
    return '$inviter invited you';
  }

  @override
  String get acceptButton => 'Accept';

  @override
  String get declineButton => 'Decline';

  @override
  String get friendsTitle => 'Friends';

  @override
  String get friendRequestsReceivedPageTitle => 'Requests';

  @override
  String get friendRequestsSentPageTitle => 'Invites';

  @override
  String friendRequestsReceivedSection(int count) {
    return 'Received ($count)';
  }

  @override
  String friendRequestsSentSection(int count) {
    return 'Sent ($count)';
  }

  @override
  String get friendMutualFriendsSample => '3 mutual friends';

  @override
  String get pendingLabel => 'Pending';

  @override
  String get friendRequestsIncomingEmptyTitle => 'No received requests';

  @override
  String get friendRequestsSentEmptyTitle => 'No sent invites';

  @override
  String get friendRequestsIncomingEmptySubtitle =>
      'Requests will appear here.';

  @override
  String get friendRequestsSentEmptySubtitle =>
      'Your sent invites will appear here.';

  @override
  String get friendRequestsSafetyNotice =>
      'Only accept people you know and trust.';

  @override
  String get categoryEmptyStudyingTitle => 'No subject yet';

  @override
  String get categoryEmptyExercisesTitle => 'No exercise yet';

  @override
  String get categoryEmptyReadingTitle => 'No reading yet';

  @override
  String get categoryEmptyHobbiesTitle => 'No hobby yet';

  @override
  String get categoryEmptyStudyingDescription =>
      'Add your first subject to organize your studies and log focus.';

  @override
  String get categoryEmptyExercisesDescription =>
      'Add your first exercise to track workouts, sessions and progress.';

  @override
  String get categoryEmptyReadingDescription =>
      'Add your first reading item to track pages, time and progress.';

  @override
  String get categoryEmptyHobbiesDescription =>
      'Add your first hobby to log practice and keep momentum.';

  @override
  String get categorySuggestionStudyingOne => 'Math';

  @override
  String get categorySuggestionStudyingTwo => 'English';

  @override
  String get categorySuggestionStudyingThree => 'Writing';

  @override
  String get categorySuggestionExercisesOne => 'Running';

  @override
  String get categorySuggestionExercisesTwo => 'Strength';

  @override
  String get categorySuggestionExercisesThree => 'Stretching';

  @override
  String get categorySuggestionReadingOne => 'Novel';

  @override
  String get categorySuggestionReadingTwo => 'Technical';

  @override
  String get categorySuggestionReadingThree => 'Articles';

  @override
  String get categorySuggestionHobbiesOne => 'Guitar';

  @override
  String get categorySuggestionHobbiesTwo => 'Drawing';

  @override
  String get categorySuggestionHobbiesThree => 'Cooking';

  @override
  String get pagesAbbreviation => 'pgs';

  @override
  String get loginSecurityNote => 'Your data is protected and secure.';

  @override
  String get nextBreakDurationLabel => 'Next break duration';

  @override
  String timerReadingExitContent(String duration, String subjectName) {
    return 'You read for $duration. Enter how many pages you read in $subjectName.';
  }

  @override
  String get appleSignInIncompleteMessage =>
      'Sign in with Apple is not complete yet.';

  @override
  String get activityTypeLabel => 'Activity type';

  @override
  String get activityTypeDailyLabel => 'Daily';

  @override
  String get activityTypeDailyDescription =>
      'Use focus sections with breaks and set how many sessions you want to complete each day.';

  @override
  String get activityTypeDailyDescriptionStudying =>
      'Use study sections with breaks and set how many sessions you want to complete each day.';

  @override
  String get activityTypeDailyDescriptionExercises =>
      'Use exercise sections with breaks and set how many sessions you want to complete each day.';

  @override
  String get activityTypeDailyDescriptionHobbies =>
      'Use practice sections with breaks and set how many sessions you want to complete each day.';

  @override
  String get activityTypePermanentLabel => 'Permanent';

  @override
  String get activityTypePermanentDescription =>
      'Set the total study time. The activity stays active until you complete it.';

  @override
  String get activityTypePermanentDescriptionStudying =>
      'Set the total study time. The activity stays active until you complete it.';

  @override
  String get activityTypePermanentDescriptionExercises =>
      'Set the total exercise time. The activity stays active until you complete it.';

  @override
  String get activityTypePermanentDescriptionHobbies =>
      'Set the total practice time. The activity stays active until you complete it.';

  @override
  String get pagesSuffix => 'pages';

  @override
  String get updatedSuccessfullyMessage => 'Updated successfully';

  @override
  String get focusSessionCountLabel => 'Number of sessions';

  @override
  String get subjectSectionDurationDescription =>
      'How long each focus section lasts before a break or completion.';

  @override
  String get subjectSessionCountDescription =>
      'How many focus sections you want to complete in a day.';

  @override
  String get subjectRestDurationDescription =>
      'How long each pause lasts between focus sections.';

  @override
  String get groupEditingComingSoon => 'Group editing is coming soon.';

  @override
  String get leftGroupMessage => 'You left the group.';

  @override
  String get groupImageSourceTitle => 'Send image';

  @override
  String get groupImageSourceSubtitle =>
      'Choose how you want to send the image';

  @override
  String get deleteButton => 'Delete';

  @override
  String get manageMembersTitle => 'Manage members';

  @override
  String get groupLeaderLabel => 'Leader';

  @override
  String get groupLeaderRoleLabel => 'Group leader';

  @override
  String get groupMemberRoleLabel => 'Member';

  @override
  String get groupMembersLabel => 'Members';

  @override
  String get groupActionsLabel => 'Group actions';

  @override
  String get goalsTabLabel => 'Data';

  @override
  String get chatTabLabel => 'Chat';

  @override
  String get groupGoalTitle => 'Group goal';

  @override
  String get groupMainRuleTitle => 'Main rule';

  @override
  String get groupNextMilestoneTitle => 'Next milestone';

  @override
  String groupMembersProgressValue(int current, int total) {
    return '$current/$total members';
  }

  @override
  String get groupNextMilestoneDescription =>
      'to unlock the \"Total Focus\" badge';

  @override
  String get groupActivityLabel => 'Group activity';

  @override
  String groupActivityReachedGoal(int reached, int total) {
    return '$reached/$total reached the goal';
  }

  @override
  String get groupActivityFocusDataLabel => 'Focus';

  @override
  String get groupActivityPauseDataLabel => 'Break';

  @override
  String get groupActivitySessionsDataLabel => 'Sessions';

  @override
  String get groupActivityPendingUsersTitle => 'Pending users';

  @override
  String get groupActivityAllCompletedToday =>
      'Everyone completed the activity today.';

  @override
  String get groupNoImagesTitle => 'No images yet';

  @override
  String get groupNoImagesDescription => 'Send the first group image.';

  @override
  String get groupSendImageButton => 'Send image';

  @override
  String get groupSendingImage => 'Sending image...';

  @override
  String get editGroupLabel => 'Edit group';

  @override
  String get leaveGroupLabel => 'Leave group';

  @override
  String groupDescription(String metric) {
    return 'Ranking by $metric. Keep progressing with your group.';
  }

  @override
  String groupsFriendsSubtitleWithCount(int groupCount) {
    return 'Requests, invites and $groupCount in groups';
  }

  @override
  String groupGoalKeepMetric(String metric) {
    return 'Keep $metric every day';
  }

  @override
  String groupGoalDescription(String metric) {
    return 'Each member logs $metric to keep the group streak active.';
  }

  @override
  String groupRuleDescription(String metric) {
    return 'Log at least one $metric entry per day to strengthen the group streak.';
  }

  @override
  String get joinWithCodeButton => 'I have an invite code';

  @override
  String get groupsBenefitsHeader => 'In a group you can:';

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
    return '$completed/$total members completed today';
  }

  @override
  String get addMemberButton => 'Add member';

  @override
  String get groupCollectiveProgressTitle => 'Collective progress';

  @override
  String get dailyLabel => 'Daily';

  @override
  String get completedLabel => 'Completed';

  @override
  String groupActivityCompletedCount(int completed, int total) {
    return '$completed of $total completed';
  }

  @override
  String groupMissingParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participants left to complete the goal',
      one: '1 participant left to complete the goal',
      zero: 'Everyone completed the goal',
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
    return 'Completed ($count)';
  }

  @override
  String groupPendingMembersTitle(int count) {
    return 'Pending ($count)';
  }

  @override
  String get groupNoCompletedMembersTitle => 'No one completed yet';

  @override
  String get groupNoCompletedMembersSubtitle =>
      'Be the first to complete the goal!';

  @override
  String get groupStatisticsTitle => 'Group statistics';

  @override
  String get groupStreakStatLabel => 'Group streak';

  @override
  String get groupTodayTotalStatLabel => 'Total time today';

  @override
  String get groupPeriodTotalStatLabel => 'Period total';

  @override
  String get groupCompletedSessionsStatLabel => 'Completed sessions';

  @override
  String get groupParticipantsStatLabel => 'Participant in group';

  @override
  String get currentUserRankCompleteFirstGoal =>
      'Complete your first goal to enter the ranking.';

  @override
  String get currentUserRankTiedLead => 'Tied for the lead.';

  @override
  String get currentUserRankTiedFirstLabel => 'Tied for 1st';

  @override
  String rankLabel(int rank) {
    return '#$rank';
  }

  @override
  String get homeScheduleRoutineSubtitle =>
      'Upcoming schedule and weekly routine';

  @override
  String get homeNextCommitmentTitle => 'Up next';

  @override
  String get todayLabel => 'Today';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get studiedTimeLabel => 'Studied time';

  @override
  String get readingTimeLabel => 'Reading time';

  @override
  String get totalPagesReadLabel => 'Total pages';

  @override
  String get pagesReadTodayLabel => 'Pages today';

  @override
  String get goalLabel => 'Goal';

  @override
  String get sessionsLabel => 'Sessions';

  @override
  String get restLabel => 'Rest';

  @override
  String get comparativesTitle => 'Comparisons';

  @override
  String get overviewTitle => 'Overview';

  @override
  String get studiedUnit => 'studied';

  @override
  String get readPagesUnit => 'read';

  @override
  String get versusLastMonth => 'vs last month';

  @override
  String get versusLastWeek => 'vs last week';

  @override
  String get noPreviousPeriodComparison => 'No previous period to compare';

  @override
  String get noTimeLabel => 'No time';

  @override
  String untilTimeLabel(String time) {
    return 'Until $time';
  }

  @override
  String get achievementsUnlockedSuffix => ' /50 unlocked';

  @override
  String get currentLevelLabel => 'Current level';

  @override
  String get allAchievementsUnlockedLabel => 'All unlocked';

  @override
  String get nextUnlockLabel => 'Next unlock';

  @override
  String get allAchievementsUnlockedDescription => 'You unlocked everything.';

  @override
  String xpToGo(int xp) {
    return '$xp XP to go';
  }

  @override
  String levelLabel(int level) {
    return 'Level $level';
  }

  @override
  String get allFilterLabel => 'All';

  @override
  String get unlockedFilterLabel => 'Unlocked';

  @override
  String get lockedFilterLabel => 'Locked';

  @override
  String get selectCategoryTooltip => 'Select category';

  @override
  String get allCategoriesLabel => 'All categories';

  @override
  String get byCategoryLabel => 'By category';

  @override
  String get allLevelsTitle => 'All levels';

  @override
  String get allLevelsDescription => 'Unlock achievements to climb the ranks.';

  @override
  String levelPlusLabel(int level) {
    return 'Level $level+';
  }

  @override
  String get currentLabel => 'Current';

  @override
  String rankTierLearner(String tier) {
    return '$tier Learner';
  }

  @override
  String get achievementCategoryFocus => 'Focus';

  @override
  String get achievementCategoryStudy => 'Study';

  @override
  String get achievementCategoryReading => 'Reading';

  @override
  String get achievementCategoryGoals => 'Goals';

  @override
  String get achievementCategoryLifestyle => 'Lifestyle';

  @override
  String get achievement1Title => 'First Focus';

  @override
  String get achievement1Description => 'Complete your first focus session';

  @override
  String get achievement2Title => '25-Min Starter';

  @override
  String get achievement2Description => 'Focus for 25 minutes';

  @override
  String get achievement3Title => '1-Hour Focus';

  @override
  String get achievement3Description => 'Focus for 1 hour';

  @override
  String get achievement4Title => 'Deep Work';

  @override
  String get achievement4Description => 'Reach 2 hours of focus';

  @override
  String get achievement5Title => 'Zero Distractions';

  @override
  String get achievement5Description => 'Complete 3 focus sessions';

  @override
  String get achievement6Title => 'Focus Marathon';

  @override
  String get achievement6Description => 'Reach 10 hours of focus';

  @override
  String get achievement7Title => 'Early Bird';

  @override
  String get achievement7Description => 'Log focus on 5 days';

  @override
  String get achievement8Title => 'Night Owl';

  @override
  String get achievement8Description => 'Complete 10 focus sessions';

  @override
  String get achievement9Title => 'Focus Streak';

  @override
  String get achievement9Description => 'Log focus on 7 days';

  @override
  String get achievement10Title => 'Focus Master';

  @override
  String get achievement10Description => 'Reach 25 hours of focus';

  @override
  String get achievement11Title => 'Study Started';

  @override
  String get achievement11Description => 'Create your first study record';

  @override
  String get achievement12Title => '3 Sessions';

  @override
  String get achievement12Description => 'Complete 3 sessions';

  @override
  String get achievement13Title => '5 Sessions';

  @override
  String get achievement13Description => 'Complete 5 sessions';

  @override
  String get achievement14Title => '10 Sessions';

  @override
  String get achievement14Description => 'Complete 10 sessions';

  @override
  String get achievement15Title => 'Subject Explorer';

  @override
  String get achievement15Description => 'Study at least one subject';

  @override
  String get achievement16Title => 'Revision Hero';

  @override
  String get achievement16Description => 'Reach 5 hours studying';

  @override
  String get achievement17Title => 'Quiz Finisher';

  @override
  String get achievement17Description => 'Complete 15 sessions';

  @override
  String get achievement18Title => 'Study Planner';

  @override
  String get achievement18Description => 'Create a focus goal';

  @override
  String get achievement19Title => 'Exam Ready';

  @override
  String get achievement19Description => 'Reach 20 hours studying';

  @override
  String get achievement20Title => 'Scholar Mode';

  @override
  String get achievement20Description => 'Reach 50 hours studying';

  @override
  String get achievement21Title => 'First Page';

  @override
  String get achievement21Description => 'Read your first page';

  @override
  String get achievement22Title => '10 Pages';

  @override
  String get achievement22Description => 'Read 10 pages';

  @override
  String get achievement23Title => '25 Pages';

  @override
  String get achievement23Description => 'Read 25 pages';

  @override
  String get achievement24Title => '50 Pages';

  @override
  String get achievement24Description => 'Read 50 pages';

  @override
  String get achievement25Title => '100 Pages';

  @override
  String get achievement25Description => 'Read 100 pages';

  @override
  String get achievement26Title => 'Chapter Complete';

  @override
  String get achievement26Description => 'Read 150 pages';

  @override
  String get achievement27Title => 'Weekend Reader';

  @override
  String get achievement27Description => 'Read 250 pages';

  @override
  String get achievement28Title => 'Daily Reader';

  @override
  String get achievement28Description => 'Read 300 pages';

  @override
  String get achievement29Title => 'Bookworm';

  @override
  String get achievement29Description => 'Read 500 pages';

  @override
  String get achievement30Title => 'Library Legend';

  @override
  String get achievement30Description => 'Read 1000 pages';

  @override
  String get achievement31Title => 'First Goal';

  @override
  String get achievement31Description => 'Create your first goal';

  @override
  String get achievement32Title => 'Goal Crusher';

  @override
  String get achievement32Description => 'Complete a goal';

  @override
  String get achievement33Title => 'All Goals Done';

  @override
  String get achievement33Description => 'Finish every goal today';

  @override
  String get achievement34Title => 'Morning Routine';

  @override
  String get achievement34Description => 'Complete goals on 3 days';

  @override
  String get achievement35Title => 'Balanced Day';

  @override
  String get achievement35Description => 'Complete goals on 5 days';

  @override
  String get achievement36Title => 'Habit Builder';

  @override
  String get achievement36Description => 'Complete goals on 10 days';

  @override
  String get achievement37Title => 'Perfect Day';

  @override
  String get achievement37Description => 'Complete goals on 15 days';

  @override
  String get achievement38Title => 'Comeback';

  @override
  String get achievement38Description => 'Complete goals on 20 days';

  @override
  String get achievement39Title => 'Consistency Star';

  @override
  String get achievement39Description => 'Complete goals on 30 days';

  @override
  String get achievement40Title => 'Unstoppable';

  @override
  String get achievement40Description => 'Complete goals on 50 days';

  @override
  String get achievement41Title => 'First Group';

  @override
  String get achievement41Description => 'Join a study group';

  @override
  String get achievement42Title => 'Team Player';

  @override
  String get achievement42Description => 'Compete with friends';

  @override
  String get achievement43Title => 'Helpful Friend';

  @override
  String get achievement43Description => 'Help a friend stay consistent';

  @override
  String get achievement44Title => 'Challenge Winner';

  @override
  String get achievement44Description => 'Win a challenge';

  @override
  String get achievement45Title => 'Exercise Start';

  @override
  String get achievement45Description => 'Log exercise focus';

  @override
  String get achievement46Title => '30-Min Workout';

  @override
  String get achievement46Description => 'Exercise for 30 minutes';

  @override
  String get achievement47Title => 'Hobby Time';

  @override
  String get achievement47Description => 'Log hobby focus';

  @override
  String get achievement48Title => 'Creative Spark';

  @override
  String get achievement48Description => 'Reach 30 minutes of hobbies';

  @override
  String get achievement49Title => 'Weekend Warrior';

  @override
  String get achievement49Description => 'Reach 2 hours exercising';

  @override
  String get achievement50Title => 'Achievement Hunter';

  @override
  String get achievement50Description => 'Unlock 25 achievements';

  @override
  String get achievementUnlockedNotificationTitle => 'Achievement unlocked';

  @override
  String get rankTierPaper => 'Paper';

  @override
  String get rankTierWood => 'Wood';

  @override
  String get rankTierStone => 'Stone';

  @override
  String get rankTierCopper => 'Copper';

  @override
  String get rankTierBronze => 'Bronze';

  @override
  String get rankTierIron => 'Iron';

  @override
  String get rankTierSilver => 'Silver';

  @override
  String get rankTierGold => 'Gold';

  @override
  String get rankTierPlatinum => 'Platinum';

  @override
  String get rankTierAmethyst => 'Amethyst';

  @override
  String get rankTierEmerald => 'Emerald';

  @override
  String get rankTierDiamond => 'Diamond';

  @override
  String get rankTierObsidian => 'Obsidian';

  @override
  String get rankTierAdamantium => 'Adamantium';

  @override
  String get rankTierMithril => 'Mithril';

  @override
  String get concentrationModeTitle => 'Focus mode';

  @override
  String get concentrationModeSubtitle =>
      'Choose which focus sessions block leaving the app.';

  @override
  String get concentrationStudyTitle => 'Study';

  @override
  String get concentrationStudySubtitle => 'Full focus on your studies.';

  @override
  String get concentrationExercisesTitle => 'Exercises';

  @override
  String get concentrationExercisesSubtitle => 'Stay focused on your workouts.';

  @override
  String get concentrationReadingTitle => 'Reading';

  @override
  String get concentrationReadingSubtitle => 'Dive into your reading.';

  @override
  String get concentrationHobbiesTitle => 'Hobbies';

  @override
  String get concentrationHobbiesSubtitle => 'Enjoy your hobbies with focus.';

  @override
  String get createGroupDescriptionLabel => 'Description';

  @override
  String get createGroupDescriptionHint => 'Describe the group and its goal.';

  @override
  String get createGroupThemeMetricDescription =>
      'This theme defines the ranking metric.';

  @override
  String get createGroupActivityTypeDescription =>
      'Each member gets a copy to track.';

  @override
  String get createGroupActivityNameLabel => 'Activity name';

  @override
  String get createGroupActivityNameHint => 'Ex: Calculus I';

  @override
  String get createGroupGoalTypeLabel => 'Goal type';

  @override
  String get createGroupGoalTypeTotal => 'Total';

  @override
  String get createGroupGoalTypeDaily => 'Daily';

  @override
  String get createGroupDaysGoalLabel => 'Days goal';

  @override
  String get createGroupPagesGoalLabel => 'Pages goal';

  @override
  String get createGroupTimeGoalMinutesLabel => 'Time goal (min)';

  @override
  String get createGroupSummaryTitle => 'Group summary';

  @override
  String get createGroupActivitySummaryLabel => 'Activity';

  @override
  String get createGroupGuestsLabel => 'Guests';

  @override
  String get timerTotalTodayLabel => 'Total today';

  @override
  String get timerEndActionLabel => 'End';

  @override
  String get createGroupActivityStepSubtitle =>
      'Choose the activity everyone in the group will do.';

  @override
  String get createGroupFriendsStepSubtitle =>
      'Invite at least 1 friend to join.';

  @override
  String get createGroupSummaryStepSubtitle =>
      'Review the details before creating.';

  @override
  String get createGroupStepInformation => 'Information';

  @override
  String get createGroupStepActivity => 'Activity';

  @override
  String get createGroupStepFriends => 'Friends';

  @override
  String get createGroupStepSummary => 'Summary';

  @override
  String get createGroupDaysGoalHint => 'Ex: 30';

  @override
  String get createGroupPagesGoalHint => 'Ex: 10';

  @override
  String get createGroupMinutesGoalHint => 'Ex: 30';

  @override
  String get createGroupAddFriendsPromptTitle => 'Didn\'t find someone?';

  @override
  String get createGroupAddFriendsPromptDescription =>
      'Add more friends to be able to invite them.';

  @override
  String get createGroupContinueButton => 'Continue';

  @override
  String get createGroupActivitySummaryDaily => 'Daily goal';

  @override
  String createGroupActivitySummaryGoalDays(String days) {
    return 'Goal • $days days';
  }

  @override
  String createGroupActivitySummaryReading(String pages) {
    return 'Reading • $pages pages';
  }

  @override
  String createGroupActivitySummaryTime(String category, String minutes) {
    return '$category • $minutes min';
  }

  @override
  String get createGroupActivityRequiredError =>
      'Choose an activity for the group.';

  @override
  String get createGroupActivityNameRequiredError =>
      'Give the activity a name.';

  @override
  String get createGroupActivityGoalInvalidError => 'Set a valid goal.';

  @override
  String get createGroupActivityMissingError => 'Define the group\'s activity.';

  @override
  String get timerBackTooltip => 'Go back';

  @override
  String get timerRestMessageTitle => 'Rest a little';

  @override
  String get timerFocusLabel => 'Focus';

  @override
  String get timerReadingLabel => 'Reading';

  @override
  String get timerPauseLabel => 'Pause';

  @override
  String get timerReadingTimeLabel => 'reading time';

  @override
  String timerTotalOfLabel(String duration) {
    return 'of $duration';
  }

  @override
  String get timerCurrentPagesLabel => 'Current pages';

  @override
  String get timerNotesLabel => 'Notes';

  @override
  String get concentrationModeSheetDescription =>
      'When enabled, the app helps you stay focused during the activity until you pause or finish.';

  @override
  String get timerFocusLockWarning =>
      'Focus mode is active. Finish or pause the session to leave.';

  @override
  String timerProgressSemanticLabel(int percent) {
    return 'Progress: $percent%';
  }

  @override
  String homeStreakLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-day streak',
      one: '$count-day streak',
    );
    return '$_temp0';
  }
}
