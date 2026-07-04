import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/timer/timer_controller.dart";
import "package:help_out/shared/functions/format_duration.dart";
import "package:help_out/shared/widgets/app_button.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TimerController controller = Get.find();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          controller.saveProgress();
        }
      },
      child: AppScaffold(
        backgroundColor: Colors.black,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(16),
            IconButton(
              onPressed: appNavigator.back,
              icon: AppIcon("left_back", size: 20, color: context.colorTokens.primary),
            ),
            const Gap(24),
            Center(
              child: Column(
                children: [
                  Text(controller.subject.name, style: context.textStyles.titleFont),
                  const Gap(48),
                  Obx(
                    () => Text(
                      formatDurationClock(Duration(seconds: controller.sessionSeconds.value)),
                      style: context.textStyles.black32.copyWith(fontSize: 56),
                    ),
                  ),
                  const Gap(8),
                  Obx(
                    () => Text(
                      context.l10n.timerTotalLabel(formatDurationClock(Duration(seconds: controller.totalSeconds))),
                      style: context.textStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.7)),
                    ),
                  ),
                  const Gap(12),
                  Obx(
                    () => Text(
                      context.l10n.timerNextBreakLabel(
                        formatDurationClock(Duration(seconds: controller.breakCountdownSeconds.value)),
                      ),
                      style: context.textStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.4)),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: Obx(
                () => AppButton(
                  icon: controller.isRunning.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  onTap: controller.togglePause,
                  size: 84,
                ),
              ),
            ),
            const Gap(48),
          ],
        ),
      ),
    );
  }
}
