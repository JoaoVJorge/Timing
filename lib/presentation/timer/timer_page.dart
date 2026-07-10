import "dart:math" as math;

import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/timer/timer_controller.dart";
import "package:help_out/presentation/timer/timer_visual_state.dart";
import "package:help_out/shared/functions/format_duration.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/theme/subject_icons.dart";
import "package:help_out/theme/timer_wallpapers.dart";

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TimerController controller = Get.find();

    return Obx(() {
      final TimerVisualState state = _stateFor(controller);
      final _TimerViewData data = _TimerViewData.fromController(
        context: context,
        controller: controller,
        state: state,
      );

      return PopScope(
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
        child: _TimerScaffold(
          data: data,
          onBackTap: () async {
            if (await controller.confirmExitIfNeeded()) {
              appNavigator.back();
            }
          },
          onEndTap: controller.finishSession,
          onMainTap: () {
            if (state == TimerVisualState.resting) {
              controller.continueFocus();
              return;
            }
            if (state == TimerVisualState.finished) {
              appNavigator.back();
              return;
            }
            controller.togglePause();
          },
          onTrailingTap: () {
            if (state == TimerVisualState.resting) {
              controller.skipRest();
              return;
            }
            appNavigator.toNamed(
              AppRoutes.notes,
              arguments: controller.subject,
            );
          },
        ),
      );
    });
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

class _TimerScaffold extends StatelessWidget {
  const _TimerScaffold({
    required this.data,
    required this.onBackTap,
    required this.onEndTap,
    required this.onMainTap,
    required this.onTrailingTap,
  });

