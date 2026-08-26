import "package:dartz/dartz.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/domain/entities/group_activity_progress_entity.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/entities/group_member_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/get_groups_use_case.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/presentation/groups/groups_controller.dart";

class _FakeGroupsRepository implements GroupsRepository {
  _FakeGroupsRepository(this.groupsResult);

  List<GroupEntity> groupsResult;
  final Map<String, List<GroupActivityProgressEntity>> progressByGroup =
      <String, List<GroupActivityProgressEntity>>{};
  final List<String> progressRequests = <String>[];

  @override
  Future<Either<AppError, List<GroupEntity>>> getGroups() async =>
      Right(groupsResult);

  @override
  Future<Either<AppError, List<GroupActivityProgressEntity>>>
  getGroupActivityProgress(String groupId, {String? localDate}) async {
    progressRequests.add(groupId);
    return Right(progressByGroup[groupId] ?? const []);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSupabaseService implements SupabaseService {
  @override
  String? get currentUserId => "me";

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAppNavigator implements AppNavigator {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeLocalStorageService implements AppLocalStorageService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  tearDown(Get.reset);

  group("GroupsController refreshAfterActivityChange", () {
    test(
      "keeps the affected group selected and reloads its goal status",
      () async {
        final GroupEntity firstGroup = _group("group-1", "Primeiro");
        final GroupEntity affectedGroup = _group("group-2", "Segundo");
        final _FakeGroupsRepository repository = _FakeGroupsRepository([
          firstGroup,
          affectedGroup,
        ]);
        repository.progressByGroup["group-2"] = const [
          GroupActivityProgressEntity(
            activityId: "activity-2",
            kind: "goal",
            name: "Beber agua",
            memberId: "me",
            progress: 1,
            target: 1,
            reached: true,
          ),
        ];
        final GroupsController controller = _controller(repository);
        await controller.loadGroups();
        controller.selectedGroup.value = affectedGroup;
        controller.selectedDetailsTab.value = GroupDetailsTab.goals;

        await controller.refreshAfterActivityChange(groupId: "group-2");

        expect(controller.selectedGroup.value?.id, "group-2");
        expect(repository.progressRequests, ["group-2"]);
        expect(controller.activityProgress.single.reached, true);
      },
    );
  });
}

GroupsController _controller(_FakeGroupsRepository repository) =>
    GroupsController(
      getGroupsUseCase: GetGroupsUseCase(groupsRepository: repository),
      groupsRepository: repository,
      appNavigator: _FakeAppNavigator(),
      supabaseService: _FakeSupabaseService(),
      localStorageService: _FakeLocalStorageService(),
    );

GroupEntity _group(String id, String name) => GroupEntity(
  id: id,
  name: name,
  theme: GroupThemeType.dailyGoals,
  members: const [
    GroupMemberEntity(
      id: "me",
      name: "Eu",
      avatarColorValue: 1,
      todaySeconds: 0,
      weekSeconds: 0,
      monthSeconds: 0,
    ),
  ],
);
