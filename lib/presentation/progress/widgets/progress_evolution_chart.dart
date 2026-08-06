import "package:flutter/material.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/theme/app_surfaces.dart";

/// What the bar heights represent, which drives axis and value labels.
enum EvolutionValueUnit { minutes, pages }

/// Framed evolution chart used on the Progress page.
class ProgressEvolutionChart extends StatelessWidget {
  const ProgressEvolutionChart({required this.values, super.key});

  final List<int> values;

  @override
  Widget build(BuildContext context) => Container(
    height: 232,
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
    decoration: AppSurfaces.content(context.colorTokens),
    child: EvolutionBarChart(values: values),
  );
}

/// Bare bar chart (no surrounding card) so it can be embedded in other cards.
class EvolutionBarChart extends StatefulWidget {
  const EvolutionBarChart({
    required this.values,
    this.unit = EvolutionValueUnit.minutes,
    super.key,
  });

  final List<int> values;
  final EvolutionValueUnit unit;

  @override
  State<EvolutionBarChart> createState() => _EvolutionBarChartState();
}

class _EvolutionBarChartState extends State<EvolutionBarChart> {
  int? _selectedIndex;
  double _currentHighlightPosition = 0;
  double _lastHighlightPosition = 0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final List<int> safeValues = widget.values.isEmpty
          ? const [0]
          : widget.values;
      final double targetHighlightPosition =
          (_selectedIndex ?? _highlightIndex(safeValues)).toDouble();

      return TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: _lastHighlightPosition,
          end: targetHighlightPosition,
        ),
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        onEnd: () => _lastHighlightPosition = targetHighlightPosition,
        builder: (context, highlightPosition, child) {
          _currentHighlightPosition = highlightPosition;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => _selectDayAt(
              details.localPosition.dx,
              constraints.maxWidth,
              safeValues.length,
            ),
            child: CustomPaint(
              painter: _EvolutionBarChartPainter(
                values: widget.values,
                unit: widget.unit,
                selectedIndex: _selectedIndex,
                highlightPosition: highlightPosition,
                barColor: context.colorTokens.primary,
                gridColor: context.colorTokens.divider,
                axisColor: context.colorTokens.textHint,
                axisTextStyle: context.textStyles.caption.copyWith(
                  color: context.colorTokens.textHint,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                tooltipTextStyle: context.textStyles.caption.copyWith(
                  color: context.colorTokens.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
                dayLabels: _dayLabels(context, widget.values.length),
              ),
              child: const SizedBox.expand(),
            ),
          );
        },
      );
    },
  );

  void _selectDayAt(double localX, double width, int valueCount) {
    final double chartWidth = width - _EvolutionChartMetrics.chartLeft;
    if (chartWidth <= 0 || valueCount <= 0) {
      return;
    }

    final double slotWidth = chartWidth / valueCount;
    final int index = ((localX - _EvolutionChartMetrics.chartLeft) / slotWidth)
        .floor()
        .clamp(0, valueCount - 1);
    _lastHighlightPosition = _currentHighlightPosition;
    setState(() => _selectedIndex = index);
  }
}

int _highlightIndex(List<int> safeValues) {
  int bestIndex = 0;
  int bestValue = 0;
  for (int i = 0; i < safeValues.length; i++) {
    if (safeValues[i] > bestValue) {
      bestValue = safeValues[i];
      bestIndex = i;
    }
  }
  return bestIndex;
}

class _EvolutionBarChartPainter extends CustomPainter {
  const _EvolutionBarChartPainter({
    required this.values,
    required this.unit,
    required this.selectedIndex,
    required this.highlightPosition,
    required this.barColor,
    required this.gridColor,
    required this.axisColor,
    required this.axisTextStyle,
    required this.tooltipTextStyle,
    required this.dayLabels,
  });

  final List<int> values;
  final EvolutionValueUnit unit;
  final int? selectedIndex;
  final double highlightPosition;
  final Color barColor;
  final Color gridColor;
  final Color axisColor;
  final TextStyle axisTextStyle;
  final TextStyle tooltipTextStyle;
  final List<String> dayLabels;

