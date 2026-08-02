import "package:flutter/material.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/theme/app_surfaces.dart";

class ProgressEvolutionChart extends StatelessWidget {
  const ProgressEvolutionChart({required this.values, super.key});

  final List<int> values;

  @override
  Widget build(BuildContext context) => Container(
    height: 156,
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
    decoration: AppSurfaces.content(context.colorTokens),
    child: CustomPaint(
      painter: _EvolutionChartPainter(
        values: values,
        color: context.colorTokens.primary,
        textColor: context.colorTokens.textHint,
      ),
      child: const SizedBox.expand(),
    ),
  );
}

class _EvolutionChartPainter extends CustomPainter {
  const _EvolutionChartPainter({
    required this.values,
    required this.color,
    required this.textColor,
  });

  final List<int> values;
  final Color color;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = textColor.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final Paint fillPaint = Paint()
      ..color = color.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;
    final Paint dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final int rawMaxValue = values.fold<int>(
      60,
      (currentMax, value) => value > currentMax ? value : currentMax,
    );
    final int interval = rawMaxValue <= 3600 ? 1800 : 3600;
    final int maxValue = ((rawMaxValue + interval - 1) ~/ interval) * interval;

    const double chartTop = 6;
    final double chartBottom = size.height - 24;
    final double chartHeight = chartBottom - chartTop;
    const double labelWidth = 42;
    const double chartLeft = labelWidth;
    final double chartWidth = size.width - chartLeft;
    final double step = values.length <= 1
        ? 0
        : chartWidth / (values.length - 1);
    final bool showDots = values.length <= 14;

    for (int i = 0; i < 3; i++) {
      final double y = chartTop + chartHeight * (i / 2);
      canvas.drawLine(Offset(chartLeft, y), Offset(size.width, y), gridPaint);
      final TextPainter labelPainter = TextPainter(
        text: TextSpan(
          text: _formatChartLabel((maxValue * (2 - i) / 2).round()),
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: labelWidth - 6);
      labelPainter.paint(canvas, Offset(0, y - labelPainter.height / 2));
    }

    final Path line = Path();
    final Path fill = Path();
    for (int i = 0; i < values.length; i++) {
      final double x = chartLeft + (i * step);
      final double normalizedValue = (values[i] / maxValue).clamp(0, 1);
      final double y = chartBottom - chartHeight * normalizedValue;
      if (i == 0) {
        line.moveTo(x, y);
        fill.moveTo(x, chartBottom);
        fill.lineTo(x, y);
      } else {
        line.lineTo(x, y);
        fill.lineTo(x, y);
      }
      if (showDots) {
        canvas.drawCircle(Offset(x, y), 4, dotPaint);
      }
    }
    fill.lineTo(size.width, chartBottom);
    fill.close();

    canvas.drawPath(fill, fillPaint);
    canvas.drawPath(line, linePaint);
  }

  @override
  bool shouldRepaint(covariant _EvolutionChartPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.color != color ||
      oldDelegate.textColor != textColor;

  String _formatChartLabel(int seconds) {
    if (seconds >= 3600) {
      final int hours = seconds ~/ 3600;
      final int minutes = (seconds % 3600) ~/ 60;
      return minutes == 0 ? "${hours}h" : "${hours}h${minutes}m";
    }

    final int minutes = (seconds / 60).round();
    return minutes <= 0 ? "0min" : "${minutes}min";
  }
}
