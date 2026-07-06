import "package:dartz/dartz.dart";
import "package:help_out/core/data/repositories/groups_repository.dart";
import "package:help_out/core/domain/entities/friend_option.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class GetInvitableFriendsUseCase {
  GetInvitableFriendsUseCase({required this._groupsRepository});

  final GroupsRepository _groupsRepository;

  Future<Either<AppError, List<FriendOption>>> call() => _groupsRepository.getInvitableFriends();
}
