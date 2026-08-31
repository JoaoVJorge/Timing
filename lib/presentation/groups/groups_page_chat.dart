part of "groups_page.dart";

// The image-only chat tab inside a group's details.

class _ChatTab extends StatelessWidget {
  const _ChatTab({required this.controller, required this.group});

  final GroupsController controller;
  final GroupEntity group;

  @override
  Widget build(BuildContext context) => Obx(() {
    final List<GroupImageMessageEntity> messages = controller.imageMessagesFor(
      group.id,
    );
    final bool isLoadingOlder = controller.isLoadingOlderImageMessagesFor(
      group.id,
    );

    return Column(
      children: [
        Expanded(
          child: controller.isLoadingChat.value && messages.isEmpty
              ? const _TabLoadingIndicator()
              : messages.isEmpty
              ? _ChatEmptyImages(
                  onTapSend: () => controller.onTapSendGroupImage(group.id),
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.pixels >=
                        notification.metrics.maxScrollExtent - 200) {
                      controller.loadOlderImageMessages(group.id);
                    }
                    return false;
                  },
                  child: ListView.separated(
                    reverse: true,
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    itemCount: messages.length + (isLoadingOlder ? 1 : 0),
                    separatorBuilder: (_, _) => const Gap(14),
                    itemBuilder: (context, index) {
                      if (index == messages.length) {
                        return const _InlineLoadingIndicator();
                      }
                      final GroupImageMessageEntity message =
                          messages[messages.length - index - 1];
                      return _ImageMessageBubble(
                        key: ValueKey(message.id),
                        message: message,
                        isMine: message.senderId == controller.currentUserId,
                      );
                    },
                  ),
                ),
        ),
        const Gap(12),
        _SendImageBar(
          isSending: controller.isSendingImage.value,
          onTap: () => controller.onTapSendGroupImage(group.id),
        ),
        const Gap(8),
      ],
    );
  });
}

class _ImageMessageBubble extends StatefulWidget {
  const _ImageMessageBubble({
    required this.message,
    required this.isMine,
    super.key,
  });

  final GroupImageMessageEntity message;
  final bool isMine;

  @override
  State<_ImageMessageBubble> createState() => _ImageMessageBubbleState();
}

class _ImageMessageBubbleState extends State<_ImageMessageBubble> {
  late Uint8List _imageBytes;

  @override
  void initState() {
    super.initState();
    _imageBytes = base64Decode(widget.message.imageBase64);
  }

  @override
  void didUpdateWidget(covariant _ImageMessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.imageBase64 != widget.message.imageBase64) {
      _imageBytes = base64Decode(widget.message.imageBase64);
    }
  }

  @override
  Widget build(BuildContext context) {
    final GroupImageMessageEntity message = widget.message;
    final bool isMine = widget.isMine;
    final int decodeWidth = (220 * MediaQuery.devicePixelRatioOf(context))
        .round();

    return Row(
      mainAxisAlignment: isMine
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMine) ...[
          GroupMemberAvatar(
            name: message.senderName,
            colorValue: message.senderAvatarColorValue,
            avatar: message.senderAvatar,
            size: 42,
          ),
          const Gap(8),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            decoration: BoxDecoration(
              color: isMine
                  ? context.colorTokens.primaryVeryLight
                  : context.colorTokens.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.colorTokens.borderUnfocused.withValues(
                  alpha: 0.38,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.senderName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall.copyWith(
                    color: isMine
                        ? context.colorTokens.primary
                        : const Color(0xFFE85888),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Gap(8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    _imageBytes,
                    width: 220,
                    fit: BoxFit.cover,
                    cacheWidth: decodeWidth,
                  ),
                ),
                const Gap(6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    formatClockTime(message.createdAt),
                    style: context.textStyles.bodyTiny,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isMine) ...[
          const Gap(8),
          GroupMemberAvatar(
            name: message.senderName,
            colorValue: message.senderAvatarColorValue,
            avatar: message.senderAvatar,
            size: 42,
          ),
        ],
      ],
    );
  }
}

class _ChatEmptyImages extends StatelessWidget {
  const _ChatEmptyImages({required this.onTapSend});

  final VoidCallback onTapSend;

  @override
  Widget build(BuildContext context) => Center(
    child: AppEmptyState(
      icon: Icons.image_outlined,
      title: context.l10n.groupNoImagesTitle,
      description: context.l10n.groupNoImagesDescription,
      actionLabel: context.l10n.groupSendImageButton,
      onTapAction: onTapSend,
    ),
  );
}

class _SendImageBar extends StatelessWidget {
  const _SendImageBar({required this.isSending, required this.onTap});

  final bool isSending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: isSending ? () {} : onTap,
    pressedScale: 0.98,
    child: Container(
      height: 56,
      padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: context.colorTokens.borderUnfocused.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Icon(
              Icons.image_outlined,
              color: context.colorTokens.primary,
              size: 22,
            ),
          ),
          const Gap(10),
          Expanded(
            child: Text(
              isSending
                  ? context.l10n.groupSendingImage
                  : context.l10n.groupSendImageButton,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.cardTitle.copyWith(fontSize: 15),
            ),
          ),
          const Gap(10),
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: context.colorTokens.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: isSending
                ? Padding(
                    padding: const EdgeInsets.all(11),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.colorTokens.primaryForeground,
                    ),
                  )
                : Icon(
                    Icons.add_photo_alternate_outlined,
                    color: context.colorTokens.primaryForeground,
                    size: 22,
                  ),
          ),
        ],
      ),
    ),
  );
}
