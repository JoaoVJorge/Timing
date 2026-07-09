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
    backgroundColor: Colors.black,
    body: DecoratedBox(
      decoration: BoxDecoration(gradient: data.backgroundGradient),
      child: Stack(
        children: [
          Positioned.fill(child: _TimerGlow(color: data.accentColor)),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double progressSize = math.min(
                  constraints.maxWidth * 0.76,
                  292,
                );
                final bool compact = constraints.maxHeight < 700;

                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    22,
                    12,
                    22,
                    math.max(MediaQuery.paddingOf(context).bottom, 12),
                  ),
                  child: Column(
                    children: [
                      _TimerHeader(data: data, onBackTap: onBackTap),
                      Gap(compact ? 20 : 32),
                      _TimerProgressRing(data: data, size: progressSize),
                      Gap(compact ? 22 : 28),
                      if (data.state == TimerVisualState.resting)
                        const _RestMessage()
                      else
                        Column(
                          children: [
                            _TimerInfoChip(
                              children: [
                                TextSpan(text: data.nextBreakLabel),
                                TextSpan(
                                  text: data.nextBreak,
                                  style: TextStyle(
                                    color: data.accentColor,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(16),
                            _TimerInfoChip(
                              children: [
                                TextSpan(text: data.totalSubjectTimeLabel),
                              ],
                            ),
                          ],
                        ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _TimerActionButton(
                            icon: Icons.stop_rounded,
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
                      const Gap(34),
                    ],
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
    height: 48,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: onBackTap,
            tooltip: "Voltar",
            icon: const AppIcon("left_back", size: 22, color: Colors.white),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: data.headerIconColor,
                boxShadow: [
                  BoxShadow(
                    color: data.headerIconColor.withValues(alpha: 0.35),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: Icon(data.subjectIcon, color: Colors.white, size: 19),
            ),
            const Gap(10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.subjectName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const Gap(5),
                Text(
                  data.status,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.58),
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
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(12),
            Text(
              data.currentTime,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.w300,
                height: 1,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    offset: Offset(0, 2),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
            const Gap(14),
            Text(
              data.totalTimeLabel,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.52),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _TimerInfoChip extends StatelessWidget {
  const _TimerInfoChip({required this.children});

  final List<InlineSpan> children;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.055),
      borderRadius: BorderRadius.circular(100),
      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.16),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.74),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        children: children,
      ),
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
    width: 84,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 78,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.82),
              size: 29,
            ),
          ),
        ),
        const Gap(10),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.58),
            fontSize: 12,
            fontWeight: FontWeight.w700,
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
        InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.white.withValues(alpha: 0.22), accentColor],
                center: const Alignment(-0.24, -0.3),
                radius: 0.92,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.38),
                  blurRadius: 34,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 36),
          ),
        ),
        const Gap(12),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 12,
            fontWeight: FontWeight.w800,
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
      const Text(
        "Descanse um pouco",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
      const Gap(10),
      Text(
        context.l10n.timerStateRestingDescription,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.54),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _TimerGlow extends StatelessWidget {
  const _TimerGlow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: RadialGradient(
        colors: [color.withValues(alpha: 0.22), Colors.transparent],
        center: const Alignment(0, -0.2),
        radius: 0.72,
      ),
    ),
  );
}

class _TimerRingPainter extends CustomPainter {
  const _TimerRingPainter({required this.data});

  final _TimerViewData data;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    const double strokeWidth = 10;
    final double radius = (size.width - strokeWidth) / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    const double startAngle = -math.pi / 2;
    final double sweepAngle = math.pi * 2 * data.progress;

    final Paint trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..color = data.trackColor;
    final Paint glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth + 9
      ..color = data.accentColor.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
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
      ..drawArc(rect, startAngle, sweepAngle, false, glowPaint)
      ..drawArc(rect, startAngle, sweepAngle, false, progressPaint);

    _drawDot(
      canvas,
      center,
      radius,
      startAngle + sweepAngle,
      data.accentColor,
      strokeWidth * 0.84,
    );
    if (data.showStartDot) {
      _drawDot(
        canvas,
        center,
        radius,
        startAngle,
        data.accentColor,
        strokeWidth * 0.52,
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
    canvas
      ..drawCircle(
        dotCenter,
        dotRadius * 1.75,
        Paint()..color = color.withValues(alpha: 0.2),
      )
      ..drawCircle(dotCenter, dotRadius, Paint()..color = color);
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
    final IconData? subjectIcon = SubjectIcons.byName(
      controller.subject.iconName,
    );

    return _TimerViewData(
      state: state,
      subjectName: controller.subject.name,
      status: switch (state) {
        TimerVisualState.resting => context.l10n.timerStateRestingTitle,
        TimerVisualState.paused => context.l10n.timerStatePausedTitle,
        TimerVisualState.finished => context.l10n.timerSessionSavedTitle,
        TimerVisualState.focusing => isReading ? "Lendo" : "Estudando",
      },
      mainLabel: isResting
          ? "Pausa"
          : isReading
          ? "Leitura"
          : "Foco",
      currentTime: formatDurationClock(Duration(seconds: currentSeconds)),
      totalTimeLabel:
          "de ${formatDurationClock(Duration(seconds: totalIntervalSeconds))}",
      nextBreakLabel: "Próxima pausa em ",
      nextBreak: formatDurationClock(
        Duration(seconds: controller.breakCountdownSeconds.value),
      ),
      totalSubjectTimeLabel:
          "${context.l10n.timerTotalInSubject(controller.subject.name)}: ${formatDurationLong(Duration(seconds: controller.totalSeconds))}",
      accentColor: accent,
      headerIconColor: accent.withValues(alpha: 0.82),
      subjectIcon:
          subjectIcon ??
          (isReading ? Icons.menu_book_rounded : Icons.school_rounded),
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
              Color.lerp(accent, Colors.white, 0.2) ?? accent,
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
