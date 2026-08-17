import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
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
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Timing'**
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
  /// **'No appointments today'**
  String get homeNextScheduleEmpty;

  /// No description provided for @homeNextScheduleAdd.
  ///
  /// In en, this message translates to:
  /// **'Add appointment'**
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
  /// **'Duration in minutes'**
  String get estimatedHoursGoalHint;

  /// No description provided for @createSubjectTotalHoursGoalHint.
  ///
  /// In en, this message translates to:
  /// **'Total time in hours'**
  String get createSubjectTotalHoursGoalHint;

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
  /// **'Duration of each section'**
  String get createSubjectTimeGoalLabel;

  /// No description provided for @createSubjectTotalTimeGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'How long do you want to study in total?'**
  String get createSubjectTotalTimeGoalLabel;

  /// No description provided for @createSubjectTotalTimeGoalLabelStudying.
  ///
  /// In en, this message translates to:
  /// **'How long do you want to study in total?'**
  String get createSubjectTotalTimeGoalLabelStudying;

  /// No description provided for @createSubjectTotalTimeGoalLabelExercises.
  ///
  /// In en, this message translates to:
  /// **'How long do you want to exercise in total?'**
  String get createSubjectTotalTimeGoalLabelExercises;

  /// No description provided for @createSubjectTotalTimeGoalLabelHobbies.
  ///
  /// In en, this message translates to:
  /// **'How long do you want to practice in total?'**
  String get createSubjectTotalTimeGoalLabelHobbies;

  /// No description provided for @createSubjectPagesGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Page goal'**
  String get createSubjectPagesGoalLabel;

  /// No description provided for @createSubjectTimeGoalHelp.
  ///
  /// In en, this message translates to:
  /// **'How many minutes do you want to focus?'**
  String get createSubjectTimeGoalHelp;

  /// No description provided for @createSubjectPagesGoalHelp.
  ///
  /// In en, this message translates to:
  /// **'How many pages do you want to log in total?'**
  String get createSubjectPagesGoalHelp;

  /// No description provided for @createSubjectRestLabel.
  ///
  /// In en, this message translates to:
  /// **'Break duration'**
  String get createSubjectRestLabel;

  /// No description provided for @createSubjectRestHelp.
  ///
  /// In en, this message translates to:
  /// **'The timer suggests a break after 30 min of focus.'**
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
  /// **'{hours}h {minutes} min'**
  String createSubjectHoursMinutesValue(int hours, int minutes);

  /// No description provided for @createSubjectPagesValue.
  ///
  /// In en, this message translates to:
  /// **'{value} pages'**
  String createSubjectPagesValue(int value);

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
  /// **'Set a valid focus goal'**
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

  /// No description provided for @addNotesPageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add page'**
  String get addNotesPageTooltip;

  /// No description provided for @notesPageCounter.
  ///
  /// In en, this message translates to:
  /// **'Page {currentPage} of {pageCount}'**
  String notesPageCounter(int currentPage, int pageCount);

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
  /// **'Start a session, log some reading or set a goal from Home to track your evolution in Timing.'**
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

  /// No description provided for @profileAchievementFirstUnlocked.
  ///
  /// In en, this message translates to:
  /// **'1st achievement'**
  String get profileAchievementFirstUnlocked;

  /// No description provided for @profileAchievementGoalStarted.
  ///
  /// In en, this message translates to:
  /// **'Goal started'**
  String get profileAchievementGoalStarted;

  /// No description provided for @profileAchievementsStartHint.
  ///
  /// In en, this message translates to:
  /// **'Start to earn achievements'**
  String get profileAchievementsStartHint;

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

  /// No description provided for @periodFiveDays.
  ///
  /// In en, this message translates to:
  /// **'5 days'**
  String get periodFiveDays;

  /// No description provided for @periodWeek.
  ///
  /// In en, this message translates to:
  /// **'1 week'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In en, this message translates to:
  /// **'1 month'**
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

  /// No description provided for @automaticLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get automaticLanguageLabel;

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

  /// No description provided for @linkedAccountsSection.
  ///
  /// In en, this message translates to:
  /// **'Connected sign-ins'**
  String get linkedAccountsSection;

  /// No description provided for @linkedAccountsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use Google and Apple to access this same account.'**
  String get linkedAccountsSubtitle;

  /// No description provided for @linkGoogleAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Link Google'**
  String get linkGoogleAccountTitle;

  /// No description provided for @linkGoogleAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google on this account'**
  String get linkGoogleAccountSubtitle;

  /// No description provided for @linkAppleAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Link Apple'**
  String get linkAppleAccountTitle;

  /// No description provided for @linkAppleAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple on this account'**
  String get linkAppleAccountSubtitle;

  /// No description provided for @authProviderConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get authProviderConnected;

  /// No description provided for @linkAuthProviderStarted.
  ///
  /// In en, this message translates to:
  /// **'Finish sign-in to link the account.'**
  String get linkAuthProviderStarted;

  /// No description provided for @linkAuthProviderFailure.
  ///
  /// In en, this message translates to:
  /// **'Could not start account linking. Check the provider and manual linking in Supabase.'**
  String get linkAuthProviderFailure;

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

  /// No description provided for @profilePhotoSelectLabel.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get profilePhotoSelectLabel;

  /// No description provided for @profilePhotoRemoveLabel.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get profilePhotoRemoveLabel;

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
  /// **'Each session follows a focus cycle: a 30 minute countdown to your next break. When it reaches zero it simply resets, it\'s a reminder, not a hard stop.'**
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
  /// **'No appointments yet'**
  String get noScheduleYet;

  /// No description provided for @noScheduleYetDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to add\nyour first appointment'**
  String get noScheduleYetDescription;

  /// No description provided for @addScheduleEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Appointment'**
  String get addScheduleEntryTitle;

  /// No description provided for @addScheduleEntryButton.
  ///
  /// In en, this message translates to:
  /// **'Add Appointment'**
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
  /// **'Appointment color'**
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

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// No description provided for @progressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything you have done so far'**
  String get progressSubtitle;

  /// No description provided for @progressPeriodDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get progressPeriodDay;

  /// No description provided for @progressPeriodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get progressPeriodWeek;

  /// No description provided for @progressPeriodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get progressPeriodMonth;

  /// No description provided for @progressFocusResultLabel.
  ///
  /// In en, this message translates to:
  /// **'Focus in this period'**
  String get progressFocusResultLabel;

  /// No description provided for @progressComparisonMore.
  ///
  /// In en, this message translates to:
  /// **'{value} more than the previous period'**
  String progressComparisonMore(String value);

  /// No description provided for @progressComparisonLess.
  ///
  /// In en, this message translates to:
  /// **'{value} less than the previous period'**
  String progressComparisonLess(String value);

  /// No description provided for @progressComparisonSame.
  ///
  /// In en, this message translates to:
  /// **'Same as the previous period'**
  String get progressComparisonSame;

  /// No description provided for @progressComparisonFirst.
  ///
  /// In en, this message translates to:
  /// **'Your first data for this period'**
  String get progressComparisonFirst;

  /// No description provided for @progressStatExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get progressStatExercises;

  /// No description provided for @progressStatLongestGoal.
  ///
  /// In en, this message translates to:
  /// **'Longest goal'**
  String get progressStatLongestGoal;

  /// No description provided for @progressStatMainReading.
  ///
  /// In en, this message translates to:
  /// **'Main reading'**
  String get progressStatMainReading;

  /// No description provided for @progressStatGoalsDone.
  ///
  /// In en, this message translates to:
  /// **'Goals done'**
  String get progressStatGoalsDone;

  /// No description provided for @progressDistributionTitle.
  ///
  /// In en, this message translates to:
  /// **'By activity'**
  String get progressDistributionTitle;

  /// No description provided for @homeTodayInline.
  ///
  /// In en, this message translates to:
  /// **'Today: {focus} focus · {pages} pages · {goals} goals'**
  String homeTodayInline(String focus, int pages, int goals);

  /// No description provided for @homePlanDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan my day'**
  String get homePlanDayTitle;

  /// No description provided for @homePlanDaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily goals and weekly schedule'**
  String get homePlanDaySubtitle;

  /// No description provided for @groupsFriendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get groupsFriendsTitle;

  /// No description provided for @groupsFriendsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Requests, invites and your code'**
  String get groupsFriendsSubtitle;

  /// No description provided for @groupMembersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}}'**
  String groupMembersCount(int count);

  /// No description provided for @createScheduleEntryButton.
  ///
  /// In en, this message translates to:
  /// **'Create appointment'**
  String get createScheduleEntryButton;

  /// No description provided for @scheduleEntryMissingFields.
  ///
  /// In en, this message translates to:
  /// **'Fill in the title, start and end time to continue'**
  String get scheduleEntryMissingFields;

  /// No description provided for @timerSessionCounter.
  ///
  /// In en, this message translates to:
  /// **'Focus {current} of {total}'**
  String timerSessionCounter(int current, int total);

  /// No description provided for @timerExitBackToFocus.
  ///
  /// In en, this message translates to:
  /// **'Back to focus'**
  String get timerExitBackToFocus;

  /// No description provided for @timerExitSaveAndEnd.
  ///
  /// In en, this message translates to:
  /// **'Save and end'**
  String get timerExitSaveAndEnd;

  /// No description provided for @notesSavedNow.
  ///
  /// In en, this message translates to:
  /// **'Saved just now'**
  String get notesSavedNow;

  /// No description provided for @notesSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get notesSaving;

  /// No description provided for @dailyGoalsPendingSection.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get dailyGoalsPendingSection;

  /// No description provided for @dailyGoalsCompletedSection.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get dailyGoalsCompletedSection;

  /// No description provided for @dailyGoalsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No goals for today yet'**
  String get dailyGoalsEmptyTitle;

  /// No description provided for @dailyGoalsEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Write a goal above or pick one of the suggestions to start your day.'**
  String get dailyGoalsEmptyDescription;

  /// No description provided for @achievementProgressValue.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String achievementProgressValue(String current, String total);

  /// No description provided for @categoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get categoryEmptyTitle;

  /// No description provided for @categoryEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Create your first item to start tracking focus time.'**
  String get categoryEmptyDescription;

  /// No description provided for @scheduleEmptyExampleLabel.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get scheduleEmptyExampleLabel;

  /// No description provided for @progressAchievementsNextTitle.
  ///
  /// In en, this message translates to:
  /// **'Next achievement'**
  String get progressAchievementsNextTitle;

  /// No description provided for @achievementFocusHourTitle.
  ///
  /// In en, this message translates to:
  /// **'1 hour of focus'**
  String get achievementFocusHourTitle;

  /// No description provided for @achievementSessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'5 completed sessions'**
  String get achievementSessionsTitle;

  /// No description provided for @achievementStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'7-day streak'**
  String get achievementStreakTitle;

  /// No description provided for @achievementReaderTitle.
  ///
  /// In en, this message translates to:
  /// **'100 pages read'**
  String get achievementReaderTitle;

  /// No description provided for @achievementGoalStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'First goal started'**
  String get achievementGoalStartedTitle;

  /// No description provided for @unitMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'{value} min'**
  String unitMinutesShort(int value);

  /// No description provided for @unitSessions.
  ///
  /// In en, this message translates to:
  /// **'{value} sessions'**
  String unitSessions(int value);

  /// No description provided for @unitDays.
  ///
  /// In en, this message translates to:
  /// **'{value} days'**
  String unitDays(int value);

  /// No description provided for @currentUserRankNextStepNamed.
  ///
  /// In en, this message translates to:
  /// **'{score} to reach {name}'**
  String currentUserRankNextStepNamed(String score, String name);

  /// No description provided for @timerKeepAwakeNote.
  ///
  /// In en, this message translates to:
  /// **'The screen stays on during the session'**
  String get timerKeepAwakeNote;

  /// No description provided for @scheduleWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'Week of {date}'**
  String scheduleWeekLabel(String date);

  /// No description provided for @daysSuffix.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysSuffix;

  /// No description provided for @createTaskSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a daily goal and keep track of your progress'**
  String get createTaskSubtitle;

  /// No description provided for @createTaskSequenceTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Sequence type'**
  String get createTaskSequenceTypeLabel;

  /// No description provided for @createTaskSequenceIntenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Intense'**
  String get createTaskSequenceIntenseLabel;

  /// No description provided for @createTaskSequenceIntenseDescription.
  ///
  /// In en, this message translates to:
  /// **'No misses. If you lose one day, your sequence resets.'**
  String get createTaskSequenceIntenseDescription;

  /// No description provided for @createTaskSequenceCasualLabel.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get createTaskSequenceCasualLabel;

  /// No description provided for @createTaskSequenceCasualDescription.
  ///
  /// In en, this message translates to:
  /// **'More flexible. Missed days do not reset your sequence.'**
  String get createTaskSequenceCasualDescription;

  /// No description provided for @targetDaysInfinite.
  ///
  /// In en, this message translates to:
  /// **'Infinite'**
  String get targetDaysInfinite;

  /// No description provided for @deleteConfirmationDefaultTypeName.
  ///
  /// In en, this message translates to:
  /// **'item'**
  String get deleteConfirmationDefaultTypeName;

  /// No description provided for @deleteConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {typeName}?'**
  String deleteConfirmationTitle(String typeName);

  /// No description provided for @deleteConfirmationContent.
  ///
  /// In en, this message translates to:
  /// **'You are about to delete \"{itemName}\". This action cannot be undone.'**
  String deleteConfirmationContent(String itemName);

  /// No description provided for @deleteConfirmationHistoryWarning.
  ///
  /// In en, this message translates to:
  /// **'This {typeName} history will also be removed.'**
  String deleteConfirmationHistoryWarning(String typeName);

  /// No description provided for @homeDaySummaryFocusValue.
  ///
  /// In en, this message translates to:
  /// **'{focus} focus'**
  String homeDaySummaryFocusValue(String focus);

  /// No description provided for @homeDaySummaryGoalsValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 goal} other{{count} goals}}'**
  String homeDaySummaryGoalsValue(int count);

  /// No description provided for @profilePhotoSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhotoSourceTitle;

  /// No description provided for @profilePhotoSourceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to update your photo'**
  String get profilePhotoSourceSubtitle;

  /// No description provided for @photoCameraLabel.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get photoCameraLabel;

  /// No description provided for @photoGalleryLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get photoGalleryLabel;

  /// No description provided for @removePhotoDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove photo?'**
  String get removePhotoDialogTitle;

  /// No description provided for @removePhotoDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Your avatar will show on the profile again.'**
  String get removePhotoDialogContent;

  /// No description provided for @friendRequestsReceivedTab.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get friendRequestsReceivedTab;

  /// No description provided for @friendRequestsSentTab.
  ///
  /// In en, this message translates to:
  /// **'Invites'**
  String get friendRequestsSentTab;

  /// No description provided for @hobbyPracticeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min of practice'**
  String hobbyPracticeMinutes(int minutes);

  /// No description provided for @hobbyViewStatistics.
  ///
  /// In en, this message translates to:
  /// **'View statistics'**
  String get hobbyViewStatistics;

  /// No description provided for @hobbyEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit hobby'**
  String get hobbyEdit;

  /// No description provided for @pinToStart.
  ///
  /// In en, this message translates to:
  /// **'Pin to start'**
  String get pinToStart;

  /// No description provided for @hobbyDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete hobby'**
  String get hobbyDelete;

  /// No description provided for @deleteActionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteActionCannotBeUndone;

  /// No description provided for @joinGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Join group'**
  String get joinGroupTitle;

  /// No description provided for @joinGroupInviteCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get joinGroupInviteCodeLabel;

  /// No description provided for @joinGroupCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get joinGroupCodeHint;

  /// No description provided for @joinGroupButton.
  ///
  /// In en, this message translates to:
  /// **'Join group'**
  String get joinGroupButton;

  /// No description provided for @joinGroupError.
  ///
  /// In en, this message translates to:
  /// **'Could not join this group.'**
  String get joinGroupError;

  /// No description provided for @scheduleDayEventsTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule for the day'**
  String get scheduleDayEventsTitle;

  /// No description provided for @dailyGoalsNoGoalsYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No goals yet'**
  String get dailyGoalsNoGoalsYetTitle;

  /// No description provided for @dailyGoalsNoGoalsYetDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your first goal to organize the day and track your wins.'**
  String get dailyGoalsNoGoalsYetDescription;

  /// No description provided for @dailyGoalsSuggestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggestions to start'**
  String get dailyGoalsSuggestionsTitle;

  /// No description provided for @dailyGoalsSuggestionStudy.
  ///
  /// In en, this message translates to:
  /// **'Study 30 min'**
  String get dailyGoalsSuggestionStudy;

  /// No description provided for @dailyGoalsSuggestionRead.
  ///
  /// In en, this message translates to:
  /// **'Read 10 pages'**
  String get dailyGoalsSuggestionRead;

  /// No description provided for @dailyGoalsSuggestionTrain.
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get dailyGoalsSuggestionTrain;

  /// No description provided for @goalTypeName.
  ///
  /// In en, this message translates to:
  /// **'goal'**
  String get goalTypeName;

  /// No description provided for @missedYesterdayDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Did you complete it yesterday?'**
  String get missedYesterdayDialogTitle;

  /// No description provided for @missedYesterdayDialogContent.
  ///
  /// In en, this message translates to:
  /// **'You did not register \"{taskName}\" yesterday. Did you really miss it?'**
  String missedYesterdayDialogContent(String taskName);

  /// No description provided for @missedYesterdayMissedButton.
  ///
  /// In en, this message translates to:
  /// **'Yes, I missed it'**
  String get missedYesterdayMissedButton;

  /// No description provided for @missedYesterdayCompletedButton.
  ///
  /// In en, this message translates to:
  /// **'I completed it'**
  String get missedYesterdayCompletedButton;

  /// No description provided for @scheduleTitleRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Fill in the title to continue'**
  String get scheduleTitleRequiredError;

  /// No description provided for @scheduleActiveFromLabel.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get scheduleActiveFromLabel;

  /// No description provided for @scheduleActiveUntilLabel.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get scheduleActiveUntilLabel;

  /// No description provided for @selectDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDateTitle;

  /// No description provided for @selectDateHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a day in the calendar'**
  String get selectDateHint;

  /// No description provided for @addFriendTitle.
  ///
  /// In en, this message translates to:
  /// **'Add friend'**
  String get addFriendTitle;

  /// No description provided for @friendCodeNotFound.
  ///
  /// In en, this message translates to:
  /// **'We could not find a user with this code.'**
  String get friendCodeNotFound;

  /// No description provided for @friendInviteCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get friendInviteCodeTitle;

  /// No description provided for @friendInviteCodeFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Type or paste the code'**
  String get friendInviteCodeFieldLabel;

  /// No description provided for @friendInviteCodeFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Like ABCDE12345'**
  String get friendInviteCodeFieldHint;

  /// No description provided for @pasteButton.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get pasteButton;

  /// No description provided for @searchCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Search code'**
  String get searchCodeButton;

  /// No description provided for @friendUserFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'User found'**
  String get friendUserFoundTitle;

  /// No description provided for @friendFoundByCode.
  ///
  /// In en, this message translates to:
  /// **'Found by code'**
  String get friendFoundByCode;

  /// No description provided for @sentLabel.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sentLabel;

  /// No description provided for @friendHowItWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get friendHowItWorksTitle;

  /// No description provided for @friendHowItWorksStepOne.
  ///
  /// In en, this message translates to:
  /// **'Ask your friend for their code'**
  String get friendHowItWorksStepOne;

  /// No description provided for @friendHowItWorksStepTwo.
  ///
  /// In en, this message translates to:
  /// **'Paste the code to find the profile'**
  String get friendHowItWorksStepTwo;

  /// No description provided for @friendHowItWorksStepThree.
  ///
  /// In en, this message translates to:
  /// **'Send the request to add them'**
  String get friendHowItWorksStepThree;

  /// No description provided for @myCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'My code'**
  String get myCodeLabel;

  /// No description provided for @yourInviteCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Your invite code'**
  String get yourInviteCodeLabel;

  /// No description provided for @yourFriendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your friends ({count})'**
  String yourFriendsTitle(int count);

  /// No description provided for @seeAllButton.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get seeAllButton;

  /// No description provided for @onlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get onlineLabel;

  /// No description provided for @minutesAgoShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String minutesAgoShort(int minutes);

  /// No description provided for @friendsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You do not have friends yet'**
  String get friendsEmptyTitle;

  /// No description provided for @friendsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search people above or share your invite code.'**
  String get friendsEmptySubtitle;

  /// No description provided for @shareCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Share code'**
  String get shareCodeButton;

  /// No description provided for @codeCopiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get codeCopiedMessage;

  /// No description provided for @friendRequestSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get friendRequestSentMessage;

  /// No description provided for @joinedGroupMessage.
  ///
  /// In en, this message translates to:
  /// **'You joined the group'**
  String get joinedGroupMessage;

  /// No description provided for @friendTypeName.
  ///
  /// In en, this message translates to:
  /// **'friend'**
  String get friendTypeName;

  /// No description provided for @shareInviteCodeMessage.
  ///
  /// In en, this message translates to:
  /// **'Add me on Timing with my code: {code}'**
  String shareInviteCodeMessage(String code);

  /// No description provided for @groupInvitesTitle.
  ///
  /// In en, this message translates to:
  /// **'Group invites ({count})'**
  String groupInvitesTitle(int count);

  /// No description provided for @groupInvitedBy.
  ///
  /// In en, this message translates to:
  /// **'{inviter} invited you'**
  String groupInvitedBy(String inviter);

  /// No description provided for @acceptButton.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptButton;

  /// No description provided for @declineButton.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get declineButton;

  /// No description provided for @friendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friendsTitle;

  /// No description provided for @friendRequestsReceivedPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get friendRequestsReceivedPageTitle;

  /// No description provided for @friendRequestsSentPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Invites'**
  String get friendRequestsSentPageTitle;

  /// No description provided for @friendRequestsReceivedSection.
  ///
  /// In en, this message translates to:
  /// **'Received ({count})'**
  String friendRequestsReceivedSection(int count);

  /// No description provided for @friendRequestsSentSection.
  ///
  /// In en, this message translates to:
  /// **'Sent ({count})'**
  String friendRequestsSentSection(int count);

  /// No description provided for @friendMutualFriendsSample.
  ///
  /// In en, this message translates to:
  /// **'3 mutual friends'**
  String get friendMutualFriendsSample;

  /// No description provided for @pendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingLabel;

  /// No description provided for @friendRequestsIncomingEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No received requests'**
  String get friendRequestsIncomingEmptyTitle;

  /// No description provided for @friendRequestsSentEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No sent invites'**
  String get friendRequestsSentEmptyTitle;

  /// No description provided for @friendRequestsIncomingEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Requests will appear here.'**
  String get friendRequestsIncomingEmptySubtitle;

  /// No description provided for @friendRequestsSentEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your sent invites will appear here.'**
  String get friendRequestsSentEmptySubtitle;

  /// No description provided for @friendRequestsSafetyNotice.
  ///
  /// In en, this message translates to:
  /// **'Only accept people you know and trust.'**
  String get friendRequestsSafetyNotice;

  /// No description provided for @categoryEmptyStudyingTitle.
  ///
  /// In en, this message translates to:
  /// **'No subject yet'**
  String get categoryEmptyStudyingTitle;

  /// No description provided for @categoryEmptyExercisesTitle.
  ///
  /// In en, this message translates to:
  /// **'No exercise yet'**
  String get categoryEmptyExercisesTitle;

  /// No description provided for @categoryEmptyReadingTitle.
  ///
  /// In en, this message translates to:
  /// **'No reading yet'**
  String get categoryEmptyReadingTitle;

  /// No description provided for @categoryEmptyHobbiesTitle.
  ///
  /// In en, this message translates to:
  /// **'No hobby yet'**
  String get categoryEmptyHobbiesTitle;

  /// No description provided for @categoryEmptyStudyingDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your first subject to organize your studies and log focus.'**
  String get categoryEmptyStudyingDescription;

  /// No description provided for @categoryEmptyExercisesDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your first exercise to track workouts, sessions and progress.'**
  String get categoryEmptyExercisesDescription;

  /// No description provided for @categoryEmptyReadingDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your first reading item to track pages, time and progress.'**
  String get categoryEmptyReadingDescription;

  /// No description provided for @categoryEmptyHobbiesDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your first hobby to log practice and keep momentum.'**
  String get categoryEmptyHobbiesDescription;

  /// No description provided for @categorySuggestionStudyingOne.
  ///
  /// In en, this message translates to:
  /// **'Math'**
  String get categorySuggestionStudyingOne;

  /// No description provided for @categorySuggestionStudyingTwo.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get categorySuggestionStudyingTwo;

  /// No description provided for @categorySuggestionStudyingThree.
  ///
  /// In en, this message translates to:
  /// **'Writing'**
  String get categorySuggestionStudyingThree;

  /// No description provided for @categorySuggestionExercisesOne.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get categorySuggestionExercisesOne;

  /// No description provided for @categorySuggestionExercisesTwo.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get categorySuggestionExercisesTwo;

  /// No description provided for @categorySuggestionExercisesThree.
  ///
  /// In en, this message translates to:
  /// **'Stretching'**
  String get categorySuggestionExercisesThree;

  /// No description provided for @categorySuggestionReadingOne.
  ///
  /// In en, this message translates to:
  /// **'Novel'**
  String get categorySuggestionReadingOne;

  /// No description provided for @categorySuggestionReadingTwo.
  ///
  /// In en, this message translates to:
  /// **'Technical'**
  String get categorySuggestionReadingTwo;

  /// No description provided for @categorySuggestionReadingThree.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get categorySuggestionReadingThree;

  /// No description provided for @categorySuggestionHobbiesOne.
  ///
  /// In en, this message translates to:
  /// **'Guitar'**
  String get categorySuggestionHobbiesOne;

  /// No description provided for @categorySuggestionHobbiesTwo.
  ///
  /// In en, this message translates to:
  /// **'Drawing'**
  String get categorySuggestionHobbiesTwo;

  /// No description provided for @categorySuggestionHobbiesThree.
  ///
  /// In en, this message translates to:
  /// **'Cooking'**
  String get categorySuggestionHobbiesThree;

  /// No description provided for @pagesAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'pgs'**
  String get pagesAbbreviation;

  /// No description provided for @loginSecurityNote.
  ///
  /// In en, this message translates to:
  /// **'Your data is protected and secure.'**
  String get loginSecurityNote;

  /// No description provided for @nextBreakDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Next break duration'**
  String get nextBreakDurationLabel;

  /// No description provided for @timerReadingExitContent.
  ///
  /// In en, this message translates to:
  /// **'You read for {duration}. Enter how many pages you read in {subjectName}.'**
  String timerReadingExitContent(String duration, String subjectName);

  /// No description provided for @appleSignInIncompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple is not complete yet.'**
  String get appleSignInIncompleteMessage;

  /// No description provided for @activityTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity type'**
  String get activityTypeLabel;

  /// No description provided for @activityTypeDailyLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get activityTypeDailyLabel;

  /// No description provided for @activityTypeDailyDescription.
  ///
  /// In en, this message translates to:
  /// **'Use focus sections with breaks and set how many sessions you want to complete each day.'**
  String get activityTypeDailyDescription;

  /// No description provided for @activityTypeDailyDescriptionStudying.
  ///
  /// In en, this message translates to:
  /// **'Use study sections with breaks and set how many sessions you want to complete each day.'**
  String get activityTypeDailyDescriptionStudying;

  /// No description provided for @activityTypeDailyDescriptionExercises.
  ///
  /// In en, this message translates to:
  /// **'Use exercise sections with breaks and set how many sessions you want to complete each day.'**
  String get activityTypeDailyDescriptionExercises;

  /// No description provided for @activityTypeDailyDescriptionHobbies.
  ///
  /// In en, this message translates to:
  /// **'Use practice sections with breaks and set how many sessions you want to complete each day.'**
  String get activityTypeDailyDescriptionHobbies;

  /// No description provided for @activityTypePermanentLabel.
  ///
  /// In en, this message translates to:
  /// **'Permanent'**
  String get activityTypePermanentLabel;

  /// No description provided for @activityTypePermanentDescription.
  ///
  /// In en, this message translates to:
  /// **'Set the total study time. The activity stays active until you complete it.'**
  String get activityTypePermanentDescription;

  /// No description provided for @activityTypePermanentDescriptionStudying.
  ///
  /// In en, this message translates to:
  /// **'Set the total study time. The activity stays active until you complete it.'**
  String get activityTypePermanentDescriptionStudying;

  /// No description provided for @activityTypePermanentDescriptionExercises.
  ///
  /// In en, this message translates to:
  /// **'Set the total exercise time. The activity stays active until you complete it.'**
  String get activityTypePermanentDescriptionExercises;

  /// No description provided for @activityTypePermanentDescriptionHobbies.
  ///
  /// In en, this message translates to:
  /// **'Set the total practice time. The activity stays active until you complete it.'**
  String get activityTypePermanentDescriptionHobbies;

  /// No description provided for @pagesSuffix.
  ///
  /// In en, this message translates to:
  /// **'pages'**
  String get pagesSuffix;

  /// No description provided for @updatedSuccessfullyMessage.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully'**
  String get updatedSuccessfullyMessage;

  /// No description provided for @focusSessionCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Number of sessions'**
  String get focusSessionCountLabel;

  /// No description provided for @subjectSectionDurationDescription.
  ///
  /// In en, this message translates to:
  /// **'How long each focus section lasts before a break or completion.'**
  String get subjectSectionDurationDescription;

  /// No description provided for @subjectSessionCountDescription.
  ///
  /// In en, this message translates to:
  /// **'How many focus sections you want to complete in a day.'**
  String get subjectSessionCountDescription;

  /// No description provided for @subjectRestDurationDescription.
  ///
  /// In en, this message translates to:
  /// **'How long each pause lasts between focus sections.'**
  String get subjectRestDurationDescription;

  /// No description provided for @groupEditingComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Group editing is coming soon.'**
  String get groupEditingComingSoon;

  /// No description provided for @leftGroupMessage.
  ///
  /// In en, this message translates to:
  /// **'You left the group.'**
  String get leftGroupMessage;

  /// No description provided for @groupImageSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Send image'**
  String get groupImageSourceTitle;

  /// No description provided for @groupImageSourceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to send the image'**
  String get groupImageSourceSubtitle;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @manageMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage members'**
  String get manageMembersTitle;

  /// No description provided for @groupLeaderLabel.
  ///
  /// In en, this message translates to:
  /// **'Leader'**
  String get groupLeaderLabel;

  /// No description provided for @groupLeaderRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Group leader'**
  String get groupLeaderRoleLabel;

  /// No description provided for @groupMemberRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get groupMemberRoleLabel;

  /// No description provided for @groupMembersLabel.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get groupMembersLabel;

  /// No description provided for @groupActionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Group actions'**
  String get groupActionsLabel;

  /// No description provided for @goalsTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get goalsTabLabel;

  /// No description provided for @chatTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTabLabel;

  /// No description provided for @groupGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Group goal'**
  String get groupGoalTitle;

  /// No description provided for @groupMainRuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Main rule'**
  String get groupMainRuleTitle;

  /// No description provided for @groupNextMilestoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Next milestone'**
  String get groupNextMilestoneTitle;

  /// No description provided for @groupMembersProgressValue.
  ///
  /// In en, this message translates to:
  /// **'{current}/{total} members'**
  String groupMembersProgressValue(int current, int total);

  /// No description provided for @groupNextMilestoneDescription.
  ///
  /// In en, this message translates to:
  /// **'to unlock the \"Total Focus\" badge'**
  String get groupNextMilestoneDescription;

  /// No description provided for @groupActivityLabel.
  ///
  /// In en, this message translates to:
  /// **'Group activity'**
  String get groupActivityLabel;

  /// No description provided for @groupActivityReachedGoal.
  ///
  /// In en, this message translates to:
  /// **'{reached}/{total} reached the goal'**
  String groupActivityReachedGoal(int reached, int total);

  /// No description provided for @groupActivityFocusDataLabel.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get groupActivityFocusDataLabel;

  /// No description provided for @groupActivityPauseDataLabel.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get groupActivityPauseDataLabel;

  /// No description provided for @groupActivitySessionsDataLabel.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get groupActivitySessionsDataLabel;

  /// No description provided for @groupActivityPendingUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending users'**
  String get groupActivityPendingUsersTitle;

  /// No description provided for @groupActivityAllCompletedToday.
  ///
  /// In en, this message translates to:
  /// **'Everyone completed the activity today.'**
  String get groupActivityAllCompletedToday;

  /// No description provided for @groupNoImagesTitle.
  ///
  /// In en, this message translates to:
  /// **'No images yet'**
  String get groupNoImagesTitle;

  /// No description provided for @groupNoImagesDescription.
  ///
  /// In en, this message translates to:
  /// **'Send the first group image.'**
  String get groupNoImagesDescription;

  /// No description provided for @groupSendImageButton.
  ///
  /// In en, this message translates to:
  /// **'Send image'**
  String get groupSendImageButton;

  /// No description provided for @groupSendingImage.
  ///
  /// In en, this message translates to:
  /// **'Sending image...'**
  String get groupSendingImage;

  /// No description provided for @editGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit group'**
  String get editGroupLabel;

  /// No description provided for @leaveGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Leave group'**
  String get leaveGroupLabel;

  /// No description provided for @groupDescription.
  ///
  /// In en, this message translates to:
  /// **'Ranking by {metric}. Keep progressing with your group.'**
  String groupDescription(String metric);

  /// No description provided for @groupsFriendsSubtitleWithCount.
  ///
  /// In en, this message translates to:
  /// **'Requests, invites and {groupCount} in groups'**
  String groupsFriendsSubtitleWithCount(int groupCount);

  /// No description provided for @groupGoalKeepMetric.
  ///
  /// In en, this message translates to:
  /// **'Keep {metric} every day'**
  String groupGoalKeepMetric(String metric);

  /// No description provided for @groupGoalDescription.
  ///
  /// In en, this message translates to:
  /// **'Each member logs {metric} to keep the group streak active.'**
  String groupGoalDescription(String metric);

  /// No description provided for @groupRuleDescription.
  ///
  /// In en, this message translates to:
  /// **'Log at least one {metric} entry per day to strengthen the group streak.'**
  String groupRuleDescription(String metric);

  /// No description provided for @joinWithCodeButton.
  ///
  /// In en, this message translates to:
  /// **'I have an invite code'**
  String get joinWithCodeButton;

  /// No description provided for @groupsBenefitsHeader.
  ///
  /// In en, this message translates to:
  /// **'In a group you can:'**
  String get groupsBenefitsHeader;

  /// No description provided for @groupParticipantsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 participant} other{{count} participants}}'**
  String groupParticipantsCount(int count);

  /// No description provided for @groupMembersCompletedToday.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} members completed today'**
  String groupMembersCompletedToday(int completed, int total);

  /// No description provided for @addMemberButton.
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get addMemberButton;

  /// No description provided for @groupCollectiveProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Collective progress'**
  String get groupCollectiveProgressTitle;

  /// No description provided for @dailyLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get dailyLabel;

  /// No description provided for @completedLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedLabel;

  /// No description provided for @groupActivityCompletedCount.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} completed'**
  String groupActivityCompletedCount(int completed, int total);

  /// No description provided for @groupMissingParticipants.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Everyone completed the goal} =1{1 participant left to complete the goal} other{{count} participants left to complete the goal}}'**
  String groupMissingParticipants(int count);

  /// No description provided for @groupParticipantsDataTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Participants (1)} other{Participants ({count})}}'**
  String groupParticipantsDataTitle(int count);

  /// No description provided for @groupCompletedMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Completed ({count})'**
  String groupCompletedMembersTitle(int count);

  /// No description provided for @groupPendingMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending ({count})'**
  String groupPendingMembersTitle(int count);

  /// No description provided for @groupNoCompletedMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'No one completed yet'**
  String get groupNoCompletedMembersTitle;

  /// No description provided for @groupNoCompletedMembersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Be the first to complete the goal!'**
  String get groupNoCompletedMembersSubtitle;

  /// No description provided for @groupStatisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Group statistics'**
  String get groupStatisticsTitle;

  /// No description provided for @groupStreakStatLabel.
  ///
  /// In en, this message translates to:
  /// **'Group streak'**
  String get groupStreakStatLabel;

  /// No description provided for @groupTodayTotalStatLabel.
  ///
  /// In en, this message translates to:
  /// **'Total time today'**
  String get groupTodayTotalStatLabel;

  /// No description provided for @groupPeriodTotalStatLabel.
  ///
  /// In en, this message translates to:
  /// **'Period total'**
  String get groupPeriodTotalStatLabel;

  /// No description provided for @groupCompletedSessionsStatLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed sessions'**
  String get groupCompletedSessionsStatLabel;

  /// No description provided for @groupParticipantsStatLabel.
  ///
  /// In en, this message translates to:
  /// **'Participant in group'**
  String get groupParticipantsStatLabel;

  /// No description provided for @currentUserRankCompleteFirstGoal.
  ///
  /// In en, this message translates to:
  /// **'Complete your first goal to enter the ranking.'**
  String get currentUserRankCompleteFirstGoal;

  /// No description provided for @currentUserRankTiedLead.
  ///
  /// In en, this message translates to:
  /// **'Tied for the lead.'**
  String get currentUserRankTiedLead;

  /// No description provided for @currentUserRankTiedFirstLabel.
  ///
  /// In en, this message translates to:
  /// **'Tied for 1st'**
  String get currentUserRankTiedFirstLabel;

  /// No description provided for @rankLabel.
  ///
  /// In en, this message translates to:
  /// **'#{rank}'**
  String rankLabel(int rank);

  /// No description provided for @homeScheduleRoutineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming schedule and weekly routine'**
  String get homeScheduleRoutineSubtitle;

  /// No description provided for @homeNextCommitmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Up next'**
  String get homeNextCommitmentTitle;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// No description provided for @studiedTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Studied time'**
  String get studiedTimeLabel;

  /// No description provided for @readingTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Reading time'**
  String get readingTimeLabel;

  /// No description provided for @totalPagesReadLabel.
  ///
  /// In en, this message translates to:
  /// **'Total pages'**
  String get totalPagesReadLabel;

  /// No description provided for @pagesReadTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Pages today'**
  String get pagesReadTodayLabel;

  /// No description provided for @goalLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goalLabel;

  /// No description provided for @sessionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessionsLabel;

  /// No description provided for @restLabel.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get restLabel;

  /// No description provided for @comparativesTitle.
  ///
  /// In en, this message translates to:
  /// **'Comparisons'**
  String get comparativesTitle;

  /// No description provided for @overviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overviewTitle;

  /// No description provided for @studiedUnit.
  ///
  /// In en, this message translates to:
  /// **'studied'**
  String get studiedUnit;

  /// No description provided for @readPagesUnit.
  ///
  /// In en, this message translates to:
  /// **'read'**
  String get readPagesUnit;

  /// No description provided for @versusLastMonth.
  ///
  /// In en, this message translates to:
  /// **'vs last month'**
  String get versusLastMonth;

  /// No description provided for @versusLastWeek.
  ///
  /// In en, this message translates to:
  /// **'vs last week'**
  String get versusLastWeek;

  /// No description provided for @noPreviousPeriodComparison.
  ///
  /// In en, this message translates to:
  /// **'No previous period to compare'**
  String get noPreviousPeriodComparison;

  /// No description provided for @noTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'No time'**
  String get noTimeLabel;

  /// No description provided for @untilTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Until {time}'**
  String untilTimeLabel(String time);

  /// No description provided for @achievementsUnlockedSuffix.
  ///
  /// In en, this message translates to:
  /// **' /50 unlocked'**
  String get achievementsUnlockedSuffix;

  /// No description provided for @currentLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Current level'**
  String get currentLevelLabel;

  /// No description provided for @allAchievementsUnlockedLabel.
  ///
  /// In en, this message translates to:
  /// **'All unlocked'**
  String get allAchievementsUnlockedLabel;

  /// No description provided for @nextUnlockLabel.
  ///
  /// In en, this message translates to:
  /// **'Next unlock'**
  String get nextUnlockLabel;

  /// No description provided for @allAchievementsUnlockedDescription.
  ///
  /// In en, this message translates to:
  /// **'You unlocked everything.'**
  String get allAchievementsUnlockedDescription;

  /// No description provided for @xpToGo.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP to go'**
  String xpToGo(int xp);

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelLabel(int level);

  /// No description provided for @allFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFilterLabel;

  /// No description provided for @unlockedFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlockedFilterLabel;

  /// No description provided for @lockedFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get lockedFilterLabel;

  /// No description provided for @selectCategoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get selectCategoryTooltip;

  /// No description provided for @allCategoriesLabel.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategoriesLabel;

  /// No description provided for @byCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get byCategoryLabel;

  /// No description provided for @allLevelsTitle.
  ///
  /// In en, this message translates to:
  /// **'All levels'**
  String get allLevelsTitle;

  /// No description provided for @allLevelsDescription.
  ///
  /// In en, this message translates to:
  /// **'Unlock achievements to climb the ranks.'**
  String get allLevelsDescription;

  /// No description provided for @levelPlusLabel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}+'**
  String levelPlusLabel(int level);

  /// No description provided for @currentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get currentLabel;

  /// No description provided for @rankTierLearner.
  ///
  /// In en, this message translates to:
  /// **'{tier} Learner'**
  String rankTierLearner(String tier);

  /// No description provided for @achievementCategoryFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get achievementCategoryFocus;

  /// No description provided for @achievementCategoryStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get achievementCategoryStudy;

  /// No description provided for @achievementCategoryReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get achievementCategoryReading;

  /// No description provided for @achievementCategoryGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get achievementCategoryGoals;

  /// No description provided for @achievementCategoryLifestyle.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle'**
  String get achievementCategoryLifestyle;

  /// No description provided for @achievement1Title.
  ///
  /// In en, this message translates to:
  /// **'First Focus'**
  String get achievement1Title;

  /// No description provided for @achievement1Description.
  ///
  /// In en, this message translates to:
  /// **'Complete your first focus session'**
  String get achievement1Description;

  /// No description provided for @achievement2Title.
  ///
  /// In en, this message translates to:
  /// **'25-Min Starter'**
  String get achievement2Title;

  /// No description provided for @achievement2Description.
  ///
  /// In en, this message translates to:
  /// **'Focus for 25 minutes'**
  String get achievement2Description;

  /// No description provided for @achievement3Title.
  ///
  /// In en, this message translates to:
  /// **'1-Hour Focus'**
  String get achievement3Title;

  /// No description provided for @achievement3Description.
  ///
  /// In en, this message translates to:
  /// **'Focus for 1 hour'**
  String get achievement3Description;

  /// No description provided for @achievement4Title.
  ///
  /// In en, this message translates to:
  /// **'Deep Work'**
  String get achievement4Title;

  /// No description provided for @achievement4Description.
  ///
  /// In en, this message translates to:
  /// **'Reach 2 hours of focus'**
  String get achievement4Description;

  /// No description provided for @achievement5Title.
  ///
  /// In en, this message translates to:
  /// **'Zero Distractions'**
  String get achievement5Title;

  /// No description provided for @achievement5Description.
  ///
  /// In en, this message translates to:
  /// **'Complete 3 focus sessions'**
  String get achievement5Description;

  /// No description provided for @achievement6Title.
  ///
  /// In en, this message translates to:
  /// **'Focus Marathon'**
  String get achievement6Title;

  /// No description provided for @achievement6Description.
  ///
  /// In en, this message translates to:
  /// **'Reach 10 hours of focus'**
  String get achievement6Description;

  /// No description provided for @achievement7Title.
  ///
  /// In en, this message translates to:
  /// **'Early Bird'**
  String get achievement7Title;

  /// No description provided for @achievement7Description.
  ///
  /// In en, this message translates to:
  /// **'Log focus on 5 days'**
  String get achievement7Description;

  /// No description provided for @achievement8Title.
  ///
  /// In en, this message translates to:
  /// **'Night Owl'**
  String get achievement8Title;

  /// No description provided for @achievement8Description.
  ///
  /// In en, this message translates to:
  /// **'Complete 10 focus sessions'**
  String get achievement8Description;

  /// No description provided for @achievement9Title.
  ///
  /// In en, this message translates to:
  /// **'Focus Streak'**
  String get achievement9Title;

  /// No description provided for @achievement9Description.
  ///
  /// In en, this message translates to:
  /// **'Log focus on 7 days'**
  String get achievement9Description;

  /// No description provided for @achievement10Title.
  ///
  /// In en, this message translates to:
  /// **'Focus Master'**
  String get achievement10Title;

  /// No description provided for @achievement10Description.
  ///
  /// In en, this message translates to:
  /// **'Reach 25 hours of focus'**
  String get achievement10Description;

  /// No description provided for @achievement11Title.
  ///
  /// In en, this message translates to:
  /// **'Study Started'**
  String get achievement11Title;

  /// No description provided for @achievement11Description.
  ///
  /// In en, this message translates to:
  /// **'Create your first study record'**
  String get achievement11Description;

  /// No description provided for @achievement12Title.
  ///
  /// In en, this message translates to:
  /// **'3 Sessions'**
  String get achievement12Title;

  /// No description provided for @achievement12Description.
  ///
  /// In en, this message translates to:
  /// **'Complete 3 sessions'**
  String get achievement12Description;

  /// No description provided for @achievement13Title.
  ///
  /// In en, this message translates to:
  /// **'5 Sessions'**
  String get achievement13Title;

  /// No description provided for @achievement13Description.
  ///
  /// In en, this message translates to:
  /// **'Complete 5 sessions'**
  String get achievement13Description;

  /// No description provided for @achievement14Title.
  ///
  /// In en, this message translates to:
  /// **'10 Sessions'**
  String get achievement14Title;

  /// No description provided for @achievement14Description.
  ///
  /// In en, this message translates to:
  /// **'Complete 10 sessions'**
  String get achievement14Description;

  /// No description provided for @achievement15Title.
  ///
  /// In en, this message translates to:
  /// **'Subject Explorer'**
  String get achievement15Title;

  /// No description provided for @achievement15Description.
  ///
  /// In en, this message translates to:
  /// **'Study at least one subject'**
  String get achievement15Description;

  /// No description provided for @achievement16Title.
  ///
  /// In en, this message translates to:
  /// **'Revision Hero'**
  String get achievement16Title;

  /// No description provided for @achievement16Description.
  ///
  /// In en, this message translates to:
  /// **'Reach 5 hours studying'**
  String get achievement16Description;

  /// No description provided for @achievement17Title.
  ///
  /// In en, this message translates to:
  /// **'Quiz Finisher'**
  String get achievement17Title;

  /// No description provided for @achievement17Description.
  ///
  /// In en, this message translates to:
  /// **'Complete 15 sessions'**
  String get achievement17Description;

  /// No description provided for @achievement18Title.
  ///
  /// In en, this message translates to:
  /// **'Study Planner'**
  String get achievement18Title;

  /// No description provided for @achievement18Description.
  ///
  /// In en, this message translates to:
  /// **'Create a focus goal'**
  String get achievement18Description;

  /// No description provided for @achievement19Title.
  ///
  /// In en, this message translates to:
  /// **'Exam Ready'**
  String get achievement19Title;

  /// No description provided for @achievement19Description.
  ///
  /// In en, this message translates to:
  /// **'Reach 20 hours studying'**
  String get achievement19Description;

  /// No description provided for @achievement20Title.
  ///
  /// In en, this message translates to:
  /// **'Scholar Mode'**
  String get achievement20Title;

  /// No description provided for @achievement20Description.
  ///
  /// In en, this message translates to:
  /// **'Reach 50 hours studying'**
  String get achievement20Description;

  /// No description provided for @achievement21Title.
  ///
  /// In en, this message translates to:
  /// **'First Page'**
  String get achievement21Title;

  /// No description provided for @achievement21Description.
  ///
  /// In en, this message translates to:
  /// **'Read your first page'**
  String get achievement21Description;

  /// No description provided for @achievement22Title.
  ///
  /// In en, this message translates to:
  /// **'10 Pages'**
  String get achievement22Title;

  /// No description provided for @achievement22Description.
  ///
  /// In en, this message translates to:
  /// **'Read 10 pages'**
  String get achievement22Description;

  /// No description provided for @achievement23Title.
  ///
  /// In en, this message translates to:
  /// **'25 Pages'**
  String get achievement23Title;

  /// No description provided for @achievement23Description.
  ///
  /// In en, this message translates to:
  /// **'Read 25 pages'**
  String get achievement23Description;

  /// No description provided for @achievement24Title.
  ///
  /// In en, this message translates to:
  /// **'50 Pages'**
  String get achievement24Title;

  /// No description provided for @achievement24Description.
  ///
  /// In en, this message translates to:
  /// **'Read 50 pages'**
  String get achievement24Description;

  /// No description provided for @achievement25Title.
  ///
  /// In en, this message translates to:
  /// **'100 Pages'**
  String get achievement25Title;

  /// No description provided for @achievement25Description.
  ///
  /// In en, this message translates to:
  /// **'Read 100 pages'**
  String get achievement25Description;

  /// No description provided for @achievement26Title.
  ///
  /// In en, this message translates to:
  /// **'Chapter Complete'**
  String get achievement26Title;

  /// No description provided for @achievement26Description.
  ///
  /// In en, this message translates to:
  /// **'Read 150 pages'**
  String get achievement26Description;

  /// No description provided for @achievement27Title.
  ///
  /// In en, this message translates to:
  /// **'Weekend Reader'**
  String get achievement27Title;

  /// No description provided for @achievement27Description.
  ///
  /// In en, this message translates to:
  /// **'Read 250 pages'**
  String get achievement27Description;

  /// No description provided for @achievement28Title.
  ///
  /// In en, this message translates to:
  /// **'Daily Reader'**
  String get achievement28Title;

  /// No description provided for @achievement28Description.
  ///
  /// In en, this message translates to:
  /// **'Read 300 pages'**
  String get achievement28Description;

  /// No description provided for @achievement29Title.
  ///
  /// In en, this message translates to:
  /// **'Bookworm'**
  String get achievement29Title;

  /// No description provided for @achievement29Description.
  ///
  /// In en, this message translates to:
  /// **'Read 500 pages'**
  String get achievement29Description;

  /// No description provided for @achievement30Title.
  ///
  /// In en, this message translates to:
  /// **'Library Legend'**
  String get achievement30Title;

  /// No description provided for @achievement30Description.
  ///
  /// In en, this message translates to:
  /// **'Read 1000 pages'**
  String get achievement30Description;

  /// No description provided for @achievement31Title.
  ///
  /// In en, this message translates to:
  /// **'First Goal'**
  String get achievement31Title;

  /// No description provided for @achievement31Description.
  ///
  /// In en, this message translates to:
  /// **'Create your first goal'**
  String get achievement31Description;

  /// No description provided for @achievement32Title.
  ///
  /// In en, this message translates to:
  /// **'Goal Crusher'**
  String get achievement32Title;

  /// No description provided for @achievement32Description.
  ///
  /// In en, this message translates to:
  /// **'Complete a goal'**
  String get achievement32Description;

  /// No description provided for @achievement33Title.
  ///
  /// In en, this message translates to:
  /// **'All Goals Done'**
  String get achievement33Title;

  /// No description provided for @achievement33Description.
  ///
  /// In en, this message translates to:
  /// **'Finish every goal today'**
  String get achievement33Description;

  /// No description provided for @achievement34Title.
  ///
  /// In en, this message translates to:
  /// **'Morning Routine'**
  String get achievement34Title;

  /// No description provided for @achievement34Description.
  ///
  /// In en, this message translates to:
  /// **'Complete goals on 3 days'**
  String get achievement34Description;

  /// No description provided for @achievement35Title.
  ///
  /// In en, this message translates to:
  /// **'Balanced Day'**
  String get achievement35Title;

  /// No description provided for @achievement35Description.
  ///
  /// In en, this message translates to:
  /// **'Complete goals on 5 days'**
  String get achievement35Description;

  /// No description provided for @achievement36Title.
  ///
  /// In en, this message translates to:
  /// **'Habit Builder'**
  String get achievement36Title;

  /// No description provided for @achievement36Description.
  ///
  /// In en, this message translates to:
  /// **'Complete goals on 10 days'**
  String get achievement36Description;

  /// No description provided for @achievement37Title.
  ///
  /// In en, this message translates to:
  /// **'Perfect Day'**
  String get achievement37Title;

  /// No description provided for @achievement37Description.
  ///
  /// In en, this message translates to:
  /// **'Complete goals on 15 days'**
  String get achievement37Description;

  /// No description provided for @achievement38Title.
  ///
  /// In en, this message translates to:
  /// **'Comeback'**
  String get achievement38Title;

  /// No description provided for @achievement38Description.
  ///
  /// In en, this message translates to:
  /// **'Complete goals on 20 days'**
  String get achievement38Description;

  /// No description provided for @achievement39Title.
  ///
  /// In en, this message translates to:
  /// **'Consistency Star'**
  String get achievement39Title;

  /// No description provided for @achievement39Description.
  ///
  /// In en, this message translates to:
  /// **'Complete goals on 30 days'**
  String get achievement39Description;

  /// No description provided for @achievement40Title.
  ///
  /// In en, this message translates to:
  /// **'Unstoppable'**
  String get achievement40Title;

  /// No description provided for @achievement40Description.
  ///
  /// In en, this message translates to:
  /// **'Complete goals on 50 days'**
  String get achievement40Description;

  /// No description provided for @achievement41Title.
  ///
  /// In en, this message translates to:
  /// **'First Group'**
  String get achievement41Title;

  /// No description provided for @achievement41Description.
  ///
  /// In en, this message translates to:
  /// **'Join a study group'**
  String get achievement41Description;

  /// No description provided for @achievement42Title.
  ///
  /// In en, this message translates to:
  /// **'Team Player'**
  String get achievement42Title;

  /// No description provided for @achievement42Description.
  ///
  /// In en, this message translates to:
  /// **'Compete with friends'**
  String get achievement42Description;

  /// No description provided for @achievement43Title.
  ///
  /// In en, this message translates to:
  /// **'Helpful Friend'**
  String get achievement43Title;

  /// No description provided for @achievement43Description.
  ///
  /// In en, this message translates to:
  /// **'Help a friend stay consistent'**
  String get achievement43Description;

  /// No description provided for @achievement44Title.
  ///
  /// In en, this message translates to:
  /// **'Challenge Winner'**
  String get achievement44Title;

  /// No description provided for @achievement44Description.
  ///
  /// In en, this message translates to:
  /// **'Win a challenge'**
  String get achievement44Description;

  /// No description provided for @achievement45Title.
  ///
  /// In en, this message translates to:
  /// **'Exercise Start'**
  String get achievement45Title;

  /// No description provided for @achievement45Description.
  ///
  /// In en, this message translates to:
  /// **'Log exercise focus'**
  String get achievement45Description;

  /// No description provided for @achievement46Title.
  ///
  /// In en, this message translates to:
  /// **'30-Min Workout'**
  String get achievement46Title;

  /// No description provided for @achievement46Description.
  ///
  /// In en, this message translates to:
  /// **'Exercise for 30 minutes'**
  String get achievement46Description;

  /// No description provided for @achievement47Title.
  ///
  /// In en, this message translates to:
  /// **'Hobby Time'**
  String get achievement47Title;

  /// No description provided for @achievement47Description.
  ///
  /// In en, this message translates to:
  /// **'Log hobby focus'**
  String get achievement47Description;

  /// No description provided for @achievement48Title.
  ///
  /// In en, this message translates to:
  /// **'Creative Spark'**
  String get achievement48Title;

  /// No description provided for @achievement48Description.
  ///
  /// In en, this message translates to:
  /// **'Reach 30 minutes of hobbies'**
  String get achievement48Description;

  /// No description provided for @achievement49Title.
  ///
  /// In en, this message translates to:
  /// **'Weekend Warrior'**
  String get achievement49Title;

  /// No description provided for @achievement49Description.
  ///
  /// In en, this message translates to:
  /// **'Reach 2 hours exercising'**
  String get achievement49Description;

  /// No description provided for @achievement50Title.
  ///
  /// In en, this message translates to:
  /// **'Achievement Hunter'**
  String get achievement50Title;

  /// No description provided for @achievement50Description.
  ///
  /// In en, this message translates to:
  /// **'Unlock 25 achievements'**
  String get achievement50Description;

  /// No description provided for @achievementUnlockedNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievement unlocked'**
  String get achievementUnlockedNotificationTitle;

  /// No description provided for @rankTierPaper.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get rankTierPaper;

  /// No description provided for @rankTierWood.
  ///
  /// In en, this message translates to:
  /// **'Wood'**
  String get rankTierWood;

  /// No description provided for @rankTierStone.
  ///
  /// In en, this message translates to:
  /// **'Stone'**
  String get rankTierStone;

  /// No description provided for @rankTierCopper.
  ///
  /// In en, this message translates to:
  /// **'Copper'**
  String get rankTierCopper;

  /// No description provided for @rankTierBronze.
  ///
  /// In en, this message translates to:
  /// **'Bronze'**
  String get rankTierBronze;

  /// No description provided for @rankTierIron.
  ///
  /// In en, this message translates to:
  /// **'Iron'**
  String get rankTierIron;

  /// No description provided for @rankTierSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get rankTierSilver;

  /// No description provided for @rankTierGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get rankTierGold;

  /// No description provided for @rankTierPlatinum.
  ///
  /// In en, this message translates to:
  /// **'Platinum'**
  String get rankTierPlatinum;

  /// No description provided for @rankTierAmethyst.
  ///
  /// In en, this message translates to:
  /// **'Amethyst'**
  String get rankTierAmethyst;

  /// No description provided for @rankTierEmerald.
  ///
  /// In en, this message translates to:
  /// **'Emerald'**
  String get rankTierEmerald;

  /// No description provided for @rankTierDiamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get rankTierDiamond;

  /// No description provided for @rankTierObsidian.
  ///
  /// In en, this message translates to:
  /// **'Obsidian'**
  String get rankTierObsidian;

  /// No description provided for @rankTierAdamantium.
  ///
  /// In en, this message translates to:
  /// **'Adamantium'**
  String get rankTierAdamantium;

  /// No description provided for @rankTierMithril.
  ///
  /// In en, this message translates to:
  /// **'Mithril'**
  String get rankTierMithril;

  /// No description provided for @concentrationModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus mode'**
  String get concentrationModeTitle;

  /// No description provided for @concentrationModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose which focus sessions block leaving the app.'**
  String get concentrationModeSubtitle;

  /// No description provided for @concentrationStudyTitle.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get concentrationStudyTitle;

  /// No description provided for @concentrationStudySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Full focus on your studies.'**
  String get concentrationStudySubtitle;

  /// No description provided for @concentrationExercisesTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get concentrationExercisesTitle;

  /// No description provided for @concentrationExercisesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay focused on your workouts.'**
  String get concentrationExercisesSubtitle;

  /// No description provided for @concentrationReadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get concentrationReadingTitle;

  /// No description provided for @concentrationReadingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dive into your reading.'**
  String get concentrationReadingSubtitle;

  /// No description provided for @concentrationHobbiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Hobbies'**
  String get concentrationHobbiesTitle;

  /// No description provided for @concentrationHobbiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoy your hobbies with focus.'**
  String get concentrationHobbiesSubtitle;

  /// No description provided for @createGroupDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get createGroupDescriptionLabel;

  /// No description provided for @createGroupDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the group and its goal.'**
  String get createGroupDescriptionHint;

  /// No description provided for @createGroupThemeMetricDescription.
  ///
  /// In en, this message translates to:
  /// **'This theme defines the ranking metric.'**
  String get createGroupThemeMetricDescription;

  /// No description provided for @createGroupActivityTypeDescription.
  ///
  /// In en, this message translates to:
  /// **'Each member gets a copy to track.'**
  String get createGroupActivityTypeDescription;

  /// No description provided for @createGroupActivityNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity name'**
  String get createGroupActivityNameLabel;

  /// No description provided for @createGroupActivityNameHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: Calculus I'**
  String get createGroupActivityNameHint;

  /// No description provided for @createGroupGoalTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal type'**
  String get createGroupGoalTypeLabel;

  /// No description provided for @createGroupGoalTypeTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get createGroupGoalTypeTotal;

  /// No description provided for @createGroupGoalTypeDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get createGroupGoalTypeDaily;

  /// No description provided for @createGroupDaysGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Days goal'**
  String get createGroupDaysGoalLabel;

  /// No description provided for @createGroupPagesGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Pages goal'**
  String get createGroupPagesGoalLabel;

  /// No description provided for @createGroupTimeGoalMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Time goal (min)'**
  String get createGroupTimeGoalMinutesLabel;

  /// No description provided for @createGroupSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Group summary'**
  String get createGroupSummaryTitle;

  /// No description provided for @createGroupActivitySummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get createGroupActivitySummaryLabel;

  /// No description provided for @createGroupGuestsLabel.
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get createGroupGuestsLabel;

  /// No description provided for @timerTotalTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Total today'**
  String get timerTotalTodayLabel;

  /// No description provided for @timerEndActionLabel.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get timerEndActionLabel;

  /// No description provided for @createGroupActivityStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the activity everyone in the group will do.'**
  String get createGroupActivityStepSubtitle;

  /// No description provided for @createGroupFriendsStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invite at least 1 friend to join.'**
  String get createGroupFriendsStepSubtitle;

  /// No description provided for @createGroupSummaryStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review the details before creating.'**
  String get createGroupSummaryStepSubtitle;

  /// No description provided for @createGroupStepInformation.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get createGroupStepInformation;

  /// No description provided for @createGroupStepActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get createGroupStepActivity;

  /// No description provided for @createGroupStepFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get createGroupStepFriends;

  /// No description provided for @createGroupStepSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get createGroupStepSummary;

  /// No description provided for @createGroupDaysGoalHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: 30'**
  String get createGroupDaysGoalHint;

  /// No description provided for @createGroupPagesGoalHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: 10'**
  String get createGroupPagesGoalHint;

  /// No description provided for @createGroupMinutesGoalHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: 30'**
  String get createGroupMinutesGoalHint;

  /// No description provided for @createGroupAddFriendsPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t find someone?'**
  String get createGroupAddFriendsPromptTitle;

  /// No description provided for @createGroupAddFriendsPromptDescription.
  ///
  /// In en, this message translates to:
  /// **'Add more friends to be able to invite them.'**
  String get createGroupAddFriendsPromptDescription;

  /// No description provided for @createGroupContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get createGroupContinueButton;

  /// No description provided for @createGroupActivitySummaryDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get createGroupActivitySummaryDaily;

  /// No description provided for @createGroupActivitySummaryGoalDays.
  ///
  /// In en, this message translates to:
  /// **'Goal • {days} days'**
  String createGroupActivitySummaryGoalDays(String days);

  /// No description provided for @createGroupActivitySummaryReading.
  ///
  /// In en, this message translates to:
  /// **'Reading • {pages} pages'**
  String createGroupActivitySummaryReading(String pages);

  /// No description provided for @createGroupActivitySummaryTime.
  ///
  /// In en, this message translates to:
  /// **'{category} • {minutes} min'**
  String createGroupActivitySummaryTime(String category, String minutes);

  /// No description provided for @createGroupActivityRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Choose an activity for the group.'**
  String get createGroupActivityRequiredError;

  /// No description provided for @createGroupActivityNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Give the activity a name.'**
  String get createGroupActivityNameRequiredError;

  /// No description provided for @createGroupActivityGoalInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Set a valid goal.'**
  String get createGroupActivityGoalInvalidError;

  /// No description provided for @createGroupActivityMissingError.
  ///
  /// In en, this message translates to:
  /// **'Define the group\'s activity.'**
  String get createGroupActivityMissingError;

  /// No description provided for @timerBackTooltip.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get timerBackTooltip;

  /// No description provided for @timerRestMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Rest a little'**
  String get timerRestMessageTitle;

  /// No description provided for @timerFocusLabel.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get timerFocusLabel;

  /// No description provided for @timerReadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get timerReadingLabel;

  /// No description provided for @timerPauseLabel.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get timerPauseLabel;

  /// No description provided for @timerReadingTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'reading time'**
  String get timerReadingTimeLabel;

  /// No description provided for @timerTotalOfLabel.
  ///
  /// In en, this message translates to:
  /// **'of {duration}'**
  String timerTotalOfLabel(String duration);

  /// No description provided for @timerCurrentPagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Current pages'**
  String get timerCurrentPagesLabel;

  /// No description provided for @timerNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get timerNotesLabel;

  /// No description provided for @concentrationModeSheetDescription.
  ///
  /// In en, this message translates to:
  /// **'When enabled, the app helps you stay focused during the activity until you pause or finish.'**
  String get concentrationModeSheetDescription;

  /// No description provided for @timerFocusLockWarning.
  ///
  /// In en, this message translates to:
  /// **'Focus mode is active. Finish or pause the session to leave.'**
  String get timerFocusLockWarning;

  /// No description provided for @timerProgressSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress: {percent}%'**
  String timerProgressSemanticLabel(int percent);

  /// No description provided for @homeStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count}-day streak} other{{count}-day streak}}'**
  String homeStreakLabel(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
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
