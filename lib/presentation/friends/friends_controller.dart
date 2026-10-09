import "dart:async";

import "package:flutter/services.dart";
import "package:flutter/widgets.dart";
import "package:get/get.dart";
import "package:share_plus/share_plus.dart";
import "package:timing/app/app_controller.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/data/repositories/friends_repository.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/domain/entities/friend_entity.dart";
import "package:timing/core/domain/entities/friend_suggestion_entity.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/entities/group_invitation_entity.dart";
import "package:timing/core/domain/entities/sent_group_invitation_entity.dart";
import "package:timing/core/services/social/social_store.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/friends/find_friends_page.dart";
import "package:timing/presentation/friends/friend_requests_page.dart";
import "package:timing/presentation/friends/group_invitations_page.dart";
import "package:timing/presentation/group_activity_links/group_activity_links_page.dart";
import "package:timing/shared/widgets/delete_confirmation_dialog.dart";

class FriendsController extends GetxController {
  FriendsController({
    required this._socialStore,
    required this._friendsRepository,
    required this._groupsRepository,
    required this._appController,
    required this._appNavigator,
  });

  final SocialStore _socialStore;
  final FriendsRepository _friendsRepository;
  final GroupsRepository _groupsRepository;
  final AppController _appController;
  final AppNavigator _appNavigator;

  /// Friends and friend requests live in the [SocialStore], shared with the
  /// group screens; these are the same lists, not copies.
  RxList<FriendEntity> get requests => _socialStore.incomingRequests;
  RxList<FriendEntity> get sentRequests => _socialStore.sentRequests;
  RxList<FriendEntity> get friends => _socialStore.friends;
  RxString get inviteCode => _socialStore.inviteCode;

  final RxList<GroupInvitationEntity> groupInvitations =
      <GroupInvitationEntity>[].obs;
  final RxList<SentGroupInvitationEntity> sentGroupInvitations =
      <SentGroupInvitationEntity>[].obs;
  final RxBool isLoading = true.obs;
  final Rx<DateTime> presenceNow = DateTime.now().toUtc().obs;
  final RxSet<String> acceptingFriendRequestIds = <String>{}.obs;
  final RxSet<String> acceptingGroupInvitationIds = <String>{}.obs;

  final Rxn<FriendSuggestionEntity> foundUser = Rxn<FriendSuggestionEntity>();
  final RxBool isSearching = false.obs;
  final RxBool hasSearched = false.obs;
  Timer? _presenceTimer;
  Worker? _foregroundWorker;
  int _presenceTicks = 0;

  Set<String> get sentRequestIds =>
      sentRequests.map((request) => request.id).toSet();

  bool isRequestSent(String profileId) => sentRequestIds.contains(profileId);

  @override
  void onInit() {
    super.onInit();
    loadSocial();
    _foregroundWorker = ever<bool>(
      _appController.isAppInForeground,
      _setPresencePolling,
    );
    _setPresencePolling(_appController.isAppInForeground.value);
  }

