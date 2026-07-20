import "package:dartz/dartz.dart";
import "package:help_out/core/domain/entities/friend_option.dart";
import "package:help_out/core/domain/entities/group_entity.dart";
import "package:help_out/core/domain/entities/group_member_entity.dart";
import "package:help_out/core/domain/enums/group_theme_type.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/theme/group_colors.dart";

class GroupsDataSource {
  Future<Either<AppError, List<GroupEntity>>> getGroups() async =>
      Right(_mockGroups);

  Future<Either<AppError, List<FriendOption>>> getInvitableFriends() async =>
      const Right(_mockFriends);

  Future<Either<AppError, GroupEntity>> createGroup({
    required String name,
    required GroupThemeType theme,
    required List<FriendOption> invitedFriends,
  }) async {
    final List<GroupMemberEntity> members = [
      const GroupMemberEntity(
        id: "me",
        name: "You",
        avatarColorValue: 0xFFFFC107,
        todaySeconds: 0,
        weekSeconds: 0,
        monthSeconds: 0,
        role: "owner",
      ),
      for (int index = 0; index < invitedFriends.length; index++)
        GroupMemberEntity(
          id: invitedFriends[index].id,
          name: invitedFriends[index].name,
          avatarColorValue: GroupAvatarColors.byIndex(index),
          todaySeconds: 0,
          weekSeconds: 0,
          monthSeconds: 0,
        ),
    ];

    final DateTime now = DateTime.now();
    final GroupEntity newGroup = GroupEntity(
      id: now.microsecondsSinceEpoch.toString(),
      name: name,
      theme: theme,
      members: members,
      ownerId: "me",
      createdAt: now,
      inviteCode: _inviteCodeFor(now),
      privacy: "inviteOnly",
    );
    _mockGroups.add(newGroup);
    return Right(newGroup);
  }

  static const List<FriendOption> _mockFriends = [
    (id: "f1", name: "Gabriel Torres"),
    (id: "f2", name: "Helena Costa"),
    (id: "f3", name: "Igor Martins"),
    (id: "f4", name: "Julia Ramos"),
    (id: "f5", name: "Kevin Duarte"),
    (id: "f6", name: "Laura Nunes"),
  ];

  static String _inviteCodeFor(DateTime dateTime) =>
      "H${dateTime.microsecondsSinceEpoch.toRadixString(36).toUpperCase()}";

  static final List<GroupEntity> _mockGroups = [
    const GroupEntity(
      id: "study-squad",
      name: "Study Squad",
      theme: GroupThemeType.studying,
      members: [
        GroupMemberEntity(
          id: "m1",
          name: "Ana Souza",
          avatarColorValue: 0xFFE0507A,
          todaySeconds: 5400,
          weekSeconds: 32400,
          monthSeconds: 126000,
        ),
        GroupMemberEntity(
          id: "m2",
          name: "Bruno Lima",
          avatarColorValue: 0xFF2E6ADE,
          todaySeconds: 3600,
          weekSeconds: 28800,
          monthSeconds: 108000,
        ),
        GroupMemberEntity(
          id: "m3",
          name: "Carla Dias",
          avatarColorValue: 0xFF3FA65D,
          todaySeconds: 7200,
          weekSeconds: 41400,
          monthSeconds: 154800,
        ),
        GroupMemberEntity(
          id: "m4",
          name: "Diego Alves",
          avatarColorValue: 0xFF8325FF,
          todaySeconds: 1800,
          weekSeconds: 14400,
          monthSeconds: 64800,
        ),
        GroupMemberEntity(
          id: "me",
          name: "You",
          avatarColorValue: 0xFFFFC107,
          todaySeconds: 2700,
          weekSeconds: 19800,
          monthSeconds: 82800,
        ),
      ],
    ),
    const GroupEntity(
      id: "work-crew",
      name: "Work Crew",
      theme: GroupThemeType.exercises,
      members: [
        GroupMemberEntity(
          id: "m6",
          name: "Elena Prado",
          avatarColorValue: 0xFF1FA2A6,
          todaySeconds: 9000,
          weekSeconds: 46800,
          monthSeconds: 190800,
        ),
        GroupMemberEntity(
          id: "m7",
          name: "Felipe Rocha",
          avatarColorValue: 0xFFFF7A30,
          todaySeconds: 6300,
          weekSeconds: 36000,
          monthSeconds: 140400,
        ),
        GroupMemberEntity(
          id: "me",
          name: "You",
          avatarColorValue: 0xFFFFC107,
          todaySeconds: 2700,
          weekSeconds: 19800,
          monthSeconds: 82800,
        ),
      ],
    ),
  ];
}
