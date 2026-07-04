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
  /// **'Let\'s Start'**
  String get loginHeadline;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
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
  /// **'Let\'s Start'**
  String get homeGreetingDefault;

  /// No description provided for @homeGreetingWithName.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Start, {userName}'**
  String homeGreetingWithName(String userName);

  /// No description provided for @categoryStudying.
  ///
  /// In en, this message translates to:
  /// **'Studying'**
  String get categoryStudying;

  /// No description provided for @categoryWorking.
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get categoryWorking;

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

  /// No description provided for @itemNounWorking.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get itemNounWorking;

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

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

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

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Profile'**
  String get profileTitle;

  /// No description provided for @profileSubtitleDefault.
  ///
  /// In en, this message translates to:
  /// **'Accomplishments'**
  String get profileSubtitleDefault;

  /// No description provided for @profileSubtitleWithName.
  ///
  /// In en, this message translates to:
  /// **'Great work, {userName}'**
  String profileSubtitleWithName(String userName);

  /// No description provided for @statHoursStudied.
  ///
  /// In en, this message translates to:
  /// **'Hours studied'**
  String get statHoursStudied;

  /// No description provided for @statTopSubjectFallback.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get statTopSubjectFallback;

  /// No description provided for @statTopSubject.
  ///
  /// In en, this message translates to:
  /// **'Top subject'**
  String get statTopSubject;

  /// No description provided for @statHoursWorked.
  ///
  /// In en, this message translates to:
  /// **'Hours worked'**
  String get statHoursWorked;

  /// No description provided for @statHoursRead.
  ///
  /// In en, this message translates to:
  /// **'Hours read'**
  String get statHoursRead;

  /// No description provided for @mostReadThemes.
  ///
  /// In en, this message translates to:
  /// **'Most read themes'**
  String get mostReadThemes;

  /// No description provided for @noReadingYet.
  ///
  /// In en, this message translates to:
  /// **'Read something to see your top themes here.'**
  String get noReadingYet;

  /// No description provided for @groupsTitle.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groupsTitle;

  /// No description provided for @noGroupSelected.
  ///
  /// In en, this message translates to:
  /// **'No group selected yet.'**
  String get noGroupSelected;

  /// No description provided for @newGroupChip.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get newGroupChip;

  /// No description provided for @periodToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get periodToday;

  /// No description provided for @periodThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get periodThisWeek;

  /// No description provided for @periodThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get periodThisMonth;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @myProfileFallback.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfileFallback;

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

  /// No description provided for @notificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsLabel;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @supportSection.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportSection;

  /// No description provided for @faqLabel.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faqLabel;

  /// No description provided for @aboutLabel.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutLabel;

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

  /// No description provided for @logOutLabel.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOutLabel;

  /// No description provided for @logOutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOutDialogTitle;

  /// No description provided for @logOutDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This clears your local profile from this device. You can always set it up again.'**
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
  /// **'Groups show a scoreboard of everyone\'s studied hours. Switch between Today, This Week and This Month to see who studied the most in that period.'**
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
  /// **'Create Group'**
  String get createGroupTitle;

  /// No description provided for @groupNameHint.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupNameHint;

  /// No description provided for @inviteFriendsLabel.
  ///
  /// In en, this message translates to:
  /// **'Invite friends'**
  String get inviteFriendsLabel;

  /// No description provided for @createGroupButton.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get createGroupButton;

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
  /// **'No schedule yet — tap to add'**
  String get noScheduleYet;

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
  /// **'End time (optional)'**
  String get endTimeOptionalLabel;

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

  /// No description provided for @orSeparator.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orSeparator;

  /// No description provided for @createAccountSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccountSectionTitle;
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
