import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/friend_option.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/core/domain/enums/group_theme_type.dart";
import "package:help_out/presentation/create_group/create_group_controller.dart";
import "package:help_out/presentation/create_group/widgets/friend_tile.dart";
import "package:help_out/presentation/create_group/widgets/group_theme_tile.dart";
import "package:help_out/presentation/groups/group_leaderboard_formatters.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/decoration.dart";

class CreateGroupPage extends StatelessWidget {
  const CreateGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateGroupController controller = Get.find();

    return AppScaffold(
      topBar: AppTopBar(
        title: context.l10n.createGroupTitle,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.createGroupSubtitle,
              style: context.textStyles.bodyMedium.copyWith(
                color: context.colorTokens.textHint,
              ),
            ),
            const Gap(20),
            Text(
              context.l10n.groupNameLabel,
              style: context.textStyles.bodyLarge,
            ),
            const Gap(8),
            TextField(
              controller: controller.groupNameController,
              onChanged: controller.onGroupNameChanged,
              decoration: AppInputDecoration.withBorder(
                tokens: context.colorTokens,
                hintText: context.l10n.groupNameExampleHint,
                prefixIcon: AppIcon(
                  "group",
                  size: 20,
                  color: context.colorTokens.textHint,
                ),
              ),
            ),
            const Gap(24),
            Text(
              context.l10n.groupThemeLabel,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodyLarge,
            ),
            const Gap(12),
            Obx(() {
              final GroupThemeType? selected = controller.selectedTheme.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: GroupThemeType.values.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          mainAxisExtent: 112,
                        ),
                    itemBuilder: (context, index) {
                      final GroupThemeType theme = GroupThemeType.values[index];
                      return GroupThemeTile(
                        theme: theme,
                        isSelected: theme == selected,
                        onTap: () => controller.onSelectTheme(theme),
                      );
                    },
                  ),
                  if (selected != null) ...[
                    const Gap(8),
                    Text(
                      context.l10n.groupThemeSelectedDescription(
                        groupMetricDescription(context, selected),
                      ),
                      style: context.textStyles.bodySmall.copyWith(
                        color: context.colorTokens.textHint,
                      ),
                    ),
                  ],
                ],
              );
            }),
            const Gap(24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.inviteFriendsLabel,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodyLarge,
                  ),
                ),
                Obx(
                  () => Text(
                    controller.selectedFriendIds.isEmpty
                        ? context.l10n.selectAtLeastOneFriend
                        : context.l10n.selectedFriendsCount(
                            controller.selectedFriendIds.length,
                          ),
                    style: context.textStyles.bodySmall.copyWith(
                      color: controller.selectedFriendIds.isEmpty
                          ? context.colorTokens.textHint
                          : context.colorTokens.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(12),
            TextField(
              controller: controller.friendSearchController,
              onChanged: controller.onFriendSearchChanged,
              decoration: AppInputDecoration.withBorder(
                tokens: context.colorTokens,
                hintText: context.l10n.searchFriendHint,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: context.colorTokens.textHint,
                ),
              ),
            ),
            const Gap(12),
            Obx(() {
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

              // Snapshot the selection during build so the Obx subscribes to
              // it here — reading it inside the lazy itemBuilder would run
              // after the reactive scope closes and never track toggles.
              final Set<String> selectedIds = controller.selectedFriendIds
                  .toSet();
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
                  return FriendTile(
                    friend: friend,
                    isSelected: selectedIds.contains(friend.id),
                    onTap: () => controller.onToggleFriend(friend.id),
                  );
                },
              );
            }),
            const Gap(16),
            Obx(
              () => _CreateGroupRequirements(
                hasName: controller.hasName,
                hasTheme: controller.hasTheme,
                hasFriends: controller.hasFriends,
              ),
            ),
            const Gap(12),
            Text(
              context.l10n.groupPrivacyNote,
              style: context.textStyles.bodySmall.copyWith(
                color: context.colorTokens.textHint,
              ),
            ),
            const Gap(16),
            Obx(() {
              final bool canCreate = controller.canCreate.value;
              final Widget button = Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: canCreate
                      ? context.colorTokens.primaryGradient
                      : null,
                  color: canCreate
                      ? null
                      : context.colorTokens.surfaceInnerLayer,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: controller.isCreating.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        controller.createButtonText(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: canCreate
                            ? context.textStyles.textPrimaryButton
                            : context.textStyles.textPrimaryButton.copyWith(
                                color: context.colorTokens.textHint,
                              ),
                      ),
              );

              // Always tappable — when something's missing, onTapCreate surfaces
              // the specific reason instead of the button silently doing nothing.
              return BounceTap(
                pressedScale: 0.97,
                onTap: controller.onTapCreate,
                child: button,
              );
            }),
            const Gap(24),
          ],
        ),
      ),
    );
  }
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
          style: context.textStyles.bodySmall.copyWith(
            color: context.colorTokens.textHint,
          ),
        ),
      ],
    ),
  );
}

class _CreateGroupRequirements extends StatelessWidget {
  const _CreateGroupRequirements({
    required this.hasName,
    required this.hasTheme,
    required this.hasFriends,
  });

  final bool hasName;
  final bool hasTheme;
  final bool hasFriends;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: context.colorTokens.borderUnfocused),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.createGroupRequirementsTitle,
          style: context.textStyles.bodyLarge,
        ),
        const Gap(8),
        _RequirementRow(
          isComplete: hasName,
          label: context.l10n.createGroupRequirementName,
        ),
        const Gap(8),
        _RequirementRow(
          isComplete: hasTheme,
          label: context.l10n.createGroupRequirementTheme,
        ),
        const Gap(8),
        _RequirementRow(
          isComplete: hasFriends,
          label: context.l10n.createGroupRequirementFriends,
        ),
      ],
    ),
  );
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.isComplete, required this.label});

  final bool isComplete;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(
        isComplete ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
        size: 18,
        color: isComplete
            ? context.colorTokens.success
            : context.colorTokens.textHint,
      ),
      const Gap(8),
      Expanded(
        child: Text(
          label,
          style: context.textStyles.bodySmall.copyWith(
            color: isComplete
                ? context.colorTokens.textBody
                : context.colorTokens.textHint,
          ),
        ),
      ),
    ],
  );
}
