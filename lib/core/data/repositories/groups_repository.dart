import "package:dartz/dartz.dart";
import "package:timing/core/data/data_sources/groups_data_source.dart";
import "package:timing/core/domain/entities/friend_option.dart";
import "package:timing/core/domain/entities/group_activity_draft.dart";
import "package:timing/core/domain/entities/group_activity_progress_entity.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/entities/group_image_message_entity.dart";
import "package:timing/core/domain/entities/group_image_messages_page.dart";
import "package:timing/core/domain/entities/group_invite_option_entity.dart";
import "package:timing/core/domain/entities/group_invitation_entity.dart";
import "package:timing/core/domain/entities/sent_group_invitation_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/domain/errors/app_error.dart";

class GroupsRepository {
  GroupsRepository({required this._groupsDataSource});

  final GroupsDataSource _groupsDataSource;

  Future<Either<AppError, List<GroupEntity>>> getGroups() =>
      _groupsDataSource.getGroups();

  Future<Either<AppError, List<FriendOption>>> getInvitableFriends() =>
      _groupsDataSource.getInvitableFriends();

  Future<Either<AppError, List<GroupInviteOptionEntity>>> getGroupInviteOptions(
    String groupId,
  ) => _groupsDataSource.getGroupInviteOptions(groupId);

  Future<Either<AppError, void>> inviteFriendToGroup({
    required String groupId,
    required String friendId,
  }) => _groupsDataSource.inviteFriendToGroup(
    groupId: groupId,
    friendId: friendId,
  );

  Future<Either<AppError, void>> cancelGroupInvitation({
    required String groupId,
    required String friendId,
  }) => _groupsDataSource.cancelGroupInvitation(
    groupId: groupId,
    friendId: friendId,
  );

  Future<Either<AppError, List<GroupActivityProgressEntity>>>
  getGroupActivityProgress(String groupId, {String? localDate}) =>
      _groupsDataSource.getGroupActivityProgress(groupId, localDate: localDate);

  Future<Either<AppError, GroupImageMessagesPage>> getImageMessages(
    String groupId, {
    GroupImageMessageEntity? before,
  }) => _groupsDataSource.getImageMessages(groupId, before: before);

  Future<Either<AppError, GroupImageMessageEntity>> sendImageMessage({
    required String groupId,
    required String imageBase64,
  }) => _groupsDataSource.sendImageMessage(
    groupId: groupId,
    imageBase64: imageBase64,
  );

  Future<Either<AppError, void>> leaveGroup(String groupId) =>
      _groupsDataSource.leaveGroup(groupId);

  Future<Either<AppError, void>> removeMember({
    required String groupId,
    required String memberId,
  }) => _groupsDataSource.removeMember(groupId: groupId, memberId: memberId);

  Future<Either<AppError, void>> transferLeadership({
    required String groupId,
    required String nextLeaderId,
  }) => _groupsDataSource.transferLeadership(
    groupId: groupId,
    nextLeaderId: nextLeaderId,
  );

  Future<Either<AppError, void>> resetGroupProgress(String groupId) =>
      _groupsDataSource.resetGroupProgress(groupId);

  Future<Either<AppError, GroupEntity>> updateGroup({
    required GroupEntity group,
    required String name,
    required String description,
    required Map<String, dynamic> activityPayload,
  }) => _groupsDataSource.updateGroup(
    group: group,
    name: name,
    description: description,
    activityPayload: activityPayload,
  );

  Future<Either<AppError, List<GroupInvitationEntity>>>
  getPendingInvitations() => _groupsDataSource.getPendingInvitations();

  Future<Either<AppError, List<SentGroupInvitationEntity>>>
  getSentInvitations() => _groupsDataSource.getSentInvitations();

  Future<Either<AppError, GroupEntity>> acceptInvitation(String invitationId) =>
      _groupsDataSource.acceptInvitation(invitationId);

  Future<Either<AppError, void>> declineInvitation(String invitationId) =>
      _groupsDataSource.declineInvitation(invitationId);

  Future<Either<AppError, GroupEntity>> joinGroupByInviteCode(
    String inviteCode,
  ) => _groupsDataSource.joinGroupByInviteCode(inviteCode);

  Future<Either<AppError, GroupEntity>> createGroup({
    required String name,
    required GroupThemeType theme,
    required List<FriendOption> invitedFriends,
    String description = "",
    GroupActivityDraft? activity,
  }) => _groupsDataSource.createGroup(
    name: name,
    theme: theme,
    invitedFriends: invitedFriends,
    description: description,
    activity: activity,
  );
}
