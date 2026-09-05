import "package:equatable/equatable.dart";

class FriendPresenceEntity extends Equatable {
  const FriendPresenceEntity({
    required this.id,
    required this.isOnline,
    this.lastSeenAt,
  });

  final String id;
  final bool isOnline;
  final DateTime? lastSeenAt;

  @override
  List<Object?> get props => [id, isOnline, lastSeenAt];
}
