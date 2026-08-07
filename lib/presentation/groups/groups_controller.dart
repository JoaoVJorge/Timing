import "dart:convert";

import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/core/data/repositories/groups_repository.dart";
import "package:help_out/core/domain/entities/group_entity.dart";
import "package:help_out/core/domain/entities/group_image_message_entity.dart";
import "package:help_out/core/domain/entities/group_member_entity.dart";
import "package:help_out/core/domain/enums/leaderboard_period_type.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/get_groups_use_case.dart";
import "package:help_out/core/services/supabase/supabase_service.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/photo_source_bottom_sheet.dart";
import "package:image_picker/image_picker.dart";

enum GroupDetailsTab { ranking, goals, chat }

class GroupsController extends GetxController {
  GroupsController({
    required this._getGroupsUseCase,
    required this._groupsRepository,
    required this._appNavigator,
    required this._supabaseService,
  });

  final GetGroupsUseCase _getGroupsUseCase;
  final GroupsRepository _groupsRepository;
  final AppNavigator _appNavigator;
  final SupabaseService _supabaseService;
  final ImagePicker _imagePicker = ImagePicker();

  final RxList<GroupEntity> groups = <GroupEntity>[].obs;
  final Rx<GroupEntity?> selectedGroup = Rx<GroupEntity?>(null);
  final Rx<LeaderboardPeriodType> selectedPeriod =
      LeaderboardPeriodType.today.obs;
  final Rx<GroupDetailsTab> selectedDetailsTab = GroupDetailsTab.ranking.obs;
  final RxBool isLoading = true.obs;
  final RxBool isShowingGroupDetails = false.obs;
  final RxBool isShowingMemberManagement = false.obs;
  final RxBool isLoadingChat = false.obs;
  final RxBool isSendingImage = false.obs;
  final RxMap<String, List<GroupImageMessageEntity>> imageMessagesByGroup =
      <String, List<GroupImageMessageEntity>>{}.obs;

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
    _appNavigator.toNamed(AppRoutes.groupDetails);
  }

  void onBackToGroupList() {
    isShowingMemberManagement.value = false;
    isShowingGroupDetails.value = false;
    if (Get.currentRoute == AppRoutes.groupDetails) {
      _appNavigator.back<void>();
    }
  }

  void onManageMembers() => isShowingMemberManagement.value = true;

  void onBackToGroupDetails() => isShowingMemberManagement.value = false;

  void onSelectDetailsTab(GroupDetailsTab tab) {
    selectedDetailsTab.value = tab;
    if (tab == GroupDetailsTab.chat) {
      final String? groupId = selectedGroup.value?.id;
      if (groupId != null) {
        loadImageMessages(groupId);
      }
    }
  }

  List<GroupImageMessageEntity> imageMessagesFor(String groupId) =>
      imageMessagesByGroup[groupId] ?? const [];

  Future<void> loadImageMessages(String groupId) async {
    isLoadingChat.value = true;
    final Either<AppError, List<GroupImageMessageEntity>> result =
        await _groupsRepository.getImageMessages(groupId);
    result.fold(
      (error) => _appNavigator.showErrorSnackBar(),
      (messages) => imageMessagesByGroup[groupId] = messages,
    );
    isLoadingChat.value = false;
  }

  Future<void> onTapSendGroupImage(String groupId) async {
    final ImageSource? source = await _pickImageSource();
    if (source == null) {
      return;
    }
    final XFile? image = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 78,
    );
    if (image == null) {
      return;
    }

    isSendingImage.value = true;
    final List<int> bytes = await image.readAsBytes();
    final Either<AppError, GroupImageMessageEntity> result =
        await _groupsRepository.sendImageMessage(
          groupId: groupId,
          imageBase64: base64Encode(bytes),
        );
    result.fold((error) => _appNavigator.showErrorSnackBar(), (message) {
      final List<GroupImageMessageEntity> current = imageMessagesFor(groupId);
      imageMessagesByGroup[groupId] = [...current, message];
    });
    isSendingImage.value = false;
  }

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
      _appNavigator.toNamed(AppRoutes.friends) ?? Future<void>.value();

  void onTapEditGroup() {
    final String message = switch (Get.context?.languageCode) {
      "pt" => "Edição de grupo em breve.",
      "es" => "Edición del grupo próximamente.",
      _ => "Group editing is coming soon.",
    };
    _appNavigator.showSnackBar(text: message);
  }

  Future<void> onTapLeaveGroup() async {
    await onConfirmLeaveGroup();
  }

  Future<void> onConfirmLeaveGroup() async {
    final GroupEntity? group = selectedGroup.value;
    if (group == null) {
      return;
    }

    final Either<AppError, void> result = await _groupsRepository.leaveGroup(
      group.id,
    );
    result.fold((error) => _appNavigator.showErrorSnackBar(), (_) {
      groups.removeWhere((item) => item.id == group.id);
      imageMessagesByGroup.remove(group.id);
      selectedGroup.value = groups.isEmpty ? null : groups.first;
      isShowingMemberManagement.value = false;
      isShowingGroupDetails.value = false;
      groups.refresh();
      _appNavigator.showSuccessSnackBar(_leftGroupMessage);
    });
  }

  String get _leftGroupMessage => switch (Get.context?.languageCode) {
    "pt" => "Voce saiu do grupo.",
    "es" => "Saliste del grupo.",
    _ => "You left the group.",
  };

  Future<void> onTapJoinWithCode() async {
    final dynamic result = await _appNavigator.toNamed(AppRoutes.joinGroup);
    final GroupEntity? joinedGroup = result as GroupEntity?;
    if (joinedGroup == null) {
      return;
    }
    final int existingIndex = groups.indexWhere(
      (group) => group.id == joinedGroup.id,
    );
    if (existingIndex >= 0) {
      groups[existingIndex] = joinedGroup;
    } else {
      groups.add(joinedGroup);
    }
    selectedGroup.value = joinedGroup;
    groups.refresh();
    onSelectGroup(joinedGroup);
    _appNavigator.showSuccessSnackBar(_joinedGroupMessage);
  }

  Future<ImageSource?> _pickImageSource() {
    final BuildContext? context = Get.context;
    if (context == null) {
      return Future<ImageSource?>.value(null);
    }
    return showPhotoSourceBottomSheet(
      context: context,
      title: _imageSourceTitle,
      subtitle: _imageSourceSubtitle,
      cameraLabel: _cameraLabel,
      galleryLabel: _galleryLabel,
      cancelLabel: _cancelLabel,
    );
  }

  String get _imageSourceTitle => switch (Get.context?.languageCode) {
    "pt" => "Enviar imagem",
    "es" => "Enviar imagen",
    _ => "Send image",
  };

  String get _imageSourceSubtitle => switch (Get.context?.languageCode) {
    "pt" => "Escolha como deseja enviar a imagem",
    "es" => "Elige como deseas enviar la imagen",
    _ => "Choose how you want to send the image",
  };

  String get _cameraLabel => switch (Get.context?.languageCode) {
    "pt" => "Tirar foto",
    "es" => "Tomar foto",
    _ => "Take photo",
  };

  String get _galleryLabel => switch (Get.context?.languageCode) {
    "pt" => "Escolher da galeria",
    "es" => "Elegir de la galeria",
    _ => "Choose from gallery",
  };

  String get _cancelLabel => switch (Get.context?.languageCode) {
    "pt" => "Cancelar",
    "es" => "Cancelar",
    _ => "Cancel",
  };

  String get _joinedGroupMessage => switch (Get.context?.languageCode) {
    "pt" => "Voce entrou no grupo.",
    "es" => "Te uniste al grupo.",
    _ => "You joined the group.",
  };
}
