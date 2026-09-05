import "package:equatable/equatable.dart";

class FriendSuggestionEntity extends Equatable {
  const FriendSuggestionEntity({
    required this.id,
    required this.name,
    required this.handle,
    required this.colorValue,
    this.avatarIconIndex,
    this.profilePhotoBase64 = "",
  });

  final String id;
  final String name;
  final String handle;
  final int colorValue;
  final int? avatarIconIndex;
  final String profilePhotoBase64;

  @override
  List<Object?> get props => [
    id,
    name,
    handle,
    colorValue,
    avatarIconIndex,
    profilePhotoBase64,
  ];
}
