import "package:dartz/dartz.dart";
import "package:help_out/core/data/repositories/groups_repository.dart";
import "package:help_out/core/domain/entities/friend_option.dart";
import "package:help_out/core/domain/entities/group_entity.dart";
import "package:help_out/core/domain/enums/group_theme_type.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class CreateGroupUseCase {
  CreateGroupUseCase({required this._groupsRepository});

  final GroupsRepository _groupsRepository;

  Future<Either<AppError, GroupEntity>> call({
    required String name,
    required GroupThemeType theme,
    required List<FriendOption> invitedFriends,
  }) => _groupsRepository.createGroup(
    name: name,
    theme: theme,
    invitedFriends: invitedFriends,
  );
}
