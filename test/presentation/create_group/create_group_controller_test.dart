import "package:get/get.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:dartz/dartz.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/data/repositories/daily_tasks_repository.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/data/repositories/subjects_repository.dart";
import "package:timing/core/domain/entities/friend_option.dart";
import "package:timing/core/domain/entities/group_activity_draft.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/get_daily_tasks_use_case.dart";
import "package:timing/core/domain/use_cases/get_subjects_use_case.dart";
import "package:timing/core/domain/use_cases/create_group_use_case.dart";
import "package:timing/core/domain/use_cases/get_invitable_friends_use_case.dart";
import "package:timing/presentation/create_group/create_group_controller.dart";

void main() {
  group("CreateGroupController", () {
    test(
      "selects multiple compatible sources without changing personal goals",
      () {
        final controller = _buildController();
        controller.onInit();
        controller.onSelectTheme(GroupThemeType.exercises);
        final upper = SubjectEntity.fromMap(const {
          "id": "upper",
          "name": "Superior",
          "category": "exercises",
          "colorValue": 1,
          "totalSeconds": 900,
          "goalSeconds": 1200,
        });
        final lower = SubjectEntity.fromMap(const {
          "id": "lower",
          "name": "Inferior",
          "category": "exercises",
          "colorValue": 2,
          "totalSeconds": 300,
          "goalSeconds": 1800,
        });
        controller.personalSubjects.assignAll([
          upper,
          lower,
          SubjectEntity.fromMap(const {
            "id": "book",
            "name": "Livro",
            "category": "reading",
            "colorValue": 1,
            "totalSeconds": 0,
          }),
        ]);
        controller.setUseExistingActivities(true);
        controller.toggleSource("upper");
        expect(controller.activityGoalController.text, "20");
        controller.activityNameController.text = "Academia";
        controller.activityGoalController.text = "60";
        controller.toggleSource("lower");
        controller.toggleSource("book");
        final draft = controller.buildActivityDraft()!;
        expect(draft.sourceIds, ["upper", "lower"]);
        expect(draft.goalSeconds, 3600);
        expect(draft.name, "Academia");
        expect(upper.goalSeconds, 1200);
        expect(lower.goalSeconds, 1800);
        expect(draft.toPayload()["source_ids"], ["upper", "lower"]);
        controller.onSelectTheme(GroupThemeType.reading);
        expect(controller.selectedSourceIds, isEmpty);
        expect(controller.hasActivity, isFalse);
        controller.onClose();
      },
    );

    test("new activity mode does not submit previously selected sources", () {
      final controller = _buildController();
      controller.onSelectTheme(GroupThemeType.dailyGoals);
      controller.activityNameController.text = "Rotina";
      controller.selectedSourceIds.addAll(["water", "walk"]);
      controller.setUseExistingActivities(true);
      expect(controller.buildActivityDraft()!.sourceIds, ["water", "walk"]);
      controller.setUseExistingActivities(false);
      expect(
        controller.buildActivityDraft()!.toPayload().containsKey("source_ids"),
        isFalse,
      );
      controller.onClose();
    });

    test("builds a daily goal draft for daily goals groups", () {
      final CreateGroupController controller = _buildController();
      controller.onSelectTheme(GroupThemeType.dailyGoals);
      expect(controller.activityGoalController.text, "5");

      controller.activityNameController.text = "Beber água";
      controller.activityGoalController.text = "14";

      final GroupActivityDraft? draft = controller.buildActivityDraft();

      expect(draft, isNotNull);
      expect(draft!.kind, GroupActivityKind.goal);
      expect(draft.toPayload(), {
        "name": "Beber água",
        "color_value": controller.selectedColor.value.toARGB32(),
        "target_days": 14,
        "sequence_type": "casual",
        "goal_type": "total",
      });
    });

    test("builds hobbies without rest or multiple sections", () {
      final CreateGroupController controller = _buildController();
      controller.onSelectTheme(GroupThemeType.hobbies);
      controller.activityNameController.text = "Pintura";
      controller.activityGoalController.text = "45";
      controller.setRestMinutes(15);
      controller.setFocusSessionCount(3);

      final GroupActivityDraft? draft = controller.buildActivityDraft();

      expect(draft, isNotNull);
      expect(draft!.category, TimeCategoryType.hobbies);
      expect(draft.restMinutes, 0);
      expect(draft.focusSessionCount, 1);
      expect(draft.goalSeconds, 45 * 60);
    });

    test("uses the group name as the default activity name", () {
      final CreateGroupController controller = _buildController();
      controller.onInit();
      controller.onSelectTheme(GroupThemeType.dailyGoals);
      controller.groupNameController.text = "Desafio da família";

      controller.onTapContinue();

      expect(controller.currentStep.value, 1);
      expect(controller.activityNameController.text, "Desafio da família");
      controller.onClose();
    });

    test("preserves a custom activity name when the group name changes", () {
      final CreateGroupController controller = _buildController();
      controller.onInit();
      controller.activityNameController.text = "Beber água";

      controller.groupNameController.text = "Desafio da família";

      expect(controller.activityNameController.text, "Beber água");
      controller.onClose();
    });
  });
}

CreateGroupController _buildController() {
  final _NoopGroupsRepository repository = _NoopGroupsRepository();
  return CreateGroupController(
    getInvitableFriendsUseCase: GetInvitableFriendsUseCase(
      groupsRepository: repository,
    ),
    createGroupUseCase: CreateGroupUseCase(groupsRepository: repository),
    getDailyTasksUseCase: GetDailyTasksUseCase(
      dailyTasksRepository: _NoopDailyTasksRepository(),
    ),
    getSubjectsUseCase: GetSubjectsUseCase(
      subjectsRepository: _NoopSubjectsRepository(),
    ),
    appNavigator: AppNavigator(),
  );
}

class _NoopGroupsRepository implements GroupsRepository {
  @override
  Future<Either<AppError, List<FriendOption>>> getInvitableFriends() async =>
      const Right([]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoopDailyTasksRepository implements DailyTasksRepository {
  @override
  Future<Either<AppError, List<DailyTaskEntity>>> getTasks() async =>
      const Right([]);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoopSubjectsRepository implements SubjectsRepository {
  @override
  Future<Either<AppError, List<SubjectEntity>>> getSubjects() async =>
      const Right([]);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
