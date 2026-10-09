import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/schedule/add_schedule_entry_page.dart";
import "package:timing/theme/theme.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets("the title field suggests an example, not the word Title", (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 4000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    Get.put<AppNavigator>(AppNavigator());

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale("pt"),
        theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const AddScheduleEntryPage(),
      ),
    );
    await tester.pump();

    final TextField title = tester.widget<TextField>(
      find.byType(TextField).first,
    );
    expect(title.decoration?.hintText, "Ex.: Aula de inglês");
    // The label above the field keeps saying what the field is.
    expect(find.text("Título"), findsWidgets);
  });
}
