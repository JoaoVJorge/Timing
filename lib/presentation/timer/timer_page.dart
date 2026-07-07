import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/timer/timer_controller.dart";
import "package:help_out/shared/extensions/enum_localization_extensions.dart";
import "package:help_out/shared/functions/format_duration.dart";
import "package:help_out/shared/widgets/app_button.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/theme/subject_icons.dart";
import "package:help_out/theme/timer_wallpapers.dart";

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TimerController controller = Get.find();
    final Color subjectColor = Color(controller.subject.colorValue);
    final IconData? subjectIcon = SubjectIcons.byName(
      controller.subject.iconName,
    );

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          controller.saveProgress();
        }
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: TimerWallpapers.byIndex(controller.subject.wallpaperIndex),
        ),
        child: AppScaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(16),
              IconButton(
                onPressed: appNavigator.back,
                icon: AppIcon(
                  "left_back",
                  size: 20,
                  color: context.colorTokens.primary,
                ),
              ),
              const Gap(24),
              Center(
                child: Column(
                  children: [
                    if (subjectIcon != null) ...[
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: subjectColor.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                          border: Border.all(color: subjectColor, width: 2),
                        ),
                        child: Icon(subjectIcon, size: 28, color: subjectColor),
                      ),
                      const Gap(12),
                    ],
                    Text(
                      controller.subject.category
                          .localizedLabel(context)
                          .toUpperCase(),
                      style: context.textStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                        letterSpacing: 2,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      controller.subject.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: context.textStyles.titleFont,
                    ),
                    if (controller.subject.musicSuggestion.isNotEmpty) ...[
                      const Gap(12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.music_note_rounded,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            const Gap(4),
                            Flexible(
                              child: Text(
                                context.l10n.timerMusicSuggestion(
                                  controller.subject.musicSuggestion,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textStyles.bodySmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Gap(36),
                    Obx(
                      () => Text(
                        formatDurationClock(
                          Duration(seconds: controller.sessionSeconds.value),
                        ),
                        style: context.textStyles.black32.copyWith(
                          fontSize: 56,
                        ),
                      ),
                    ),
                    const Gap(12),
                    Obx(
                      () => Text(
                        context.l10n.timerTotalLabel(
                          formatDurationClock(
                            Duration(seconds: controller.totalSeconds),
                          ),
                        ),
                        style: context.textStyles.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    const Gap(4),
                    Obx(
                      () => Text(
                        controller.isResting.value
                            ? context.l10n.timerRestingLabel(
                                formatDurationClock(
                                  Duration(
                                    seconds:
                                        controller.restCountdownSeconds.value,
                                  ),
                                ),
                              )
                            : context.l10n.timerNextBreakLabel(
                                formatDurationClock(
                                  Duration(
                                    seconds:
                                        controller.breakCountdownSeconds.value,
                                  ),
                                ),
                              ),
                        style: context.textStyles.bodySmall.copyWith(
                          color: controller.isResting.value
                              ? context.colorTokens.success
                              : Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Center(
                child: Obx(
                  () => AppButton(
                    icon: controller.isRunning.value
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    onTap: controller.togglePause,
                    size: 84,
                  ),
                ),
              ),
              const Gap(48),
            ],
          ),
        ),
      ),
    );
  }
}
