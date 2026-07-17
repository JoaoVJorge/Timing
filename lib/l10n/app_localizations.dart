import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'HelpOut'**
  String get appTitle;

  /// No description provided for @genericErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again later.'**
  String get genericErrorMessage;

  /// No description provided for @loginHeadline.
  ///
  /// In en, this message translates to:
  /// **'Let\'s begin'**
  String get loginHeadline;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to keep studying and organize your routine.'**
  String get loginSubtitle;

  /// No description provided for @loginNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get loginNameHint;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Start'**
  String get loginButton;

  /// No description provided for @homeGreetingDefault.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get homeGreetingDefault;

  /// No description provided for @homeGreetingWithName.
  ///
  /// In en, this message translates to:
  /// **'Hello, {userName}'**
  String homeGreetingWithName(String userName);

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What are we tackling today?'**
  String get homeSubtitle;

  /// No description provided for @homeSubtitleFocusedToday.
  ///
  /// In en, this message translates to:
  /// **'You\'ve focused {duration} today'**
  String homeSubtitleFocusedToday(String duration);

  /// No description provided for @homeSubtitleNextSchedule.
  ///
  /// In en, this message translates to:
  /// **'Agenda: {title} at {time}'**
  String homeSubtitleNextSchedule(String title, String time);

  /// No description provided for @homeSubtitleStart.
  ///
  /// In en, this message translates to:
  /// **'Start your first focus session'**
  String get homeSubtitleStart;

  /// No description provided for @homeTasksSection.
  ///
  /// In en, this message translates to:
  /// **'Daily goals'**
  String get homeTasksSection;

  /// No description provided for @homeCategoriesSection.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get homeCategoriesSection;

  /// No description provided for @homeActionContinueEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Continue now'**
  String get homeActionContinueEyebrow;

  /// No description provided for @homeActionContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get homeActionContinueButton;

  /// No description provided for @homeActionStartEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Start focus'**
  String get homeActionStartEyebrow;

  /// No description provided for @homeActionStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get homeActionStartButton;

  /// No description provided for @homeActionSuggestedMeta.
  ///
  /// In en, this message translates to:
  /// **'Your most-tracked subject'**
  String get homeActionSuggestedMeta;

  /// No description provided for @homeActionCreateBody.
  ///
  /// In en, this message translates to:
  /// **'Create your first subject to start a focus session.'**
  String get homeActionCreateBody;

  /// No description provided for @homeActionCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create subject'**
  String get homeActionCreateButton;

  /// No description provided for @homeSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s summary'**
  String get homeSummaryTitle;

  /// No description provided for @homeSummaryFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get homeSummaryFocus;

  /// No description provided for @homeSummaryGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get homeSummaryGoals;

  /// No description provided for @homeSummaryPages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get homeSummaryPages;

  /// No description provided for @homeSummarySessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get homeSummarySessions;

  /// No description provided for @homeGoalsProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String homeGoalsProgress(int done, int total);

  /// No description provided for @homeCategoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet'**
  String get homeCategoryEmpty;

  /// No description provided for @homeNextScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Agenda'**
  String get homeNextScheduleTitle;

  /// No description provided for @homeTodayAgendaTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s agenda'**
  String get homeTodayAgendaTitle;

  /// No description provided for @homeNextScheduleEmpty.
  ///
  /// In en, this message translates to:
  /// **'No schedule today'**
  String get homeNextScheduleEmpty;

  /// No description provided for @homeNextScheduleAdd.
  ///
  /// In en, this message translates to:
  /// **'Add schedule'**
  String get homeNextScheduleAdd;

  /// No description provided for @addTaskButton.
  ///
  /// In en, this message translates to:
  /// **'Add goal'**
  String get addTaskButton;

  /// No description provided for @createTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'New goal'**
  String get createTaskTitle;

  /// No description provided for @taskNameHint.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get taskNameHint;

  /// No description provided for @targetDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Target (days)'**
  String get targetDaysLabel;

  /// No description provided for @targetDaysChip.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String targetDaysChip(int days);

  /// No description provided for @targetDaysHint.
  ///
  /// In en, this message translates to:
  /// **'Custom target'**
  String get targetDaysHint;

  /// No description provided for @taskDaysProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{target} days'**
  String taskDaysProgress(int completed, int target);

  /// No description provided for @taskCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'Done!'**
  String get taskCompletedLabel;

  /// No description provided for @lastActivityLabel.
  ///
  /// In en, this message translates to:
  /// **'Last activity'**
  String get lastActivityLabel;

  /// No description provided for @lastActivityNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet — start something!'**
  String get lastActivityNone;

  /// No description provided for @lastActivityJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get lastActivityJustNow;

  /// No description provided for @lastActivityMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String lastActivityMinutesAgo(int minutes);

  /// No description provided for @lastActivityHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} h ago'**
  String lastActivityHoursAgo(int hours);

  /// No description provided for @lastActivityDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} d ago'**
  String lastActivityDaysAgo(int days);

  /// No description provided for @categoryStudying.
  ///
  /// In en, this message translates to:
  /// **'Studies'**
  String get categoryStudying;

  /// No description provided for @categoryExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercising'**
  String get categoryExercises;

  /// No description provided for @categoryReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get categoryReading;

  /// No description provided for @categoryHobbies.
  ///
  /// In en, this message translates to:
  /// **'Hobbies'**
  String get categoryHobbies;

  /// No description provided for @itemNounStudying.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get itemNounStudying;

  /// No description provided for @itemNounExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get itemNounExercises;

  /// No description provided for @itemNounReading.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get itemNounReading;

  /// No description provided for @itemNounHobbies.
  ///
  /// In en, this message translates to:
  /// **'Hobby'**
  String get itemNounHobbies;

  /// No description provided for @iconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get iconLabel;

  /// No description provided for @restTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Rest time'**
  String get restTimeLabel;

  /// No description provided for @restMinutesChip.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String restMinutesChip(int minutes);

  /// No description provided for @timeUnitHoursSuffix.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get timeUnitHoursSuffix;

  /// No description provided for @timeUnitMinutesSuffix.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get timeUnitMinutesSuffix;

  /// No description provided for @wallpaperLabel.
  ///
  /// In en, this message translates to:
  /// **'Timer wallpaper'**
  String get wallpaperLabel;

  /// No description provided for @addItemButton.
  ///
  /// In en, this message translates to:
  /// **'Add {itemNoun}'**
  String addItemButton(String itemNoun);

  /// No description provided for @itemNameHint.
  ///
  /// In en, this message translates to:
  /// **'{itemNoun} name'**
  String itemNameHint(String itemNoun);

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @bookThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Book theme'**
  String get bookThemeLabel;

  /// No description provided for @estimatedHoursGoalHint.
  ///
  /// In en, this message translates to:
  /// **'Estimated hours (goal)'**
  String get estimatedHoursGoalHint;

  /// No description provided for @goalPagesHint.
  ///
  /// In en, this message translates to:
  /// **'Goal (pages)'**
  String get goalPagesHint;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @confirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButton;

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// No description provided for @createSubjectTitleStudying.
  ///
  /// In en, this message translates to:
  /// **'New subject'**
  String get createSubjectTitleStudying;

  /// No description provided for @createSubjectTitleReading.
  ///
  /// In en, this message translates to:
  /// **'New reading'**
  String get createSubjectTitleReading;

  /// No description provided for @createSubjectTitleExercises.
  ///
  /// In en, this message translates to:
  /// **'New workout'**
  String get createSubjectTitleExercises;

  /// No description provided for @createSubjectTitleHobbies.
  ///
  /// In en, this message translates to:
  /// **'New hobby'**
  String get createSubjectTitleHobbies;

  /// No description provided for @createSubjectSubtitleStudying.
  ///
  /// In en, this message translates to:
  /// **'Set a goal and personalize your focus'**
  String get createSubjectSubtitleStudying;

  /// No description provided for @createSubjectSubtitleReading.
  ///
  /// In en, this message translates to:
  /// **'Track pages and personalize your reading'**
  String get createSubjectSubtitleReading;

  /// No description provided for @createSubjectSubtitleExercises.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to track this activity'**
  String get createSubjectSubtitleExercises;

  /// No description provided for @createSubjectSubtitleHobbies.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to track this hobby'**
  String get createSubjectSubtitleHobbies;

  /// No description provided for @createSubjectBasicSection.
  ///
  /// In en, this message translates to:
  /// **'Basic information'**
  String get createSubjectBasicSection;

  /// No description provided for @createSubjectGoalSection.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get createSubjectGoalSection;

  /// No description provided for @createSubjectRoutineSection.
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get createSubjectRoutineSection;

  /// No description provided for @createSubjectPersonalizationSection.
  ///
  /// In en, this message translates to:
  /// **'Personalization'**
  String get createSubjectPersonalizationSection;

  /// No description provided for @createSubjectNameLabelStudying.
  ///
  /// In en, this message translates to:
  /// **'Subject name'**
  String get createSubjectNameLabelStudying;

  /// No description provided for @createSubjectNameLabelReading.
  ///
  /// In en, this message translates to:
  /// **'Reading name'**
  String get createSubjectNameLabelReading;

  /// No description provided for @createSubjectNameLabelExercises.
  ///
  /// In en, this message translates to:
  /// **'Activity name'**
  String get createSubjectNameLabelExercises;

  /// No description provided for @createSubjectNameLabelHobbies.
  ///
  /// In en, this message translates to:
  /// **'Hobby name'**
  String get createSubjectNameLabelHobbies;

  /// No description provided for @createSubjectNameHintStudying.
  ///
  /// In en, this message translates to:
  /// **'Ex.: Biology, Math, English'**
  String get createSubjectNameHintStudying;

  /// No description provided for @createSubjectNameHintReading.
  ///
  /// In en, this message translates to:
  /// **'Ex.: History book, Dom Casmurro'**
  String get createSubjectNameHintReading;

  /// No description provided for @createSubjectNameHintExercises.
  ///
  /// In en, this message translates to:
  /// **'Ex.: Gym, Running, Stretching'**
  String get createSubjectNameHintExercises;

  /// No description provided for @createSubjectNameHintHobbies.
  ///
  /// In en, this message translates to:
  /// **'Ex.: Guitar, Drawing, Programming'**
  String get createSubjectNameHintHobbies;

  /// No description provided for @createSubjectTimeGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Time goal'**
  String get createSubjectTimeGoalLabel;

  /// No description provided for @createSubjectPagesGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Page goal'**
  String get createSubjectPagesGoalLabel;

  /// No description provided for @createSubjectTimeGoalHelp.
  ///
  /// In en, this message translates to:
  /// **'How many hours do you want to accumulate in total?'**
  String get createSubjectTimeGoalHelp;

  /// No description provided for @createSubjectPagesGoalHelp.
  ///
  /// In en, this message translates to:
  /// **'How many pages do you want to log in total?'**
  String get createSubjectPagesGoalHelp;

  /// No description provided for @createSubjectRestLabel.
  ///
  /// In en, this message translates to:
  /// **'Break after each focus'**
  String get createSubjectRestLabel;

  /// No description provided for @createSubjectRestHelp.
  ///
  /// In en, this message translates to:
  /// **'The timer suggests a break after 25 min of focus.'**
  String get createSubjectRestHelp;

  /// No description provided for @customRestMinutesHint.
  ///
  /// In en, this message translates to:
  /// **'Custom break (min)'**
  String get customRestMinutesHint;

  /// No description provided for @createSubjectPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get createSubjectPreviewTitle;

  /// No description provided for @createSubjectPreviewNoGoal.
  ///
  /// In en, this message translates to:
  /// **'No goal set'**
  String get createSubjectPreviewNoGoal;

  /// No description provided for @createSubjectPreviewGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal: {goal}'**
  String createSubjectPreviewGoal(String goal);

  /// No description provided for @createSubjectPreviewRest.
  ///
  /// In en, this message translates to:
  /// **'Break: {minutes} min'**
  String createSubjectPreviewRest(int minutes);

  /// No description provided for @createSubjectHoursValue.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String createSubjectHoursValue(int hours);

  /// No description provided for @createSubjectHoursMinutesValue.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String createSubjectHoursMinutesValue(int hours, int minutes);

  /// No description provided for @createSubjectColorSemantic.
  ///
  /// In en, this message translates to:
  /// **'Color {index}'**
  String createSubjectColorSemantic(int index);

  /// No description provided for @createSubjectButtonStudying.
  ///
  /// In en, this message translates to:
  /// **'Create subject'**
  String get createSubjectButtonStudying;

  /// No description provided for @createSubjectButtonReading.
  ///
  /// In en, this message translates to:
  /// **'Create reading'**
  String get createSubjectButtonReading;

  /// No description provided for @createSubjectButtonExercises.
  ///
  /// In en, this message translates to:
  /// **'Create activity'**
  String get createSubjectButtonExercises;

  /// No description provided for @createSubjectButtonHobbies.
  ///
  /// In en, this message translates to:
  /// **'Create hobby'**
  String get createSubjectButtonHobbies;

  /// No description provided for @createSubjectMissingName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name to continue'**
  String get createSubjectMissingName;

  /// No description provided for @createSubjectMissingTimeGoal.
  ///
  /// In en, this message translates to:
  /// **'Set a valid time goal'**
  String get createSubjectMissingTimeGoal;

  /// No description provided for @createSubjectMissingPagesGoal.
  ///
  /// In en, this message translates to:
  /// **'Set a valid page goal'**
  String get createSubjectMissingPagesGoal;

  /// No description provided for @createSubjectSuccessStudying.
  ///
  /// In en, this message translates to:
  /// **'Subject created successfully'**
  String get createSubjectSuccessStudying;

  /// No description provided for @createSubjectSuccessReading.
  ///
  /// In en, this message translates to:
  /// **'Reading created successfully'**
  String get createSubjectSuccessReading;

  /// No description provided for @createSubjectSuccessExercises.
  ///
  /// In en, this message translates to:
  /// **'Activity created successfully'**
  String get createSubjectSuccessExercises;

  /// No description provided for @createSubjectSuccessHobbies.
  ///
  /// In en, this message translates to:
  /// **'Hobby created successfully'**
  String get createSubjectSuccessHobbies;

  /// No description provided for @pagesProgress.
  ///
  /// In en, this message translates to:
  /// **'{currentPages} of {goalPages} pages'**
  String pagesProgress(int currentPages, int goalPages);

  /// No description provided for @pagesReadOnly.
  ///
  /// In en, this message translates to:
  /// **'{currentPages} pages read'**
  String pagesReadOnly(int currentPages);

  /// No description provided for @pagesReadNowHint.
  ///
  /// In en, this message translates to:
  /// **'Pages read now'**
  String get pagesReadNowHint;

  /// No description provided for @logPagesButton.
  ///
  /// In en, this message translates to:
  /// **'Log pages'**
  String get logPagesButton;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Write your notes here...'**
  String get notesHint;

  /// No description provided for @saveNotesButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveNotesButton;

  /// No description provided for @durationProgress.
  ///
  /// In en, this message translates to:
  /// **'{duration} of {goalDuration}'**
  String durationProgress(String duration, String goalDuration);

  /// No description provided for @timerTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total: {duration}'**
  String timerTotalLabel(String duration);

  /// No description provided for @timerNextBreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Next break in {duration}'**
  String timerNextBreakLabel(String duration);

  /// No description provided for @timerRestingLabel.
  ///
  /// In en, this message translates to:
  /// **'Resting — back in {duration}'**
  String timerRestingLabel(String duration);

  /// No description provided for @timerNotificationRunning.
  ///
  /// In en, this message translates to:
  /// **'Focus session in progress'**
  String get timerNotificationRunning;

  /// No description provided for @timerNotificationResting.
  ///
  /// In en, this message translates to:
  /// **'Resting — back soon'**
  String get timerNotificationResting;

  /// No description provided for @timerNotificationPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get timerNotificationPaused;

  /// No description provided for @timerStateFocusingTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus in progress'**
  String get timerStateFocusingTitle;

  /// No description provided for @timerStateFocusingDescription.
  ///
  /// In en, this message translates to:
  /// **'Keep your focus. A break will be suggested soon.'**
  String get timerStateFocusingDescription;

  /// No description provided for @timerStatePausedTitle.
  ///
  /// In en, this message translates to:
  /// **'Timer paused'**
  String get timerStatePausedTitle;

  /// No description provided for @timerStatePausedDescription.
  ///
  /// In en, this message translates to:
  /// **'Continue when you\'re ready.'**
  String get timerStatePausedDescription;

  /// No description provided for @timerStateRestingTitle.
  ///
  /// In en, this message translates to:
  /// **'Well-earned break'**
  String get timerStateRestingTitle;

  /// No description provided for @timerStateRestingDescription.
  ///
  /// In en, this message translates to:
  /// **'Drink water or breathe a little before continuing.'**
  String get timerStateRestingDescription;

  /// No description provided for @timerSessionSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Session logged'**
  String get timerSessionSavedTitle;

  /// No description provided for @timerSessionSavedDescription.
  ///
  /// In en, this message translates to:
  /// **'Your time was added to the subject.'**
  String get timerSessionSavedDescription;

  /// No description provided for @timerCurrentFocusLabel.
  ///
  /// In en, this message translates to:
  /// **'Focused time now'**
  String get timerCurrentFocusLabel;

  /// No description provided for @timerRestTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Break time'**
  String get timerRestTimeLabel;

  /// No description provided for @timerSessionLabel.
  ///
  /// In en, this message translates to:
  /// **'Current session'**
  String get timerSessionLabel;

  /// No description provided for @timerTotalInSubject.
  ///
  /// In en, this message translates to:
  /// **'Total in {subjectName}'**
  String timerTotalInSubject(String subjectName);

  /// No description provided for @timerPauseButton.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get timerPauseButton;

  /// No description provided for @timerContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get timerContinueButton;

  /// No description provided for @timerContinueFocusButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get timerContinueFocusButton;

  /// No description provided for @timerSkipRestButton.
  ///
  /// In en, this message translates to:
  /// **'Skip break'**
  String get timerSkipRestButton;

  /// No description provided for @timerEndSessionButton.
  ///
  /// In en, this message translates to:
  /// **'End session'**
  String get timerEndSessionButton;

  /// No description provided for @timerStartAnotherSessionButton.
  ///
  /// In en, this message translates to:
  /// **'Start another session'**
  String get timerStartAnotherSessionButton;

  /// No description provided for @timerSaveReassurance.
  ///
  /// In en, this message translates to:
  /// **'Progress is also saved when you pause or leave.'**
  String get timerSaveReassurance;

  /// No description provided for @timerFocusedValue.
  ///
  /// In en, this message translates to:
  /// **'{duration} focused'**
  String timerFocusedValue(String duration);

  /// No description provided for @timerAccumulatedTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Accumulated total'**
  String get timerAccumulatedTotalLabel;

  /// No description provided for @timerBackToSubjectsButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get timerBackToSubjectsButton;

  /// No description provided for @timerExitDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'End session?'**
  String get timerExitDialogTitle;

  /// No description provided for @timerExitDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Your {duration} progress will be saved in {subjectName}.'**
  String timerExitDialogContent(String duration, String subjectName);

  /// No description provided for @timerExitDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get timerExitDialogCancel;

  /// No description provided for @timerExitDialogContinueLater.
  ///
  /// In en, this message translates to:
  /// **'You can continue later.'**
  String get timerExitDialogContinueLater;

  /// No description provided for @timerExitDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get timerExitDialogConfirm;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @editButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButton;

  /// No description provided for @nicknameFallback.
  ///
  /// In en, this message translates to:
  /// **'user'**
  String get nicknameFallback;

  /// No description provided for @profileSummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Total summary'**
  String get profileSummaryLabel;

  /// No description provided for @profileSummarySinceStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Since the beginning'**
  String get profileSummarySinceStartLabel;

  /// No description provided for @profileSummaryAccumulatedFocus.
  ///
  /// In en, this message translates to:
  /// **'{duration} of accumulated focus'**
  String profileSummaryAccumulatedFocus(Object duration);

  /// No description provided for @profileSummaryFocusLabel.
  ///
  /// In en, this message translates to:
  /// **'Total focus time'**
  String get profileSummaryFocusLabel;

  /// No description provided for @profileSummaryFocusDescription.
  ///
  /// In en, this message translates to:
  /// **'Studying, exercise and hobbies'**
  String get profileSummaryFocusDescription;

  /// No description provided for @statHoursStudied.
  ///
  /// In en, this message translates to:
  /// **'Studying'**
  String get statHoursStudied;

  /// No description provided for @statHoursExercised.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get statHoursExercised;

  /// No description provided for @statPagesRead.
  ///
  /// In en, this message translates to:
  /// **'Pages read'**
  String get statPagesRead;

  /// No description provided for @statTopSubject.
  ///
  /// In en, this message translates to:
  /// **'Most studied'**
  String get statTopSubject;

  /// No description provided for @profileStatTimeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Start your first focus'**
  String get profileStatTimeEmptyTitle;

  /// No description provided for @profileStatTimeEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Your time will show up here'**
  String get profileStatTimeEmptyDescription;

  /// No description provided for @profileStatExerciseEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No exercise yet'**
  String get profileStatExerciseEmptyTitle;

  /// No description provided for @profileStatExerciseEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Log your first activity'**
  String get profileStatExerciseEmptyDescription;

  /// No description provided for @profileStatReadingEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No pages yet'**
  String get profileStatReadingEmptyTitle;

  /// No description provided for @profileStatReadingEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Log your first reading'**
  String get profileStatReadingEmptyDescription;

  /// No description provided for @profileTopSubjectEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'None yet'**
  String get profileTopSubjectEmptyTitle;

  /// No description provided for @profileTopSubjectEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Study a subject to feature it here'**
  String get profileTopSubjectEmptyDescription;

  /// No description provided for @profileEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your progress starts here'**
  String get profileEmptyTitle;

  /// No description provided for @profileEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Start a session, log some reading or set a goal from Home to track your evolution in HelpOut.'**
  String get profileEmptyDescription;

  /// No description provided for @profileEmptyGuidance.
  ///
  /// In en, this message translates to:
  /// **'After that, your total time, top activities and reading highlights will appear here.'**
  String get profileEmptyGuidance;

  /// No description provided for @profileEmptyStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start now'**
  String get profileEmptyStartButton;

  /// No description provided for @profileShortcutsTitle.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts'**
  String get profileShortcutsTitle;

  /// No description provided for @profileShortcutCreateSubject.
  ///
  /// In en, this message translates to:
  /// **'Create subject'**
  String get profileShortcutCreateSubject;

  /// No description provided for @profileShortcutCreateGoal.
  ///
  /// In en, this message translates to:
  /// **'Create goal'**
  String get profileShortcutCreateGoal;

  /// No description provided for @profileShortcutAddSchedule.
  ///
  /// In en, this message translates to:
  /// **'Add schedule'**
  String get profileShortcutAddSchedule;

  /// No description provided for @profileEvolutionTitle.
  ///
  /// In en, this message translates to:
  /// **'Your progress'**
  String get profileEvolutionTitle;

  /// No description provided for @profileEvolutionFocus.
  ///
  /// In en, this message translates to:
  /// **'You\'ve accumulated {duration} of focus.'**
  String profileEvolutionFocus(String duration);

  /// No description provided for @profileEvolutionTopSubject.
  ///
  /// In en, this message translates to:
  /// **'Your most studied subject is {name}.'**
  String profileEvolutionTopSubject(String name);

  /// No description provided for @profileEvolutionRemaining.
  ///
  /// In en, this message translates to:
  /// **'You\'re {duration} away from your goal.'**
  String profileEvolutionRemaining(String duration);

  /// No description provided for @profileEvolutionGoalReached.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached your focus goal!'**
  String get profileEvolutionGoalReached;

  /// No description provided for @profileProgressSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Your progress'**
  String get profileProgressSectionTitle;

  /// No description provided for @profileAchievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get profileAchievementsTitle;

  /// No description provided for @profileSeeHistory.
  ///
  /// In en, this message translates to:
  /// **'See history'**
  String get profileSeeHistory;

  /// No description provided for @profileSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get profileSeeAll;

  /// No description provided for @profileAchievementFirstFocus.
  ///
  /// In en, this message translates to:
  /// **'First focus'**
  String get profileAchievementFirstFocus;

  /// No description provided for @profileAchievementStudyStarted.
  ///
  /// In en, this message translates to:
  /// **'Study started'**
  String get profileAchievementStudyStarted;

  /// No description provided for @profileAchievementReadingStarted.
  ///
  /// In en, this message translates to:
  /// **'Reading started'**
  String get profileAchievementReadingStarted;

  /// No description provided for @profileAchievementLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get profileAchievementLocked;

  /// No description provided for @periodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get periodMonth;

  /// No description provided for @periodTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get periodTotal;

  /// No description provided for @profileAgendaTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s schedule'**
  String get profileAgendaTitle;

  /// No description provided for @profileAgendaEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No schedule planned'**
  String get profileAgendaEmptyTitle;

  /// No description provided for @profileAgendaEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Add blocks to organize your routine.'**
  String get profileAgendaEmptyDescription;

  /// No description provided for @profileAgendaAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add schedule'**
  String get profileAgendaAddButton;

  /// No description provided for @profileTopReadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Top reading'**
  String get profileTopReadingTitle;

  /// No description provided for @profileTopReadingEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No reading logged'**
  String get profileTopReadingEmptyTitle;

  /// No description provided for @profileTopReadingEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Log pages read to see your top themes here.'**
  String get profileTopReadingEmptyDescription;

  /// No description provided for @groupsTitle.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groupsTitle;

  /// No description provided for @groupsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Compare your progress with friends'**
  String get groupsSubtitle;

  /// No description provided for @noGroupSelected.
  ///
  /// In en, this message translates to:
  /// **'No group selected yet.'**
  String get noGroupSelected;

  /// No description provided for @newGroupChip.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newGroupChip;

  /// No description provided for @groupHeaderCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get groupHeaderCreateButton;

  /// No description provided for @groupsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No groups yet'**
  String get groupsEmptyTitle;

  /// No description provided for @groupsEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a group to compare progress with friends and keep the momentum going.'**
  String get groupsEmptyDescription;

  /// No description provided for @groupsEmptyButton.
  ///
  /// In en, this message translates to:
  /// **'Create first group'**
  String get groupsEmptyButton;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @mockStudyGroupName.
  ///
  /// In en, this message translates to:
  /// **'Study Squad'**
  String get mockStudyGroupName;

  /// No description provided for @mockWorkoutGroupName.
  ///
  /// In en, this message translates to:
  /// **'Workout Crew'**
  String get mockWorkoutGroupName;

  /// No description provided for @periodToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get periodToday;

  /// No description provided for @periodThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get periodThisWeek;

  /// No description provided for @periodThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get periodThisMonth;

  /// No description provided for @periodDescriptionToday.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get periodDescriptionToday;

  /// No description provided for @periodDescriptionThisWeek.
  ///
  /// In en, this message translates to:
  /// **'this week'**
  String get periodDescriptionThisWeek;

  /// No description provided for @periodDescriptionThisMonth.
  ///
  /// In en, this message translates to:
  /// **'this month'**
  String get periodDescriptionThisMonth;

  /// No description provided for @groupMetricStudying.
  ///
  /// In en, this message translates to:
  /// **'study hours'**
  String get groupMetricStudying;

  /// No description provided for @groupMetricDailyGoals.
  ///
  /// In en, this message translates to:
  /// **'completed goal days'**
  String get groupMetricDailyGoals;

  /// No description provided for @groupMetricExercises.
  ///
  /// In en, this message translates to:
  /// **'exercise hours'**
  String get groupMetricExercises;

  /// No description provided for @groupMetricReading.
  ///
  /// In en, this message translates to:
  /// **'pages read'**
  String get groupMetricReading;

  /// No description provided for @groupMetricHobbies.
  ///
  /// In en, this message translates to:
  /// **'hobby hours'**
  String get groupMetricHobbies;

  /// No description provided for @groupLeaderboardDescription.
  ///
  /// In en, this message translates to:
  /// **'Ranking for {period} · measured in {metric}'**
  String groupLeaderboardDescription(String period, String metric);

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Ranking'**
  String get leaderboardTitle;

  /// No description provided for @currentUserRankTitle.
  ///
  /// In en, this message translates to:
  /// **'Your performance'**
  String get currentUserRankTitle;

  /// No description provided for @currentUserRankValue.
  ///
  /// In en, this message translates to:
  /// **'{rank} place · {score}'**
  String currentUserRankValue(String rank, String score);

  /// No description provided for @currentUserRankNextStep.
  ///
  /// In en, this message translates to:
  /// **'{score} to climb one position'**
  String currentUserRankNextStep(String score);

  /// No description provided for @currentUserRankLeading.
  ///
  /// In en, this message translates to:
  /// **'You\'re leading this ranking.'**
  String get currentUserRankLeading;

  /// No description provided for @currentUserRankSubtitle.
  ///
  /// In en, this message translates to:
  /// **'your current position'**
  String get currentUserRankSubtitle;

  /// No description provided for @leaderboardTopPosition.
  ///
  /// In en, this message translates to:
  /// **'leading this ranking'**
  String get leaderboardTopPosition;

  /// No description provided for @leaderboardDifferenceAhead.
  ///
  /// In en, this message translates to:
  /// **'+{value} ahead'**
  String leaderboardDifferenceAhead(String value);

  /// No description provided for @groupCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Group created successfully'**
  String get groupCreatedSuccess;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust your account and preferences'**
  String get settingsSubtitle;

  /// No description provided for @myProfileFallback.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfileFallback;

  /// No description provided for @personalProfileLabel.
  ///
  /// In en, this message translates to:
  /// **'Personal profile'**
  String get personalProfileLabel;

  /// No description provided for @accountDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{nickname} · personal data and security'**
  String accountDataSubtitle(Object nickname);

  /// No description provided for @preferencesSection.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferencesSection;

  /// No description provided for @darkModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkModeLabel;

  /// No description provided for @darkModeEnabledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dark theme is on'**
  String get darkModeEnabledSubtitle;

  /// No description provided for @darkModeDisabledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the dark theme in the app'**
  String get darkModeDisabledSubtitle;

  /// No description provided for @accentColorSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get accentColorSettingsTitle;

  /// No description provided for @accentColorSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personalize the app appearance'**
  String get accentColorSettingsSubtitle;

  /// No description provided for @notificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsLabel;

  /// No description provided for @timerNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Timer notifications'**
  String get timerNotificationsTitle;

  /// No description provided for @notificationsEnabledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Focus, break and progress alerts'**
  String get notificationsEnabledSubtitle;

  /// No description provided for @notificationsDisabledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts are off on this device'**
  String get notificationsDisabledSubtitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguageSubtitle;

  /// No description provided for @chooseLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguageTitle;

  /// No description provided for @languageChangedMessage.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String languageChangedMessage(String language);

  /// No description provided for @preferenceSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Preference saved'**
  String get preferenceSavedMessage;

  /// No description provided for @supportSection.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportSection;

  /// No description provided for @helpSection.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpSection;

  /// No description provided for @faqLabel.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faqLabel;

  /// No description provided for @faqSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Questions about timer, goals and groups'**
  String get faqSettingsSubtitle;

  /// No description provided for @sendFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get sendFeedbackTitle;

  /// No description provided for @sendFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us what could be better'**
  String get sendFeedbackSubtitle;

  /// No description provided for @feedbackUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Feedback is not available yet'**
  String get feedbackUnavailable;

  /// No description provided for @aboutLabel.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutLabel;

  /// No description provided for @aboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSection;

  /// No description provided for @appVersionValue.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersionValue(String version);

  /// No description provided for @debugEnvironmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get debugEnvironmentTitle;

  /// No description provided for @debugEnvironmentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Debug · sample data active'**
  String get debugEnvironmentSubtitle;

  /// No description provided for @appVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'{appTitle} v{appVersion}'**
  String appVersionLabel(String appTitle, String appVersion);

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @sessionSection.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get sessionSection;

  /// No description provided for @logOutLabel.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOutLabel;

  /// No description provided for @logOutSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'End the session on this device'**
  String get logOutSettingsSubtitle;

  /// No description provided for @logOutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logOutDialogTitle;

  /// No description provided for @logOutDialogContent.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to access this account on this device. Your local study data will be kept.'**
  String get logOutDialogContent;

  /// No description provided for @logOutConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOutConfirmButton;

  /// No description provided for @myProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfileTitle;

  /// No description provided for @avatarLabel.
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get avatarLabel;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @yourNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourNameHint;

  /// No description provided for @nicknameLabel.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nicknameLabel;

  /// No description provided for @nicknameHint.
  ///
  /// In en, this message translates to:
  /// **'What friends call you'**
  String get nicknameHint;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @optionalHint.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optionalHint;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneLabel;

  /// No description provided for @themeColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme color'**
  String get themeColorLabel;

  /// No description provided for @saveChangesButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChangesButton;

  /// No description provided for @profileSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSavedMessage;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faqTitle;

  /// No description provided for @faqQ1.
  ///
  /// In en, this message translates to:
  /// **'How does the study timer work?'**
  String get faqQ1;

  /// No description provided for @faqA1.
  ///
  /// In en, this message translates to:
  /// **'Pick a subject, tap play, and the timer tracks your current session while adding it to that subject\'s total time. Tap pause any time to stop and save your progress.'**
  String get faqA1;

  /// No description provided for @faqQ2.
  ///
  /// In en, this message translates to:
  /// **'What is the break countdown?'**
  String get faqQ2;

  /// No description provided for @faqA2.
  ///
  /// In en, this message translates to:
  /// **'Each session follows a classic Pomodoro cycle: a 25 minute countdown to your next break. When it reaches zero it simply resets, it\'s a reminder, not a hard stop.'**
  String get faqA2;

  /// No description provided for @faqQ3.
  ///
  /// In en, this message translates to:
  /// **'How do I add a new subject?'**
  String get faqQ3;

  /// No description provided for @faqA3.
  ///
  /// In en, this message translates to:
  /// **'Open a category from Home, then tap \"Add Subject\" at the bottom of the list. You can pick a color and set an estimated hours goal for it.'**
  String get faqA3;

  /// No description provided for @faqQ4.
  ///
  /// In en, this message translates to:
  /// **'How are groups and the leaderboard calculated?'**
  String get faqQ4;

  /// No description provided for @faqA4.
  ///
  /// In en, this message translates to:
  /// **'Groups show a scoreboard based on the group\'s theme: focus hours, completed goal days or pages read. Switch between Today, Week and Month to compare progress.'**
  String get faqA4;

  /// No description provided for @faqQ5.
  ///
  /// In en, this message translates to:
  /// **'Can I change the app\'s color theme?'**
  String get faqQ5;

  /// No description provided for @faqA5.
  ///
  /// In en, this message translates to:
  /// **'Yes, go to Settings > My Profile and pick any theme color. Every gradient, button and highlight across the app updates to match it, including dark mode.'**
  String get faqA5;

  /// No description provided for @createGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get createGroupTitle;

  /// No description provided for @createGroupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a theme and invite friends'**
  String get createGroupSubtitle;

  /// No description provided for @groupNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupNameLabel;

  /// No description provided for @groupNameHint.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupNameHint;

  /// No description provided for @groupNameExampleHint.
  ///
  /// In en, this message translates to:
  /// **'Ex.: Exam study crew'**
  String get groupNameExampleHint;

  /// No description provided for @groupThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get groupThemeLabel;

  /// No description provided for @groupThemeSelectedDescription.
  ///
  /// In en, this message translates to:
  /// **'This group ranks by {metric}.'**
  String groupThemeSelectedDescription(String metric);

  /// No description provided for @inviteFriendsLabel.
  ///
  /// In en, this message translates to:
  /// **'Invite friends'**
  String get inviteFriendsLabel;

  /// No description provided for @selectedFriendsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedFriendsCount(int count);

  /// No description provided for @selectAtLeastOneFriend.
  ///
  /// In en, this message translates to:
  /// **'Select at least 1 friend'**
  String get selectAtLeastOneFriend;

  /// No description provided for @searchFriendHint.
  ///
  /// In en, this message translates to:
  /// **'Search friend'**
  String get searchFriendHint;

  /// No description provided for @loadingFriends.
  ///
  /// In en, this message translates to:
  /// **'Loading friends...'**
  String get loadingFriends;

  /// No description provided for @friendsLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load friends'**
  String get friendsLoadErrorTitle;

  /// No description provided for @friendsLoadErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'Try again in a moment.'**
  String get friendsLoadErrorDescription;

  /// No description provided for @noFriendsAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'No friends available'**
  String get noFriendsAvailableTitle;

  /// No description provided for @noFriendsAvailableDescription.
  ///
  /// In en, this message translates to:
  /// **'Add friends before creating a group.'**
  String get noFriendsAvailableDescription;

  /// No description provided for @noFriendsFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No friend found'**
  String get noFriendsFoundTitle;

  /// No description provided for @noFriendsFoundDescription.
  ///
  /// In en, this message translates to:
  /// **'Try another name.'**
  String get noFriendsFoundDescription;

  /// No description provided for @createGroupButton.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get createGroupButton;

  /// No description provided for @createGroupMissingName.
  ///
  /// In en, this message translates to:
  /// **'Enter the group name'**
  String get createGroupMissingName;

  /// No description provided for @createGroupMissingTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose a theme'**
  String get createGroupMissingTheme;

  /// No description provided for @createGroupMissingFriends.
  ///
  /// In en, this message translates to:
  /// **'Select at least 1 friend'**
  String get createGroupMissingFriends;

  /// No description provided for @createGroupWithFriendsButton.
  ///
  /// In en, this message translates to:
  /// **'Create group with {count} friends'**
  String createGroupWithFriendsButton(int count);

  /// No description provided for @createGroupRequirementsTitle.
  ///
  /// In en, this message translates to:
  /// **'To create:'**
  String get createGroupRequirementsTitle;

  /// No description provided for @createGroupRequirementName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get createGroupRequirementName;

  /// No description provided for @createGroupRequirementTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme chosen'**
  String get createGroupRequirementTheme;

  /// No description provided for @createGroupRequirementFriends.
  ///
  /// In en, this message translates to:
  /// **'At least 1 friend'**
  String get createGroupRequirementFriends;

  /// No description provided for @groupPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your friends will only see your name, avatar and progress in this theme.'**
  String get groupPrivacyNote;

  /// No description provided for @metricDaysValue.
  ///
  /// In en, this message translates to:
  /// **'{value} days'**
  String metricDaysValue(int value);

  /// No description provided for @metricPagesValue.
  ///
  /// In en, this message translates to:
  /// **'{value} pages'**
  String metricPagesValue(int value);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get navGroups;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @myScheduleCardTitle.
  ///
  /// In en, this message translates to:
  /// **'My Schedule'**
  String get myScheduleCardTitle;

  /// No description provided for @myScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'My Schedule'**
  String get myScheduleTitle;

  /// No description provided for @noScheduleYet.
  ///
  /// In en, this message translates to:
  /// **'No schedule yet'**
  String get noScheduleYet;

  /// No description provided for @noScheduleYetDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to add\nyour first schedule'**
  String get noScheduleYetDescription;

  /// No description provided for @addScheduleEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Schedule Entry'**
  String get addScheduleEntryTitle;

  /// No description provided for @addScheduleEntryButton.
  ///
  /// In en, this message translates to:
  /// **'Add Entry'**
  String get addScheduleEntryButton;

  /// No description provided for @scheduleInfoSection.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get scheduleInfoSection;

  /// No description provided for @scheduleWhenSection.
  ///
  /// In en, this message translates to:
  /// **'When?'**
  String get scheduleWhenSection;

  /// No description provided for @scheduleColorSection.
  ///
  /// In en, this message translates to:
  /// **'Schedule color'**
  String get scheduleColorSection;

  /// No description provided for @schedulePreviewSection.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get schedulePreviewSection;

  /// No description provided for @scheduleDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration: {duration}'**
  String scheduleDurationLabel(String duration);

  /// No description provided for @scheduleDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String scheduleDurationMinutes(int minutes);

  /// No description provided for @scheduleDurationHours.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String scheduleDurationHours(int hours);

  /// No description provided for @scheduleDurationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes} min'**
  String scheduleDurationHoursMinutes(int hours, int minutes);

  /// No description provided for @scheduleTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get scheduleTitleHint;

  /// No description provided for @startTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get startTimeLabel;

  /// No description provided for @endTimeOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get endTimeOptionalLabel;

  /// No description provided for @incompleteScheduleEntryError.
  ///
  /// In en, this message translates to:
  /// **'Incomplete entry — fill in the title, start time and end time.'**
  String get incompleteScheduleEntryError;

  /// No description provided for @endTimeBeforeStartError.
  ///
  /// In en, this message translates to:
  /// **'End time must be later than the start time.'**
  String get endTimeBeforeStartError;

  /// No description provided for @nameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name first.'**
  String get nameRequiredError;

  /// No description provided for @groupThemeRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Pick a theme for your group.'**
  String get groupThemeRequiredError;

  /// No description provided for @groupNeedsFriendError.
  ///
  /// In en, this message translates to:
  /// **'Invite at least one friend — a group can\'t be created alone.'**
  String get groupNeedsFriendError;

  /// No description provided for @continueWithGoogleButton.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogleButton;

  /// No description provided for @continueWithAppleButton.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithAppleButton;

  /// No description provided for @continueWithPhoneButton.
  ///
  /// In en, this message translates to:
  /// **'Continue with phone number'**
  String get continueWithPhoneButton;

  /// No description provided for @phoneLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Your number'**
  String get phoneLoginTitle;

  /// No description provided for @phoneLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to receive an access code.'**
  String get phoneLoginSubtitle;

  /// No description provided for @sendCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCodeButton;

  /// No description provided for @phoneSecurityNote.
  ///
  /// In en, this message translates to:
  /// **'You can use your number to sign in securely.'**
  String get phoneSecurityNote;

  /// No description provided for @selectCountryTitle.
  ///
  /// In en, this message translates to:
  /// **'Select your country'**
  String get selectCountryTitle;

  /// No description provided for @searchCountryHint.
  ///
  /// In en, this message translates to:
  /// **'Search country'**
  String get searchCountryHint;

  /// No description provided for @otpCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'Code expired. Resend to get a new one.'**
  String get otpCodeExpired;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your number'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code we sent to {phone}.'**
  String otpSubtitle(String phone);

  /// No description provided for @verifyCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyCodeButton;

  /// No description provided for @resendCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCodeButton;

  /// No description provided for @otpCodeValidFor.
  ///
  /// In en, this message translates to:
  /// **'Code valid for {time}'**
  String otpCodeValidFor(String time);

  /// No description provided for @codeResentMessage.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent'**
  String get codeResentMessage;

  /// No description provided for @invalidCodeError.
  ///
  /// In en, this message translates to:
  /// **'Invalid code. Please try again.'**
  String get invalidCodeError;

  /// No description provided for @credentialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your profile'**
  String get credentialsTitle;

  /// No description provided for @credentialsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us a bit about yourself to personalize your experience.'**
  String get credentialsSubtitle;

  /// No description provided for @birthDateHint.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get birthDateHint;

  /// No description provided for @profileEditableLaterNote.
  ///
  /// In en, this message translates to:
  /// **'You can edit this later.'**
  String get profileEditableLaterNote;

  /// No description provided for @finishButton.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finishButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
