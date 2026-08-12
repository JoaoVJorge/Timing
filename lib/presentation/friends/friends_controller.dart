import "package:flutter/services.dart";
import "package:flutter/widgets.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/data/repositories/groups_repository.dart";
import "package:help_out/core/domain/entities/friend_entity.dart";
import "package:help_out/core/domain/entities/friend_suggestion_entity.dart";
import "package:help_out/core/domain/entities/friends_social_entity.dart";
import "package:help_out/core/domain/entities/group_invitation_entity.dart";
import "package:help_out/core/domain/entities/sent_group_invitation_entity.dart";
import "package:help_out/core/domain/use_cases/accept_friend_request_use_case.dart";
import "package:help_out/core/domain/use_cases/accept_group_invitation_use_case.dart";
import "package:help_out/core/domain/use_cases/cancel_friend_request_use_case.dart";
import "package:help_out/core/domain/use_cases/decline_friend_request_use_case.dart";
import "package:help_out/core/domain/use_cases/decline_group_invitation_use_case.dart";
import "package:help_out/core/domain/use_cases/find_profile_by_code_use_case.dart";
import "package:help_out/core/domain/use_cases/get_friends_social_use_case.dart";
import "package:help_out/core/domain/use_cases/get_group_invitations_use_case.dart";
import "package:help_out/core/domain/use_cases/remove_friend_use_case.dart";
import "package:help_out/core/domain/use_cases/send_friend_request_use_case.dart";
import "package:help_out/l10n/app_localizations.dart";
import "package:help_out/presentation/friends/find_friends_page.dart";
import "package:help_out/presentation/friends/friend_requests_page.dart";
import "package:help_out/presentation/friends/group_invitations_page.dart";
import "package:help_out/shared/widgets/delete_confirmation_dialog.dart";
import "package:share_plus/share_plus.dart";

class FriendsController extends GetxController {
  FriendsController({
    required this._getFriendsSocialUseCase,
    required this._sendFriendRequestUseCase,
    required this._acceptFriendRequestUseCase,
    required this._declineFriendRequestUseCase,
    required this._cancelFriendRequestUseCase,
    required this._removeFriendUseCase,
    required this._findProfileByCodeUseCase,
    required this._getGroupInvitationsUseCase,
    required this._acceptGroupInvitationUseCase,
    required this._declineGroupInvitationUseCase,
    required this._groupsRepository,
    required this._appNavigator,
  });

  final GetFriendsSocialUseCase _getFriendsSocialUseCase;
  final SendFriendRequestUseCase _sendFriendRequestUseCase;
  final AcceptFriendRequestUseCase _acceptFriendRequestUseCase;
  final DeclineFriendRequestUseCase _declineFriendRequestUseCase;
  final CancelFriendRequestUseCase _cancelFriendRequestUseCase;
  final RemoveFriendUseCase _removeFriendUseCase;
  final FindProfileByCodeUseCase _findProfileByCodeUseCase;
  final GetGroupInvitationsUseCase _getGroupInvitationsUseCase;
  final AcceptGroupInvitationUseCase _acceptGroupInvitationUseCase;
  final DeclineGroupInvitationUseCase _declineGroupInvitationUseCase;
  final GroupsRepository _groupsRepository;
  final AppNavigator _appNavigator;

  final RxList<FriendEntity> requests = <FriendEntity>[].obs;
  final RxList<FriendEntity> sentRequests = <FriendEntity>[].obs;
  final RxList<FriendEntity> friends = <FriendEntity>[].obs;
  final RxList<GroupInvitationEntity> groupInvitations =
      <GroupInvitationEntity>[].obs;
  final RxList<SentGroupInvitationEntity> sentGroupInvitations =
      <SentGroupInvitationEntity>[].obs;
  final RxString inviteCode = "".obs;
  final RxBool isLoading = true.obs;

  final Rxn<FriendSuggestionEntity> foundUser = Rxn<FriendSuggestionEntity>();
  final RxBool isSearching = false.obs;
  final RxBool hasSearched = false.obs;

  Set<String> get sentRequestIds =>
      sentRequests.map((request) => request.id).toSet();

  bool isRequestSent(String profileId) => sentRequestIds.contains(profileId);

