import "package:dartz/dartz.dart";
import "package:help_out/core/data/data_sources/groups_data_source.dart";
import "package:help_out/core/domain/entities/friend_option.dart";
import "package:help_out/core/domain/entities/group_activity_draft.dart";
import "package:help_out/core/domain/entities/group_activity_progress_entity.dart";
import "package:help_out/core/domain/entities/group_entity.dart";
import "package:help_out/core/domain/entities/group_image_message_entity.dart";
import "package:help_out/core/domain/entities/group_invite_option_entity.dart";
import "package:help_out/core/domain/entities/group_invitation_entity.dart";
import "package:help_out/core/domain/enums/group_theme_type.dart";
import "package:help_out/core/domain/errors/app_error.dart";

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

  Future<Either<AppError, List<GroupImageMessageEntity>>> getImageMessages(
    String groupId,
  ) => _groupsDataSource.getImageMessages(groupId);

  Future<Either<AppError, GroupImageMessageEntity>> sendImageMessage({
    required String groupId,
    required String imageBase64,
  }) => _groupsDataSource.sendImageMessage(
    groupId: groupId,
    imageBase64: imageBase64,
  );

  Future<Either<AppError, void>> leaveGroup(String groupId) =>
      _groupsDataSource.leaveGroup(groupId);

  Future<Either<AppError, List<GroupInvitationEntity>>>
  getPendingInvitations() => _groupsDataSource.getPendingInvitations();

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
