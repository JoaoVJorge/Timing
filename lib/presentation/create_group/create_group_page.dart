import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/core/domain/entities/friend_option.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/create_group/create_group_controller.dart";
import "package:timing/presentation/create_subject/create_subject_page.dart";
import "package:timing/presentation/create_group/widgets/friend_tile.dart";
import "package:timing/presentation/groups/group_leaderboard_formatters.dart";
import "package:timing/presentation/groups/widgets/group_member_avatar.dart";
import "package:timing/shared/extensions/enum_localization_extensions.dart";
import "package:timing/shared/widgets/app_icon.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_top_bar.dart";
import "package:timing/shared/widgets/bounce_tap.dart";
import "package:timing/shared/widgets/creation/creation_form_widgets.dart";
import "package:timing/theme/decoration.dart";
import "package:timing/theme/group_colors.dart";

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final GlobalKey _groupNameKey = GlobalKey();
  final GlobalKey _themeKey = GlobalKey();
  final GlobalKey _activityNameKey = GlobalKey();
  final GlobalKey _activityGoalKey = GlobalKey();
  final GlobalKey _friendsKey = GlobalKey();

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
                  0 => _InformationStep(
                    controller: controller,
                    groupNameKey: _groupNameKey,
                    themeKey: _themeKey,
                  ),
                  1 => _ActivityStep(
                    controller: controller,
                    activityNameKey: _activityNameKey,
                    activityGoalKey: _activityGoalKey,
                  ),
                  2 => _FriendsStep(
                    controller: controller,
                    friendsKey: _friendsKey,
                  ),
                  _ => _SummaryStep(controller: controller),
                },
              ),
            ),
            const Gap(12),
            _BottomAction(
              controller: controller,
              onTap: () => _onTapBottomAction(controller),
            ),
            const Gap(16),
          ],
        );
      }),
    );
  }

  String _subtitleForStep(BuildContext context, int step) => switch (step) {
    0 => context.l10n.createGroupSubtitle,
    1 => context.l10n.createGroupActivityStepSubtitle,
    2 => context.l10n.createGroupFriendsStepSubtitle,
    _ => context.l10n.createGroupSummaryStepSubtitle,
  };

  Future<void> _onTapBottomAction(CreateGroupController controller) async {
    if (controller.isSummaryStep) {
      await _scrollToCreateError(controller);
      await controller.onTapCreate();
      return;
    }

    await _scrollToContinueError(controller);
    controller.onTapContinue();
  }

  Future<void> _scrollToContinueError(CreateGroupController controller) async {
    GlobalKey? targetKey;

    if (controller.isInformationStep) {
      targetKey = !controller.hasName
          ? _groupNameKey
          : !controller.hasTheme
          ? _themeKey
          : null;
    } else if (controller.isActivityStep) {
      targetKey = controller.activityName.value.trim().isEmpty
          ? _activityNameKey
          : !controller.hasValidActivityGoal
          ? _activityGoalKey
          : null;
    } else if (controller.isFriendsStep && !controller.hasFriends) {
      targetKey = _friendsKey;
    }

    await _scrollToKey(targetKey);
  }

  Future<void> _scrollToCreateError(CreateGroupController controller) async {
    if (!controller.hasName) {
      controller.currentStep.value = 0;
      await _scrollToKey(_groupNameKey);
      return;
    }
    if (!controller.hasTheme) {
      controller.currentStep.value = 0;
      await _scrollToKey(_themeKey);
      return;
    }
    if (!controller.hasActivity) {
      controller.currentStep.value = 1;
      await _scrollToKey(
        controller.activityName.value.trim().isEmpty
            ? _activityNameKey
            : _activityGoalKey,
      );
      return;
    }
    if (!controller.hasFriends) {
      controller.currentStep.value = 2;
      await _scrollToKey(_friendsKey);
    }
  }

  Future<void> _scrollToKey(GlobalKey? targetKey) async {
    if (targetKey == null) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) {
      return;
    }
    final BuildContext? targetContext = targetKey.currentContext;
    if (targetContext == null || !targetContext.mounted) {
      return;
    }

    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeInOutCubic,
      alignment: 0.08,
    );
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final List<String> labels = [
      context.l10n.createGroupStepInformation,
      context.l10n.createGroupStepActivity,
      context.l10n.createGroupStepFriends,
      context.l10n.createGroupStepSummary,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final double stepWidth = constraints.maxWidth / labels.length;

        return SizedBox(
          height: 62,
          child: Stack(
            children: [
              for (int index = 0; index < labels.length - 1; index++)
                Positioned(
                  top: 16,
                  left: stepWidth * (index + 0.5) + 22,
                  width: stepWidth - 44,
                  child: Container(
                    height: 1,
                    color: index < currentStep
                        ? context.colorTokens.primary
                        : context.colorTokens.borderUnfocused,
                  ),
                ),
              Row(
                children: [
                  for (int index = 0; index < labels.length; index++)
                    Expanded(
                      child: _StepMarker(
                        number: index + 1,
                        label: labels[index],
                        isActive: index <= currentStep,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
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
          textAlign: TextAlign.center,
          maxLines: 2,
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
  const _InformationStep({
    required this.controller,
    required this.groupNameKey,
    required this.themeKey,
  });

  final CreateGroupController controller;
  final Key groupNameKey;
  final Key themeKey;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SectionCard(
        key: groupNameKey,
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
            const Gap(16),
            Text(
              context.l10n.createGroupDescriptionLabel,
              style: context.textStyles.bodySmall,
            ),
            const Gap(8),
            TextField(
              controller: controller.descriptionController,
              minLines: 2,
              maxLines: 4,
              maxLength: 280,
              style: context.textStyles.inputText,
              decoration: AppInputDecoration.withBorder(
                tokens: context.colorTokens,
                hintText: context.l10n.createGroupDescriptionHint,
              ),
            ),
          ],
        ),
      ),
      const Gap(18),
      Text(
        context.l10n.groupThemeLabel,
        key: themeKey,
        style: context.textStyles.bodyLarge,
      ),
      const Gap(4),
      Text(
        context.l10n.createGroupThemeMetricDescription,
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

class _ActivityStep extends StatelessWidget {
  const _ActivityStep({
    required this.controller,
    required this.activityNameKey,
    required this.activityGoalKey,
  });

  final CreateGroupController controller;
  final Key activityNameKey;
  final Key activityGoalKey;

  @override
  Widget build(BuildContext context) {
    controller.initializeThemeColor(context.colorTokens.primary);
    return Obx(
      () => controller.isDailyGoalsTheme
          ? _DailyGoalActivityForm(
              controller: controller,
              nameKey: activityNameKey,
              goalKey: activityGoalKey,
            )
          : CreateSubjectFormContent(
              controller: controller,
              showHero: false,
              nameKey: activityNameKey,
              goalKey: activityGoalKey,
            ),
    );
  }
}

class _DailyGoalActivityForm extends StatelessWidget {
  const _DailyGoalActivityForm({
    required this.controller,
    required this.nameKey,
    required this.goalKey,
  });

  final CreateGroupController controller;
  final Key nameKey;
  final Key goalKey;

  @override
  Widget build(BuildContext context) => Obx(() {
    final Color accent = controller.selectedColor.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KeyedSubtree(
          key: nameKey,
          child: CreationNameField(
            controller: controller.activityNameController,
            hintText: context.l10n.taskNameHint,
            accent: accent,
            icon: Icon(Icons.flag_rounded, color: accent, size: 22),
          ),
        ),
        const Gap(12),
        CreationConfigCard(
          accent: accent,
          header: CreationSectionHeader(
            icon: Icons.track_changes_rounded,
            label: context.l10n.targetDaysLabel,
            accent: accent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KeyedSubtree(
                key: goalKey,
                child: _DailyGoalTargetInput(
                  controller: controller,
                  accent: accent,
                ),
              ),
              const Gap(12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final int days
                      in CreateGroupController.dailyGoalTargetDaysOptions)
                    Obx(
                      () => CreationSelectableChip(
                        label: context.l10n.targetDaysChip(days),
                        isSelected:
                            controller.activityGoal.value.trim() ==
                            days.toString(),
                        accent: accent,
                        onTap: () => controller.setGoalPreset(days),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const Gap(12),
        Obx(
          () => CreationColorSection(
            accent: controller.selectedColor.value,
            label: context.l10n.colorLabel,
            includePastelColors: true,
            onSelect: (color) => controller.selectedColor.value = color,
          ),
        ),
      ],
    );
  });
}

class _DailyGoalTargetInput extends StatelessWidget {
  const _DailyGoalTargetInput({required this.controller, required this.accent});

  final CreateGroupController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    height: 50,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: context.colorTokens.scaffold.withValues(alpha: 0.36),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: context.colorTokens.borderUnfocused),
    ),
    child: Row(
      children: [
        Icon(Icons.calendar_today_rounded, color: accent, size: 19),
        const Gap(12),
        Expanded(
          child: TextField(
            controller: controller.activityGoalController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              color: context.colorTokens.textBody,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: context.l10n.targetDaysHint,
              suffixText: context.daysSuffix,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintStyle: TextStyle(
                color: context.colorTokens.textHint.withValues(alpha: 0.62),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

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

class _BottomAction extends StatelessWidget {
  const _BottomAction({required this.controller, required this.onTap});

  final CreateGroupController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Obx(() {
    final bool isSummary = controller.isSummaryStep;
    final bool isEnabled = switch (controller.currentStep.value) {
      0 => controller.hasName && controller.hasTheme,
      1 => controller.hasActivity,
      2 => controller.hasFriends,
      _ => controller.canCreate.value,
    };

    return BounceTap(
      pressedScale: 0.97,
      onTap: onTap,
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
            ? SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 3.2,
                  strokeCap: StrokeCap.round,
                  color: context.colorTokens.primaryForeground,
                ),
              )
            : Text(
                isSummary
                    ? context.l10n.createGroupButton
                    : context.l10n.createGroupContinueButton,
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
  const _SectionCard({required this.child, super.key});

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
