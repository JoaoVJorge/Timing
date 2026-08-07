import "package:equatable/equatable.dart";

class FriendSuggestionEntity extends Equatable {
  const FriendSuggestionEntity({
    required this.id,
    required this.name,
    required this.handle,
    required this.colorValue,
  });

  final String id;
  final String name;
  final String handle;
  final int colorValue;

  @override
  List<Object?> get props => [id, name, handle, colorValue];
}
