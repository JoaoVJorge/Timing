import "package:timing/core/domain/entities/group_image_message_entity.dart";

class GroupImageMessagesPage {
  const GroupImageMessagesPage({required this.messages, required this.hasMore});

  final List<GroupImageMessageEntity> messages;
  final bool hasMore;
}