  @override
  void paint(Canvas canvas, Size size) {
    final List<int> safeValues = values.isEmpty ? const [0] : values;
    final int baseline = unit == EvolutionValueUnit.pages ? 4 : 60;
    final int rawMaxValue = safeValues.fold<int>(
      baseline,
      (currentMax, value) => value > currentMax ? value : currentMax,
    );
    final int interval = _interval(rawMaxValue);
    final int maxValue = ((rawMaxValue + interval - 1) ~/ interval) * interval;

    const double chartTop = _EvolutionChartMetrics.chartTop;
    final double chartBottom = size.height - 34;
    final double chartHeight = chartBottom - chartTop;
    const double chartLeft = _EvolutionChartMetrics.chartLeft;
    final double chartRight = size.width;
    final double chartWidth = chartRight - chartLeft;
    final double slotWidth = chartWidth / safeValues.length;
    final double barWidth = (slotWidth * 0.30).clamp(6, 12).toDouble();

    _drawGrid(canvas, size, maxValue, chartTop, chartBottom, chartLeft);
    _drawVerticalGrid(
      canvas,
      chartTop,
      chartBottom,
      chartLeft,
      slotWidth,
      safeValues.length,
    );
    _drawBars(
      canvas,
      safeValues,
      maxValue,
      chartTop,
      chartBottom,
      chartHeight,
      chartLeft,
      slotWidth,
      barWidth,
    );
  }

  void _drawGrid(
    Canvas canvas,
    Size size,
    int maxValue,
    double chartTop,
    double chartBottom,
    double chartLeft,
  ) {
    final Paint gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.8)
      ..strokeWidth = 1;
    final Paint baselinePaint = Paint()
      ..color = axisColor.withValues(alpha: 0.45)
      ..strokeWidth = 1.3;

