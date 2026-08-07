import "package:dartz/dartz.dart";
import "package:help_out/core/data/data_sources/groups_data_source.dart";
import "package:help_out/core/domain/entities/friend_option.dart";
import "package:help_out/core/domain/entities/group_entity.dart";
import "package:help_out/core/domain/entities/group_image_message_entity.dart";
import "package:help_out/core/domain/enums/group_theme_type.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class GroupsRepository {
  GroupsRepository({required this._groupsDataSource});

  final GroupsDataSource _groupsDataSource;

  Future<Either<AppError, List<GroupEntity>>> getGroups() =>
      _groupsDataSource.getGroups();

  Future<Either<AppError, List<FriendOption>>> getInvitableFriends() =>
      _groupsDataSource.getInvitableFriends();

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

  Future<Either<AppError, GroupEntity>> createGroup({
    required String name,
    required GroupThemeType theme,
    required List<FriendOption> invitedFriends,
  }) => _groupsDataSource.createGroup(
    name: name,
    theme: theme,
    invitedFriends: invitedFriends,
  );
}
