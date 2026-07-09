import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/functions/format_schedule_time.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/shared/widgets/subject_color_selector.dart";
import "package:help_out/theme/decoration.dart";
import "package:help_out/theme/subject_colors.dart";
import "package:intl/intl.dart";

typedef AddScheduleEntryResult = ({
  String title,
  int weekday,
  int startMinutes,
  int endMinutes,
  int colorValue,
});

class AddScheduleEntryPage extends StatefulWidget {
  const AddScheduleEntryPage({super.key});

  @override
  State<AddScheduleEntryPage> createState() => _AddScheduleEntryPageState();
}

class _AddScheduleEntryPageState extends State<AddScheduleEntryPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final FocusNode _startTimeFocusNode = FocusNode();
  final FocusNode _endTimeFocusNode = FocusNode();

  late final int _selectedWeekday = Get.arguments is int
      ? Get.arguments as int
      : DateTime.now().weekday;
  Color _selectedColor = SubjectColors.values.first;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_rebuildPreview);
    _startTimeController.addListener(_rebuildPreview);
    _endTimeController.addListener(_rebuildPreview);
  }

  @override
  void dispose() {
    _titleController.removeListener(_rebuildPreview);
    _startTimeController.removeListener(_rebuildPreview);
    _endTimeController.removeListener(_rebuildPreview);
    _titleController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _startTimeFocusNode.dispose();
    _endTimeFocusNode.dispose();
    super.dispose();
  }

  void _rebuildPreview() {
    if (mounted) {
      setState(() {});
    }
  }

  static ({int hour, int minute})? _parseTime(String raw) {
    final RegExpMatch? match = RegExp(
      r"^([0-9]{1,2}):([0-9]{1,2})$",
    ).firstMatch(raw.trim());
    if (match == null) {
      return null;
    }

    final int hour = int.parse(match.group(1)!);
    final int minute = int.parse(match.group(2)!);
    if (hour > 24 || minute > 59 || (hour == 24 && minute != 0)) {
      return null;
    }

    return (hour: hour, minute: minute);
  }

  void _onSubmit() {
    final String title = _titleController.text.trim();
    final ({int hour, int minute})? startTime = _parseTime(
      _startTimeController.text,
    );
    final ({int hour, int minute})? endTime = _parseTime(
      _endTimeController.text,
    );

    if (title.isEmpty || startTime == null || endTime == null) {
      appNavigator.showErrorSnackBar(context.l10n.incompleteScheduleEntryError);
      return;
    }

    final int startMinutes = startTime.hour * 60 + startTime.minute;
    final int endMinutes = endTime.hour * 60 + endTime.minute;
    if (endMinutes <= startMinutes) {
      appNavigator.showErrorSnackBar(context.l10n.endTimeBeforeStartError);
      return;
    }

    appNavigator.back<Object>(
      result: (
        title: title,
        weekday: _selectedWeekday,
        startMinutes: startMinutes,
        endMinutes: endMinutes,
        colorValue: _selectedColor.toARGB32(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    topBar: AppTopBar(
      title: context.l10n.addScheduleEntryTitle,
      showBackButton: true,
    ),
    bottomBar: _SubmitButton(onTap: _onSubmit),
    body: SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FormSection(
            title: "Informações",
            icon: "list",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(text: context.l10n.scheduleTitleHint),
                const Gap(8),
                TextField(
                  controller: _titleController,
                  autofocus: true,
                  decoration: AppInputDecoration.withBorder(
                    tokens: context.colorTokens,
                    hintText: context.l10n.scheduleTitleHint,
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),
          _FormSection(
            title: "Quando?",
            icon: "schedule",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _TimeTextField(
                        label: context.l10n.startTimeLabel,
                        controller: _startTimeController,
                        focusNode: _startTimeFocusNode,
                        onCompleted: () => FocusScope.of(
                          context,
                        ).requestFocus(_endTimeFocusNode),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: _TimeTextField(
                        label: context.l10n.endTimeOptionalLabel,
                        controller: _endTimeController,
                        focusNode: _endTimeFocusNode,
                      ),
                    ),
                  ],
                ),
                if (_durationLabel != null) ...[
                  const Gap(12),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 18,
                        color: context.colorTokens.primary,
                      ),
                      const Gap(6),
                      Text(
                        "Duração: $_durationLabel",
                        style: context.textStyles.bodySmall.copyWith(
                          color: context.colorTokens.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Gap(16),
          _FormSection(
            title: "Cor do horário",
            icon: Icons.palette_rounded,
            child: SubjectColorSelector(
              selectedColor: _selectedColor,
              onSelected: (color) => setState(() => _selectedColor = color),
            ),
          ),
          const Gap(16),
          _FormSection(
            title: "Prévia",
            icon: Icons.visibility_rounded,
            child: _SchedulePreview(
              title: _previewTitle,
              weekdayLabel: _selectedWeekdayLabel(context),
              startMinutes: _startMinutes,
              endMinutes: _endMinutes,
              color: _selectedColor,
            ),
          ),
        ],
      ),
    ),
  );

  String get _previewTitle {
    final String title = _titleController.text.trim();
    return title.isEmpty ? context.l10n.scheduleTitleHint : title;
  }

  int? get _startMinutes {
    final ({int hour, int minute})? time = _parseTime(
      _startTimeController.text,
    );
    return time == null ? null : time.hour * 60 + time.minute;
  }

  int? get _endMinutes {
    final ({int hour, int minute})? time = _parseTime(_endTimeController.text);
    return time == null ? null : time.hour * 60 + time.minute;
  }

  String? get _durationLabel {
    final int? start = _startMinutes;
    final int? end = _endMinutes;
    if (start == null || end == null || end <= start) {
      return null;
    }

    final int totalMinutes = end - start;
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;
    if (hours == 0) {
      return "${minutes}min";
    }
    if (minutes == 0) {
      return "${hours}h";
    }
    return "${hours}h ${minutes}min";
  }

  String _selectedWeekdayLabel(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    final String label = DateFormat.E(
      locale,
    ).format(DateTime(2024, 1, _selectedWeekday));
    return label.isEmpty
        ? label
        : "${label[0].toUpperCase()}${label.substring(1)}";
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.icon,
    required this.child,
  }) : assert(icon is String || icon is IconData);

  final String title;
  final Object icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: context.colorTokens.borderUnfocused),
      boxShadow: [
        BoxShadow(
          color: context.colorTokens.surfaceShadow,
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.colorTokens.primaryVeryLight,
                shape: BoxShape.circle,
              ),
              child: icon is IconData
                  ? Icon(
                      icon as IconData,
                      color: context.colorTokens.primary,
                      size: 22,
                    )
                  : AppIcon(
                      icon as String,
                      color: context.colorTokens.primary,
                      size: 24,
                    ),
            ),
            const Gap(12),
            Text(
              title,
              style: context.textStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const Gap(12),
        child,
      ],
    ),
  );
}

