import "package:equatable/equatable.dart";

class FriendEntity extends Equatable {
  const FriendEntity({
    required this.id,
    required this.friendshipId,
    required this.name,
    required this.handle,
    required this.colorValue,
  });

  final String id;
  final String friendshipId;
  final String name;
  final String handle;
  final int colorValue;

  @override
  List<Object?> get props => [id, friendshipId, name, handle, colorValue];
}
