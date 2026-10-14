import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/data/repositories/daily_tasks_repository.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/data/repositories/subjects_repository.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/entities/friend_option.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/create_group/create_group_bindings.dart";
import "package:timing/presentation/create_group/create_group_controller.dart";
import "package:timing/presentation/create_group/create_group_page.dart";
import "package:timing/theme/theme.dart";

SubjectEntity _subject(String id, String name, String category) =>
    SubjectEntity.fromMap({
      "id": id,
      "name": name,
      "category": category,
      "colorValue": 1,
      "totalSeconds": 0,
      "goalSeconds": 1200,
    });

DailyTaskEntity _goal(String id, String name) => DailyTaskEntity(
  id: id,
  name: name,
  colorValue: 1,
  targetDays: 30,
  completedDates: const [],
);

final List<SubjectEntity> _subjects = [
  _subject("upper", "Superior", "exercises"),
  _subject("lower", "Inferior", "exercises"),
  _subject("book", "Livro", "reading"),
];

final List<DailyTaskEntity> _goals = [
  _goal("water", "Beber água"),
  _goal("walk", "Caminhar"),
];

void main() {
  testWidgets(
    "binding resolves repositories registered with non-nullable types",
    (tester) async {
      addTearDown(() => Get.reset());
      final dailyTasks = _DailyTasksRepository();
      final subjects = _SubjectsRepository();
      Get.put<GroupsRepository>(_GroupsRepository());
      Get.put<DailyTasksRepository>(dailyTasks);
      Get.put<SubjectsRepository>(subjects);
      Get.put<AppNavigator>(AppNavigator());

      CreateGroupBindings().dependencies();
      await tester.pump();

      final controller = Get.find<CreateGroupController>();
      expect(controller.dailyTasksRepository, same(dailyTasks));
      expect(controller.subjectsRepository, same(subjects));
      expect(controller.isLoadingSources.value, isFalse);
      expect(controller.sourcesLoadFailed.value, isFalse);
    },
  );

  group("CreateGroupController", () {
    test("offers only the creator's activities of the chosen theme", () async {
      final controller = _buildController();
      await controller.loadPersonalActivities();
      expect(controller.compatibleSources, isEmpty);

      controller.onSelectTheme(GroupThemeType.exercises);
      expect(controller.compatibleSources.map((source) => source.id), [
        "upper",
        "lower",
      ]);

      controller.toggleSource("upper");
      controller.toggleSource("lower");
      // A book cannot count for an exercise group.
      controller.toggleSource("book");
      expect(controller.selectedSourceIds, {"upper", "lower"});

      controller.toggleSource("upper");
      expect(controller.selectedSourceIds, {"lower"});
      controller.onClose();
    });

    test(
      "choosing another theme drops what was picked for the first",
      () async {
        final controller = _buildController();
        await controller.loadPersonalActivities();
        controller.onSelectTheme(GroupThemeType.exercises);
        controller.toggleSource("upper");

        controller.onSelectTheme(GroupThemeType.exercises);
        expect(controller.selectedSourceIds, {"upper"});

        controller.onSelectTheme(GroupThemeType.reading);
        expect(controller.selectedSourceIds, isEmpty);
        expect(controller.compatibleSources.single.id, "book");
        controller.onClose();
      },
    );

    test("a daily-goals group takes a single goal", () async {
      final controller = _buildController();
      await controller.loadPersonalActivities();
      controller.onSelectTheme(GroupThemeType.dailyGoals);
      expect(controller.compatibleSources.map((source) => source.id), [
        "water",
        "walk",
      ]);

      controller.toggleSource("water");
      controller.toggleSource("walk");
      expect(controller.selectedSourceIds, {"walk"});

      controller.toggleSource("walk");
      expect(controller.selectedSourceIds, isEmpty);
      controller.onClose();
    });

    test("goes from the information straight to the friends", () {
      final controller = _buildController();
      controller.onInit();
      controller.groupNameController.text = "Academia";
      controller.onSelectTheme(GroupThemeType.exercises);

      controller.onTapContinue();
      expect(controller.isFriendsStep, isTrue);

      controller.onToggleFriend("friend-1");
      controller.onTapContinue();
      expect(controller.isSummaryStep, isTrue);
      expect(CreateGroupController.lastStep, 2);
      // Linking is optional: the group can be created with nothing linked.
      expect(controller.selectedSourceIds, isEmpty);
      expect(controller.canCreate.value, isTrue);
      controller.onClose();
    });

    test(
      "creates the group with its theme and the linked activities",
      () async {
        final repository = _GroupsRepository();
        final controller = _buildController(repository: repository);
        controller.onInit();
        await controller.loadFriends();
        await controller.loadPersonalActivities();
        controller.groupNameController.text = "  Academia ";
        controller.descriptionController.text = "Treino";
        controller.onSelectTheme(GroupThemeType.exercises);
        controller.toggleSource("lower");
        controller.toggleSource("upper");
        controller.onToggleFriend("friend-1");

        await controller.onTapCreate();

        expect(repository.created, hasLength(1));
        final created = repository.created.single;
        expect(created.name, "Academia");
        expect(created.theme, GroupThemeType.exercises);
        expect(created.description, "Treino");
        expect(created.invitedFriendIds, ["friend-1"]);
        // In the order the activities are listed, whatever the tap order.
        expect(created.linkedSourceIds, ["upper", "lower"]);
        expect(controller.isCreating.value, isFalse);
        controller.onClose();
      },
    );
  });

  group("CreateGroupPage", () {
    Future<CreateGroupController> pumpPage(
      WidgetTester tester, {
      _GroupsRepository? repository,
      Size screenSize = const Size(640, 1900),
    }) async {
      tester.view.devicePixelRatio = 1;
      // Most scenarios use a large canvas; focused layout tests can opt into
      // a real phone viewport.
      tester.view.physicalSize = screenSize;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(Get.reset);
      final controller = Get.put<CreateGroupController>(
        _buildController(repository: repository),
      );
      await tester.pumpWidget(
        GetMaterialApp(
          locale: const Locale("pt"),
          theme: AppThemes.build(
            seed: Colors.blue,
            brightness: Brightness.light,
          ),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const CreateGroupPage(),
        ),
      );
      await tester.pumpAndSettle();
      return controller;
    }

    testWidgets("keeps the about section concise on a phone", (tester) async {
      await pumpPage(tester, screenSize: const Size(390, 844));
      final AppLocalizations l10n = lookupAppLocalizations(const Locale("pt"));

      expect(find.text(l10n.createGroupAboutTitle), findsOneWidget);
      expect(find.text(l10n.groupNameLabel), findsOneWidget);
      expect(find.text(l10n.createGroupDescriptionLabel), findsOneWidget);
      expect(find.text("Opcional"), findsNothing);
      expect(find.text("Obrigatório"), findsNothing);
      expect(find.textContaining("Uma frase curta"), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets("has no activity step: information, friends, summary", (
      tester,
    ) async {
      await pumpPage(tester);

      expect(find.text("Informações"), findsOneWidget);
      expect(find.text("Amigos"), findsOneWidget);
      expect(find.text("Resumo"), findsOneWidget);
      expect(find.text("Atividade"), findsNothing);
      // Nothing to link until a theme says what fits.
      expect(find.text("Atividades vinculadas"), findsNothing);
    });

    testWidgets("the theme brings the creator's activities that fit it", (
      tester,
    ) async {
      final controller = await pumpPage(tester);
      final AppLocalizations l10n = lookupAppLocalizations(const Locale("pt"));

      await tester.tap(find.text(l10n.groupMetricExercises));
      await tester.pumpAndSettle();

      expect(find.text("Atividades vinculadas"), findsOneWidget);
      expect(find.text(l10n.groupLinksHintExercises), findsOneWidget);
      expect(find.text(l10n.createGroupLinksOptional), findsOneWidget);
      expect(find.text("Superior"), findsOneWidget);
      expect(find.text("Inferior"), findsOneWidget);
      expect(find.text("Livro"), findsNothing);
      expect(find.text("Criar atividade"), findsNothing);

      await tester.tap(find.text("Superior"));
      await tester.tap(find.text("Inferior"));
      await tester.pumpAndSettle();
      expect(controller.selectedSourceIds, {"upper", "lower"});
      expect(find.text("2 atividades selecionadas."), findsOneWidget);
    });

    testWidgets("a goals theme lets a single goal be picked", (tester) async {
      final controller = await pumpPage(tester);
      final AppLocalizations l10n = lookupAppLocalizations(const Locale("pt"));

      await tester.tap(find.text(l10n.groupMetricDailyGoals));
      await tester.pumpAndSettle();
      expect(find.text(l10n.groupLinksHintDailyGoals), findsOneWidget);

      await tester.tap(find.text("Beber água"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Caminhar"));
      await tester.pumpAndSettle();

      expect(controller.selectedSourceIds, {"walk"});
      expect(find.text("1 meta selecionada."), findsOneWidget);
    });

    testWidgets("the summary lists what will be linked", (tester) async {
      final controller = await pumpPage(tester);
      final AppLocalizations l10n = lookupAppLocalizations(const Locale("pt"));

      await tester.enterText(find.byType(TextField).first, "Academia");
      await tester.tap(find.text(l10n.groupMetricExercises));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Superior"));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.createGroupContinueButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Ana"));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.createGroupContinueButton));
      await tester.pumpAndSettle();

      expect(controller.isSummaryStep, isTrue);
      expect(find.text("Academia"), findsOneWidget);
      expect(find.text("Atividades vinculadas"), findsOneWidget);
      expect(find.text("Superior"), findsOneWidget);
      expect(find.text(l10n.createGroupButton), findsOneWidget);
    });

    testWidgets("does not create without a name, a theme and a friend", (
      tester,
    ) async {
      final repository = _GroupsRepository();
      final controller = await pumpPage(tester, repository: repository);

      await controller.onTapCreate();
      controller.groupNameController.text = "Academia";
      await controller.onTapCreate();
      controller.onSelectTheme(GroupThemeType.exercises);
      await controller.onTapCreate();
      expect(repository.created, isEmpty);

      controller.onToggleFriend("friend-1");
      await controller.onTapCreate();
      expect(repository.created.single.linkedSourceIds, isEmpty);
    });

    testWidgets("the summary says when nothing is linked yet", (tester) async {
      final controller = await pumpPage(tester);
      final AppLocalizations l10n = lookupAppLocalizations(const Locale("pt"));

      await tester.enterText(find.byType(TextField).first, "Leitura");
      await tester.tap(find.text(l10n.groupMetricReading));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.createGroupContinueButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Ana"));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.createGroupContinueButton));
      await tester.pumpAndSettle();

      expect(controller.isSummaryStep, isTrue);
      expect(find.text(l10n.createGroupNoLinksYet), findsOneWidget);
    });
  });
}

CreateGroupController _buildController({_GroupsRepository? repository}) =>
    CreateGroupController(
      groupsRepository: repository ?? _GroupsRepository(),
      dailyTasksRepository: _DailyTasksRepository(),
      subjectsRepository: _SubjectsRepository(),
      appNavigator: _Navigator(),
    );

typedef _CreatedGroup = ({
  String name,
  GroupThemeType theme,
  String description,
  List<String> invitedFriendIds,
  List<String> linkedSourceIds,
});

class _GroupsRepository implements GroupsRepository {
  final List<_CreatedGroup> created = [];

  @override
  Future<Either<AppError, List<FriendOption>>> getInvitableFriends() async =>
      const Right([
        (
          id: "friend-1",
          name: "Ana",
          colorValue: 0xFF2196F3,
          avatarIconIndex: null,
          profilePhotoBase64: "",
        ),
      ]);

  @override
  Future<Either<AppError, GroupEntity>> createGroup({
    required String name,
    required GroupThemeType theme,
    required List<FriendOption> invitedFriends,
    String description = "",
    List<String> linkedSourceIds = const [],
  }) async {
    created.add((
      name: name,
      theme: theme,
      description: description,
      invitedFriendIds: [for (final friend in invitedFriends) friend.id],
      linkedSourceIds: linkedSourceIds,
    ));
    // Answering with a failure keeps the test off the real navigation stack.
    return Left(
      UnexpectedError(
        cause: StateError("stop here"),
        stackTrace: StackTrace.current,
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Navigator implements AppNavigator {
  @override
  void showError(AppError error) {}

  @override
  void showErrorSnackBar([String? message]) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _DailyTasksRepository implements DailyTasksRepository {
  @override
  Future<Either<AppError, List<DailyTaskEntity>>> getTasks() async =>
      Right(_goals);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SubjectsRepository implements SubjectsRepository {
  @override
  Future<Either<AppError, List<SubjectEntity>>> getSubjects() async =>
      Right(_subjects);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
