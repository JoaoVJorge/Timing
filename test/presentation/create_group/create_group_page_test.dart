import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/domain/entities/friend_option.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/create_group/create_group_controller.dart";
import "package:timing/presentation/create_group/create_group_page.dart";
import "package:timing/theme/theme.dart";

class _GroupsRepository implements GroupsRepository {
  @override
  Future<Either<AppError, List<FriendOption>>> getInvitableFriends() async =>
      const Right([]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<CreateGroupController> _pumpPage(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  final controller = CreateGroupController(
    groupsRepository: _GroupsRepository(),
    appNavigator: AppNavigator(),
  );
  Get.put(controller);

  await tester.pumpWidget(
    GetMaterialApp(
      theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
      locale: const Locale("pt"),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const CreateGroupPage(),
    ),
  );
  await tester.pumpAndSettle();
  return controller;
}

void main() {
  tearDown(Get.reset);

  testWidgets("keeps the first step compact after choosing a theme", (
    tester,
  ) async {
    await _pumpPage(tester);

    expect(find.text("Novo grupo"), findsOneWidget);
    expect(find.textContaining("1/3"), findsNothing);
    expect(find.text("Tema do ranking"), findsOneWidget);
    expect(find.text("Horas focadas"), findsOneWidget);
    expect(
      find.text(
        "Depois você escolhe quais atividades contam para o ranking.",
      ),
      findsOneWidget,
    );

    await tester.tap(find.text("Estudos"));
    await tester.pumpAndSettle();

    expect(find.text("Atividades vinculadas"), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets("shows the current step and back returns to the previous one", (
    tester,
  ) async {
    final controller = await _pumpPage(tester);
    controller.currentStep.value = 1;
    await tester.pump();

    expect(find.text("Novo grupo"), findsOneWidget);
    expect(find.textContaining("2/3"), findsNothing);

    controller.onTapBack();
    await tester.pump();

    expect(controller.currentStep.value, 0);
    expect(find.text("Novo grupo"), findsOneWidget);
    expect(find.textContaining("1/3"), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
