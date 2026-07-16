import "package:dartz/dartz.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/core/domain/entities/group_entity.dart";
import "package:help_out/core/domain/entities/group_member_entity.dart";
import "package:help_out/core/domain/enums/leaderboard_period_type.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/get_groups_use_case.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

class GroupsController extends GetxController {
  GroupsController({
    required this._getGroupsUseCase,
    required this._appNavigator,
  });

  final GetGroupsUseCase _getGroupsUseCase;
  final AppNavigator _appNavigator;

  final RxList<GroupEntity> groups = <GroupEntity>[].obs;
  final Rx<GroupEntity?> selectedGroup = Rx<GroupEntity?>(null);
  final Rx<LeaderboardPeriodType> selectedPeriod =
      LeaderboardPeriodType.today.obs;
  final RxBool isLoading = true.obs;
  static const String currentUserId = "me";

  List<GroupMemberEntity> get rankedMembers {
    final GroupEntity? group = selectedGroup.value;
    if (group == null) {
      return const [];
    }
    final List<GroupMemberEntity> members = List.of(group.members)
      ..sort(
        (a, b) => b
            .secondsFor(selectedPeriod.value)
            .compareTo(a.secondsFor(selectedPeriod.value)),
      );
    return members;
  }

  GroupMemberEntity? get currentUserMember {
    for (final GroupMemberEntity member in rankedMembers) {
      if (isCurrentUser(member)) {
        return member;
      }
    }
    return null;
  }

  int get currentUserRank {
    final int index = rankedMembers.indexWhere(isCurrentUser);
    return index < 0 ? 0 : index + 1;
  }

  int? differenceToPrevious(GroupMemberEntity member) {
    final List<GroupMemberEntity> members = rankedMembers;
    final int index = members.indexWhere((item) => item.id == member.id);
    if (index <= 0) {
      return null;
    }
    return members[index - 1].secondsFor(selectedPeriod.value) -
        member.secondsFor(selectedPeriod.value);
  }

  bool isCurrentUser(GroupMemberEntity member) => member.id == currentUserId;

  @override
  void onInit() {
    super.onInit();
    loadGroups();
  }

  Future<void> loadGroups() async {
    isLoading.value = true;
    final Either<AppError, List<GroupEntity>> result =
        await _getGroupsUseCase();
    result.fold((error) => groups.clear(), (value) {
      // Copy so the controller's list doesn't alias the data source's mutable
      // store — otherwise a created group appears in both the store add and the
      // controller add below, showing up twice.
      groups.value = List.of(value);
      selectedGroup.value = value.isEmpty ? null : value.first;
    });
    isLoading.value = false;
  }

  void onSelectGroup(GroupEntity group) => selectedGroup.value = group;

  void onSelectPeriod(LeaderboardPeriodType period) =>
      selectedPeriod.value = period;

  Future<void> onTapCreateGroup() async {
    // Get.toNamed<T> with a concrete type crashes at runtime (GetX types the
    // route result future as dynamic internally), so await dynamic and cast.
    final dynamic result = await _appNavigator.toNamed(AppRoutes.createGroup);
    final GroupEntity? newGroup = result as GroupEntity?;
    if (newGroup == null) {
      return;
    }
    final int existingIndex = groups.indexWhere(
      (group) => group.id == newGroup.id,
    );
    if (existingIndex >= 0) {
      groups[existingIndex] = newGroup;
    } else {
      groups.add(newGroup);
    }
    selectedGroup.value = newGroup;
    groups.refresh();
    _appNavigator.showSuccessSnackBar(Get.context!.l10n.groupCreatedSuccess);
  }
}
