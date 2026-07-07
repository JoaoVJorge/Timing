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
  String get loginHeadline => 'Let\'s Start';

  @override
  String get loginSubtitle => 'Sign in to get started.';

  @override
  String get loginNameHint => 'Your name';

  @override
  String get loginButton => 'Let\'s Start';

  @override
  String get homeGreetingDefault => 'Let\'s Start';

  @override
  String homeGreetingWithName(String userName) {
    return 'Let\'s Start, $userName';
  }

  @override
  String get homeSubtitle => 'What are we tackling today?';

  @override
  String get homeTasksSection => 'Daily goals';

  @override
  String get homeCategoriesSection => 'Your time';

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
  String get targetDaysHint => 'Custom target (days)';

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
  String get categoryStudying => 'Studying';

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
  String get musicSuggestionLabel => 'Music suggestion';

  @override
  String get musicSuggestionHint => 'e.g. Lo-fi beats';

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
  String get addButton => 'Add';

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
  String timerMusicSuggestion(String name) {
    return 'Suggested: $name';
  }

  @override
  String get timerNotificationRunning => 'Focus session in progress';

  @override
  String get timerNotificationResting => 'Resting — back soon';

  @override
  String get timerNotificationPaused => 'Paused';

  @override
  String get profileTitle => 'Your Profile';

  @override
  String get profileSubtitleDefault => 'Accomplishments';

  @override
  String profileSubtitleWithName(String userName) {
    return 'Great work, $userName';
  }

  @override
  String get statHoursStudied => 'Hours studied';

  @override
  String get statTopSubjectFallback => '—';

  @override
  String get statTopSubject => 'Top subject';

  @override
  String get statHoursExercised => 'Hours exercising';

  @override
  String get statHoursRead => 'Hours read';

  @override
  String get mostReadThemes => 'Most read themes';

  @override
  String get noReadingYet => 'Read something to see your top themes here.';

  @override
  String get groupsTitle => 'Groups';

  @override
  String get noGroupSelected => 'No group selected yet.';

  @override
  String get newGroupChip => 'New group';

  @override
  String get periodToday => 'Today';

  @override
  String get periodThisWeek => 'This Week';

  @override
  String get periodThisMonth => 'This Month';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get myProfileFallback => 'My Profile';

  @override
  String get preferencesSection => 'Preferences';

  @override
  String get darkModeLabel => 'Dark mode';

  @override
  String get notificationsLabel => 'Notifications';

  @override
  String get language => 'Language';

  @override
  String get supportSection => 'Support';

  @override
  String get faqLabel => 'FAQ';

  @override
  String get aboutLabel => 'About';

  @override
  String appVersionLabel(String appTitle, String appVersion) {
    return '$appTitle v$appVersion';
  }

  @override
  String get accountSection => 'Account';

  @override
  String get logOutLabel => 'Log out';

  @override
  String get logOutDialogTitle => 'Log out';

  @override
  String get logOutDialogContent =>
      'This clears your local profile from this device. You can always set it up again.';

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
      'Groups show a scoreboard of everyone\'s studied hours. Switch between Today, This Week and This Month to see who studied the most in that period.';

  @override
  String get faqQ5 => 'Can I change the app\'s color theme?';

  @override
  String get faqA5 =>
      'Yes, go to Settings > My Profile and pick any theme color. Every gradient, button and highlight across the app updates to match it, including dark mode.';

  @override
  String get createGroupTitle => 'Create Group';

  @override
  String get groupNameHint => 'Group name';

  @override
  String get groupThemeLabel => 'Theme';

  @override
  String get inviteFriendsLabel => 'Invite friends';

  @override
  String get createGroupButton => 'Create Group';

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
  String get noScheduleYet => 'No schedule yet — tap to add';

  @override
  String get addScheduleEntryTitle => 'Add Schedule Entry';

  @override
  String get addScheduleEntryButton => 'Add Entry';

  @override
  String get scheduleTitleHint => 'Title';

  @override
  String get startTimeLabel => 'Start time';

  @override
  String get endTimeOptionalLabel => 'End time (optional)';

  @override
  String get incompleteScheduleEntryError =>
      'Incomplete entry — fill in the title and a valid start time.';

  @override
  String get continueWithGoogleButton => 'Continue with Google';

  @override
  String get continueWithAppleButton => 'Continue with Apple';

  @override
  String get continueWithPhoneButton => 'Continue with phone number';

  @override
  String get phoneLoginTitle => 'Sign in';

  @override
  String get phoneLoginSubtitle =>
      'Enter your phone number and we\'ll text you a verification code.';

  @override
  String get sendCodeButton => 'Send code';

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
  String get codeResentMessage => 'Verification code sent';

  @override
  String get invalidCodeError => 'Invalid code. Please try again.';

  @override
  String get credentialsTitle => 'Almost there';

  @override
  String get credentialsSubtitle => 'Tell us a bit about you.';

  @override
  String get birthDateHint => 'Date of birth';

  @override
  String get finishButton => 'Finish';
}
