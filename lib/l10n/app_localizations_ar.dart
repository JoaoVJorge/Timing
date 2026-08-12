// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Timing';

  @override
  String get genericErrorMessage => 'حدث خطأ ما. يرجى المحاولة مرة أخرى لاحقا.';

  @override
  String get loginHeadline => 'لنبدأ';

  @override
  String get loginSubtitle => 'قم بتسجيل الدخول لمواصلة الدراسة وتنظيم روتينك.';

  @override
  String get loginNameHint => 'اسمك';

  @override
  String get loginButton => 'لنبدأ';

  @override
  String get homeGreetingDefault => 'مرحبا';

  @override
  String homeGreetingWithName(String userName) {
    return 'مرحبًا، $userName';
  }

  @override
  String get homeSubtitle => 'ما الذي نتعامل معه اليوم؟';

  @override
  String homeSubtitleFocusedToday(String duration) {
    return 'لقد ركزت على $duration اليوم';
  }

  @override
  String homeSubtitleNextSchedule(String title, String time) {
    return 'جدول الأعمال: $title في $time';
  }

  @override
  String get homeSubtitleStart => 'ابدأ جلسة التركيز الأولى';

  @override
  String get homeTasksSection => 'الأهداف اليومية';

  @override
  String get homeCategoriesSection => 'الأنشطة';

  @override
  String get homeActionContinueEyebrow => 'استمر الآن';

  @override
  String get homeActionContinueButton => 'متابعة';

  @override
  String get homeActionStartEyebrow => 'ابدأ بالتركيز';

  @override
  String get homeActionStartButton => 'ابدأ';

  @override
  String get homeActionSuggestedMeta => 'الموضوع الأكثر متابعة لديك';

  @override
  String get homeActionCreateBody => 'أنشئ موضوعك الأول لبدء جلسة التركيز.';

  @override
  String get homeActionCreateButton => 'إنشاء الموضوع';

  @override
  String get homeSummaryTitle => 'ملخص اليوم';

  @override
  String get homeSummaryFocus => 'التركيز';

  @override
  String get homeSummaryGoals => 'الأهداف';

  @override
  String get homeSummaryPages => 'الصفحات';

  @override
  String get homeSummarySessions => 'الجلسات';

  @override
  String homeGoalsProgress(int done, int total) {
    return 'تم الانتهاء من $done من $total';
  }

  @override
  String get homeCategoryEmpty => 'لا شيء بعد';

  @override
  String get homeNextScheduleTitle => 'جدول الأعمال';

  @override
  String get homeTodayAgendaTitle => 'جدول أعمال اليوم';

  @override
  String get homeNextScheduleEmpty => 'لا توجد مواعيد اليوم';

  @override
  String get homeNextScheduleAdd => 'إضافة موعد';

  @override
  String get addTaskButton => 'أضف هدفا';

  @override
  String get createTaskTitle => 'هدف جديد';

  @override
  String get taskNameHint => 'اسم الهدف';

  @override
  String get targetDaysLabel => 'الهدف (الأيام)';

  @override
  String targetDaysChip(int days) {
    return '$days يوم';
  }

  @override
  String get targetDaysHint => 'هدف مخصص';

  @override
  String taskDaysProgress(int completed, int target) {
    return '$completed/$target يوم';
  }

  @override
  String get taskCompletedLabel => 'تم!';

  @override
  String get lastActivityLabel => 'النشاط الأخير';

  @override
  String get lastActivityNone => 'لا شيء بعد - ابدأ شيئًا!';

  @override
  String get lastActivityJustNow => 'الآن فقط';

  @override
  String lastActivityMinutesAgo(int minutes) {
    return '$minutes منذ دقيقة';
  }

  @override
  String lastActivityHoursAgo(int hours) {
    return '$hours منذ ساعة';
  }

  @override
  String lastActivityDaysAgo(int days) {
    return '$days د مضت';
  }

  @override
  String get categoryStudying => 'دراسات';

  @override
  String get categoryExercises => 'ممارسة الرياضة';

  @override
  String get categoryReading => 'القراءة';

  @override
  String get categoryHobbies => 'الهوايات';

  @override
  String get itemNounStudying => 'الموضوع';

  @override
  String get itemNounExercises => 'تمرين';

  @override
  String get itemNounReading => 'كتاب';

  @override
  String get itemNounHobbies => 'هواية';

  @override
  String get iconLabel => 'أيقونة';

  @override
  String get restTimeLabel => 'وقت الراحة';

  @override
  String restMinutesChip(int minutes) {
    return '$minutes دقيقة';
  }

  @override
  String get timeUnitHoursSuffix => 'ح';

  @override
  String get timeUnitMinutesSuffix => 'دقيقة';

  @override
  String get wallpaperLabel => 'خلفية الموقت';

  @override
  String addItemButton(String itemNoun) {
    return 'أضف $itemNoun';
  }

  @override
  String itemNameHint(String itemNoun) {
    return 'الاسم $itemNoun';
  }

  @override
  String get colorLabel => 'اللون';

  @override
  String get bookThemeLabel => 'موضوع الكتاب';

  @override
  String get estimatedHoursGoalHint => 'الهدف في دقائق';

  @override
  String get goalPagesHint => 'الهدف (صفحات)';

  @override
  String get cancelButton => 'إلغاء';

  @override
  String get confirmButton => 'تأكيد';

  @override
  String get addButton => 'أضف';

  @override
  String get createSubjectTitleStudying => 'موضوع جديد';

  @override
  String get createSubjectTitleReading => 'قراءة جديدة';

  @override
  String get createSubjectTitleExercises => 'تجريب جديد';

  @override
  String get createSubjectTitleHobbies => 'هواية جديدة';

  @override
  String get createSubjectSubtitleStudying => 'حدد هدفًا وقم بتخصيص تركيزك';

  @override
  String get createSubjectSubtitleReading => 'تتبع الصفحات وتخصيص قراءتك';

  @override
  String get createSubjectSubtitleExercises =>
      'اختر الطريقة التي تريد بها تتبع هذا النشاط';

  @override
  String get createSubjectSubtitleHobbies =>
      'اختر الطريقة التي تريد بها تتبع هذه الهواية';

  @override
  String get createSubjectBasicSection => 'المعلومات الأساسية';

  @override
  String get createSubjectGoalSection => 'هدف';

  @override
  String get createSubjectRoutineSection => 'روتين';

  @override
  String get createSubjectPersonalizationSection => 'التخصيص';

  @override
  String get createSubjectNameLabelStudying => 'اسم الموضوع';

  @override
  String get createSubjectNameLabelReading => 'اسم القراءة';

  @override
  String get createSubjectNameLabelExercises => 'اسم النشاط';

  @override
  String get createSubjectNameLabelHobbies => 'اسم الهواية';

  @override
  String get createSubjectNameHintStudying =>
      'على سبيل المثال: الأحياء، الرياضيات، اللغة الإنجليزية';

  @override
  String get createSubjectNameHintReading =>
      'على سبيل المثال: كتاب التاريخ، دوم كاسمورو';

  @override
  String get createSubjectNameHintExercises =>
      'على سبيل المثال: صالة الألعاب الرياضية، الجري، التمدد';

  @override
  String get createSubjectNameHintHobbies =>
      'على سبيل المثال: الجيتار، الرسم، البرمجة';

  @override
  String get createSubjectTimeGoalLabel => 'هدف التركيز';

  @override
  String get createSubjectPagesGoalLabel => 'هدف الصفحة';

  @override
  String get createSubjectTimeGoalHelp => 'كم دقيقة تريد التركيز؟';

  @override
  String get createSubjectPagesGoalHelp =>
      'كم عدد الصفحات التي تريد تسجيل الدخول بها إجمالاً؟';

  @override
  String get createSubjectRestLabel => 'استراحة بعد كل تركيز';

  @override
  String get createSubjectRestHelp =>
      'يقترح الموقت استراحة بعد 30 دقيقة من التركيز.';

  @override
  String get customRestMinutesHint => 'فاصل مخصص (دقيقة)';

  @override
  String get createSubjectPreviewTitle => 'معاينة';

  @override
  String get createSubjectPreviewNoGoal => 'لم يتم تحديد أي هدف';

  @override
  String createSubjectPreviewGoal(String goal) {
    return 'الهدف: $goal';
  }

  @override
  String createSubjectPreviewRest(int minutes) {
    return 'استراحة: $minutes دقيقة';
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
    return 'صفحات $value';
  }

  @override
  String createSubjectColorSemantic(int index) {
    return 'اللون $index';
  }

  @override
  String get createSubjectButtonStudying => 'إنشاء الموضوع';

  @override
  String get createSubjectButtonReading => 'خلق القراءة';

  @override
  String get createSubjectButtonExercises => 'إنشاء نشاط';

  @override
  String get createSubjectButtonHobbies => 'خلق هواية';

  @override
  String get createSubjectMissingName => 'أدخل اسمًا للمتابعة';

  @override
  String get createSubjectMissingTimeGoal => 'حدد هدفًا صالحًا للتركيز';

  @override
  String get createSubjectMissingPagesGoal => 'قم بتعيين هدف صالح للصفحة';

  @override
  String get createSubjectSuccessStudying => 'تم إنشاء الموضوع بنجاح';

  @override
  String get createSubjectSuccessReading => 'تم إنشاء القراءة بنجاح';

  @override
  String get createSubjectSuccessExercises => 'تم إنشاء النشاط بنجاح';

  @override
  String get createSubjectSuccessHobbies => 'تم إنشاء الهواية بنجاح';

  @override
  String pagesProgress(int currentPages, int goalPages) {
    return '$currentPages من صفحات $goalPages';
  }

  @override
  String pagesReadOnly(int currentPages) {
    return 'قراءة صفحات $currentPages';
  }

  @override
  String get pagesReadNowHint => 'صفحات قراءة الآن';

  @override
  String get logPagesButton => 'صفحات السجل';

  @override
  String get notesLabel => 'ملاحظات';

  @override
  String get notesHint => 'أكتب ملاحظاتك هنا...';

  @override
  String get saveNotesButton => 'حفظ';

  @override
  String get addNotesPageTooltip => 'إضافة صفحة';

  @override
  String notesPageCounter(int currentPage, int pageCount) {
    return 'صفحة $currentPage من $pageCount';
  }

  @override
  String durationProgress(String duration, String goalDuration) {
    return '$duration من $goalDuration';
  }

  @override
  String timerTotalLabel(String duration) {
    return 'الإجمالي: $duration';
  }

  @override
  String timerNextBreakLabel(String duration) {
    return 'الاستراحة التالية في $duration';
  }

  @override
  String timerRestingLabel(String duration) {
    return 'يستريح - العودة إلى $duration';
  }

  @override
  String get timerNotificationRunning => 'جلسة التركيز قيد التقدم';

  @override
  String get timerNotificationResting => 'يستريح - العودة قريبا';

  @override
  String get timerNotificationPaused => 'متوقف مؤقتًا';

  @override
  String get timerStateFocusingTitle => 'التركيز قيد التقدم';

  @override
  String get timerStateFocusingDescription =>
      'حافظ على تركيزك. سيتم اقتراح استراحة قريبا.';

  @override
  String get timerStatePausedTitle => 'توقف الموقّت مؤقتًا';

  @override
  String get timerStatePausedDescription => 'استمر عندما تكون جاهزًا.';

  @override
  String get timerStateRestingTitle => 'استراحة مستحقة';

  @override
  String get timerStateRestingDescription =>
      'اشرب الماء أو تنفس قليلاً قبل المتابعة.';

  @override
  String get timerSessionSavedTitle => 'تم تسجيل الجلسة';

  @override
  String get timerSessionSavedDescription => 'تمت إضافة وقتك إلى الموضوع.';

  @override
  String get timerCurrentFocusLabel => 'وقت التركيز الآن';

  @override
  String get timerRestTimeLabel => 'وقت الاستراحة';

  @override
  String get timerSessionLabel => 'الجلسة الحالية';

  @override
  String timerTotalInSubject(String subjectName) {
    return 'الإجمالي في $subjectName';
  }

  @override
  String get timerPauseButton => 'وقفة';

  @override
  String get timerContinueButton => 'متابعة';

  @override
  String get timerContinueFocusButton => 'متابعة';

  @override
  String get timerSkipRestButton => 'تخطي الاستراحة';

  @override
  String get timerEndSessionButton => 'نهاية الجلسة';

  @override
  String get timerStartAnotherSessionButton => 'ابدأ جلسة أخرى';

  @override
  String get timerSaveReassurance =>
      'يتم أيضًا حفظ التقدم عند التوقف أو المغادرة.';

  @override
  String timerFocusedValue(String duration) {
    return 'ركز $duration';
  }

  @override
  String get timerAccumulatedTotalLabel => 'المجموع المتراكم';

  @override
  String get timerBackToSubjectsButton => 'العودة';

  @override
  String get timerExitDialogTitle => 'إنهاء الجلسة؟';

  @override
  String timerExitDialogContent(String duration, String subjectName) {
    return 'سيتم حفظ تقدمك في $duration في $subjectName.';
  }

  @override
  String get timerExitDialogCancel => 'متابعة';

  @override
  String get timerExitDialogContinueLater => 'يمكنك الاستمرار في وقت لاحق.';

  @override
  String get timerExitDialogConfirm => 'نهاية';

  @override
  String get editButton => 'تحرير';

  @override
  String get nicknameFallback => 'user';

  @override
  String get profileSummaryLabel => 'ملخص إجمالي';

  @override
  String get profileSummarySinceStartLabel => 'منذ البداية';

  @override
  String profileSummaryAccumulatedFocus(Object duration) {
    return '$duration من التركيز المتراكم';
  }

  @override
  String get profileSummaryFocusLabel => 'إجمالي وقت التركيز';

  @override
  String get profileSummaryFocusDescription =>
      'الدراسة وممارسة الرياضة والهوايات';

  @override
  String get statHoursStudied => 'دراسة';

  @override
  String get statHoursExercised => 'تمرين';

  @override
  String get statPagesRead => 'صفحات للقراءة';

  @override
  String get statTopSubject => 'الأكثر دراسة';

  @override
  String get profileStatTimeEmptyTitle => 'ابدأ تركيزك الأول';

  @override
  String get profileStatTimeEmptyDescription => 'سيظهر وقتك هنا';

  @override
  String get profileStatExerciseEmptyTitle => 'لا يوجد تمرين بعد';

  @override
  String get profileStatExerciseEmptyDescription => 'قم بتسجيل نشاطك الأول';

  @override
  String get profileStatReadingEmptyTitle => 'لا توجد صفحات بعد';

  @override
  String get profileStatReadingEmptyDescription => 'سجل قراءتك الأولى';

  @override
  String get profileTopSubjectEmptyTitle => 'لا شيء حتى الآن';

  @override
  String get profileTopSubjectEmptyDescription => 'دراسة موضوع لعرضه هنا';

  @override
  String get profileEmptyTitle => 'تقدمك يبدأ هنا';

  @override
  String get profileEmptyDescription =>
      'ابدأ جلسة، أو سجل بعض القراءة أو حدد هدفًا من الصفحة الرئيسية لتتبع تطورك في Timing.';

  @override
  String get profileEmptyGuidance =>
      'بعد ذلك، سيظهر هنا إجمالي وقتك وأهم الأنشطة وأبرز ما قرأت.';

  @override
  String get profileEmptyStartButton => 'ابدأ الآن';

  @override
  String get profileShortcutsTitle => 'الاختصارات';

  @override
  String get profileShortcutCreateSubject => 'إنشاء الموضوع';

  @override
  String get profileShortcutCreateGoal => 'إنشاء الهدف';

  @override
  String get profileShortcutAddSchedule => 'إضافة الجدول الزمني';

  @override
  String get profileEvolutionTitle => 'التقدم المحرز الخاص بك';

  @override
  String profileEvolutionFocus(String duration) {
    return 'لقد تراكمت لديك $duration من التركيز.';
  }

  @override
  String profileEvolutionTopSubject(String name) {
    return 'المادة الأكثر دراسة لديك هي $name.';
  }

  @override
  String profileEvolutionRemaining(String duration) {
    return 'أنت على بعد $duration من هدفك.';
  }

  @override
  String get profileEvolutionGoalReached =>
      'لقد وصلت إلى هدف التركيز الخاص بك!';

  @override
  String get profileProgressSectionTitle => 'التقدم المحرز الخاص بك';

  @override
  String get profileAchievementsTitle => 'الإنجازات';

  @override
  String get profileSeeHistory => 'انظر التاريخ';

  @override
  String get profileSeeAll => 'شاهد الكل';

  @override
  String get profileAchievementFirstUnlocked => 'الإنجاز الأول';

  @override
  String get profileAchievementGoalStarted => 'بدأ الهدف';

  @override
  String get profileAchievementsStartHint => 'البدء في كسب الإنجازات';

  @override
  String get profileAchievementFirstFocus => 'التركيز الأول';

  @override
  String get profileAchievementStudyStarted => 'بدأت الدراسة';

  @override
  String get profileAchievementReadingStarted => 'بدأت القراءة';

  @override
  String get profileAchievementLocked => 'مغلق';

  @override
  String get periodFiveDays => '5 أيام';

  @override
  String get periodWeek => '1 أسبوع';

  @override
  String get periodMonth => 'شهر واحد';

  @override
  String get periodTotal => 'المجموع';

  @override
  String get profileAgendaTitle => 'جدول اليوم';

  @override
  String get profileAgendaEmptyTitle => 'لا يوجد جدول زمني مخطط له';

  @override
  String get profileAgendaEmptyDescription => 'أضف الكتل لتنظيم روتينك.';

  @override
  String get profileAgendaAddButton => 'إضافة الجدول الزمني';

  @override
  String get profileTopReadingTitle => 'أعلى القراءة';

  @override
  String get profileTopReadingEmptyTitle => 'لم يتم تسجيل القراءة';

  @override
  String get profileTopReadingEmptyDescription =>
      'قراءة صفحات السجل لرؤية أهم المواضيع الخاصة بك هنا.';

  @override
  String get groupsTitle => 'المجموعات';

  @override
  String get groupsSubtitle => 'قارن تقدمك مع الأصدقاء';

  @override
  String get noGroupSelected => 'لم يتم تحديد مجموعة بعد.';

  @override
  String get newGroupChip => 'جديد';

  @override
  String get groupHeaderCreateButton => 'المجموعة';

  @override
  String get groupsEmptyTitle => 'لا توجد مجموعات حتى الآن';

  @override
  String get groupsEmptyDescription =>
      'قم بإنشاء مجموعة لمقارنة التقدم مع الأصدقاء والحفاظ على الزخم المستمر.';

  @override
  String get groupsEmptyButton => 'إنشاء المجموعة الأولى';

  @override
  String get you => 'أنت';

  @override
  String get mockStudyGroupName => 'فرقة الدراسة';

  @override
  String get mockWorkoutGroupName => 'طاقم التمرين';

  @override
  String get periodToday => 'اليوم';

  @override
  String get periodThisWeek => 'الأسبوع';

  @override
  String get periodThisMonth => 'شهر';

  @override
  String get periodDescriptionToday => 'اليوم';

  @override
  String get periodDescriptionThisWeek => 'هذا الاسبوع';

  @override
  String get periodDescriptionThisMonth => 'هذا الشهر';

  @override
  String get groupMetricStudying => 'ساعات الدراسة';

  @override
  String get groupMetricDailyGoals => 'أيام الهدف المكتملة';

  @override
  String get groupMetricExercises => 'ساعات التمرين';

  @override
  String get groupMetricReading => 'قراءة الصفحات';

  @override
  String get groupMetricHobbies => 'ساعات هواية';

  @override
  String groupLeaderboardDescription(String period, String metric) {
    return 'تصنيف $period · تم قياسه بـ $metric';
  }

  @override
  String get leaderboardTitle => 'الترتيب';

  @override
  String get currentUserRankTitle => 'أدائك';

  @override
  String currentUserRankValue(String rank, String score) {
    return 'مكان $rank · $score';
  }

  @override
  String currentUserRankNextStep(String score) {
    return '$score لتسلق مركز واحد';
  }

  @override
  String get currentUserRankLeading => 'أنت تقود هذا الترتيب.';

  @override
  String get currentUserRankSubtitle => 'موقعك الحالي';

  @override
  String get leaderboardTopPosition => 'يقود هذا الترتيب';

  @override
  String leaderboardDifferenceAhead(String value) {
    return '+$value للأمام';
  }

  @override
  String get groupCreatedSuccess => 'تم إنشاء المجموعة بنجاح';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsSubtitle => 'اضبط حسابك وتفضيلاتك';

  @override
  String get myProfileFallback => 'ملفي الشخصي';

  @override
  String get personalProfileLabel => 'الملف الشخصي';

  @override
  String accountDataSubtitle(Object nickname) {
    return '$nickname · البيانات الشخصية والأمن';
  }

  @override
  String get preferencesSection => 'التفضيلات';

  @override
  String get darkModeLabel => 'الوضع المظلم';

  @override
  String get darkModeEnabledSubtitle => 'تم تفعيل المظهر الداكن';

  @override
  String get darkModeDisabledSubtitle => 'استخدم المظهر المظلم في التطبيق';

  @override
  String get accentColorSettingsTitle => 'لون مميز';

  @override
  String get accentColorSettingsSubtitle =>
      'إضفاء الطابع الشخصي على مظهر التطبيق';

  @override
  String get notificationsLabel => 'الإخطارات';

  @override
  String get timerNotificationsTitle => 'إشعارات الموقت';

  @override
  String get notificationsEnabledSubtitle =>
      'تنبيهات التركيز والاستراحة والتقدم';

  @override
  String get notificationsDisabledSubtitle => 'التنبيهات متوقفة على هذا الجهاز';

  @override
  String get language => 'اللغة';

  @override
  String get appLanguageSubtitle => 'لغة التطبيق';

  @override
  String get automaticLanguageLabel => 'تلقائي';

  @override
  String get chooseLanguageTitle => 'اختر اللغة';

  @override
  String languageChangedMessage(String language) {
    return 'تم تغيير اللغة إلى $language';
  }

  @override
  String get preferenceSavedMessage => 'تم حفظ التفضيل';

  @override
  String get supportSection => 'الدعم';

  @override
  String get helpSection => 'مساعدة';

  @override
  String get faqLabel => 'الأسئلة الشائعة';

  @override
  String get faqSettingsSubtitle => 'أسئلة حول الموقت والأهداف والمجموعات';

  @override
  String get sendFeedbackTitle => 'إرسال ردود الفعل';

  @override
  String get sendFeedbackSubtitle => 'أخبرنا ما الذي يمكن أن يكون أفضل';

  @override
  String get feedbackUnavailable => 'ردود الفعل ليست متاحة بعد';

  @override
  String get aboutLabel => 'حول';

  @override
  String get aboutSection => 'حول';

  @override
  String appVersionValue(String version) {
    return 'الإصدار $version';
  }

  @override
  String get debugEnvironmentTitle => 'البيئة';

  @override
  String get debugEnvironmentSubtitle => 'تصحيح الأخطاء · بيانات العينة نشطة';

  @override
  String appVersionLabel(String appTitle, String appVersion) {
    return '$appTitle v$appVersion';
  }

  @override
  String get accountSection => 'الحساب';

  @override
  String get sessionSection => 'جلسة';

  @override
  String get logOutLabel => 'تسجيل الخروج';

  @override
  String get logOutSettingsSubtitle => 'قم بإنهاء الجلسة على هذا الجهاز';

  @override
  String get logOutDialogTitle => 'تسجيل الخروج؟';

  @override
  String get logOutDialogContent =>
      'ستحتاج إلى تسجيل الدخول مرة أخرى للوصول إلى هذا الحساب على هذا الجهاز. سيتم الاحتفاظ ببيانات الدراسة المحلية الخاصة بك.';

  @override
  String get logOutConfirmButton => 'تسجيل الخروج';

  @override
  String get myProfileTitle => 'ملفي الشخصي';

  @override
  String get avatarLabel => 'الصورة الرمزية';

  @override
  String get nameLabel => 'الاسم';

  @override
  String get yourNameHint => 'اسمك';

  @override
  String get nicknameLabel => 'اللقب';

  @override
  String get nicknameHint => 'ما يدعوك الأصدقاء';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get optionalHint => 'اختياري';

  @override
  String get phoneLabel => 'رقم الهاتف';

  @override
  String get themeColorLabel => 'لون الموضوع';

  @override
  String get saveChangesButton => 'حفظ التغييرات';

  @override
  String get profileSavedMessage => 'تم حفظ الملف الشخصي';

  @override
  String get profilePhotoSelectLabel => 'أضف صورة';

  @override
  String get profilePhotoRemoveLabel => 'إزالة الصورة';

  @override
  String get faqTitle => 'الأسئلة الشائعة';

  @override
  String get faqQ1 => 'كيف يعمل مؤقت الدراسة؟';

  @override
  String get faqA1 =>
      'اختر موضوعًا، وانقر فوق تشغيل، وسيقوم المؤقت بتتبع جلستك الحالية أثناء إضافتها إلى الوقت الإجمالي لهذا الموضوع. انقر فوق إيقاف مؤقت في أي وقت للتوقف وحفظ تقدمك.';

  @override
  String get faqQ2 => 'ما هو العد التنازلي للاستراحة؟';

  @override
  String get faqA2 =>
      'تتبع كل جلسة دورة تركيز: عد تنازلي مدته 30 دقيقة حتى استراحتك التالية. عندما يصل إلى الصفر، يتم إعادة ضبطه ببساطة، وهذا بمثابة تذكير، وليس توقفًا صعبًا.';

  @override
  String get faqQ3 => 'كيف أضيف موضوع جديد؟';

  @override
  String get faqA3 =>
      'افتح فئة من الصفحة الرئيسية، ثم اضغط على \"إضافة موضوع\" في أسفل القائمة. يمكنك اختيار لون وتحديد هدف الساعات المقدرة له.';

  @override
  String get faqQ4 => 'كيف يتم حساب المجموعات ولوحة المتصدرين؟';

  @override
  String get faqA4 =>
      'تعرض المجموعات لوحة النتائج بناءً على موضوع المجموعة: ساعات التركيز أو أيام الأهداف المكتملة أو الصفحات المقروءة. قم بالتبديل بين اليوم والأسبوع والشهر لمقارنة التقدم.';

  @override
  String get faqQ5 => 'هل يمكنني تغيير سمة اللون للتطبيق؟';

  @override
  String get faqA5 =>
      'نعم، انتقل إلى الإعدادات > ملفي الشخصي واختر أي لون للموضوع. يتم تحديث كل تدرج وزر وتمييز عبر التطبيق لمطابقته، بما في ذلك الوضع المظلم.';

  @override
  String get createGroupTitle => 'مجموعة جديدة';

  @override
  String get createGroupSubtitle => 'اختر موضوعًا وقم بدعوة الأصدقاء';

  @override
  String get groupNameLabel => 'اسم المجموعة';

  @override
  String get groupNameHint => 'اسم المجموعة';

  @override
  String get groupNameExampleHint => 'على سبيل المثال: طاقم دراسة الامتحان';

  @override
  String get groupThemeLabel => 'الموضوع';

  @override
  String groupThemeSelectedDescription(String metric) {
    return 'تم تصنيف هذه المجموعة حسب $metric.';
  }

  @override
  String get inviteFriendsLabel => 'دعوة الأصدقاء';

  @override
  String selectedFriendsCount(int count) {
    return 'تم تحديد $count';
  }

  @override
  String get selectAtLeastOneFriend => 'اختر صديقًا واحدًا على الأقل';

  @override
  String get searchFriendHint => 'بحث صديق';

  @override
  String get loadingFriends => 'جارٍ تحميل الأصدقاء...';

  @override
  String get friendsLoadErrorTitle => 'لا يمكن تحميل الأصدقاء';

  @override
  String get friendsLoadErrorDescription => 'حاول مرة أخرى بعد قليل.';

  @override
  String get noFriendsAvailableTitle => 'لا يوجد أصدقاء متاحين';

  @override
  String get noFriendsAvailableDescription => 'أضف أصدقاء قبل إنشاء مجموعة.';

  @override
  String get noFriendsFoundTitle => 'لم يتم العثور على صديق';

  @override
  String get noFriendsFoundDescription => 'حاول اسم آخر.';

  @override
  String get createGroupButton => 'إنشاء مجموعة';

  @override
  String get createGroupMissingName => 'أدخل اسم المجموعة';

  @override
  String get createGroupMissingTheme => 'اختر موضوعًا';

  @override
  String get createGroupMissingFriends => 'اختر صديقًا واحدًا على الأقل';

  @override
  String createGroupWithFriendsButton(int count) {
    return 'أنشئ مجموعة مع أصدقاء $count';
  }

  @override
  String get createGroupRequirementsTitle => 'لإنشاء:';

  @override
  String get createGroupRequirementName => 'اسم المجموعة';

  @override
  String get createGroupRequirementTheme => 'تم اختيار الموضوع';

  @override
  String get createGroupRequirementFriends => 'صديق واحد على الأقل';

  @override
  String get groupPrivacyNote =>
      'لن يرى أصدقاؤك سوى اسمك وصورتك الرمزية وتقدمك في هذا الموضوع.';

  @override
  String metricDaysValue(int value) {
    return '$value يوم';
  }

  @override
  String metricPagesValue(int value) {
    return 'صفحات $value';
  }

  @override
  String get navHome => 'الصفحة الرئيسية';

  @override
  String get navGroups => 'المجموعات';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get myScheduleCardTitle => 'الجدول الزمني الخاص بي';

  @override
  String get myScheduleTitle => 'الجدول الزمني الخاص بي';

  @override
  String get noScheduleYet => 'لا توجد مواعيد بعد';

  @override
  String get noScheduleYetDescription =>
      'اضغط على الزر أدناه لإضافة\nأول موعد لك';

  @override
  String get addScheduleEntryTitle => 'إضافة موعد';

  @override
  String get addScheduleEntryButton => 'إضافة موعد';

  @override
  String get scheduleInfoSection => 'معلومات';

  @override
  String get scheduleWhenSection => 'متى؟';

  @override
  String get scheduleColorSection => 'لون الموعد';

  @override
  String get schedulePreviewSection => 'معاينة';

  @override
  String scheduleDurationLabel(String duration) {
    return 'المدة: $duration';
  }

  @override
  String scheduleDurationMinutes(int minutes) {
    return '$minutes دقيقة';
  }

  @override
  String scheduleDurationHours(int hours) {
    return '${hours}h';
  }

  @override
  String scheduleDurationHoursMinutes(int hours, int minutes) {
    return '${hours}h $minutes دقيقة';
  }

  @override
  String get scheduleTitleHint => 'العنوان';

  @override
  String get startTimeLabel => 'وقت البدء';

  @override
  String get endTimeOptionalLabel => 'وقت الانتهاء';

  @override
  String get incompleteScheduleEntryError =>
      'إدخال غير مكتمل - املأ العنوان ووقت البدء ووقت الانتهاء.';

  @override
  String get endTimeBeforeStartError =>
      'يجب أن يكون وقت الانتهاء متأخرًا عن وقت البدء.';

  @override
  String get nameRequiredError => 'الرجاء إدخال اسم أولا.';

  @override
  String get groupThemeRequiredError => 'اختر موضوعًا لمجموعتك.';

  @override
  String get groupNeedsFriendError =>
      'قم بدعوة صديق واحد على الأقل — لا يمكن إنشاء المجموعة بمفردك.';

  @override
  String get continueWithGoogleButton => 'تواصل مع جوجل';

  @override
  String get continueWithAppleButton => 'تواصل مع أبل';

  @override
  String get continueWithPhoneButton => 'تواصل مع رقم الهاتف';

  @override
  String get phoneLoginTitle => 'رقمك';

  @override
  String get phoneLoginSubtitle => 'أدخل رقم هاتفك لتلقي رمز الوصول.';

  @override
  String get sendCodeButton => 'إرسال الرمز';

  @override
  String get phoneSecurityNote => 'يمكنك استخدام رقمك لتسجيل الدخول بشكل آمن.';

  @override
  String get selectCountryTitle => 'اختر بلدك';

  @override
  String get searchCountryHint => 'بحث عن البلد';

  @override
  String get otpCodeExpired =>
      'انتهت صلاحية الرمز. إعادة الإرسال للحصول على واحدة جديدة.';

  @override
  String get otpTitle => 'التحقق من رقمك';

  @override
  String otpSubtitle(String phone) {
    return 'أدخل الرمز المكون من 6 أرقام الذي أرسلناه إلى $phone.';
  }

  @override
  String get verifyCodeButton => 'تحقق';

  @override
  String get resendCodeButton => 'إعادة إرسال الرمز';

  @override
  String otpCodeValidFor(String time) {
    return 'الرمز صالح لـ $time';
  }

  @override
  String get codeResentMessage => 'تم إرسال رمز التحقق';

  @override
  String get invalidCodeError => 'رمز غير صالح. يرجى المحاولة مرة أخرى.';

  @override
  String get credentialsTitle => 'قم بإنشاء ملف التعريف الخاص بك';

  @override
  String get credentialsSubtitle => 'أخبرنا قليلاً عن نفسك لتخصيص تجربتك.';

  @override
  String get birthDateHint => 'تاريخ الميلاد';

  @override
  String get profileEditableLaterNote => 'يمكنك تعديل هذا لاحقا.';

  @override
  String get finishButton => 'إنهاء';

  @override
  String get navProgress => 'التقدم';

  @override
  String get progressTitle => 'التقدم';

  @override
  String get progressSubtitle => 'كل ما أنجزته حتى الآن';

  @override
  String get progressPeriodDay => 'يوم';

  @override
  String get progressPeriodWeek => 'أسبوع';

  @override
  String get progressPeriodMonth => 'شهر';

  @override
  String get progressFocusResultLabel => 'التركيز في هذه الفترة';

  @override
  String progressComparisonMore(String value) {
    return '$value أكثر من الفترة السابقة';
  }

  @override
  String progressComparisonLess(String value) {
    return '$value أقل من الفترة السابقة';
  }

  @override
  String get progressComparisonSame => 'مثل الفترة السابقة';

  @override
  String get progressComparisonFirst => 'أول بياناتك في هذه الفترة';

  @override
  String get progressStatExercises => 'التمارين';

  @override
  String get progressStatGoalsDone => 'الأهداف المنجزة';

  @override
  String get progressDistributionTitle => 'حسب النشاط';

  @override
  String homeTodayInline(String focus, int pages, int goals) {
    return 'اليوم: $focus تركيز · $pages صفحة · $goals هدف';
  }

  @override
  String get homePlanDayTitle => 'خطّط يومي';

  @override
  String get homePlanDaySubtitle => 'الأهداف اليومية والجدول الأسبوعي';

  @override
  String get groupsFriendsTitle => 'الأصدقاء';

  @override
  String get groupsFriendsSubtitle => 'الطلبات والدعوات ورمزك';

  @override
  String groupMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أعضاء',
      one: 'عضو واحد',
    );
    return '$_temp0';
  }

  @override
  String get createScheduleEntryButton => 'إنشاء موعد';

  @override
  String get scheduleEntryMissingFields =>
      'أكمل العنوان ووقت البدء والانتهاء للمتابعة';

  @override
  String timerSessionCounter(int current, int total) {
    return 'تركيز $current من $total';
  }

  @override
  String get timerExitBackToFocus => 'العودة إلى التركيز';

  @override
  String get timerExitSaveAndEnd => 'حفظ وإنهاء';

  @override
  String get notesSavedNow => 'تم الحفظ الآن';

  @override
  String get notesSaving => 'جارٍ الحفظ…';

  @override
  String get dailyGoalsPendingSection => 'قيد التنفيذ';

  @override
  String get dailyGoalsCompletedSection => 'مكتملة';

  @override
  String get dailyGoalsEmptyTitle => 'لا توجد أهداف لليوم بعد';

  @override
  String get dailyGoalsEmptyDescription =>
      'اكتب هدفًا في الأعلى أو اختر أحد الاقتراحات لتبدأ يومك.';

  @override
  String achievementProgressValue(String current, String total) {
    return '$current من $total';
  }

  @override
  String get categoryEmptyTitle => 'لا شيء هنا بعد';

  @override
  String get categoryEmptyDescription =>
      'أنشئ عنصرك الأول لتبدأ بتسجيل وقت تركيزك.';

  @override
  String get scheduleEmptyExampleLabel => 'مثال';

  @override
  String get progressAchievementsNextTitle => 'الإنجاز التالي';

  @override
  String get achievementFocusHourTitle => 'ساعة من التركيز';

  @override
  String get achievementSessionsTitle => '5 جلسات مكتملة';

  @override
  String get achievementStreakTitle => '7 أيام متتالية';

  @override
  String get achievementReaderTitle => '100 صفحة مقروءة';

  @override
  String get achievementGoalStartedTitle => 'بدء أول هدف';

  @override
  String unitMinutesShort(int value) {
    return '$value د';
  }

  @override
  String unitSessions(int value) {
    return '$value جلسة';
  }

  @override
  String unitDays(int value) {
    return '$value يوم';
  }

  @override
  String currentUserRankNextStepNamed(String score, String name) {
    return '$score للحاق بـ $name';
  }

  @override
  String get timerKeepAwakeNote => 'تبقى الشاشة مضاءة أثناء الجلسة';

  @override
  String scheduleWeekLabel(String date) {
    return 'أسبوع $date';
  }

  @override
  String get daysSuffix => 'أيام';

  @override
  String get createTaskSubtitle => 'اضبط هدفا يوميا لمتابعة تقدمك';

  @override
  String get createTaskSequenceTypeLabel => 'نوع التسلسل';

  @override
  String get createTaskSequenceIntenseLabel => 'مكثف';

  @override
  String get createTaskSequenceIntenseDescription =>
      'لا يسمح بالتفويت. إذا فاتك يوم واحد، يعاد ضبط تسلسلك.';

  @override
  String get createTaskSequenceCasualLabel => 'مرن';

  @override
  String get createTaskSequenceCasualDescription =>
      'أكثر مرونة. الأيام الفائتة لا تعيد ضبط تسلسلك.';

  @override
  String get targetDaysInfinite => 'بلا حدود';

  @override
  String get deleteConfirmationDefaultTypeName => 'عنصر';

  @override
  String deleteConfirmationTitle(String typeName) {
    return 'حذف $typeName؟';
  }

  @override
  String deleteConfirmationContent(String itemName) {
    return 'أنت على وشك حذف \"$itemName\". لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String deleteConfirmationHistoryWarning(String typeName) {
    return 'ستتم إزالة سجل $typeName أيضا.';
  }

  @override
  String homeDaySummaryFocusValue(String focus) {
    return '$focus ?????';
  }

  @override
  String homeDaySummaryGoalsValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أهداف',
      one: 'هدف واحد',
    );
    return '$_temp0';
  }

  @override
  String get profilePhotoSourceTitle => '???? ????? ??????';

  @override
  String get profilePhotoSourceSubtitle => '???? ??? ???? ????? ?????';

  @override
  String get photoCameraLabel => '?????? ????';

  @override
  String get photoGalleryLabel => '?????? ?? ??????';

  @override
  String get removePhotoDialogTitle => '????? ???????';

  @override
  String get removePhotoDialogContent => 'سيعود رمزك الشخصي للظهور في الملف.';

  @override
  String get friendRequestsReceivedTab => '???????';

  @override
  String get friendRequestsSentTab => '???????';

  @override
  String hobbyPracticeMinutes(int minutes) {
    return '$minutes ????? ?? ???????';
  }

  @override
  String get hobbyViewStatistics => '??? ?????????';

  @override
  String get hobbyEdit => '????? ???????';

  @override
  String get pinToStart => '????? ?? ???????';

  @override
  String get hobbyDelete => '??? ???????';

  @override
  String get deleteActionCannotBeUndone => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get joinGroupTitle => '???????? ??? ??????';

  @override
  String get joinGroupInviteCodeLabel => '??? ??????';

  @override
  String get joinGroupCodeHint => '???? ?????';

  @override
  String get joinGroupButton => '???? ??? ????????';

  @override
  String get joinGroupError => 'تعذر الانضمام إلى هذه المجموعة.';

  @override
  String get scheduleDayEventsTitle => 'جدول اليوم';

  @override
  String get dailyGoalsNoGoalsYetTitle => '?? ???? ????? ???';

  @override
  String get dailyGoalsNoGoalsYetDescription =>
      'أضف هدفك الأول لتنظيم اليوم ومتابعة إنجازاتك.';

  @override
  String get dailyGoalsSuggestionsTitle => '???????? ?????';

  @override
  String get dailyGoalsSuggestionStudy => '????? 30 ?';

  @override
  String get dailyGoalsSuggestionRead => '????? 10 ?????';

  @override
  String get dailyGoalsSuggestionTrain => '?????';

  @override
  String get goalTypeName => '???';

  @override
  String get missedYesterdayDialogTitle => '?? ?????? ????';

  @override
  String missedYesterdayDialogContent(String taskName) {
    return '?? ???? \"$taskName\" ???. ?? ???? ?????';
  }

  @override
  String get missedYesterdayMissedButton => '???? ?????';

  @override
  String get missedYesterdayCompletedButton => '??????';

  @override
  String get scheduleTitleRequiredError => 'أدخل العنوان للمتابعة';

  @override
  String get scheduleActiveFromLabel => 'يبدأ';

  @override
  String get scheduleActiveUntilLabel => 'ينتهي';

  @override
  String get selectDateTitle => 'اختيار التاريخ';

  @override
  String get selectDateHint => 'اختر يومًا من التقويم';

  @override
  String get addFriendTitle => '????? ????';

  @override
  String get friendCodeNotFound => 'لم نجد مستخدما بهذا الرمز.';

  @override
  String get friendInviteCodeTitle => '??? ??????';

  @override
  String get friendInviteCodeFieldLabel => '???? ????? ?? ?????';

  @override
  String get friendInviteCodeFieldHint => 'مثل ABCDE12345';

  @override
  String get pasteButton => '???';

  @override
  String get searchCodeButton => '??? ?? ?????';

  @override
  String get friendUserFoundTitle => '?? ?????? ??? ????????';

  @override
  String get friendFoundByCode => '?? ?????? ???? ??????';

  @override
  String get sentLabel => '?? ???????';

  @override
  String get friendHowItWorksTitle => '??? ????';

  @override
  String get friendHowItWorksStepOne => '???? ????? ?? ?????';

  @override
  String get friendHowItWorksStepTwo => '???? ????? ?????? ??? ?????';

  @override
  String get friendHowItWorksStepThree => '???? ????? ???????';

  @override
  String get myCodeLabel => '????';

  @override
  String get yourInviteCodeLabel => '??? ?????';

  @override
  String yourFriendsTitle(int count) {
    return 'أصدقاؤك ($count)';
  }

  @override
  String get seeAllButton => '??? ????';

  @override
  String get onlineLabel => '????';

  @override
  String minutesAgoShort(int minutes) {
    return '??? $minutes ?';
  }

  @override
  String get friendsEmptyTitle => '??? ???? ?????? ???';

  @override
  String get friendsEmptySubtitle => 'ابحث عن أشخاص أعلاه أو شارك رمز الدعوة.';

  @override
  String get shareCodeButton => '?????? ?????';

  @override
  String get codeCopiedMessage => '?? ??? ?????';

  @override
  String get friendRequestSentMessage => '?? ????? ?????';

  @override
  String get joinedGroupMessage => '?????? ??? ????????';

  @override
  String get friendTypeName => '????';

  @override
  String shareInviteCodeMessage(String code) {
    return 'أضفني على HelpOut باستخدام رمزي: $code';
  }

  @override
  String groupInvitesTitle(int count) {
    return 'دعوات المجموعات ($count)';
  }

  @override
  String groupInvitedBy(String inviter) {
    return 'دعاك $inviter';
  }

  @override
  String get acceptButton => '????';

  @override
  String get declineButton => '???';

  @override
  String get friendsTitle => '????????';

  @override
  String get friendRequestsReceivedPageTitle => '???????';

  @override
  String get friendRequestsSentPageTitle => '???????';

  @override
  String friendRequestsReceivedSection(int count) {
    return 'الواردة ($count)';
  }

  @override
  String friendRequestsSentSection(int count) {
    return 'المرسلة ($count)';
  }

  @override
  String get friendMutualFriendsSample => '3 ?????? ???????';

  @override
  String get pendingLabel => '??? ????????';

  @override
  String get friendRequestsIncomingEmptyTitle => '?? ???? ????? ??????';

  @override
  String get friendRequestsSentEmptyTitle => '?? ???? ????? ?????';

  @override
  String get friendRequestsIncomingEmptySubtitle => 'ستظهر الطلبات هنا.';

  @override
  String get friendRequestsSentEmptySubtitle => 'ستظهر دعواتك المرسلة هنا.';

  @override
  String get friendRequestsSafetyNotice =>
      'اقبل فقط الأشخاص الذين تعرفهم وتثق بهم.';

  @override
  String get categoryEmptyStudyingTitle => 'لا توجد مادة بعد';

  @override
  String get categoryEmptyExercisesTitle => 'لا يوجد تمرين بعد';

  @override
  String get categoryEmptyReadingTitle => 'لا توجد قراءة بعد';

  @override
  String get categoryEmptyHobbiesTitle => 'لا توجد هواية بعد';

  @override
  String get categoryEmptyStudyingDescription =>
      'أضف مادتك الأولى لتنظيم دراستك وتسجيل تركيزك.';

  @override
  String get categoryEmptyExercisesDescription =>
      'أضف تمرينك الأول لمتابعة التدريبات والجلسات والتقدم.';

  @override
  String get categoryEmptyReadingDescription =>
      'أضف قراءتك الأولى لتسجيل الصفحات والوقت والتقدم.';

  @override
  String get categoryEmptyHobbiesDescription =>
      'أضف هوايتك الأولى لتسجيل الممارسة والاستمرار.';

  @override
  String get categorySuggestionStudyingOne => 'رياضيات';

  @override
  String get categorySuggestionStudyingTwo => 'فيزياء';

  @override
  String get categorySuggestionStudyingThree => 'لغة';

  @override
  String get categorySuggestionExercisesOne => 'جري';

  @override
  String get categorySuggestionExercisesTwo => 'نادي رياضي';

  @override
  String get categorySuggestionExercisesThree => 'تمدد';

  @override
  String get categorySuggestionReadingOne => 'رواية';

  @override
  String get categorySuggestionReadingTwo => 'كتاب';

  @override
  String get categorySuggestionReadingThree => 'مقالة';

  @override
  String get categorySuggestionHobbiesOne => 'رسم';

  @override
  String get categorySuggestionHobbiesTwo => 'موسيقى';

  @override
  String get categorySuggestionHobbiesThree => 'لعبة';

  @override
  String get pagesAbbreviation => '?????';

  @override
  String get loginSecurityNote => 'بياناتك محمية وآمنة.';

  @override
  String get nextBreakDurationLabel => '??? ????????? ???????';

  @override
  String timerReadingExitContent(String duration, String subjectName) {
    return 'لقد قرأت لمدة $duration. أدخل عدد الصفحات التي قرأتها في $subjectName.';
  }

  @override
  String get appleSignInIncompleteMessage =>
      'تسجيل الدخول باستخدام Apple لم يكتمل بعد.';

  @override
  String get activityTypeLabel => 'نوع النشاط';

  @override
  String get activityTypeDailyLabel => 'يومي';

  @override
  String get activityTypeDailyDescription =>
      'يتجدد كل يوم. يعود النشاط متاحا في الصباح.';

  @override
  String get activityTypePermanentLabel => 'دائم';

  @override
  String get activityTypePermanentDescription =>
      'يبقى نشطا حتى تنهيه. بعد ذلك يتم تعليمه كمنته.';

  @override
  String get pagesSuffix => '?????';

  @override
  String get updatedSuccessfullyMessage => '?? ??????? ?????';

  @override
  String get focusSessionCountLabel => '????? ???????';

  @override
  String get groupEditingComingSoon => 'تعديل المجموعة قريبا.';

  @override
  String get leftGroupMessage => 'غادرت المجموعة.';

  @override
  String get groupImageSourceTitle => '????? ????';

  @override
  String get groupImageSourceSubtitle => '???? ??? ???? ????? ??????';

  @override
  String get deleteButton => 'حذف';

  @override
  String get manageMembersTitle => '????? ???????';

  @override
  String get groupLeaderLabel => '??????';

  @override
  String get groupLeaderRoleLabel => '???? ????????';

  @override
  String get groupMemberRoleLabel => '???';

  @override
  String get groupMembersLabel => '???????';

  @override
  String get groupActionsLabel => '??????? ????????';

  @override
  String get goalsTabLabel => '???????';

  @override
  String get chatTabLabel => '???????';

  @override
  String get groupGoalTitle => '??? ????????';

  @override
  String get groupMainRuleTitle => '??????? ????????';

  @override
  String get groupNextMilestoneTitle => '?????? ??????';

  @override
  String groupMembersProgressValue(int current, int total) {
    return '$current/$total ?????';
  }

  @override
  String get groupNextMilestoneDescription => 'لفتح شارة \"التركيز الكامل\"';

  @override
  String get groupActivityLabel => '???? ????????';

  @override
  String groupActivityReachedGoal(int reached, int total) {
    return '$reached/$total ????? ?????';
  }

  @override
  String get groupNoImagesTitle => '?? ???? ??? ???';

  @override
  String get groupNoImagesDescription => 'أرسل أول صورة للمجموعة.';

  @override
  String get groupSendImageButton => '????? ????';

  @override
  String get groupSendingImage => 'جار إرسال الصورة...';

  @override
  String get editGroupLabel => '????? ????????';

  @override
  String get leaveGroupLabel => '?????? ????????';

  @override
  String groupDescription(String metric) {
    return 'ترتيب حسب $metric. واصل التقدم مع مجموعتك.';
  }

  @override
  String groupsFriendsSubtitleWithCount(int groupCount) {
    return '????? ?????? ?$groupCount ?? ???????';
  }

  @override
  String groupGoalKeepMetric(String metric) {
    return '?????? ??? $metric ?? ???';
  }

  @override
  String groupGoalDescription(String metric) {
    return 'يسجل كل عضو $metric للحفاظ على سلسلة المجموعة نشطة.';
  }

  @override
  String groupRuleDescription(String metric) {
    return 'سجل إدخالا واحدا على الأقل من $metric يوميا لتعزيز سلسلة المجموعة.';
  }

  @override
  String get joinWithCodeButton => '??? ??? ????';

  @override
  String get groupsBenefitsHeader => 'في المجموعة يمكنك:';

  @override
  String groupParticipantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مشاركين',
      one: 'مشارك واحد',
    );
    return '$_temp0';
  }

  @override
  String groupMembersCompletedToday(int completed, int total) {
    return '$completed/$total ????? ?????? ?????';
  }

  @override
  String get addMemberButton => '????? ???';

  @override
  String get groupCollectiveProgressTitle => '?????? ???????';

  @override
  String get currentUserRankCompleteFirstGoal =>
      'أكمل هدفك الأول للدخول إلى الترتيب.';

  @override
  String get currentUserRankTiedLead => 'تعادل على الصدارة.';

  @override
  String get currentUserRankTiedFirstLabel => '????? ??? ?????? ?????';

  @override
  String rankLabel(int rank) {
    return '#$rank';
  }

  @override
  String get homeScheduleRoutineSubtitle =>
      'المواعيد القادمة والروتين الأسبوعي';

  @override
  String get homeNextCommitmentTitle => 'التالي';

  @override
  String get todayLabel => 'اليوم';

  @override
  String get statisticsTitle => '?????????';

  @override
  String get studiedTimeLabel => '??? ???????';

  @override
  String get readingTimeLabel => '??? ???????';

  @override
  String get totalPagesReadLabel => '?????? ???????';

  @override
  String get pagesReadTodayLabel => '????? ?????';

  @override
  String get goalLabel => '?????';

  @override
  String get sessionsLabel => '???????';

  @override
  String get restLabel => '??????';

  @override
  String get comparativesTitle => '?????????';

  @override
  String get overviewTitle => '???? ????';

  @override
  String get studiedUnit => '??????';

  @override
  String get readPagesUnit => '??????';

  @override
  String get versusLastMonth => '?????? ?????? ??????';

  @override
  String get versusLastWeek => '?????? ???????? ??????';

  @override
  String get noPreviousPeriodComparison => '?? ???? ???? ????? ????????';

  @override
  String get noTimeLabel => '?? ???? ???';

  @override
  String untilTimeLabel(String time) {
    return 'حتى $time';
  }

  @override
  String get achievementsUnlockedSuffix => ' /50 مفتوحة';

  @override
  String get currentLevelLabel => 'المستوى الحالي';

  @override
  String get allAchievementsUnlockedLabel => 'تم فتح كل شيء';

  @override
  String get nextUnlockLabel => 'الإنجاز التالي';

  @override
  String get allAchievementsUnlockedDescription => 'لقد فتحت كل الإنجازات.';

  @override
  String xpToGo(int xp) {
    return 'باقي $xp XP';
  }

  @override
  String levelLabel(int level) {
    return 'المستوى $level';
  }

  @override
  String get allFilterLabel => 'الكل';

  @override
  String get unlockedFilterLabel => 'مفتوحة';

  @override
  String get lockedFilterLabel => 'مقفلة';

  @override
  String get selectCategoryTooltip => 'اختر الفئة';

  @override
  String get allCategoriesLabel => 'كل الفئات';

  @override
  String get byCategoryLabel => 'حسب الفئة';

  @override
  String get allLevelsTitle => 'كل المستويات';

  @override
  String get allLevelsDescription => 'افتح الإنجازات للارتقاء في المستويات.';

  @override
  String levelPlusLabel(int level) {
    return 'المستوى $level+';
  }

  @override
  String get currentLabel => 'الحالي';

  @override
  String rankTierLearner(String tier) {
    return 'متعلم $tier';
  }

  @override
  String get achievementCategoryFocus => 'التركيز';

  @override
  String get achievementCategoryStudy => 'الدراسة';

  @override
  String get achievementCategoryReading => 'القراءة';

  @override
  String get achievementCategoryGoals => 'الأهداف';

  @override
  String get achievementCategoryLifestyle => 'نمط الحياة';

  @override
  String get achievement1Title => 'أول تركيز';

  @override
  String get achievement1Description => 'أكمل أول جلسة تركيز';

  @override
  String get achievement2Title => 'بداية 25 دقيقة';

  @override
  String get achievement2Description => 'ركز لمدة 25 دقيقة';

  @override
  String get achievement3Title => 'ساعة تركيز';

  @override
  String get achievement3Description => 'ركز لمدة ساعة واحدة';

  @override
  String get achievement4Title => 'تركيز عميق';

  @override
  String get achievement4Description => 'صل إلى ساعتين من التركيز';

  @override
  String get achievement5Title => 'بلا مشتتات';

  @override
  String get achievement5Description => 'أكمل 3 جلسات تركيز';

  @override
  String get achievement6Title => 'ماراثون التركيز';

  @override
  String get achievement6Description => 'صل إلى 10 ساعات من التركيز';

  @override
  String get achievement7Title => 'مستيقظ مبكر';

  @override
  String get achievement7Description => 'سجل تركيزا في 5 أيام';

  @override
  String get achievement8Title => 'ساهر الليل';

  @override
  String get achievement8Description => 'أكمل 10 جلسات تركيز';

  @override
  String get achievement9Title => 'سلسلة التركيز';

  @override
  String get achievement9Description => 'سجل تركيزا في 7 أيام';

  @override
  String get achievement10Title => 'سيد التركيز';

  @override
  String get achievement10Description => 'صل إلى 25 ساعة من التركيز';

  @override
  String get achievement11Title => 'بدأت الدراسة';

  @override
  String get achievement11Description => 'أنشئ أول سجل دراسة';

  @override
  String get achievement12Title => '3 جلسات';

  @override
  String get achievement12Description => 'أكمل 3 جلسات';

  @override
  String get achievement13Title => '5 جلسات';

  @override
  String get achievement13Description => 'أكمل 5 جلسات';

  @override
  String get achievement14Title => '10 جلسات';

  @override
  String get achievement14Description => 'أكمل 10 جلسات';

  @override
  String get achievement15Title => 'مستكشف المواد';

  @override
  String get achievement15Description => 'ادرس مادة واحدة على الأقل';

  @override
  String get achievement16Title => 'بطل المراجعة';

  @override
  String get achievement16Description => 'صل إلى 5 ساعات من الدراسة';

  @override
  String get achievement17Title => 'اختبار مكتمل';

  @override
  String get achievement17Description => 'أكمل 15 جلسة';

  @override
  String get achievement18Title => 'مخطط الدراسة';

  @override
  String get achievement18Description => 'أنشئ هدف تركيز';

  @override
  String get achievement19Title => 'جاهز للاختبار';

  @override
  String get achievement19Description => 'صل إلى 20 ساعة من الدراسة';

  @override
  String get achievement20Title => 'وضع الطالب';

  @override
  String get achievement20Description => 'صل إلى 50 ساعة من الدراسة';

  @override
  String get achievement21Title => 'أول صفحة';

  @override
  String get achievement21Description => 'اقرأ أول صفحة لك';

  @override
  String get achievement22Title => '10 صفحات';

  @override
  String get achievement22Description => 'اقرأ 10 صفحات';

  @override
  String get achievement23Title => '25 صفحة';

  @override
  String get achievement23Description => 'اقرأ 25 صفحة';

  @override
  String get achievement24Title => '50 صفحة';

  @override
  String get achievement24Description => 'اقرأ 50 صفحة';

  @override
  String get achievement25Title => '100 صفحة';

  @override
  String get achievement25Description => 'اقرأ 100 صفحة';

  @override
  String get achievement26Title => 'فصل مكتمل';

  @override
  String get achievement26Description => 'اقرأ 150 صفحة';

  @override
  String get achievement27Title => 'قارئ نهاية الأسبوع';

  @override
  String get achievement27Description => 'اقرأ 250 صفحة';

  @override
  String get achievement28Title => 'قارئ يومي';

  @override
  String get achievement28Description => 'اقرأ 300 صفحة';

  @override
  String get achievement29Title => 'قارئ مخلص';

  @override
  String get achievement29Description => 'اقرأ 500 صفحة';

  @override
  String get achievement30Title => 'أسطورة المكتبة';

  @override
  String get achievement30Description => 'اقرأ 1000 صفحة';

  @override
  String get achievement31Title => 'أول هدف';

  @override
  String get achievement31Description => 'أنشئ أول هدف لك';

  @override
  String get achievement32Title => 'هدف مكتمل';

  @override
  String get achievement32Description => 'أكمل هدفا';

  @override
  String get achievement33Title => 'كل الأهداف منجزة';

  @override
  String get achievement33Description => 'أنجز كل أهداف اليوم';

  @override
  String get achievement34Title => 'روتين الصباح';

  @override
  String get achievement34Description => 'أكمل أهدافا في 3 أيام';

  @override
  String get achievement35Title => 'يوم متوازن';

  @override
  String get achievement35Description => 'أكمل أهدافا في 5 أيام';

  @override
  String get achievement36Title => 'باني العادات';

  @override
  String get achievement36Description => 'أكمل أهدافا في 10 أيام';

  @override
  String get achievement37Title => 'يوم مثالي';

  @override
  String get achievement37Description => 'أكمل أهدافا في 15 يوما';

  @override
  String get achievement38Title => 'عودة قوية';

  @override
  String get achievement38Description => 'أكمل أهدافا في 20 يوما';

  @override
  String get achievement39Title => 'نجم الاستمرارية';

  @override
  String get achievement39Description => 'أكمل أهدافا في 30 يوما';

  @override
  String get achievement40Title => 'لا يمكن إيقافك';

  @override
  String get achievement40Description => 'أكمل أهدافا في 50 يوما';

  @override
  String get achievement41Title => 'أول مجموعة';

  @override
  String get achievement41Description => 'انضم إلى مجموعة دراسة';

  @override
  String get achievement42Title => 'لاعب جماعي';

  @override
  String get achievement42Description => 'نافس أصدقاءك';

  @override
  String get achievement43Title => 'صديق مساعد';

  @override
  String get achievement43Description =>
      'ساعد صديقا على الحفاظ على الاستمرارية';

  @override
  String get achievement44Title => 'فائز بالتحدي';

  @override
  String get achievement44Description => 'افز بتحد';

  @override
  String get achievement45Title => 'بدأ التمرين';

  @override
  String get achievement45Description => 'سجل تركيزا في التمرين';

  @override
  String get achievement46Title => 'تمرين 30 دقيقة';

  @override
  String get achievement46Description => 'تمرن لمدة 30 دقيقة';

  @override
  String get achievement47Title => 'وقت الهواية';

  @override
  String get achievement47Description => 'سجل تركيزا في هواية';

  @override
  String get achievement48Title => 'شرارة إبداعية';

  @override
  String get achievement48Description => 'صل إلى 30 دقيقة في الهوايات';

  @override
  String get achievement49Title => 'محارب نهاية الأسبوع';

  @override
  String get achievement49Description => 'صل إلى ساعتين من التمارين';

  @override
  String get achievement50Title => 'صائد الإنجازات';

  @override
  String get achievement50Description => 'افتح 25 إنجازا';

  @override
  String get rankTierPaper => 'ورق';

  @override
  String get rankTierWood => 'خشب';

  @override
  String get rankTierStone => 'حجر';

  @override
  String get rankTierCopper => 'نحاس';

  @override
  String get rankTierBronze => 'برونز';

  @override
  String get rankTierIron => 'حديد';

  @override
  String get rankTierSilver => 'فضة';

  @override
  String get rankTierGold => 'ذهب';

  @override
  String get rankTierPlatinum => 'بلاتين';

  @override
  String get rankTierAmethyst => 'جمشت';

  @override
  String get rankTierEmerald => 'زمرد';

  @override
  String get rankTierDiamond => 'ألماس';

  @override
  String get rankTierObsidian => 'سبج';

  @override
  String get rankTierAdamantium => 'أدامانتيوم';

  @override
  String get rankTierMithril => 'ميثريل';

  @override
  String get concentrationModeTitle => 'وضع التركيز';

  @override
  String get concentrationModeSubtitle =>
      'اختر الجلسات التي تمنع مغادرة التطبيق.';

  @override
  String get concentrationStudyTitle => 'الدراسة';

  @override
  String get concentrationStudySubtitle => 'تركيز كامل على دراستك.';

  @override
  String get concentrationExercisesTitle => 'التمارين';

  @override
  String get concentrationExercisesSubtitle => 'ابق مركزا على تدريباتك.';

  @override
  String get concentrationReadingTitle => 'القراءة';

  @override
  String get concentrationReadingSubtitle => 'انغمس في قراءاتك.';

  @override
  String get concentrationHobbiesTitle => 'الهوايات';

  @override
  String get concentrationHobbiesSubtitle => 'استمتع بهواياتك بتركيز.';

  @override
  String get createGroupDescriptionLabel => 'الوصف';

  @override
  String get createGroupDescriptionHint => 'صف المجموعة وهدفها.';

  @override
  String get createGroupThemeMetricDescription =>
      'يحدد هذا الموضوع مقياس الترتيب.';

  @override
  String get createGroupActivityTypeDescription =>
      'يحصل كل عضو على نسخة للمتابعة.';

  @override
  String get createGroupActivityNameLabel => '??? ??????';

  @override
  String get createGroupActivityNameHint => 'مثال: التفاضل I';

  @override
  String get createGroupGoalTypeLabel => '??? ?????';

  @override
  String get createGroupGoalTypeTotal => '????????';

  @override
  String get createGroupGoalTypeDaily => 'يومي';

  @override
  String get createGroupDaysGoalLabel => 'هدف الأيام';

  @override
  String get createGroupPagesGoalLabel => 'هدف الصفحات';

  @override
  String get createGroupTimeGoalMinutesLabel => 'هدف الوقت (دقيقة)';

  @override
  String get createGroupSummaryTitle => 'ملخص المجموعة';

  @override
  String get createGroupActivitySummaryLabel => 'النشاط';

  @override
  String get createGroupGuestsLabel => '????????';

  @override
  String get timerTotalTodayLabel => 'إجمالي اليوم';

  @override
  String get timerEndActionLabel => 'إنهاء';

  @override
  String get createGroupActivityStepSubtitle =>
      'اختر النشاط الذي سيقوم به جميع أعضاء المجموعة.';

  @override
  String get createGroupFriendsStepSubtitle =>
      'ادعُ صديقًا واحدًا على الأقل للانضمام.';

  @override
  String get createGroupSummaryStepSubtitle => 'راجع التفاصيل قبل الإنشاء.';

  @override
  String get createGroupStepInformation => 'المعلومات';

  @override
  String get createGroupStepActivity => 'النشاط';

  @override
  String get createGroupStepFriends => 'الأصدقاء';

  @override
  String get createGroupStepSummary => 'الملخص';

  @override
  String get createGroupDaysGoalHint => 'مثال: 30';

  @override
  String get createGroupPagesGoalHint => 'مثال: 10';

  @override
  String get createGroupMinutesGoalHint => 'مثال: 30';

  @override
  String get createGroupAddFriendsPromptTitle => 'لم تجد أحدًا؟';

  @override
  String get createGroupAddFriendsPromptDescription =>
      'أضف المزيد من الأصدقاء لتتمكن من دعوتهم.';

  @override
  String get createGroupContinueButton => 'متابعة';

  @override
  String get createGroupActivitySummaryDaily => 'هدف يومي';

  @override
  String createGroupActivitySummaryGoalDays(String days) {
    return 'الهدف • $days يوم';
  }

  @override
  String createGroupActivitySummaryReading(String pages) {
    return 'قراءة • $pages صفحة';
  }

  @override
  String createGroupActivitySummaryTime(String category, String minutes) {
    return '$category • $minutes دقيقة';
  }

  @override
  String get createGroupActivityRequiredError => 'اختر نشاطًا للمجموعة.';

  @override
  String get createGroupActivityNameRequiredError => 'أعطِ النشاط اسمًا.';

  @override
  String get createGroupActivityGoalInvalidError => 'حدد هدفًا صالحًا.';

  @override
  String get createGroupActivityMissingError => 'حدد نشاط المجموعة.';

  @override
  String get timerBackTooltip => 'رجوع';

  @override
  String get timerRestMessageTitle => 'استرح قليلًا';

  @override
  String get timerFocusLabel => 'تركيز';

  @override
  String get timerReadingLabel => 'قراءة';

  @override
  String get timerPauseLabel => 'إيقاف مؤقت';

  @override
  String get timerReadingTimeLabel => 'وقت القراءة';

  @override
  String timerTotalOfLabel(String duration) {
    return 'من $duration';
  }

  @override
  String get timerCurrentPagesLabel => 'الصفحات الحالية';

  @override
  String get timerNotesLabel => 'ملاحظات';

  @override
  String get concentrationModeSheetDescription =>
      'عند التفعيل، يساعدك التطبيق على البقاء مركزا أثناء النشاط حتى توقفه مؤقتا أو تنهيه.';

  @override
  String get timerFocusLockWarning =>
      'وضع التركيز مفعل. أنه الجلسة أو أوقفها مؤقتا للخروج.';
}
