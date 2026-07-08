import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/timer/timer_controller.dart";
import "package:help_out/presentation/timer/timer_visual_state.dart";
import "package:help_out/presentation/timer/widgets/timer_action_buttons.dart";
import "package:help_out/presentation/timer/widgets/timer_session_summary.dart";
import "package:help_out/presentation/timer/widgets/timer_status_card.dart";
import "package:help_out/shared/extensions/enum_localization_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/theme/subject_icons.dart";
import "package:help_out/theme/timer_wallpapers.dart";

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TimerController controller = Get.find();

    return Obx(
      () => PopScope(
        canPop: !controller.hasActiveSession,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) {
            controller.saveProgress();
            return;
          }
          if (await controller.confirmExitIfNeeded()) {
            appNavigator.back();
          }
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: TimerWallpapers.byIndex(
              controller.subject.wallpaperIndex,
            ),
          ),
          child: Container(
            color: Colors.black.withValues(alpha: 0.36),
            child: AppScaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TimerHeader(controller: controller),
                      const Gap(24),
                      if (controller.isSessionFinished.value)
                        TimerSessionSummary(
                          subjectName: controller.subject.name,
                          sessionSeconds: controller.sessionSeconds.value,
                          totalSeconds: controller.totalSeconds,
                          onBackTap: appNavigator.back,
                        )
                      else ...[
                        TimerStatusCard(
                          subjectName: controller.subject.name,
                          state: _stateFor(controller),
                          sessionSeconds: controller.sessionSeconds.value,
                          totalSeconds: controller.totalSeconds,
                          breakCountdownSeconds:
                              controller.breakCountdownSeconds.value,
                          restCountdownSeconds:
                              controller.restCountdownSeconds.value,
                          restIntervalSeconds: controller.restIntervalSeconds,
                          focusProgress: controller.focusProgress,
                        ),
                        const Gap(16),
                        _MusicSuggestion(controller: controller),
                        const Gap(18),
                        TimerActionButtons(
                          state: _stateFor(controller),
                          onPrimaryTap: () {
                            if (controller.isResting.value) {
                              controller.continueFocus();
                              return;
                            }
                            controller.togglePause();
                          },
                          onSkipRestTap: controller.skipRest,
                          onEndTap: controller.finishSession,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TimerVisualState _stateFor(TimerController controller) {
    if (controller.isSessionFinished.value) {
      return TimerVisualState.finished;
    }
    if (controller.isResting.value) {
      return TimerVisualState.resting;
    }
    if (!controller.isRunning.value) {
      return TimerVisualState.paused;
    }
    return TimerVisualState.focusing;
  }
}

class _TimerHeader extends StatelessWidget {
  const _TimerHeader({required this.controller});

  final TimerController controller;

  @override
  Widget build(BuildContext context) {
    final Color subjectColor = Color(controller.subject.colorValue);
    final IconData? subjectIcon = SubjectIcons.byName(
      controller.subject.iconName,
    );

    return Row(
      children: [
        IconButton(
          onPressed: () async {
            if (await controller.confirmExitIfNeeded()) {
              appNavigator.back();
            }
          },
          icon: const AppIcon("left_back", size: 20, color: Colors.white),
        ),
        const Gap(8),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: subjectColor.withValues(alpha: 0.25),
            shape: BoxShape.circle,
            border: Border.all(color: subjectColor.withValues(alpha: 0.8)),
          ),
          child: Icon(subjectIcon, size: 24, color: Colors.white),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.subject.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Gap(4),
              Text(
                controller.subject.category.localizedLabel(context),
                style: context.textStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MusicSuggestion extends StatelessWidget {
  const _MusicSuggestion({required this.controller});

  final TimerController controller;

  @override
  Widget build(BuildContext context) {
    final String suggestion = controller.subject.musicSuggestion.trim();
    if (suggestion.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.music_note_rounded,
            size: 20,
            color: Colors.white.withValues(alpha: 0.76),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.timerMusicSuggestionTitle,
                  style: context.textStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.58),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(4),
                Text(
                  suggestion,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
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