  @override
  void onInit() {
    super.onInit();
    loadSocial();
  }

  Future<void> loadSocial() async {
    isLoading.value = true;
    final result = await _getFriendsSocialUseCase();
    result.fold(
      (error) {
        isLoading.value = false;
        _appNavigator.showErrorSnackBar();
      },
      (FriendsSocialEntity social) {
        inviteCode.value = social.inviteCode;
        requests.assignAll(social.requests);
        sentRequests.assignAll(social.sentRequests);
        friends.assignAll(social.friends);
        isLoading.value = false;
      },
    );
    await _loadGroupInvitations();
    await _loadSentGroupInvitations();
  }

  Future<void> _loadGroupInvitations() async {
    final result = await _getGroupInvitationsUseCase();
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

  Future<void> acceptGroupInvitation(GroupInvitationEntity invitation) async {
    final result = await _acceptGroupInvitationUseCase(invitation.id);
    result.fold((error) => _appNavigator.showErrorSnackBar(), (_) {
      groupInvitations.removeWhere((item) => item.id == invitation.id);
      _appNavigator.showSuccessSnackBar(
        _l10n?.joinedGroupMessage ?? "You joined the group",
      );
    });
  }

  Future<void> declineGroupInvitation(GroupInvitationEntity invitation) async {
    final result = await _declineGroupInvitationUseCase(invitation.id);
    result.fold(
      (error) => _appNavigator.showErrorSnackBar(),
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
    final result = await _sendFriendRequestUseCase(profile.id);
    result.fold((error) => _appNavigator.showErrorSnackBar(), (_) {
      sentRequests.add(
        FriendEntity(
          id: profile.id,
          friendshipId: "",
          name: profile.name,
          handle: profile.handle,
          colorValue: profile.colorValue,
        ),
      );
      _appNavigator.showSuccessSnackBar(
        _l10n?.friendRequestSentMessage ?? "Request sent",
      );
    });
  }

  Future<void> acceptRequest(FriendEntity profile) async {
    final result = await _acceptFriendRequestUseCase(profile.friendshipId);
    result.fold((error) => _appNavigator.showErrorSnackBar(), (_) {
      requests.removeWhere((request) => request.id == profile.id);
      if (!friends.any((friend) => friend.id == profile.id)) {
        friends.insert(0, profile);
      }
    });
  }

  Future<void> declineRequest(FriendEntity profile) async {
    final result = await _declineFriendRequestUseCase(profile.friendshipId);
    result.fold(
      (error) => _appNavigator.showErrorSnackBar(),
      (_) => requests.removeWhere((request) => request.id == profile.id),
    );
  }

  Future<void> cancelSentRequest(FriendEntity profile) async {
    final result = await _cancelFriendRequestUseCase(
      addresseeId: profile.id,
      friendshipId: profile.friendshipId,
    );
    result.fold(
      (error) => _appNavigator.showErrorSnackBar(),
      (_) => sentRequests.removeWhere((request) => request.id == profile.id),
    );
  }

  Future<void> removeFriend(FriendEntity profile) async {
    final bool confirmed = await showDeleteConfirmationDialog(
      itemName: profile.name,
      itemTypeName: _l10n?.friendTypeName ?? "friend",
    );
    if (!confirmed) {
      return;
    }
    final result = await _removeFriendUseCase(
      friendId: profile.id,
      friendshipId: profile.friendshipId,
    );
    result.fold(
      (error) => _appNavigator.showErrorSnackBar(),
      (_) => friends.removeWhere((friend) => friend.id == profile.id),
    );
  }

  Future<void> findByCode(String code) async {
    if (code.trim().replaceAll("@", "").isEmpty || isSearching.value) {
      return;
    }
    isSearching.value = true;
    hasSearched.value = true;
    foundUser.value = null;
    final result = await _findProfileByCodeUseCase(code);
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
            "Add me on HelpOut with my code: ${inviteCode.value}",
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

  void openGroupInvitationsPage() {
    Get.to<void>(() => const GroupInvitationsPage());
  }

  AppLocalizations? get _l10n {
    final BuildContext? context = Get.context;
    return context == null ? null : AppLocalizations.of(context);
  }
}
