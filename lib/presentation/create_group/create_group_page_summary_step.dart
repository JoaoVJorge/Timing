part of "create_group_page.dart";

class _SummaryStep extends StatelessWidget {
  const _SummaryStep({required this.controller});

  final CreateGroupController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final GroupThemeType? theme = controller.selectedTheme.value;
    final List<FriendOption> selectedFriends = controller.availableFriends
        .where((friend) => controller.selectedFriendIds.contains(friend.id))
        .toList();
    final String description = controller.descriptionController.text.trim();
    final String activityName = controller.activityNameController.text.trim();

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.createGroupSummaryTitle,
            style: context.textStyles.extraBold20,
          ),
          const Gap(16),
          _SummaryRow(
            icon: "group",
            title: context.l10n.groupNameLabel,
            child: Text(
              controller.groupNameController.text.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodyLarge,
            ),
          ),
          if (theme != null) ...[
            const Gap(10),
            _SummaryRow(
              icon: theme.iconName,
              title: context.l10n.groupThemeLabel,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme.localizedLabel(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodyLarge,
                  ),
                  const Gap(2),
                  Text(
                    groupMetricDescription(context, theme),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colorTokens.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (description.isNotEmpty) ...[
            const Gap(10),
            _SummaryRow(
              icon: "group",
              title: context.l10n.createGroupDescriptionLabel,
              child: Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.bodyLarge,
              ),
            ),
          ],
          if (activityName.isNotEmpty) ...[
            const Gap(10),
            _SummaryRow(
              icon: theme?.iconName ?? controller.category.iconName,
              title: context.l10n.createGroupActivitySummaryLabel,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activityName.isEmpty ? "-" : activityName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodyLarge,
                  ),
                  const Gap(2),
                  Text(
                    _activitySummary(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colorTokens.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Gap(10),
          _SummaryRow(
            icon: "group",
            title: context.l10n.createGroupGuestsLabel,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final FriendOption friend in selectedFriends.take(5))
                  GroupMemberAvatar(
                    name: friend.name,
                    colorValue: GroupAvatarColors.byIndex(friend.id.hashCode),
                  ),
                if (selectedFriends.length > 5)
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.colorTokens.primaryVeryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "+${selectedFriends.length - 5}",
                      style: context.textStyles.bodySmall.copyWith(
                        color: context.colorTokens.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  });
}

extension on _SummaryStep {
  String _activitySummary(BuildContext context) {
    final String goal = controller.activityGoalController.text.trim();
    if (controller.isDailyGoalsTheme) {
      return context.l10n.createGroupActivitySummaryGoalDays(goal);
    }
    if (controller.isPageBased) {
      return context.l10n.createGroupActivitySummaryReading(goal);
    }
    return context.l10n.createGroupActivitySummaryTime(
      controller.category.localizedLabel(context),
      goal,
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.title,
    required this.child,
  });

  final String icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: context.colorTokens.borderUnfocused),
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: context.colorTokens.primaryVeryLight,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: AppIcon(icon, size: 20, color: context.colorTokens.primary),
          ),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.bodySmall.copyWith(
                  color: context.colorTokens.textHint,
                ),
              ),
              const Gap(2),
              child,
            ],
          ),
        ),
      ],
    ),
  );
}