class _SchedulePreview extends StatelessWidget {
  const _SchedulePreview({
    required this.title,
    required this.weekdayLabel,
    required this.startMinutes,
    required this.endMinutes,
    required this.color,
  });

  final String title;
  final String weekdayLabel;
  final int? startMinutes;
  final int? endMinutes;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final String timeLabel = startMinutes == null || endMinutes == null
        ? "--:-- - --:--"
        : formatScheduleRange(context, startMinutes!, endMinutes!);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(width: 6, height: 74, color: color),
          const Gap(14),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.calendar_month_rounded, color: color, size: 26),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Gap(4),
                Text(
                  "$weekdayLabel • $timeLabel",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colorTokens.textHint,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Gap(14),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon("schedule", color: context.colorTokens.primary),
          const Gap(8),
          Text(
            context.l10n.addScheduleEntryButton,
            style: context.textStyles.bodyLarge.copyWith(
              color: context.colorTokens.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.textStyles.bodySmall.copyWith(
      color: context.colorTokens.textBody,
      fontWeight: FontWeight.w800,
    ),
  );
}

class _TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String rawDigits = newValue.text.replaceAll(RegExp(r"\D"), "");
    final String digits = rawDigits.length > 4
        ? rawDigits.substring(0, 4)
        : rawDigits;
    final String normalizedDigits = _normalizeTimeDigits(digits);
    final String formatted = normalizedDigits.length <= 2
        ? normalizedDigits
        : "${normalizedDigits.substring(0, 2)}:${normalizedDigits.substring(2)}";

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _normalizeTimeDigits(String digits) {
    if (digits.length < 2) {
      return digits;
    }

    final int hour = int.parse(digits.substring(0, 2)).clamp(0, 24).toInt();
    final String hourDigits = hour.toString().padLeft(2, "0");
    if (digits.length == 2) {
      return hourDigits;
    }

    String minuteDigits = digits.substring(2);
    if (hour == 24) {
      minuteDigits = List.filled(minuteDigits.length, "0").join();
      return "$hourDigits$minuteDigits";
    }

    if (minuteDigits.isNotEmpty && int.parse(minuteDigits[0]) > 5) {
      minuteDigits =
          "5${minuteDigits.length > 1 ? minuteDigits.substring(1) : ""}";
    }
    if (minuteDigits.length == 2) {
      final int minute = int.parse(minuteDigits).clamp(0, 59).toInt();
      minuteDigits = minute.toString().padLeft(2, "0");
    }

    return "$hourDigits$minuteDigits";
  }
}

class _TimeTextField extends StatelessWidget {
  const _TimeTextField({
    required this.label,
    required this.controller,
    required this.focusNode,
    this.onCompleted,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback? onCompleted;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _FieldLabel(text: label),
      const Gap(8),
      TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          _TimeInputFormatter(),
        ],
        onChanged: (value) {
          if (value.length == 5) {
            onCompleted?.call();
          }
        },
        decoration: AppInputDecoration.withBorder(
          tokens: context.colorTokens,
          hintText: "00:00",
        ),
      ),
    ],
  );
}
