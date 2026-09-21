import "package:equatable/equatable.dart";

class FriendEntity extends Equatable {
  const FriendEntity({
    required this.id,
    required this.friendshipId,
    required this.name,
    required this.handle,
    required this.colorValue,
    this.avatarIconIndex,
    this.profilePhotoBase64 = "",
    this.isOnline = false,
    this.lastSeenAt,
  });

  factory FriendEntity.fromMap(Map<String, dynamic> map) => FriendEntity(
    id: map["id"] as String,
    friendshipId: map["friendshipId"] as String,
    name: map["name"] as String,
    handle: map["handle"] as String,
    colorValue: map["colorValue"] as int,
    avatarIconIndex: map["avatarIconIndex"] as int?,
    profilePhotoBase64: map["profilePhotoBase64"] as String? ?? "",
    isOnline: map["isOnline"] as bool? ?? false,
    lastSeenAt: DateTime.tryParse(map["lastSeenAt"] as String? ?? ""),
  );

  final String id;
  final String friendshipId;
  final String name;
  final String handle;
  final int colorValue;
  final int? avatarIconIndex;
  final String profilePhotoBase64;
  final bool isOnline;
  final DateTime? lastSeenAt;

  FriendEntity copyWith({
    int? avatarIconIndex,
    String? profilePhotoBase64,
    bool? isOnline,
    DateTime? lastSeenAt,
  }) => FriendEntity(
    id: id,
    friendshipId: friendshipId,
    name: name,
    handle: handle,
    colorValue: colorValue,
    avatarIconIndex: avatarIconIndex ?? this.avatarIconIndex,
    profilePhotoBase64: profilePhotoBase64 ?? this.profilePhotoBase64,
    isOnline: isOnline ?? this.isOnline,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "friendshipId": friendshipId,
    "name": name,
    "handle": handle,
    "colorValue": colorValue,
    "avatarIconIndex": avatarIconIndex,
    "profilePhotoBase64": profilePhotoBase64,
    "isOnline": isOnline,
    "lastSeenAt": lastSeenAt?.toIso8601String(),
  };

  bool isOnlineAt(DateTime now) {
    final DateTime? seenAt = lastSeenAt;
    if (!isOnline || seenAt == null) {
      return false;
    }
    return now.toUtc().difference(seenAt.toUtc()) < const Duration(minutes: 2);
  }

  @override
  List<Object?> get props => [
    id,
    friendshipId,
    name,
    handle,
    colorValue,
    avatarIconIndex,
    profilePhotoBase64,
    isOnline,
    lastSeenAt,
  ];
}
