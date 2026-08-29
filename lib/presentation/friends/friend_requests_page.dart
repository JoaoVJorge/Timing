import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/core/domain/entities/friend_entity.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/friends/friends_controller.dart";
import "package:timing/presentation/friends/widgets/friends_shared.dart";
import "package:timing/presentation/groups/widgets/group_member_avatar.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_top_bar.dart";
import "package:timing/shared/widgets/bounce_tap.dart";

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
  Widget build(BuildContext context) => AppScaffold(
    topBar: AppTopBar(
      title: context.l10n.friendRequestsReceivedPageTitle,
      showBackButton: true,
      onBack: () => Navigator.of(context).maybePop(),
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RequestsModeTabs(
          selectedMode: selectedMode,
          onSelect: (mode) => setState(() => selectedMode = mode),
        ),
        const Gap(18),
        Expanded(
          child: Obx(
            () => switch (selectedMode) {
              FriendRequestsMode.incoming => _IncomingRequestsList(
                requests: controller.requests.toList(),
                acceptingRequestIds: controller.acceptingFriendRequestIds
                    .toSet(),
                onAccept: controller.acceptRequest,
                onDecline: controller.declineRequest,
              ),
              FriendRequestsMode.sent => _SentRequestsList(
                requests: controller.sentRequests.toList(),
                onCancel: controller.cancelSentRequest,
              ),
            },
          ),
        ),
        const Gap(18),
      ],
    ),
  );
}

class _RequestsModeTabs extends StatelessWidget {
  const _RequestsModeTabs({required this.selectedMode, required this.onSelect});

  final FriendRequestsMode selectedMode;
  final ValueChanged<FriendRequestsMode> onSelect;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _RequestModeTab(
          icon: Icons.inbox_rounded,
          label: context.l10n.receivedTab,
          isSelected: selectedMode == FriendRequestsMode.incoming,
          onTap: () => onSelect(FriendRequestsMode.incoming),
        ),
      ),
      const Gap(10),
      Expanded(
        child: _RequestModeTab(
          icon: Icons.send_rounded,
          label: context.l10n.sentLabel,
          isSelected: selectedMode == FriendRequestsMode.sent,
          onTap: () => onSelect(FriendRequestsMode.sent),
        ),
      ),
    ],
  );
}

class _RequestModeTab extends StatelessWidget {
  const _RequestModeTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    pressedScale: 0.96,
    child: Container(
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: isSelected ? context.colorTokens.primaryGradient : null,
        color: isSelected ? null : context.colorTokens.surfaceInnerLayer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected
                ? context.colorTokens.primaryForeground
                : context.colorTokens.textHint,
          ),
          const Gap(7),
          Text(
            label,
            style: context.textStyles.bodySmall.copyWith(
              color: isSelected
                  ? context.colorTokens.primaryForeground
                  : context.colorTokens.textHint,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
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
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
    decoration: friendsSurfaceDecoration(context, radius: 18),
    child: Column(
      children: [
        Row(
          children: [
            GroupMemberAvatar(
              name: profile.name,
              colorValue: profile.colorValue,
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
          Row(
            children: [
              Expanded(
                child: FriendRequestActionButton(
                  label: context.l10n.declineButton,
                  isPrimary: false,
                  isEnabled: !isAccepting,
                  onTap: onDecline,
                ),
              ),
              const Gap(10),
              Expanded(
                child: FriendRequestActionButton(
                  label: context.l10n.acceptButton,
                  isPrimary: true,
                  isLoading: isAccepting,
                  onTap: onAccept,
                ),
              ),
            ],
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
  Widget build(BuildContext context) => Center(
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 28),
      decoration: friendsSurfaceDecoration(context, radius: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FriendsPinkBadge(
            icon: mode == FriendRequestsMode.incoming
                ? Icons.person_add_alt_1_rounded
                : Icons.send_rounded,
            size: 64,
            iconSize: 34,
          ),
          const Gap(14),
          Text(
            switch (mode) {
              FriendRequestsMode.incoming =>
                context.l10n.friendRequestsIncomingEmptyTitle,
              FriendRequestsMode.sent =>
                context.l10n.friendRequestsSentEmptyTitle,
            },
            textAlign: TextAlign.center,
            style: context.textStyles.extraBold20.copyWith(
              color: context.colorTokens.textBody,
              fontSize: 17,
            ),
          ),
          const Gap(6),
          Text(
            switch (mode) {
              FriendRequestsMode.incoming =>
                context.l10n.friendRequestsIncomingEmptySubtitle,
              FriendRequestsMode.sent =>
                context.l10n.friendRequestsSentEmptySubtitle,
            },
            textAlign: TextAlign.center,
            style: context.textStyles.bodyMedium.copyWith(
              color: context.colorTokens.textHint,
              fontSize: 13,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
