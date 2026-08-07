import "package:dartz/dartz.dart";
import "package:help_out/core/data/repositories/friends_repository.dart";
import "package:help_out/core/domain/entities/friend_suggestion_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class FindProfileByCodeUseCase {
  FindProfileByCodeUseCase({required this._friendsRepository});

  final FriendsRepository _friendsRepository;

  Future<Either<AppError, FriendSuggestionEntity?>> call(String code) =>
      _friendsRepository.findByCode(code);
}
