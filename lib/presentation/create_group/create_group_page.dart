import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/core/domain/entities/friend_option.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/create_group/create_group_controller.dart";
import "package:timing/presentation/create_group/widgets/friend_tile.dart";
import "package:timing/presentation/groups/group_leaderboard_formatters.dart";
import "package:timing/presentation/groups/widgets/group_member_avatar.dart";
import "package:timing/shared/extensions/enum_localization_extensions.dart";
import "package:timing/shared/widgets/app_icon.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_top_bar.dart";
import "package:timing/shared/widgets/bounce_tap.dart";
import "package:timing/theme/decoration.dart";

part "create_group_page_step_progress.dart";
part "create_group_page_information_step.dart";
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
        backgroundColor: context.creationPageBackground,
        topBar: AppTopBar(
          title: context.l10n.createGroupTitle,
          showBackButton: true,
          onBack: controller.onTapBack,
          titleStyle: context.textStyles.pageTitle.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        body: Obx(() {
          final int step = controller.currentStep.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StepProgress(currentStep: step),
              const Gap(20),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: switch (step) {
                    0 => _InformationStep(
                      controller: controller,
                      groupNameKey: _groupNameKey,
                      themeKey: _themeKey,
                      onSelectTheme: controller.onSelectTheme,
                    ),
                    1 => _FriendsStep(
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
    if (!controller.hasFriends) {
      controller.currentStep.value = 1;
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
    final bool isLoading = controller.isCreating.value;
    final bool isEnabled = switch (controller.currentStep.value) {
      0 => controller.hasName && controller.hasTheme,
      1 => controller.hasFriends,
      _ => controller.canCreate.value,
    };

    return Align(
      child: BounceTap(
        pressedScale: 0.97,
        onTap: onTap,
        // The tap stays live while disabled so it can scroll to the field that
        // is still missing; only the fill dims, like `CreationSubmitButton`.
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: !isEnabled && !isLoading ? 0.62 : 1,
          child: Container(
            // No `alignment` here: it would make the container fill the row
            // instead of hugging the label. The inner row does the centering.
            constraints: const BoxConstraints(minWidth: 200, minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 28),
            decoration: BoxDecoration(
              gradient: context.colorTokens.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: isLoading
                  ? [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 3.2,
                          strokeCap: StrokeCap.round,
                          color: context.colorTokens.primaryForeground,
                        ),
                      ),
                    ]
                  : [
                      Flexible(
                        child: Text(
                          isSummary
                              ? context.l10n.createGroupButton
                              : context.l10n.createGroupContinueButton,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: context.textStyles.textPrimaryButton.copyWith(
                            fontSize: 15,
                            color: context.colorTokens.primaryForeground,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (!isSummary) ...[
                        const Gap(8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 20,
                          color: context.colorTokens.primaryForeground,
                        ),
                      ],
                    ],
            ),
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
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: context.colorTokens.borderUnfocused),
      boxShadow: [
        BoxShadow(
          color: context.colorTokens.surfaceShadow,
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: child,
  );
}
