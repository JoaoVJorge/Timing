import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/faq/faq_controller.dart";
import "package:timing/presentation/faq/faq_page.dart";
import "package:timing/theme/theme.dart";

void main() {
  Future<AppLocalizations> pumpFaq(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(Get.reset);

    Get.put<AppNavigator>(AppNavigator());
    Get.put<FaqController>(FaqController());

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale("pt"),
        theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const FaqPage(),
      ),
    );
    await tester.pumpAndSettle();

    return AppLocalizations.of(tester.element(find.byType(FaqPage)));
  }

  testWidgets("lists every question and opens its answer", (tester) async {
    final AppLocalizations l10n = await pumpFaq(tester);
    final FaqController controller = Get.find();
    final List<FaqEntry> entries = controller.entries(
      tester.element(find.byType(FaqPage)),
    );

    expect(entries.length, 13);
    expect(find.text(l10n.faqTitle), findsOneWidget);

    // Every question is reachable and carries its own answer.
    for (final FaqEntry entry in entries) {
      await tester.scrollUntilVisible(find.text(entry.question), 120);
      expect(find.text(entry.answer), findsOneWidget);
    }
  });

  testWidgets("tapping a question expands only that card", (tester) async {
    await pumpFaq(tester);
    final FaqController controller = Get.find();
    final List<FaqEntry> entries = controller.entries(
      tester.element(find.byType(FaqPage)),
    );

    CrossFadeState stateOf(String question) => tester
        .widget<AnimatedCrossFade>(
          find.ancestor(
            of: find.text(
              entries.firstWhere((e) => e.question == question).answer,
            ),
            matching: find.byType(AnimatedCrossFade),
          ),
        )
        .crossFadeState;

    expect(stateOf(entries.first.question), CrossFadeState.showFirst);

    await tester.tap(find.text(entries.first.question));
    await tester.pumpAndSettle();

    expect(stateOf(entries.first.question), CrossFadeState.showSecond);
    expect(stateOf(entries[1].question), CrossFadeState.showFirst);
  });
}
