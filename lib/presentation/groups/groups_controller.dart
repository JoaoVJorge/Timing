import "package:dartz/dartz.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/core/domain/entities/group_entity.dart";
import "package:help_out/core/domain/entities/group_member_entity.dart";
import "package:help_out/core/domain/enums/leaderboard_period_type.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/get_groups_use_case.dart";
import "package:help_out/core/services/supabase/supabase_service.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

enum GroupDetailsTab { ranking, goals, chat }

class GroupsController extends GetxController {
  GroupsController({
    required this._getGroupsUseCase,
    required this._appNavigator,
    required this._supabaseService,
  });

  final GetGroupsUseCase _getGroupsUseCase;
  final AppNavigator _appNavigator;
  final SupabaseService _supabaseService;

  final RxList<GroupEntity> groups = <GroupEntity>[].obs;
  final Rx<GroupEntity?> selectedGroup = Rx<GroupEntity?>(null);
  final Rx<LeaderboardPeriodType> selectedPeriod =
      LeaderboardPeriodType.today.obs;
  final Rx<GroupDetailsTab> selectedDetailsTab = GroupDetailsTab.ranking.obs;
  final RxBool isLoading = true.obs;
  final RxBool isShowingGroupDetails = false.obs;
  final RxBool isShowingMemberManagement = false.obs;

  String get currentUserId => _supabaseService.currentUserId ?? "";

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
    final GroupMemberEntity? member = currentUserMember;
    return member == null ? 0 : rankOf(member);
  }

  int rankOf(GroupMemberEntity member) {
    final int value = member.secondsFor(selectedPeriod.value);
    return rankedMembers
            .where((item) => item.secondsFor(selectedPeriod.value) > value)
            .length +
        1;
  }

  bool get currentUserIsTiedForFirst {
    final GroupMemberEntity? member = currentUserMember;
    if (member == null || rankOf(member) != 1) {
      return false;
    }
    final int value = member.secondsFor(selectedPeriod.value);
    return rankedMembers
            .where((item) => item.secondsFor(selectedPeriod.value) == value)
            .length >
        1;
  }

  /// Member ranked immediately above the current user, used to turn "2nd place"
  /// into a concrete target.
  GroupMemberEntity? get memberAheadOfCurrentUser {
    final List<GroupMemberEntity> members = rankedMembers;
    final int index = members.indexWhere(isCurrentUser);
    if (index <= 0) {
      return null;
    }
    final int currentValue = members[index].secondsFor(selectedPeriod.value);
    for (int i = index - 1; i >= 0; i--) {
      if (members[i].secondsFor(selectedPeriod.value) > currentValue) {
        return members[i];
      }
    }
    return null;
  }

  int? differenceToPrevious(GroupMemberEntity member) {
    final List<GroupMemberEntity> members = rankedMembers;
    final int index = members.indexWhere((item) => item.id == member.id);
    if (index <= 0) {
      return null;
    }
    final int value = member.secondsFor(selectedPeriod.value);
    GroupMemberEntity? previous;
    for (int i = index - 1; i >= 0; i--) {
      if (members[i].secondsFor(selectedPeriod.value) > value) {
        previous = members[i];
        break;
      }
    }
    if (previous == null) {
      return 0;
    }
    return previous.secondsFor(selectedPeriod.value) - value;
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

  void onSelectGroup(GroupEntity group) {
    selectedGroup.value = group;
    selectedDetailsTab.value = GroupDetailsTab.ranking;
    isShowingGroupDetails.value = true;
    isShowingMemberManagement.value = false;
  }

  void onBackToGroupList() {
    isShowingMemberManagement.value = false;
    isShowingGroupDetails.value = false;
  }

  void onManageMembers() => isShowingMemberManagement.value = true;

  void onBackToGroupDetails() => isShowingMemberManagement.value = false;

  void onSelectDetailsTab(GroupDetailsTab tab) =>
      selectedDetailsTab.value = tab;

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

  /// Friends live next to Groups: both answer "how am I doing with others?".
  Future<void> onTapFriends() =>
      _appNavigator.toNamed(AppRoutes.friends, id: 1) ?? Future<void>.value();

  void onTapEditGroup() {
    final String message = switch (Get.context?.languageCode) {
      "pt" => "Edicao de grupo em breve.",
      "es" => "Edicion del grupo proximamente.",
      _ => "Group editing is coming soon.",
    };
    _appNavigator.showSnackBar(text: message);
  }

  void onTapLeaveGroup() {
    final String message = switch (Get.context?.languageCode) {
      "pt" => "Saida de grupo em breve.",
      "es" => "Salir del grupo proximamente.",
      _ => "Leaving groups is coming soon.",
    };
    _appNavigator.showSnackBar(text: message, isAnError: true);
  }

  void onTapJoinWithCode() {
    final String message = switch (Get.context?.languageCode) {
      "pt" => "Entrada por código de convite em breve.",
      "es" => "Unirse con código estará disponible pronto.",
      _ => "Joining with an invite code is coming soon.",
    };
    _appNavigator.showSnackBar(text: message);
  }
}
