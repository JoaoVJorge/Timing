import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/core/domain/entities/friend_entity.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/friends/friends_controller.dart";
import "package:timing/presentation/friends/widgets/friends_shared.dart";
import "package:timing/presentation/friends/widgets/friends_request_widgets.dart";
import "package:timing/presentation/groups/widgets/group_member_avatar.dart";

enum FriendRequestsMode { incoming, sent }

class FriendRequestsPage extends StatefulWidget {
  const FriendRequestsPage({required this.initialMode, super.key});

  final FriendRequestsMode initialMode;

  @override
  State<FriendRequestsPage> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> {
  final FriendsController controller = Get.find();
  late FriendRequestsMode selectedMode = widget.initialMode;

  @override
  Widget build(BuildContext context) =>
      FriendsRequestLayout<FriendRequestsMode>(
        title: context.l10n.friendRequestsReceivedPageTitle,
        selectedMode: selectedMode,
        incomingMode: FriendRequestsMode.incoming,
        sentMode: FriendRequestsMode.sent,
        onSelect: (mode) => setState(() => selectedMode = mode),
        child: Obx(
          () => switch (selectedMode) {
            FriendRequestsMode.incoming => _IncomingRequestsList(
              requests: controller.requests.toList(),
              acceptingRequestIds: controller.acceptingFriendRequestIds.toSet(),
              onAccept: controller.acceptRequest,
              onDecline: controller.declineRequest,
            ),
            FriendRequestsMode.sent => _SentRequestsList(
              requests: controller.sentRequests.toList(),
              onCancel: controller.cancelSentRequest,
            ),
          },
        ),
      );
}

class _IncomingRequestsList extends StatelessWidget {
  const _IncomingRequestsList({
    required this.requests,
    required this.acceptingRequestIds,
    required this.onAccept,
    required this.onDecline,
  });

  final List<FriendEntity> requests;
  final Set<String> acceptingRequestIds;
  final ValueChanged<FriendEntity> onAccept;
  final ValueChanged<FriendEntity> onDecline;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const _RequestEmptyState(mode: FriendRequestsMode.incoming);
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 18),
      itemCount: requests.length,
      separatorBuilder: (context, index) => const Gap(12),
      itemBuilder: (context, index) {
        final FriendEntity profile = requests[index];
        return _RequestProfileCard(
          profile: profile,
          mode: FriendRequestsMode.incoming,
          isAccepting: acceptingRequestIds.contains(profile.id),
          onAccept: () => onAccept(profile),
          onDecline: () => onDecline(profile),
          onCancel: () {},
        );
      },
    );
  }
}

class _SentRequestsList extends StatelessWidget {
  const _SentRequestsList({required this.requests, required this.onCancel});

  final List<FriendEntity> requests;
  final ValueChanged<FriendEntity> onCancel;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const _RequestEmptyState(mode: FriendRequestsMode.sent);
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 18),
      itemCount: requests.length,
      separatorBuilder: (context, index) => const Gap(12),
      itemBuilder: (context, index) {
        final FriendEntity profile = requests[index];
        return _RequestProfileCard(
          profile: profile,
          mode: FriendRequestsMode.sent,
          isAccepting: false,
          onAccept: () {},
          onDecline: () {},
          onCancel: () => onCancel(profile),
        );
      },
    );
  }
}

class _RequestProfileCard extends StatelessWidget {
  const _RequestProfileCard({
    required this.profile,
    required this.mode,
    required this.isAccepting,
    required this.onAccept,
    required this.onDecline,
    required this.onCancel,
  });

  final FriendEntity profile;
  final FriendRequestsMode mode;
  final bool isAccepting;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => FriendsRequestCard(
    child: Column(
      children: [
        Row(
          children: [
            GroupMemberAvatar(
              name: profile.name,
              colorValue: profile.colorValue,
              avatarIconIndex: profile.avatarIconIndex,
              avatar: profile.profilePhotoBase64,
              size: 48,
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FriendNameBlock(name: profile.name, handle: profile.handle),
                  const Gap(5),
                  Row(
                    children: [
                      Icon(
                        mode == FriendRequestsMode.incoming
                            ? Icons.group_rounded
                            : Icons.schedule_rounded,
                        color: context.colorTokens.textHint,
                        size: 15,
                      ),
                      const Gap(5),
                      Expanded(
                        child: Text(
                          mode == FriendRequestsMode.incoming
                              ? context.l10n.friendMutualFriendsSample
                              : context.l10n.pendingLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.bodySmall.copyWith(
                            color: mode == FriendRequestsMode.incoming
                                ? context.colorTokens.textHint
                                : context.colorTokens.warning,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const Gap(14),
        if (mode == FriendRequestsMode.incoming)
          FriendsRequestActions(
            isAccepting: isAccepting,
            onAccept: onAccept,
            onDecline: onDecline,
          )
        else
          Align(
            alignment: Alignment.centerRight,
            child: FriendRequestActionButton(
              label: context.l10n.cancelButton,
              isPrimary: false,
              onTap: onCancel,
            ),
          ),
      ],
    ),
  );
}

class _RequestEmptyState extends StatelessWidget {
  const _RequestEmptyState({required this.mode});

  final FriendRequestsMode mode;

  @override
  Widget build(BuildContext context) => FriendsRequestEmptyState(
    icon: mode == FriendRequestsMode.incoming
        ? Icons.person_add_alt_1_rounded
        : Icons.send_rounded,
    title: switch (mode) {
      FriendRequestsMode.incoming =>
        context.l10n.friendRequestsIncomingEmptyTitle,
      FriendRequestsMode.sent => context.l10n.friendRequestsSentEmptyTitle,
    },
    description: switch (mode) {
      FriendRequestsMode.incoming =>
        context.l10n.friendRequestsIncomingEmptySubtitle,
      FriendRequestsMode.sent => context.l10n.friendRequestsSentEmptySubtitle,
    },
  );
}
