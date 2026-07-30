import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/friend_option.dart";
import "package:help_out/core/domain/enums/group_theme_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/create_group/create_group_controller.dart";
import "package:help_out/presentation/create_group/widgets/friend_tile.dart";
import "package:help_out/presentation/groups/group_leaderboard_formatters.dart";
import "package:help_out/presentation/groups/widgets/group_member_avatar.dart";
import "package:help_out/shared/extensions/enum_localization_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/theme/decoration.dart";
import "package:help_out/theme/group_colors.dart";

class CreateGroupPage extends StatelessWidget {
  const CreateGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateGroupController controller = Get.find();

    return AppScaffold(
      topBar: AppTopBar(
        title: context.l10n.createGroupTitle,
        showBackButton: true,
        onBack: controller.onTapBack,
      ),
      body: Obx(() {
        final int step = controller.currentStep.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _subtitleForStep(context, step),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodyMedium.copyWith(
                color: context.colorTokens.textHint,
              ),
            ),
            const Gap(18),
            _StepProgress(currentStep: step),
            const Gap(18),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: switch (step) {
                  0 => _InformationStep(controller: controller),
                  1 => _FriendsStep(controller: controller),
                  _ => _SummaryStep(controller: controller),
                },
              ),
            ),
            const Gap(12),
            _BottomAction(controller: controller),
            const Gap(16),
          ],
        );
      }),
    );
  }

  String _subtitleForStep(BuildContext context, int step) => switch (step) {
    0 => context.l10n.createGroupSubtitle,
    1 => "Convide pelo menos 1 amigo para participar.",
    _ => "Revise os dados antes de criar.",
  };
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    const List<String> labels = ["Informações", "Amigos", "Resumo"];

    return Row(
      children: [
        for (int index = 0; index < labels.length; index++) ...[
          Expanded(
            child: _StepMarker(
              number: index + 1,
              label: labels[index],
              isActive: index <= currentStep,
            ),
          ),
          if (index < labels.length - 1)
            Expanded(
              child: Container(
                height: 1,
                margin: const EdgeInsets.only(bottom: 24),
                color: index < currentStep
                    ? context.colorTokens.primary
                    : context.colorTokens.borderUnfocused,
              ),
            ),
        ],
      ],
    );
  }
}

class _StepMarker extends StatelessWidget {
  const _StepMarker({
    required this.number,
    required this.label,
    required this.isActive,
  });

  final int number;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final Color color = isActive
        ? context.colorTokens.primary
        : context.colorTokens.borderUnfocused;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Text(
            "$number",
            style: context.textStyles.bodyMedium.copyWith(
              color: context.colorTokens.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const Gap(8),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.bodySmall.copyWith(
            color: isActive
                ? context.colorTokens.primary
                : context.colorTokens.textHint,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _InformationStep extends StatelessWidget {
  const _InformationStep({required this.controller});

  final CreateGroupController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.groupNameLabel,
              style: context.textStyles.bodySmall,
            ),
            const Gap(8),
            TextField(
              controller: controller.groupNameController,
              onChanged: controller.onGroupNameChanged,
              style: context.textStyles.inputText,
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
          ],
        ),
      ),
      const Gap(18),
      Text(context.l10n.groupThemeLabel, style: context.textStyles.bodyLarge),
      const Gap(4),
      Text(
        "Este tema define a métrica do ranking.",
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodySmall.copyWith(
          color: context.colorTokens.textHint,
        ),
      ),
      const Gap(12),
      Obx(() {
        final GroupThemeType? selected = controller.selectedTheme.value;

        return Column(
          children: [
            for (final GroupThemeType theme in GroupThemeType.values) ...[
              _ThemeRow(
                theme: theme,
                isSelected: theme == selected,
                onTap: () => controller.onSelectTheme(theme),
              ),
              const Gap(8),
            ],
          ],
        );
      }),
    ],
  );
}

class _ThemeRow extends StatelessWidget {
  const _ThemeRow({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  final GroupThemeType theme;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    pressedScale: 0.98,
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected
            ? context.colorTokens.primaryVeryLight
            : context.colorTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? context.colorTokens.primary
              : context.colorTokens.borderUnfocused,
          width: isSelected ? 1.5 : 1,
        ),
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
              child: AppIcon(
                theme.iconName,
                size: 20,
                color: context.colorTokens.primary,
              ),
            ),
          ),
          const Gap(12),
          Expanded(
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
          const Gap(12),
          Icon(
            isSelected
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 22,
            color: isSelected
                ? context.colorTokens.primary
                : context.colorTokens.borderUnfocused,
          ),
        ],
      ),
    ),
  );
}

class _FriendsStep extends StatelessWidget {
  const _FriendsStep({required this.controller});

  final CreateGroupController controller;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _SectionCard(
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
                      "Não encontrou alguém?",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodyLarge,
                    ),
                    const Gap(2),
                    Text(
                      "Adicione mais amigos para poder convidar.",
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

    final Set<String> selectedIds = controller.selectedFriendIds.toSet();
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
  });
}

class _SummaryStep extends StatelessWidget {
  const _SummaryStep({required this.controller});

  final CreateGroupController controller;

  @override
  Widget build(BuildContext context) {
    final GroupThemeType? theme = controller.selectedTheme.value;
    final List<FriendOption> selectedFriends = controller.availableFriends
        .where((friend) => controller.selectedFriendIds.contains(friend.id))
        .toList();

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Resumo do grupo", style: context.textStyles.extraBold20),
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
          const Gap(10),
          _SummaryRow(
            icon: "group",
            title: "Participantes",
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

class _BottomAction extends StatelessWidget {
  const _BottomAction({required this.controller});

  final CreateGroupController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final bool isSummary = controller.isSummaryStep;
    final bool isEnabled = switch (controller.currentStep.value) {
      0 => controller.hasName && controller.hasTheme,
      1 => controller.hasFriends,
      _ => controller.canCreate.value,
    };

    return BounceTap(
      pressedScale: 0.97,
      onTap: isSummary ? controller.onTapCreate : controller.onTapContinue,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: isEnabled ? context.colorTokens.primaryGradient : null,
          color: isEnabled ? null : context.colorTokens.surfaceInnerLayer,
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
                isSummary ? context.l10n.createGroupButton : "Continuar",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.textPrimaryButton.copyWith(
                  color: isEnabled
                      ? context.colorTokens.primaryForeground
                      : context.colorTokens.textHint,
                ),
              ),
      ),
    );
  });
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: context.colorTokens.borderUnfocused),
    ),
    child: child,
  );
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