  final _TimerViewData data;
  final VoidCallback onBackTap;
  final VoidCallback onEndTap;
  final VoidCallback onMainTap;
  final VoidCallback onTrailingTap;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colorTokens.black,
    body: DecoratedBox(
      decoration: BoxDecoration(gradient: data.backgroundGradient),
      child: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double progressSize = math.min(
                  constraints.maxWidth * 0.76,
                  292,
                );

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          22,
                          14,
                          22,
                          math.max(MediaQuery.paddingOf(context).bottom, 10),
                        ),
                        child: Column(
                          children: [
                            _TimerHeader(data: data, onBackTap: onBackTap),
                            const Gap(20),
                            _TimerProgressRing(data: data, size: progressSize),
                            const Gap(32),
                            if (data.state == TimerVisualState.resting)
                              const _RestMessage()
                            else
                              Column(
                                children: [
                                  _TimerInfoRow(
                                    icon: Icons.schedule_rounded,
                                    label: data.nextBreakLabel,
                                    value: data.nextBreak,
                                    accentColor: data.accentColor,
                                  ),
                                  const Gap(10),
                                  _TimerInfoRow(
                                    icon: Icons.bar_chart_rounded,
                                    label: "Total hoje",
                                    value: data.totalSubjectTimeLabel,
                                    accentColor: data.accentColor,
                                  ),
                                ],
                              ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _TimerActionButton(
                                  icon: Icons.crop_square_rounded,
                                  label: "Encerrar",
                                  onTap: onEndTap,
                                ),
                                _TimerMainActionButton(
                                  icon: data.mainActionIcon,
                                  label: data.mainActionLabel,
                                  accentColor: data.accentColor,
                                  onTap: onMainTap,
                                ),
                                _TimerActionButton(
                                  icon: data.trailingActionIcon,
                                  label: data.trailingLabel,
                                  onTap: onTrailingTap,
                                ),
                              ],
                            ),
                            const Gap(10),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class _TimerHeader extends StatelessWidget {
  const _TimerHeader({required this.data, required this.onBackTap});

  final _TimerViewData data;
  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 52,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: onBackTap,
            tooltip: "Voltar",
            icon: AppIcon(
              "left_back",
              size: 22,
              color: context.colorTokens.white,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: data.headerIconColor,
              ),
              child: Center(
                child: data.subjectSvgIconName == null
                    ? Icon(
                        data.subjectIcon,
                        color: context.colorTokens.white,
                        size: 22,
                      )
                    : AppIcon(
                        data.subjectSvgIconName!,
                        color: context.colorTokens.white,
                        size: 22,
                      ),
              ),
            ),
            const Gap(12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.subjectName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.colorTokens.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const Gap(6),
                Text(
                  data.status,
                  style: TextStyle(
                    color: context.colorTokens.white.withValues(alpha: 0.58),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

class _TimerProgressRing extends StatelessWidget {
  const _TimerProgressRing({required this.data, required this.size});

  final _TimerViewData data;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size.square(size),
          painter: _TimerRingPainter(data: data),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              data.mainLabel,
              style: TextStyle(
                color: data.accentColor,
                fontSize: math.max(15, size * 0.055),
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap(math.max(10, size * 0.055)),
            Text(
              data.currentTime,
              style: TextStyle(
                color: context.colorTokens.white,
                fontSize: math.max(44, size * 0.22),
                fontWeight: FontWeight.w300,
                height: 1,
              ),
            ),
            Gap(math.max(8, size * 0.045)),
            Text(
              data.totalTimeLabel,
              style: TextStyle(
                color: context.colorTokens.white.withValues(alpha: 0.52),
                fontSize: math.max(14, size * 0.05),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _TimerInfoRow extends StatelessWidget {
  const _TimerInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 480),
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
    decoration: BoxDecoration(
      color: context.colorTokens.black.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(
        color: context.colorTokens.white.withValues(alpha: 0.12),
      ),
    ),
    child: Row(
      children: [
        Icon(icon, color: accentColor, size: 21),
        const Gap(14),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.colorTokens.white.withValues(alpha: 0.64),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Gap(10),
        Text(
          value,
          style: TextStyle(
            color: accentColor,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _TimerActionButton extends StatelessWidget {
  const _TimerActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 72,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: context.colorTokens.white.withValues(alpha: 0.9),
              size: 32,
            ),
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.colorTokens.white.withValues(alpha: 0.58),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

class _TimerMainActionButton extends StatelessWidget {
  const _TimerMainActionButton({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 96,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colorTokens.transparent,
              border: Border.all(color: accentColor, width: 3),
            ),
            child: Icon(icon, color: accentColor, size: 36),
          ),
        ),
        const Gap(13),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.colorTokens.white.withValues(alpha: 0.88),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _RestMessage extends StatelessWidget {
  const _RestMessage();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        "Descanse um pouco",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: context.colorTokens.white,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
      const Gap(10),
      Text(
        context.l10n.timerStateRestingDescription,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: context.colorTokens.white.withValues(alpha: 0.54),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _TimerRingPainter extends CustomPainter {
  const _TimerRingPainter({required this.data});

  final _TimerViewData data;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    const double strokeWidth = 8;
    final double radius = (size.width - strokeWidth) / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    const double startAngle = -math.pi / 2;
    final double sweepAngle = math.pi * 2 * data.progress;

    final Paint trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..color = data.trackColor;
    final Paint progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        colors: data.ringGradientColors,
        stops: const [0, 0.55, 1],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);

    canvas
      ..drawCircle(center, radius, trackPaint)
      ..drawArc(rect, startAngle, sweepAngle, false, progressPaint);

    if (data.showStartDot) {
      _drawDot(
        canvas,
        center,
        radius,
        startAngle,
        data.accentColor,
        strokeWidth * 0.9,
      );
      _drawDot(
        canvas,
        center,
        radius,
        startAngle + sweepAngle,
        data.accentColor,
        strokeWidth * 0.56,
      );
    } else {
      _drawDot(
        canvas,
        center,
        radius,
        startAngle + sweepAngle,
        data.accentColor,
        strokeWidth * 0.84,
      );
    }
  }

  void _drawDot(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    Color color,
    double dotRadius,
  ) {
    final Offset dotCenter = Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );
    canvas.drawCircle(dotCenter, dotRadius, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) =>
      oldDelegate.data != data;
}

class _TimerViewData {
  const _TimerViewData({
    required this.state,
    required this.subjectName,
    required this.status,
    required this.mainLabel,
    required this.currentTime,
    required this.totalTimeLabel,
    required this.nextBreakLabel,
    required this.nextBreak,
    required this.totalSubjectTimeLabel,
    required this.accentColor,
    required this.headerIconColor,
    required this.subjectIcon,
    required this.subjectSvgIconName,
    required this.progress,
    required this.backgroundGradient,
    required this.trackColor,
    required this.ringGradientColors,
    required this.mainActionIcon,
    required this.mainActionLabel,
    required this.trailingActionIcon,
    required this.trailingLabel,
    required this.showStartDot,
  });

  factory _TimerViewData.fromController({
    required BuildContext context,
    required TimerController controller,
    required TimerVisualState state,
  }) {
    final bool isResting = state == TimerVisualState.resting;
    final bool isReading =
        controller.subject.category == TimeCategoryType.reading;
    final Color accent = isResting
        ? const Color(0xFFA879FF)
        : Color(controller.subject.colorValue);
    final int totalIntervalSeconds = isResting
        ? controller.restIntervalSeconds
        : TimerController.focusIntervalSeconds;
    final int currentSeconds = isResting
        ? controller.restCountdownSeconds.value
        : controller.breakCountdownSeconds.value;
    final double progress = state == TimerVisualState.finished
        ? 1
        : isResting
        ? 1 -
              (controller.restCountdownSeconds.value /
                  controller.restIntervalSeconds)
        : controller.focusProgress;
    final String iconName = controller.subject.iconName.isEmpty
        ? _fallbackIconName(controller.subject.category)
        : controller.subject.iconName;
    final IconData? subjectIcon = SubjectIcons.byName(iconName);
    final String? subjectSvgIconName =
        subjectIcon == null && iconName.isNotEmpty ? iconName : null;

    return _TimerViewData(
      state: state,
      subjectName: controller.subject.name,
      status: switch (state) {
        TimerVisualState.resting => context.l10n.timerStateRestingTitle,
        TimerVisualState.paused => context.l10n.timerStatePausedTitle,
        TimerVisualState.finished => context.l10n.timerSessionSavedTitle,
        TimerVisualState.focusing => isReading ? "Leitura" : "Foco",
      },
      mainLabel: isResting
          ? "Pausa"
          : isReading
          ? "Leitura"
          : "Foco",
      currentTime: formatDurationClock(Duration(seconds: currentSeconds)),
      totalTimeLabel:
          "de ${formatDurationClock(Duration(seconds: totalIntervalSeconds))}",
      nextBreakLabel: "Próxima pausa em",
      nextBreak: formatDurationClock(
        Duration(seconds: controller.breakCountdownSeconds.value),
      ),
      totalSubjectTimeLabel: formatDurationLong(
        Duration(seconds: controller.totalSeconds),
      ),
      accentColor: accent,
      headerIconColor: accent.withValues(alpha: 0.82),
      subjectIcon:
          subjectIcon ??
          (isReading ? Icons.menu_book_rounded : Icons.school_rounded),
      subjectSvgIconName: subjectSvgIconName,
      progress: progress.clamp(0, 1).toDouble(),
      backgroundGradient: isResting
          ? const LinearGradient(
              colors: [Color(0xFF07163E), Color(0xFF050C27), Color(0xFF020613)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : TimerWallpapers.byIndex(controller.subject.wallpaperIndex),
      trackColor: accent.withValues(alpha: isResting ? 0.3 : 0.24),
      ringGradientColors: isResting
          ? const [Color(0xFF653CC9), Color(0xFFB986FF), Color(0xFF8F5CFF)]
          : [
              accent.withValues(alpha: 0.72),
              accent,
              Color.lerp(accent, context.colorTokens.white, 0.2) ?? accent,
            ],
      mainActionIcon: switch (state) {
        TimerVisualState.resting => Icons.play_arrow_rounded,
        TimerVisualState.paused => Icons.play_arrow_rounded,
        TimerVisualState.finished => Icons.arrow_back_rounded,
        TimerVisualState.focusing => Icons.pause_rounded,
      },
      mainActionLabel: switch (state) {
        TimerVisualState.resting => context.l10n.timerContinueButton,
        TimerVisualState.paused => context.l10n.timerContinueButton,
        TimerVisualState.finished => context.l10n.timerBackToSubjectsButton,
        TimerVisualState.focusing => context.l10n.timerPauseButton,
      },
      trailingActionIcon: isResting
          ? Icons.skip_next_rounded
          : Icons.sticky_note_2_outlined,
      trailingLabel: isResting ? context.l10n.timerSkipRestButton : "Notas",
      showStartDot: !isResting,
    );
  }

  static String _fallbackIconName(TimeCategoryType category) =>
      switch (category) {
        TimeCategoryType.studying => "school",
        TimeCategoryType.reading => "book",
        TimeCategoryType.exercises => "fitness",
        TimeCategoryType.hobbies => "music",
      };

  final TimerVisualState state;
  final String subjectName;
  final String status;
  final String mainLabel;
  final String currentTime;
  final String totalTimeLabel;
  final String nextBreakLabel;
  final String nextBreak;
  final String totalSubjectTimeLabel;
  final Color accentColor;
  final Color headerIconColor;
  final IconData subjectIcon;
  final String? subjectSvgIconName;
  final double progress;
  final LinearGradient backgroundGradient;
  final Color trackColor;
  final List<Color> ringGradientColors;
  final IconData mainActionIcon;
  final String mainActionLabel;
  final IconData trailingActionIcon;
  final String trailingLabel;
  final bool showStartDot;
}
