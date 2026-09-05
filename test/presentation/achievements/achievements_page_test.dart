import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/achievements/achievements_controller.dart";
import "package:timing/presentation/achievements/achievements_models.dart";
import "package:timing/presentation/achievements/achievements_page.dart";
import "package:timing/shared/widgets/app_skeleton.dart";
import "package:timing/theme/theme.dart";

class _FakeAchievementsController extends GetxController
    implements AchievementsController {
  _FakeAchievementsController({required bool loading})
    : isLoading = loading.obs;

  @override
  final RxBool isLoading;

  @override
  final Rx<AchievementFilter> selectedFilter = AchievementFilter.all.obs;

  @override
  final Rxn<AchievementCategory> selectedCategory = Rxn<AchievementCategory>();

  final AchievementDefinition achievement = const AchievementDefinition(
    id: 1,
    category: AchievementCategory.focus,
    icon: Icons.bolt_rounded,
    color: Colors.blue,
    title: "Primeiro foco",
    description: "Conclua sua primeira sessão.",
    isUnlocked: false,
  );

  void _observe() {
    selectedFilter.value;
  }

  @override
  List<AchievementDefinition> get filteredAchievements {
    _observe();
    return [achievement];
  }

  @override
  int get unlockedCount {
    _observe();
    return 0;
  }

  @override
  AchievementDefinition? get nextUnlock {
    _observe();
    return achievement;
  }

  @override
  RankTier get currentTier {
    _observe();
    return RankTier.paper;
  }

  @override
  int get level {
    _observe();
    return 1;
  }

  @override
  int get levelXp {
    _observe();
    return 0;
  }

  @override
  double get levelProgress {
    _observe();
    return 0;
  }

  @override
  void onBack() {}

  @override
  void onSelectFilter(AchievementFilter filter) {
    selectedFilter.value = filter;
  }

  @override
  void onSelectCategory(AchievementCategory? category) {
    selectedCategory.value = category;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Future<void> _pumpPage(
  WidgetTester tester,
  _FakeAchievementsController controller,
) async {
  Get.put<AchievementsController>(controller);
  await tester.pumpWidget(
    GetMaterialApp(
      theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
      locale: const Locale("pt"),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const AchievementsPage(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets("renders the achievements loading skeleton", (tester) async {
    await _pumpPage(tester, _FakeAchievementsController(loading: true));

    expect(find.byType(AppSkeleton), findsOneWidget);
    expect(find.byType(AppSkeletonBox), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets("opens the achievement details dialog", (tester) async {
    await _pumpPage(tester, _FakeAchievementsController(loading: false));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Primeiro foco").last);
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Conclua sua primeira sessão."), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
