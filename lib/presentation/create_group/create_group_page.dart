import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/friend_option.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/core/domain/enums/group_theme_type.dart";
import "package:help_out/presentation/create_group/create_group_controller.dart";
import "package:help_out/presentation/create_group/widgets/friend_tile.dart";
import "package:help_out/presentation/create_group/widgets/group_theme_tile.dart";
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller.groupNameController,
            onChanged: controller.onGroupNameChanged,
            decoration: AppInputDecoration.withBorder(
              tokens: context.colorTokens,
              hintText: context.l10n.groupNameHint,
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
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (
                    int index = 0;
                    index < GroupThemeType.values.length;
                    index++
                  ) ...[
                    if (index > 0) const Gap(8),
                    GroupThemeTile(
                      theme: GroupThemeType.values[index],
                      isSelected: GroupThemeType.values[index] == selected,
                      onTap: () => controller.onSelectTheme(
                        GroupThemeType.values[index],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
          const Gap(24),
          Text(
            context.l10n.inviteFriendsLabel,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.bodyLarge,
          ),
          const Gap(12),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              // Snapshot the selection during build so the Obx subscribes to
              // it here — reading it inside the lazy itemBuilder would run
              // after the reactive scope closes and never track toggles.
              final Set<String> selectedIds = controller.selectedFriendIds
                  .toSet();

              return ListView.separated(
                itemCount: controller.availableFriends.length,
                separatorBuilder: (context, index) => const Gap(8),
                itemBuilder: (context, index) {
                  final FriendOption friend =
                      controller.availableFriends[index];
                  return FriendTile(
                    friend: friend,
                    isSelected: selectedIds.contains(friend.id),
                    onTap: () => controller.onToggleFriend(friend.id),
                  );
                },
              );
            }),
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
                color: canCreate ? null : context.colorTokens.surfaceInnerLayer,
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
                      context.l10n.createGroupButton,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: canCreate
                          ? context.textStyles.textPrimaryButton
                          : context.textStyles.textPrimaryButton.copyWith(
                              color: context.colorTokens.textHint,
                            ),
                    ),
            );

            if (!canCreate) {
              return button;
            }
            return BounceTap(
              pressedScale: 0.97,
              onTap: controller.onTapCreate,
              child: button,
            );
          }),
          const Gap(24),
        ],
      ),
    );
  }
}
