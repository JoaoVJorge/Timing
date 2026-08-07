import "package:dartz/dartz.dart";
import "package:help_out/core/data/data_sources/friends_data_source.dart";
import "package:help_out/core/domain/entities/friend_suggestion_entity.dart";
import "package:help_out/core/domain/entities/friends_social_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class FriendsRepository {
  FriendsRepository({required this._friendsDataSource});

  final FriendsDataSource _friendsDataSource;

  Future<Either<AppError, FriendsSocialEntity>> getSocial() =>
      _friendsDataSource.getSocial();

  Future<Either<AppError, void>> sendFriendRequest(String addresseeId) =>
      _friendsDataSource.sendFriendRequest(addresseeId);

  Future<Either<AppError, void>> acceptRequest(String friendshipId) =>
      _friendsDataSource.acceptRequest(friendshipId);

  Future<Either<AppError, void>> declineRequest(String friendshipId) =>
      _friendsDataSource.declineRequest(friendshipId);

  Future<Either<AppError, void>> cancelSentRequest({
    required String addresseeId,
    String friendshipId = "",
  }) => _friendsDataSource.cancelSentRequest(
    addresseeId: addresseeId,
    friendshipId: friendshipId,
  );

  Future<Either<AppError, void>> removeFriend({
    required String friendId,
    String friendshipId = "",
  }) => _friendsDataSource.removeFriend(
    friendId: friendId,
    friendshipId: friendshipId,
  );

  Future<Either<AppError, FriendSuggestionEntity?>> findByCode(String code) =>
      _friendsDataSource.findByCode(code);
}
