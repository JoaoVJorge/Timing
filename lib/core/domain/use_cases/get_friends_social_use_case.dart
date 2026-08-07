import "package:dartz/dartz.dart";
import "package:help_out/core/data/repositories/friends_repository.dart";
import "package:help_out/core/domain/entities/friends_social_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class GetFriendsSocialUseCase {
  GetFriendsSocialUseCase({required this._friendsRepository});

  final FriendsRepository _friendsRepository;

  Future<Either<AppError, FriendsSocialEntity>> call() =>
      _friendsRepository.getSocial();
}