    for (int i = 0; i < 4; i++) {
      final double y = chartTop + (chartBottom - chartTop) * (i / 3);
      final int value = (maxValue * (3 - i) / 3).round();
      if (i == 3) {
        canvas.drawLine(
          Offset(chartLeft, y),
          Offset(size.width, y),
          baselinePaint,
        );
      } else {
        _drawDashedLine(
          canvas,
          Offset(chartLeft, y),
          Offset(size.width, y),
          gridPaint,
        );
      }

      final TextPainter labelPainter = TextPainter(
        text: TextSpan(text: _formatChartLabel(value), style: axisTextStyle),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: chartLeft - 8);
      labelPainter.paint(canvas, Offset(0, y - labelPainter.height / 2));
    }
  }

  void _drawBars(
    Canvas canvas,
    List<int> safeValues,
    int maxValue,
    double chartTop,
    double chartBottom,
    double chartHeight,
    double chartLeft,
    double slotWidth,
    double barWidth,
  ) {
    final int highlightIndex = highlightPosition.round().clamp(
      0,
      safeValues.length - 1,
    );

    for (int i = 0; i < safeValues.length; i++) {
      final double normalizedValue = (safeValues[i] / maxValue).clamp(0, 1);
      final double barHeight = (chartHeight * normalizedValue).clamp(
        4,
        chartHeight,
      );
      final double centerX = chartLeft + slotWidth * i + slotWidth / 2;
      final Rect barRect = Rect.fromLTWH(
        centerX - barWidth / 2,
        chartBottom - barHeight,
        barWidth,
        barHeight,
      );
      final bool isHighlighted =
          i == highlightIndex && (selectedIndex != null || safeValues[i] > 0);
      final Paint barPaint = Paint()
        ..color = isHighlighted
            ? Color.lerp(barColor, Colors.black, 0.34)!
            : barColor
        ..style = PaintingStyle.fill;
      final RRect roundedBar = RRect.fromRectAndCorners(
        barRect,
        topLeft: Radius.circular(barWidth * 0.42),
        topRight: Radius.circular(barWidth * 0.42),
      );
      canvas.drawRRect(roundedBar, barPaint);

      if (i < dayLabels.length) {
        _paintCenteredText(
          canvas,
          text: dayLabels[i],
          centerX: centerX,
          y: chartBottom + 10,
          maxWidth: slotWidth.clamp(18, double.infinity).toDouble(),
          style: axisTextStyle,
        );
      }
    }

    final bool shouldShowHighlight =
        selectedIndex != null || safeValues.any((value) => value > 0);
    if (shouldShowHighlight) {
      _drawHighlightMarker(
        canvas,
        _highlightedBarForPosition(
          safeValues,
          maxValue,
          chartBottom,
          chartHeight,
          chartLeft,
          slotWidth,
        ),
        chartLeft,
        chartLeft + slotWidth * safeValues.length,
        chartTop,
      );
    }
  }

  void _drawVerticalGrid(
    Canvas canvas,
    double chartTop,
    double chartBottom,
    double chartLeft,
    double slotWidth,
    int count,
  ) {
    final Paint verticalPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.55)
      ..strokeWidth = 1;

    for (int i = 0; i < count; i++) {
      if (i >= dayLabels.length || dayLabels[i].isEmpty) {
        continue;
      }
      final double x = chartLeft + slotWidth * i + slotWidth / 2;
      _drawDashedLine(
        canvas,
        Offset(x, chartTop),
        Offset(x, chartBottom),
        verticalPaint,
        isVertical: true,
      );
    }
  }

  void _drawHighlightMarker(
    Canvas canvas,
    _HighlightedBar bar,
    double chartLeft,
    double chartRight,
    double chartTop,
  ) {
    final Paint markerOuterPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;
    final Paint markerInnerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final String label = "${bar.index + 1} - ${_formatValueLabel(bar.value)}";
    final TextPainter labelPainter = TextPainter(
      text: TextSpan(text: label, style: tooltipTextStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    const double bubbleHeight = 30;
    const double arrowHeight = 7;
    final double bubbleWidth = labelPainter.width + 24;
    final double bubbleLeft = (bar.centerX - bubbleWidth / 2).clamp(
      chartLeft,
      chartRight - bubbleWidth,
    );
    final double bubbleTop = (bar.topY - bubbleHeight - arrowHeight - 8).clamp(
      0,
      chartTop - 2,
    );
    final RRect bubbleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bubbleLeft, bubbleTop, bubbleWidth, bubbleHeight),
      const Radius.circular(8),
    );
    canvas.drawRRect(bubbleRect, markerOuterPaint);

    final Path arrowPath = Path()
      ..moveTo(bar.centerX - 7, bubbleTop + bubbleHeight)
      ..lineTo(bar.centerX + 7, bubbleTop + bubbleHeight)
      ..lineTo(bar.centerX, bubbleTop + bubbleHeight + arrowHeight)
      ..close();
    canvas.drawPath(arrowPath, markerOuterPaint);
    labelPainter.paint(
      canvas,
      Offset(
        bubbleLeft + (bubbleWidth - labelPainter.width) / 2,
        bubbleTop + (bubbleHeight - labelPainter.height) / 2,
      ),
    );

    canvas.drawCircle(Offset(bar.centerX, bar.topY), 5.5, markerOuterPaint);
    canvas.drawCircle(Offset(bar.centerX, bar.topY), 3, markerInnerPaint);
    canvas.drawCircle(Offset(bar.centerX, bar.topY), 2, markerOuterPaint);
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint, {
    bool isVertical = false,
  }) {
    const double dashWidth = 5;
    const double dashGap = 5;
    if (isVertical) {
      double y = start.dy;
      while (y < end.dy) {
        final double nextY = (y + dashWidth).clamp(start.dy, end.dy);
        canvas.drawLine(Offset(start.dx, y), Offset(end.dx, nextY), paint);
        y += dashWidth + dashGap;
      }
      return;
    }

    double x = start.dx;
    while (x < end.dx) {
      final double nextX = (x + dashWidth).clamp(start.dx, end.dx);
      canvas.drawLine(Offset(x, start.dy), Offset(nextX, end.dy), paint);
      x += dashWidth + dashGap;
    }
  }

  void _paintCenteredText(
    Canvas canvas, {
    required String text,
    required double centerX,
    required double y,
    required double maxWidth,
    required TextStyle style,
  }) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    painter.paint(canvas, Offset(centerX - painter.width / 2, y));
  }

  int _interval(int rawMaxValue) {
    if (unit == EvolutionValueUnit.pages) {
      if (rawMaxValue <= 8) {
        return 2;
      }
      if (rawMaxValue <= 20) {
        return 5;
      }
      if (rawMaxValue <= 50) {
        return 10;
      }
      return 20;
    }
    if (rawMaxValue <= 1800) {
      return 600;
    }
    if (rawMaxValue <= 3600) {
      return 1800;
    }
    return 3600;
  }

  @override
  bool shouldRepaint(covariant _EvolutionBarChartPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.unit != unit ||
      oldDelegate.selectedIndex != selectedIndex ||
      oldDelegate.highlightPosition != highlightPosition ||
      oldDelegate.barColor != barColor ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.axisColor != axisColor ||
      oldDelegate.axisTextStyle != axisTextStyle ||
      oldDelegate.tooltipTextStyle != tooltipTextStyle ||
      oldDelegate.dayLabels != dayLabels;

  String _formatChartLabel(int value) {
    if (unit == EvolutionValueUnit.pages) {
      return "$value";
    }
    final int minutes = (value / 60).round();
    return "${minutes}m";
  }

  String _formatValueLabel(int value) {
    if (unit == EvolutionValueUnit.pages) {
      return "$value";
    }
    final int minutes = (value / 60).round();
    if (minutes < 60) {
      return "${minutes}m";
    }
    final int hours = minutes ~/ 60;
    final int restMinutes = minutes % 60;
    return restMinutes == 0 ? "${hours}h" : "${hours}h ${restMinutes}m";
  }

  _HighlightedBar _highlightedBarForPosition(
    List<int> safeValues,
    int maxValue,
    double chartBottom,
    double chartHeight,
    double chartLeft,
    double slotWidth,
  ) {
    final double clampedPosition = highlightPosition
        .clamp(0, safeValues.length - 1)
        .toDouble();
    final int lowerIndex = clampedPosition.floor();
    final int upperIndex = clampedPosition.ceil().clamp(
      lowerIndex,
      safeValues.length - 1,
    );
    final double progress = clampedPosition - lowerIndex;
    final double lowerValue = safeValues[lowerIndex].toDouble();
    final double upperValue = safeValues[upperIndex].toDouble();
    final double animatedValue =
        lowerValue + ((upperValue - lowerValue) * progress);
    final double normalizedValue = (animatedValue / maxValue).clamp(0, 1);
    final double barHeight = (chartHeight * normalizedValue).clamp(
      4,
      chartHeight,
    );
    final int labelIndex =
        selectedIndex?.clamp(0, safeValues.length - 1) ??
        clampedPosition.round().clamp(0, safeValues.length - 1);

    return _HighlightedBar(
      index: labelIndex,
      value: safeValues[labelIndex],
      centerX: chartLeft + slotWidth * clampedPosition + slotWidth / 2,
      topY: chartBottom - barHeight,
    );
  }
}

class _EvolutionChartMetrics {
  const _EvolutionChartMetrics._();

  static const double chartLeft = 34;
  static const double chartTop = 28;
}

class _HighlightedBar {
  const _HighlightedBar({
    required this.index,
    required this.value,
    required this.centerX,
    required this.topY,
  });

  final int index;
  final int value;
  final double centerX;
  final double topY;
}

List<String> _dayLabels(BuildContext context, int count) {
  if (count == 7) {
    return switch (context.languageCode) {
      "pt" => const ["S", "T", "Q", "Q", "S", "S", "D"],
      "es" => const ["L", "M", "M", "J", "V", "S", "D"],
      "fr" => const ["L", "M", "M", "J", "V", "S", "D"],
      "de" => const ["M", "D", "M", "D", "F", "S", "S"],
      _ => const ["M", "T", "W", "T", "F", "S", "S"],
    };
  }

  if (count <= 1) {
    return const [""];
  }

  return [
    for (int index = 0; index < count; index++)
      switch (index + 1) {
        1 || 10 || 20 || 30 => "${index + 1}",
        _ => "",
      },
  ];
}
