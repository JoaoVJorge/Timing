import "package:equatable/equatable.dart";
import "package:help_out/core/domain/entities/friend_entity.dart";

class FriendsSocialEntity extends Equatable {
  const FriendsSocialEntity({
    required this.inviteCode,
    required this.requests,
    required this.sentRequests,
    required this.friends,
  });

  const FriendsSocialEntity.empty()
    : inviteCode = "",
      requests = const [],
      sentRequests = const [],
      friends = const [];

  final String inviteCode;
  final List<FriendEntity> requests;
  final List<FriendEntity> sentRequests;
  final List<FriendEntity> friends;

  @override
  List<Object?> get props => [inviteCode, requests, sentRequests, friends];
}