  void _setPresencePolling(bool isForeground) {
    _presenceTimer?.cancel();
    _presenceTimer = null;
    if (!isForeground) {
      return;
    }
    _presenceTicks = 0;
    presenceNow.value = DateTime.now().toUtc();
    unawaited(_socialStore.refreshPresences());
    _presenceTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      presenceNow.value = DateTime.now().toUtc();
      _presenceTicks++;
      if (_presenceTicks.isEven) {
        unawaited(_socialStore.refreshPresences());
      }
    });
  }

  Future<void> loadSocial() async {
    isLoading.value = true;
    try {
      final socialFuture = _socialStore.load();
      final groupInvitationsFuture = _loadGroupInvitations();
      final sentGroupInvitationsFuture = _loadSentGroupInvitations();
      final result = await socialFuture;
      result.fold((error) => _appNavigator.showErrorSnackBar(), (_) {});
      await Future.wait([groupInvitationsFuture, sentGroupInvitationsFuture]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadGroupInvitations() async {
    final result = await _groupsRepository.getPendingInvitations();
    result.fold(
      (error) => groupInvitations.clear(),
      groupInvitations.assignAll,
    );
  }

  Future<void> _loadSentGroupInvitations() async {
    final result = await _groupsRepository.getSentInvitations();
    result.fold(
      (error) => sentGroupInvitations.clear(),
      sentGroupInvitations.assignAll,
    );
  }

  Future<void> refreshGroupInvitations() async {
    await Future.wait([_loadGroupInvitations(), _loadSentGroupInvitations()]);
  }

  Future<void> acceptGroupInvitation(GroupInvitationEntity invitation) async {
    if (!acceptingGroupInvitationIds.add(invitation.id)) {
      return;
    }
    try {
      final result = await _groupsRepository.acceptInvitation(invitation.id);
      await result.fold(
        (error) async => _appNavigator.showErrorOrOfflineSnackBar(),
        (outcome) async {
          groupInvitations.removeWhere((item) => item.id == invitation.id);
          // Only the leader's invitation joins on the spot; a member's one
          // leaves the leader to answer, so there is no group to open yet.
          final GroupEntity? group = outcome.group;
          if (group == null) {
            _appNavigator.showSuccessSnackBar(
              _l10n?.groupJoinRequestSentMessage(invitation.groupName) ??
                  "Request sent to the group's leader.",
            );
            return;
          }
          await showGroupActivityLinks(group);
          _socialStore.announceJoinedGroup(group);
          _appNavigator.showSuccessSnackBar(
            _l10n?.joinedGroupMessage ?? "You joined the group",
          );
        },
      );
    } finally {
      acceptingGroupInvitationIds.remove(invitation.id);
    }
  }

  Future<void> declineGroupInvitation(GroupInvitationEntity invitation) async {
    final result = await _groupsRepository.declineInvitation(invitation.id);
    result.fold(
      (error) => _appNavigator.showErrorOrOfflineSnackBar(),
      (_) => groupInvitations.removeWhere((item) => item.id == invitation.id),
    );
  }

  Future<void> cancelGroupInvitation(
    SentGroupInvitationEntity invitation,
  ) async {
    final result = await _groupsRepository.cancelGroupInvitation(
      groupId: invitation.groupId,
      friendId: invitation.inviteeId,
    );
    result.fold(
      (error) => _appNavigator.showErrorSnackBar(),
      (_) =>
          sentGroupInvitations.removeWhere((item) => item.id == invitation.id),
    );
  }

  Future<void> sendFriendRequest(FriendSuggestionEntity profile) async {
    if (isRequestSent(profile.id)) {
      return;
    }
    final result = await _socialStore.sendRequest(
      FriendEntity(
        id: profile.id,
        friendshipId: "",
        name: profile.name,
        handle: profile.handle,
        colorValue: profile.colorValue,
        avatarIconIndex: profile.avatarIconIndex,
        profilePhotoBase64: profile.profilePhotoBase64,
      ),
    );
    result.fold(
      (error) => _appNavigator.showErrorSnackBar(),
      (_) => _appNavigator.showSuccessSnackBar(
        _l10n?.friendRequestSentMessage ?? "Request sent",
      ),
    );
  }

  Future<void> acceptRequest(FriendEntity profile) async {
    if (!acceptingFriendRequestIds.add(profile.id)) {
      return;
    }
    try {
      final result = await _socialStore.acceptRequest(profile);
      result.fold((error) => _appNavigator.showErrorSnackBar(), (_) {});
    } finally {
      acceptingFriendRequestIds.remove(profile.id);
    }
  }

  Future<void> declineRequest(FriendEntity profile) async {
    final result = await _socialStore.declineRequest(profile);
    result.fold((error) => _appNavigator.showErrorSnackBar(), (_) {});
  }

  Future<void> cancelSentRequest(FriendEntity profile) async {
    final result = await _socialStore.cancelSentRequest(profile);
    result.fold((error) => _appNavigator.showErrorSnackBar(), (_) {});
  }

  Future<void> removeFriend(FriendEntity profile) async {
    final bool confirmed = await showDeleteConfirmationDialog(
      itemName: profile.name,
      itemTypeName: _l10n?.friendTypeName ?? "friend",
    );
    if (!confirmed) {
      return;
    }
    final result = await _socialStore.removeFriend(profile);
    result.fold((error) => _appNavigator.showErrorSnackBar(), (_) {});
  }

  Future<void> findByCode(String code) async {
    if (code.trim().replaceAll("@", "").isEmpty || isSearching.value) {
      return;
    }
    isSearching.value = true;
    hasSearched.value = true;
    foundUser.value = null;
    final result = await _friendsRepository.findByCode(code);
    result.fold(
      (error) {
        isSearching.value = false;
        _appNavigator.showErrorSnackBar();
      },
      (FriendSuggestionEntity? profile) {
        foundUser.value = profile;
        isSearching.value = false;
      },
    );
  }

  void resetSearch() {
    foundUser.value = null;
    hasSearched.value = false;
    isSearching.value = false;
  }

  Future<void> copyInviteCode() async {
    if (inviteCode.value.isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: inviteCode.value));
    _appNavigator.showSuccessSnackBar(
      _l10n?.codeCopiedMessage ?? "Code copied",
    );
  }

  Future<void> shareInviteCode() async {
    if (inviteCode.value.isEmpty) {
      return;
    }
    await SharePlus.instance.share(
      ShareParams(
        text:
            _l10n?.shareInviteCodeMessage(inviteCode.value) ??
            "Add me on Timing with my code: ${inviteCode.value}",
      ),
    );
  }

  Future<void> openAddFriendPage() async {
    resetSearch();
    await Get.to<void>(() => const FindFriendsPage());
    await loadSocial();
  }

  void openPendingRequestsPage() {
    Get.to<void>(
      () => const FriendRequestsPage(initialMode: FriendRequestsMode.incoming),
    );
  }

  Future<void> openGroupInvitationsPage() async {
    await refreshGroupInvitations();
    await Get.to<void>(() => const GroupInvitationsPage());
  }

  AppLocalizations? get _l10n {
    final BuildContext? context = Get.context;
    return context == null ? null : AppLocalizations.of(context);
  }

  @override
  void onClose() {
    _presenceTimer?.cancel();
    _foregroundWorker?.dispose();
    super.onClose();
  }
}
