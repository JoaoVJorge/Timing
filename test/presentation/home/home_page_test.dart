import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/core/domain/entities/daily_progress_entity.dart";
import "package:timing/core/domain/entities/schedule_entry_entity.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/home/home_controller.dart";
import "package:timing/presentation/home/home_page.dart";
import "package:timing/shared/widgets/app_skeleton.dart";
import "package:timing/theme/theme.dart";

class _FakeHomeController extends GetxController implements HomeController {
  @override
  final RxBool isLoading = true.obs;
  @override
  final RxString userName = "".obs;
  @override
  final RxInt currentStreak = 0.obs;
  @override
  final Rx<DailyProgressEntity> todayProgress = const DailyProgressEntity().obs;
  @override
  final RxList<SubjectEntity> subjects = <SubjectEntity>[].obs;

  final Rx<ScheduleEntryEntity?> nextEntry = Rx<ScheduleEntryEntity?>(null);

  @override
  ScheduleEntryEntity? get nextTodayEntry => nextEntry.value;
  @override
  SubjectEntity? get resumableSubject => subjects.firstOrNull;
  @override
  SubjectEntity? get suggestedSubject => subjects.firstOrNull;
  @override
  int get goalsTotal => 0;
  @override
  int get goalsDoneToday => 0;
  @override
  bool hasSubjectsIn(TimeCategoryType category) => subjects.isNotEmpty;
  @override
  String emptyCategoryValue(BuildContext context, TimeCategoryType category) =>
      "Empty";

  @override
  Future<void> onCreateFirstSubject() async {}
  @override
  Future<void> onTapDailyGoals() async {}
  @override
  Future<void> onTapSchedule() async {}
  @override
  Future<void> onTapCategory(TimeCategoryType category) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  tearDown(Get.reset);

  for (final Brightness brightness in Brightness.values) {
    testWidgets("planning subtitles shimmer only while loading ($brightness)", (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final _FakeHomeController controller = _FakeHomeController();
      Get.put<HomeController>(controller);

      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppThemes.build(seed: Colors.blue, brightness: brightness),
          locale: const Locale("en"),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const HomePage(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      final AppLocalizations l10n = tester.element(find.byType(HomePage)).l10n;
      expect(find.byType(AppSkeleton), findsNWidgets(2));
      expect(find.text(l10n.homeTasksSection), findsOneWidget);
      expect(find.text(l10n.homeNextCommitmentTitle), findsOneWidget);
      expect(find.text(l10n.dailyGoalsEmptyTitle), findsNothing);
      expect(find.text(l10n.homeScheduleRoutineSubtitle), findsNothing);
      expect(tester.takeException(), isNull);

      controller.isLoading.value = false;
      await tester.pumpAndSettle();

      expect(find.byType(AppSkeleton), findsNothing);
      expect(find.text(l10n.dailyGoalsEmptyTitle), findsOneWidget);
      expect(find.text(l10n.homeScheduleRoutineSubtitle), findsOneWidget);
      expect(tester.takeException(), isNull);

      controller.isLoading.value = true;
      await tester.pump();
      expect(find.byType(AppSkeleton), findsNWidgets(2));
      expect(find.text(l10n.dailyGoalsEmptyTitle), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
