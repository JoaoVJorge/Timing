import "package:dartz/dartz.dart";
import "package:timing/core/data/repositories/friends_repository.dart";
import "package:timing/core/domain/entities/friend_presence_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";

class GetFriendPresencesUseCase {
  GetFriendPresencesUseCase({required this.friendsRepository});

  final FriendsRepository friendsRepository;

  Future<Either<AppError, List<FriendPresenceEntity>>> call(
    List<String> friendIds,
  ) => friendsRepository.getPresences(friendIds);
}
