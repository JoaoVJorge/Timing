import "package:equatable/equatable.dart";
import "package:timing/core/domain/entities/friend_entity.dart";

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

  factory FriendsSocialEntity.fromMap(Map<String, dynamic> map) =>
      FriendsSocialEntity(
        inviteCode: map["inviteCode"] as String? ?? "",
        requests: (map["requests"] as List<dynamic>? ?? const [])
            .map((item) => FriendEntity.fromMap(item as Map<String, dynamic>))
            .toList(),
        sentRequests: (map["sentRequests"] as List<dynamic>? ?? const [])
            .map((item) => FriendEntity.fromMap(item as Map<String, dynamic>))
            .toList(),
        friends: (map["friends"] as List<dynamic>? ?? const [])
            .map((item) => FriendEntity.fromMap(item as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
    "inviteCode": inviteCode,
    "requests": requests.map((friend) => friend.toMap()).toList(),
    "sentRequests": sentRequests.map((friend) => friend.toMap()).toList(),
    "friends": friends.map((friend) => friend.toMap()).toList(),
  };

  final String inviteCode;
  final List<FriendEntity> requests;
  final List<FriendEntity> sentRequests;
  final List<FriendEntity> friends;

  @override
  List<Object?> get props => [inviteCode, requests, sentRequests, friends];
}
