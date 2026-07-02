import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/timer/timer_controller.dart";
import "package:help_out/shared/functions/format_duration.dart";
import "package:help_out/shared/widgets/app_button.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TimerController controller = Get.find();
    final Color subjectColor = Color(controller.subject.colorValue);

    return AppScaffold(
      backgroundColor: subjectColor.withValues(alpha: 0.06),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(16),
          IconButton(onPressed: appNavigator.back, icon: Icon(Icons.arrow_back, color: context.colorTokens.textBody)),
          const Gap(24),
          Center(
            child: Column(
              children: [
                Text(controller.subject.name, style: context.textStyles.titleFont.copyWith(color: subjectColor)),
                const Gap(48),
                Obx(
                  () => Text(
                    formatDurationClock(Duration(seconds: controller.totalSeconds)),
                    style: context.textStyles.black32.copyWith(fontSize: 56, color: subjectColor),
                  ),
                ),
                const Gap(8),
                Obx(
                  () => Text(
                    "This session: ${formatDurationClock(Duration(seconds: controller.sessionSeconds.value))}",
                    style: context.textStyles.bodyMedium,
                  ),
                ),
                const Gap(12),
                Obx(
                  () => Text(
                    "Next break in ${formatDurationClock(Duration(seconds: controller.breakCountdownSeconds.value))}",
                    style: context.textStyles.bodySmall.copyWith(color: context.colorTokens.textBody.withValues(alpha: 0.4)),
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
    );
  }
}
