import "package:dartz/dartz.dart";
import "package:help_out/core/data/repositories/friends_repository.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class CancelFriendRequestUseCase {
  CancelFriendRequestUseCase({required this._friendsRepository});

  final FriendsRepository _friendsRepository;

  Future<Either<AppError, void>> call({
    required String addresseeId,
    String friendshipId = "",
  }) => _friendsRepository.cancelSentRequest(
    addresseeId: addresseeId,
    friendshipId: friendshipId,
  );
}
