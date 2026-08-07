import "package:equatable/equatable.dart";

class GroupImageMessageEntity extends Equatable {
  const GroupImageMessageEntity({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.imageBase64,
    required this.createdAt,
    this.senderName = "Membro",
    this.senderAvatar = "",
    this.senderAvatarColorValue = 0xFF6B9528,
  });

  final String id;
  final String groupId;
  final String senderId;
  final String imageBase64;
  final DateTime createdAt;
  final String senderName;
  final String senderAvatar;
  final int senderAvatarColorValue;

  @override
  List<Object?> get props => [
    id,
    groupId,
    senderId,
    imageBase64,
    createdAt,
    senderName,
    senderAvatar,
    senderAvatarColorValue,
  ];
}
