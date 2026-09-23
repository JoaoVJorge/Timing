part of "create_group_page.dart";

class _FriendsStep extends StatelessWidget {
  const _FriendsStep({required this.controller, required this.friendsKey});

  final CreateGroupController controller;
  final Key friendsKey;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _SectionCard(
        key: friendsKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.inviteFriendsLabel,
              style: context.textStyles.extraBold20,
            ),
            const Gap(4),
            Obx(
              () => Text(
                controller.selectedFriendIds.isEmpty
                    ? context.l10n.selectAtLeastOneFriend
                    : context.l10n.selectedFriendsCount(
                        controller.selectedFriendIds.length,
                      ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.bodyMedium.copyWith(
                  color: context.colorTokens.textHint,
                ),
              ),
            ),
            const Gap(14),
            TextField(
              controller: controller.friendSearchController,
              onChanged: controller.onFriendSearchChanged,
              style: context.textStyles.inputText,
              decoration: AppInputDecoration.withBorder(
                tokens: context.colorTokens,
                hintText: context.l10n.searchFriendHint,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 22,
                  color: context.colorTokens.textHint,
                ),
              ),
            ),
            const Gap(14),
            _FriendList(controller: controller),
          ],
        ),
      ),
      const Gap(12),
      Obx(() {
        if (controller.selectedFriendIds.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: context.colorTokens.primaryVeryLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colorTokens.borderUnfocused),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon("group", size: 18, color: context.colorTokens.primary),
              const Gap(8),
              Text(
                context.l10n.selectedFriendsCount(
                  controller.selectedFriendIds.length,
                ),
                style: context.textStyles.bodyMedium.copyWith(
                  color: context.colorTokens.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }),
      const Gap(12),
      BounceTap(
        pressedScale: 0.98,
        onTap: controller.onTapAddFriends,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colorTokens.primaryVeryLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colorTokens.borderUnfocused),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.colorTokens.primaryVeryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  color: context.colorTokens.primary,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.createGroupAddFriendsPromptTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodyLarge,
                    ),
                    const Gap(2),
                    Text(
                      context.l10n.createGroupAddFriendsPromptDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodySmall.copyWith(
                        color: context.colorTokens.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(12),
              Icon(
                Icons.chevron_right_rounded,
                color: context.colorTokens.primary,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _FriendList extends StatelessWidget {
  const _FriendList({required this.controller});

  final CreateGroupController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    if (controller.isLoading.value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            context.l10n.loadingFriends,
            style: context.textStyles.bodyMedium.copyWith(
              color: context.colorTokens.textHint,
            ),
          ),
        ),
      );
    }

    if (controller.hasLoadError.value) {
      return _FriendListState(
        icon: Icons.wifi_off_rounded,
        title: context.l10n.friendsLoadErrorTitle,
        description: context.l10n.friendsLoadErrorDescription,
      );
    }

    if (controller.availableFriends.isEmpty) {
      return _FriendListState(
        icon: Icons.person_add_disabled_rounded,
        title: context.l10n.noFriendsAvailableTitle,
        description: context.l10n.noFriendsAvailableDescription,
      );
    }

    final List<FriendOption> friends = controller.filteredFriends;

    if (friends.isEmpty) {
      return _FriendListState(
        icon: Icons.search_off_rounded,
        title: context.l10n.noFriendsFoundTitle,
        description: context.l10n.noFriendsFoundDescription,
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: friends.length,
      separatorBuilder: (context, index) => const Gap(8),
      itemBuilder: (context, index) {
        final FriendOption friend = friends[index];
        return Obx(
          () => FriendTile(
            friend: friend,
            isSelected: controller.selectedFriendIds.contains(friend.id),
            onTap: () => controller.onToggleFriend(friend.id),
          ),
        );
      },
    );
  });
}

class _FriendListState extends StatelessWidget {
  const _FriendListState({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: context.colorTokens.textHint),
          const Gap(12),
          Text(title, style: context.textStyles.bodyLarge),
          const Gap(4),
          Text(
            description,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.bodySmall.copyWith(
              color: context.colorTokens.textHint,
            ),
          ),
        ],
      ),
    ),
  );
}
