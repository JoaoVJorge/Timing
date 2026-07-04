import "package:dartz/dartz.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/core/domain/entities/group_entity.dart";
import "package:help_out/core/domain/entities/group_member_entity.dart";
import "package:help_out/core/domain/enums/leaderboard_period_type.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/get_groups_use_case.dart";

class GroupsController extends GetxController {
  GroupsController({required this._getGroupsUseCase, required this._appNavigator});

  final GetGroupsUseCase _getGroupsUseCase;
  final AppNavigator _appNavigator;

  final RxList<GroupEntity> groups = <GroupEntity>[].obs;
  final Rx<GroupEntity?> selectedGroup = Rx<GroupEntity?>(null);
  final Rx<LeaderboardPeriodType> selectedPeriod = LeaderboardPeriodType.today.obs;
  final RxBool isLoading = true.obs;

  List<GroupMemberEntity> get rankedMembers {
    final GroupEntity? group = selectedGroup.value;
    if (group == null) {
      return const [];
    }
    final List<GroupMemberEntity> members = List.of(group.members)
      ..sort((a, b) => b.secondsFor(selectedPeriod.value).compareTo(a.secondsFor(selectedPeriod.value)));
    return members;
  }

  @override
  void onInit() {
    super.onInit();
    loadGroups();
  }

  Future<void> loadGroups() async {
    isLoading.value = true;
    final Either<AppError, List<GroupEntity>> result = await _getGroupsUseCase();
    result.fold((error) => groups.clear(), (value) {
      groups.value = value;
      selectedGroup.value = value.isEmpty ? null : value.first;
    });
    isLoading.value = false;
  }

  void onSelectGroup(GroupEntity group) => selectedGroup.value = group;

  void onSelectPeriod(LeaderboardPeriodType period) => selectedPeriod.value = period;

  Future<void> onTapCreateGroup() async {
    final dynamic result = await _appNavigator.toNamed(AppRoutes.createGroup);
    final GroupEntity? newGroup = result as GroupEntity?;
    if (newGroup == null) {
      return;
    }
    groups.add(newGroup);
    selectedGroup.value = newGroup;
  }
}
