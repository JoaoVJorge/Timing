import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/friend_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/friends/friends_controller.dart";
import "package:help_out/presentation/friends/widgets/friends_shared.dart";
import "package:help_out/presentation/groups/widgets/group_member_avatar.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";

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

  List<FriendEntity> get _currentRequests => switch (selectedMode) {
    FriendRequestsMode.incoming => controller.requests,
    FriendRequestsMode.sent => controller.sentRequests,
  };

  @override
  Widget build(BuildContext context) => AppScaffold(
    topBar: AppTopBar(
      title: context.l10n.friendRequestsReceivedTab,
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
          child: Obx(() {
            final List<FriendEntity> requests = _currentRequests;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  switch (selectedMode) {
                    FriendRequestsMode.incoming =>
                      context.l10n.friendRequestsReceivedSection(
                        requests.length,
                      ),
                    FriendRequestsMode.sent =>
                      context.l10n.friendRequestsSentSection(requests.length),
                  },
                  style: context.textStyles.bodyMedium.copyWith(
                    color: context.colorTokens.textBody,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: requests.isEmpty
                      ? _RequestEmptyState(mode: selectedMode)
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 18),
                          itemCount: requests.length,
                          separatorBuilder: (context, index) => const Gap(12),
                          itemBuilder: (context, index) {
                            final FriendEntity profile = requests[index];
                            return _RequestProfileCard(
                              profile: profile,
                              mode: selectedMode,
                              onAccept: () => controller.acceptRequest(profile),
                              onDecline: () =>
                                  controller.declineRequest(profile),
                              onCancel: () =>
                                  controller.cancelSentRequest(profile),
                            );
                          },
                        ),
                ),
              ],
            );
          }),
        ),
        if (selectedMode == FriendRequestsMode.incoming) ...[
          const Gap(12),
          _SafetyNotice(),
        ],
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
          icon: Icons.download_rounded,
          label: context.l10n.friendRequestsReceivedTab,
          isSelected: selectedMode == FriendRequestsMode.incoming,
          onTap: () => onSelect(FriendRequestsMode.incoming),
        ),
      ),
      const Gap(10),
      Expanded(
        child: _RequestModeTab(
          icon: Icons.send_rounded,
          label: context.l10n.friendRequestsSentTab,
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

class _RequestProfileCard extends StatelessWidget {
  const _RequestProfileCard({
    required this.profile,
    required this.mode,
    required this.onAccept,
    required this.onDecline,
    required this.onCancel,
  });

  final FriendEntity profile;
  final FriendRequestsMode mode;
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
                  onTap: onDecline,
                ),
              ),
              const Gap(10),
              Expanded(
                child: FriendRequestActionButton(
                  label: context.l10n.acceptButton,
                  isPrimary: true,
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
                ? Icons.inbox_rounded
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

class _SafetyNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
    decoration: friendsSurfaceDecoration(context, radius: 16),
    child: Row(
      children: [
        const FriendsPinkBadge(
          icon: Icons.shield_outlined,
          size: 34,
          iconSize: 19,
        ),
        const Gap(10),
        Expanded(
          child: Text(
            context.l10n.friendRequestsSafetyNotice,
            style: context.textStyles.bodySmall.copyWith(
              color: context.colorTokens.textHint,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ),
      ],
    ),
  );
}
