import "dart:math" as math;

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/app/app_routes.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/timer/timer_controller.dart";
import "package:timing/presentation/timer/timer_visual_state.dart";
import "package:timing/shared/functions/format_duration.dart";
import "package:timing/shared/widgets/app_icon.dart";
import "package:timing/theme/subject_icons.dart";
import "package:timing/theme/timer_wallpapers.dart";

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TimerController controller = Get.find();

    // Outer Obx tracks only the coarse visual state (running / resting /
    // paused / finished). It rebuilds the chrome — background, header, action
    // buttons — on a transition, not on every one-second tick. The clock,
    // progress ring and stat values live behind their own inner Obx below so
    // the per-second rebuild stays scoped to what actually changes.
    return Obx(() {
      final TimerVisualState state = _stateFor(controller);
      final _TimerChrome chrome = _TimerChrome.fromController(
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
            appNavigator.back(result: controller.subject);
          }
        },
        child: _TimerScaffold(
          chrome: chrome,
          onBackTap: () async {
            if (await controller.confirmExitIfNeeded()) {
              appNavigator.back(result: controller.subject);
            }
          },
          onEndTap: controller.confirmFinishSession,
          onMainTap: () {
            if (state == TimerVisualState.resting) {
              controller.continueFocus();
              return;
            }
            if (state == TimerVisualState.finished) {
              appNavigator.back(result: controller.subject);
              return;
            }
            controller.togglePause();
          },
          onTrailingTap: () async {
            if (state == TimerVisualState.resting) {
              controller.skipRest();
              return;
            }
            final dynamic result = await appNavigator.toNamed(
              AppRoutes.notes,
              arguments: controller.subject,
            );
            final String? updatedNotes = result as String?;
            if (updatedNotes != null) {
              controller.updateSubjectNotes(updatedNotes);
            }
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
    required this.chrome,
    required this.onBackTap,
    required this.onEndTap,
    required this.onMainTap,
    required this.onTrailingTap,
  });

  final _TimerChrome chrome;
  final VoidCallback onBackTap;
  final VoidCallback onEndTap;
  final VoidCallback onMainTap;
  final VoidCallback onTrailingTap;

  @override
  Widget build(BuildContext context) {
    final TimerController controller = Get.find();

    return Scaffold(
      backgroundColor: context.colorTokens.black,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: chrome.backgroundGradient),
        child: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double progressSize = math.min(
                    constraints.maxWidth * 0.76,
                    292,
                  );
                  final double bottomPadding = math.max(
                    18,
                    MediaQuery.paddingOf(context).bottom,
                  );

                  return CustomScrollView(
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            22,
                            14,
                            22,
                            bottomPadding,
                          ),
                          child: Column(
                            children: [
                              _TimerHeader(
                                chrome: chrome,
                                onBackTap: onBackTap,
                              ),
                              const Gap(20),
                              Obx(
                                () => _TimerProgressRing(
                                  chrome: chrome,
                                  tick: _TimerTick.fromController(
                                    controller: controller,
                                    state: chrome.state,
                                  ),
                                  size: progressSize,
                                ),
                              ),
                              const Gap(32),
                              if (chrome.state == TimerVisualState.resting)
                                const _RestMessage()
                              else
                                Obx(
                                  () => _TimerStatsCard(
                                    chrome: chrome,
                                    tick: _TimerTick.fromController(
                                      controller: controller,
                                      state: chrome.state,
                                    ),
                                  ),
                                ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _TimerActionButton(
                                    iconPath: "stop",
                                    label: context.l10n.timerEndActionLabel,
                                    onTap: onEndTap,
                                  ),
                                  _TimerMainActionButton(
                                    icon: chrome.mainActionIcon,
                                    label: chrome.mainActionLabel,
                                    accentColor: chrome.accentColor,
                                    onTap: onMainTap,
                                  ),
                                  _TimerActionButton(
                                    iconPath: "note",
                                    label: chrome.trailingLabel,
                                    onTap: onTrailingTap,
                                  ),
                                ],
                              ),
                              const Gap(28),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerHeader extends StatelessWidget {
  const _TimerHeader({required this.chrome, required this.onBackTap});

  final _TimerChrome chrome;
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
            tooltip: context.l10n.timerBackTooltip,
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
                color: chrome.headerIconColor,
              ),
              child: Center(
                child: chrome.subjectSvgIconName == null
                    ? Icon(
                        chrome.subjectIcon,
                        color: context.colorTokens.white,
                        size: 22,
                      )
                    : AppIcon(
                        chrome.subjectSvgIconName!,
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
                  chrome.subjectName,
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
                  chrome.status,
                  style: TextStyle(
                    color: context.colorTokens.white.withValues(alpha: 0.58),
                    fontSize: 14,
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
  const _TimerProgressRing({
    required this.chrome,
    required this.tick,
    required this.size,
  });

  final _TimerChrome chrome;
  final _TimerTick tick;
  final double size;

  @override
  Widget build(BuildContext context) {
    final int percent = (tick.progress.clamp(0, 1) * 100).round();
    return MergeSemantics(
      child: Semantics(
        label: context.l10n.timerProgressSemanticLabel(percent),
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ExcludeSemantics(
                child: CustomPaint(
                  size: Size.square(size),
                  painter: _TimerRingPainter(
                    progress: tick.progress,
                    trackColor: chrome.trackColor,
                    ringGradientColors: chrome.ringGradientColors,
                    accentColor: chrome.accentColor,
                    showStartDot: chrome.showStartDot,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    chrome.mainLabel,
                    style: TextStyle(
                      color: chrome.accentColor,
                      fontSize: math.max(15, size * 0.055),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gap(math.max(10, size * 0.055)),
                  _TimerClockDisplay(
                    value: tick.currentTime,
                    leadingUnit: tick.currentTimeLeadingUnit,
                    trailingUnit: tick.currentTimeTrailingUnit,
                    size: size,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerClockDisplay extends StatelessWidget {
  const _TimerClockDisplay({
    required this.value,
    required this.leadingUnit,
    required this.trailingUnit,
    required this.size,
  });

  final String value;
  final String leadingUnit;
  final String trailingUnit;
  final double size;

  @override
  Widget build(BuildContext context) {
    final double fontSize = math.max(44, size * 0.22);
    final double unitFontSize = math.max(12, size * 0.045);
    final List<String> parts = value.split(":");
    final String leadingValue = parts.isNotEmpty ? parts.first : value;
    final String trailingValue = parts.length > 1 ? parts[1] : "";

    return SizedBox(
      width: size * 0.86,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TimerClockPart(
              value: leadingValue,
              unit: leadingUnit,
              fontSize: fontSize,
              unitFontSize: unitFontSize,
            ),
            Text(
              ":",
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                color: context.colorTokens.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w300,
                height: 0.96,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            _TimerClockPart(
              value: trailingValue,
              unit: trailingUnit,
              fontSize: fontSize,
              unitFontSize: unitFontSize,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerClockPart extends StatelessWidget {
  const _TimerClockPart({
    required this.value,
    required this.unit,
    required this.fontSize,
    required this.unitFontSize,
  });

  final String value;
  final String unit;
  final double fontSize;
  final double unitFontSize;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: fontSize * 1.32,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          maxLines: 1,
          softWrap: false,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.colorTokens.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w300,
            height: 0.96,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const Gap(1),
        Text(
          unit,
          maxLines: 1,
          softWrap: false,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.colorTokens.white.withValues(alpha: 0.58),
            fontSize: unitFontSize,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ],
    ),
  );
}

class _TimerStatsCard extends StatelessWidget {
  const _TimerStatsCard({required this.chrome, required this.tick});

  final _TimerChrome chrome;
  final _TimerTick tick;

  @override
  Widget build(BuildContext context) {
    final String firstLabel = chrome.isReading
        ? context.l10n.timerCurrentPagesLabel
        : context.l10n.timerBreakStatLabel;
    final IconData firstIcon = chrome.isReading
        ? Icons.menu_book_rounded
        : Icons.free_breakfast_rounded;

    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: context.colorTokens.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.colorTokens.white.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TimerStatItem(
              icon: firstIcon,
              label: firstLabel,
              value: tick.nextBreak,
              accentColor: chrome.accentColor,
            ),
          ),
          _TimerStatDivider(),
          Expanded(
            child: _TimerStatItem(
              icon: Icons.repeat_rounded,
              label: context.l10n.sessionSection,
              value: tick.focusSectionLabel,
              accentColor: chrome.accentColor,
            ),
          ),
          _TimerStatDivider(),
          Expanded(
            child: _TimerStatItem(
              icon: Icons.bar_chart_rounded,
              label: context.l10n.todayLabel,
              value: tick.totalSubjectTimeLabel,
              accentColor: chrome.accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerStatItem extends StatelessWidget {
  const _TimerStatItem({
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
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: accentColor, size: 24),
      const Gap(9),
      Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: context.colorTokens.white.withValues(alpha: 0.62),
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
      const Gap(6),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          value,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.colorTokens.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ),
    ],
  );
}

class _TimerStatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 58,
    margin: const EdgeInsets.symmetric(horizontal: 10),
    color: context.colorTokens.white.withValues(alpha: 0.12),
  );
}

class _TimerActionButton extends StatelessWidget {
  const _TimerActionButton({
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  final String iconPath;
  final String label;
  final VoidCallback onTap;

  static const double _buttonSize = 64;
  static const double _iconSize = 24;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    onTap: onTap,
    child: ExcludeSemantics(
      child: SizedBox(
        width: 82,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: _buttonSize,
                height: _buttonSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colorTokens.white.withValues(alpha: 0.08),
                  border: Border.all(
                    color: context.colorTokens.white.withValues(alpha: 0.12),
                  ),
                ),
                alignment: Alignment.center,
                child: AppIcon(
                  iconPath,
                  color: context.colorTokens.white.withValues(alpha: 0.9),
                  size: _iconSize,
                ),
              ),
            ),
            const Gap(8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.colorTokens.white.withValues(alpha: 0.58),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    onTap: onTap,
    child: ExcludeSemantics(
      child: SizedBox(
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
      ),
    ),
  );
}

class _RestMessage extends StatelessWidget {
  const _RestMessage();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        context.l10n.timerRestMessageTitle,
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
  const _TimerRingPainter({
    required this.progress,
    required this.trackColor,
    required this.ringGradientColors,
    required this.accentColor,
    required this.showStartDot,
  });

  final double progress;
  final Color trackColor;
  final List<Color> ringGradientColors;
  final Color accentColor;
  final bool showStartDot;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    const double strokeWidth = 8;
    final double radius = (size.width - strokeWidth) / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    const double startAngle = -math.pi / 2;
    final double sweepAngle = math.pi * 2 * progress;

    final Paint trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    final Paint progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        colors: ringGradientColors,
        stops: const [0, 0.55, 1],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);

    canvas
      ..drawCircle(center, radius, trackPaint)
      ..drawArc(rect, startAngle, sweepAngle, false, progressPaint);

    if (showStartDot) {
      _drawDot(
        canvas,
        center,
        radius,
        startAngle,
        accentColor,
        strokeWidth * 0.9,
      );
      _drawDot(
        canvas,
        center,
        radius,
        startAngle + sweepAngle,
        accentColor,
        strokeWidth * 0.56,
      );
    } else {
      _drawDot(
        canvas,
        center,
        radius,
        startAngle + sweepAngle,
        accentColor,
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
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.showStartDot != showStartDot ||
      !listEquals(oldDelegate.ringGradientColors, ringGradientColors);
}

/// State-derived view data for the timer chrome: everything that only changes
/// when the session moves between focusing / resting / paused / finished, or
/// that comes straight off the subject. Rebuilt by the outer [Obx].
class _TimerChrome {
  const _TimerChrome({
    required this.state,
    required this.subjectName,
    required this.status,
    required this.mainLabel,
    required this.isReading,
    required this.accentColor,
    required this.headerIconColor,
    required this.subjectIcon,
    required this.subjectSvgIconName,
    required this.backgroundGradient,
    required this.trackColor,
    required this.ringGradientColors,
    required this.mainActionIcon,
    required this.mainActionLabel,
    required this.trailingLabel,
    required this.showStartDot,
  });

  factory _TimerChrome.fromController({
    required BuildContext context,
    required TimerController controller,
    required TimerVisualState state,
  }) {
    final bool isResting = state == TimerVisualState.resting;
    final bool isReading =
        controller.subject.category == TimeCategoryType.reading;
    final Color accent = isResting
        ? TimerRestPalette.accent
        : Color(controller.subject.colorValue);
    final String iconName = controller.subject.iconName.isEmpty
        ? controller.subject.category.iconName
        : controller.subject.iconName;
    final IconData? subjectIcon = SubjectIcons.byName(iconName);
    final String? subjectSvgIconName =
        subjectIcon == null && iconName.isNotEmpty ? iconName : null;

    return _TimerChrome(
      state: state,
      subjectName: controller.subject.name,
      status: switch (state) {
        TimerVisualState.resting => context.l10n.timerStateRestingTitle,
        TimerVisualState.paused => context.l10n.timerStatePausedTitle,
        TimerVisualState.finished => context.l10n.timerSessionSavedTitle,
        TimerVisualState.focusing =>
          isReading
              ? context.l10n.timerReadingLabel
              : context.l10n.timerFocusLabel,
      },
      mainLabel: isResting
          ? context.l10n.timerPauseLabel
          : isReading
          ? context.l10n.timerReadingLabel
          : context.l10n.timerFocusLabel,
      isReading: isReading,
      accentColor: accent,
      headerIconColor: accent.withValues(alpha: 0.82),
      subjectIcon:
          subjectIcon ??
          (isReading ? Icons.menu_book_rounded : Icons.school_rounded),
      subjectSvgIconName: subjectSvgIconName,
      backgroundGradient: isResting
          ? TimerRestPalette.backgroundGradient
          : TimerWallpapers.byIndex(controller.subject.wallpaperIndex),
      trackColor: accent.withValues(alpha: isResting ? 0.3 : 0.24),
      ringGradientColors: isResting
          ? TimerRestPalette.ringGradientColors
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
      trailingLabel: isResting
          ? context.l10n.timerSkipRestButton
          : context.l10n.timerNotesLabel,
      showStartDot: !isResting,
    );
  }

  final TimerVisualState state;
  final String subjectName;
  final String status;
  final String mainLabel;
  final bool isReading;
  final Color accentColor;
  final Color headerIconColor;
  final IconData subjectIcon;
  final String? subjectSvgIconName;
  final LinearGradient backgroundGradient;
  final Color trackColor;
  final List<Color> ringGradientColors;
  final IconData mainActionIcon;
  final String mainActionLabel;
  final String trailingLabel;
  final bool showStartDot;
}

/// The per-second slice: clock text, ring progress and the stat values.
/// Rebuilt by the inner [Obx] wrappers so the tick stays off the chrome.
class _TimerTick {
  const _TimerTick({
    required this.currentTime,
    required this.currentTimeLeadingUnit,
    required this.currentTimeTrailingUnit,
    required this.nextBreak,
    required this.focusSectionLabel,
    required this.totalSubjectTimeLabel,
    required this.progress,
  });

  factory _TimerTick.fromController({
    required TimerController controller,
    required TimerVisualState state,
  }) {
    final bool isResting = state == TimerVisualState.resting;
    final bool isReading =
        controller.subject.category == TimeCategoryType.reading;
    final bool isDailyHobby =
        controller.subject.category == TimeCategoryType.hobbies &&
        controller.subject.activityType == SubjectActivityType.daily;
    final int currentSeconds = isResting
        ? (controller.restIntervalSeconds -
                  controller.restCountdownSeconds.value)
              .clamp(0, controller.restIntervalSeconds)
        : isDailyHobby
        ? controller.currentActivitySeconds
        : controller.sessionSeconds.value;
    final bool currentTimeUsesHours = currentSeconds >= 3600;
    final double progress = state == TimerVisualState.finished
        ? 1
        : isReading
        ? 1
        : isResting
        ? 1 -
              (controller.restCountdownSeconds.value /
                  controller.restIntervalSeconds)
        : controller.focusProgress;

    return _TimerTick(
      currentTime: formatDurationCompactClock(
        Duration(seconds: currentSeconds),
      ),
      currentTimeLeadingUnit: currentTimeUsesHours ? "h" : "min",
      currentTimeTrailingUnit: currentTimeUsesHours ? "min" : "s",
      nextBreak: isReading
          ? "${controller.currentActivityPages}"
          : _formatRestDuration(
              Duration(seconds: controller.restIntervalSeconds),
              controller.subject.category,
            ),
      focusSectionLabel: "${controller.currentFocusSection}",
      totalSubjectTimeLabel: formatDurationLong(
        Duration(seconds: controller.currentActivitySeconds),
      ),
      progress: progress.clamp(0, 1).toDouble(),
    );
  }

  static String _formatRestDuration(
    Duration duration,
    TimeCategoryType category,
  ) => category == TimeCategoryType.exercises
      ? formatDurationTotalSeconds(duration)
      : formatDurationTotalMinutes(duration);

  final String currentTime;
  final String currentTimeLeadingUnit;
  final String currentTimeTrailingUnit;
  final String nextBreak;
  final String focusSectionLabel;
  final String totalSubjectTimeLabel;
  final double progress;
}
