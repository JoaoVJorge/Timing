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

part "create_group_page_step_progress.dart";
part "create_group_page_information_step.dart";
part "create_group_page_activity_step.dart";
part "create_group_page_friends_step.dart";
part "create_group_page_summary_step.dart";

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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) controller.onTapBack();
      },
      child: AppScaffold(
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
                      themeKey: _themeKey,
                    ),
                    1 => _ActivityStep(
                      controller: controller,
                      activityNameKey: _activityNameKey,
                      activityGoalKey: _activityGoalKey,
                      groupNameKey: _groupNameKey,
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
      ),
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
      targetKey = !controller.hasTheme ? _themeKey : null;
    } else if (controller.isActivityStep) {
      targetKey = controller.activityName.value.trim().isEmpty
          ? _activityNameKey
          : !controller.hasValidActivityGoal
          ? _activityGoalKey
          : !controller.hasName
          ? _groupNameKey
          : null;
    } else if (controller.isFriendsStep && !controller.hasFriends) {
      targetKey = _friendsKey;
    }

    await _scrollToKey(targetKey);
  }

  Future<void> _scrollToCreateError(CreateGroupController controller) async {
    if (!controller.hasName) {
      controller.currentStep.value = 1;
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

class _BottomAction extends StatelessWidget {
  const _BottomAction({required this.controller, required this.onTap});

  final CreateGroupController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Obx(() {
    final bool isSummary = controller.isSummaryStep;
    final bool isEnabled = switch (controller.currentStep.value) {
      0 => controller.hasTheme,
      1 => controller.hasActivity && controller.hasName,
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
