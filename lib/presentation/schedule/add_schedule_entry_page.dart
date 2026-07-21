import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/domain/entities/schedule_entry_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/schedule/widgets/schedule_entry_tile.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/shared/widgets/creation/creation_form_widgets.dart";
import "package:help_out/theme/decoration.dart";
import "package:help_out/theme/subject_colors.dart";
import "package:intl/intl.dart";

typedef AddScheduleEntryResult = ({
  String title,
  List<int> weekdays,
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

  late final Set<int> _selectedWeekdays = {
    Get.arguments is int ? Get.arguments as int : DateTime.now().weekday,
  };
  Color _selectedColor = SubjectColors.values.first;
  bool _hasInitializedThemeColor = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_rebuildPreview);
    _startTimeController.addListener(_rebuildPreview);
    _endTimeController.addListener(_rebuildPreview);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasInitializedThemeColor) {
      return;
    }
    _selectedColor = SubjectColors.fromThemeAccent(context.colorTokens.primary);
    _hasInitializedThemeColor = true;
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
        weekdays: _selectedWeekdays.toList()..sort(),
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
            title: context.l10n.scheduleInfoSection,
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
            title: context.l10n.scheduleWhenSection,
            icon: "schedule",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WeekdayMultiSelector(
                  selectedWeekdays: _selectedWeekdays,
                  onToggle: _toggleWeekday,
                ),
                const Gap(14),
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
                if (_durationLabel(context) != null) ...[
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
                        context.l10n.scheduleDurationLabel(
                          _durationLabel(context)!,
                        ),
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
            title: context.l10n.scheduleColorSection,
            icon: Icons.palette_rounded,
            child: _ScheduleColorSelector(
              selectedColor: _selectedColor,
              onSelected: (color) => setState(() => _selectedColor = color),
            ),
          ),
          const Gap(16),
          _FormSection(
            title: context.l10n.schedulePreviewSection,
            icon: Icons.visibility_rounded,
            child: _PreviewFrame(
              child: ScheduleEntryTile(entry: _previewEntry),
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

  ScheduleEntryEntity get _previewEntry => ScheduleEntryEntity(
    id: "schedule-preview",
    title: _previewTitle,
    weekday: _selectedWeekdays.first,
    startMinutes: _startMinutes ?? 0,
    endMinutes: _endMinutes,
    colorValue: _selectedColor.toARGB32(),
  );

  void _toggleWeekday(int weekday) {
    setState(() {
      if (_selectedWeekdays.contains(weekday) && _selectedWeekdays.length > 1) {
        _selectedWeekdays.remove(weekday);
        return;
      }
      _selectedWeekdays.add(weekday);
    });
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

  String? _durationLabel(BuildContext context) {
    final int? start = _startMinutes;
    final int? end = _endMinutes;
    if (start == null || end == null || end <= start) {
      return null;
    }

    final int totalMinutes = end - start;
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;
    if (hours == 0) {
      return context.l10n.scheduleDurationMinutes(minutes);
    }
    if (minutes == 0) {
      return context.l10n.scheduleDurationHours(hours);
    }
    return context.l10n.scheduleDurationHoursMinutes(hours, minutes);
  }
}

class _ScheduleColorSelector extends StatelessWidget {
  const _ScheduleColorSelector({
    required this.selectedColor,
    required this.onSelected,
  });

  final Color selectedColor;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: SubjectColors.values
        .map(
          (color) => CreationColorChoice(
            color: color,
            isSelected: color.toARGB32() == selectedColor.toARGB32(),
            onTap: () => onSelected(color),
          ),
        )
        .toList(),
  );
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

class _WeekdayMultiSelector extends StatelessWidget {
  const _WeekdayMultiSelector({
    required this.selectedWeekdays,
    required this.onToggle,
  });

  final Set<int> selectedWeekdays;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    final DateTime monday = DateTime(2024, 1, 1);

    return Row(
      children: [
        for (
          int weekday = DateTime.monday;
          weekday <= DateTime.sunday;
          weekday++
        ) ...[
          if (weekday > DateTime.monday) const Gap(6),
          Expanded(
            child: _WeekdayToggleChip(
              label: DateFormat.E(locale)
                  .format(monday.add(Duration(days: weekday - 1)))
                  .characters
                  .take(3)
                  .toString()
                  .toUpperCase(),
              isSelected: selectedWeekdays.contains(weekday),
              onTap: () => onToggle(weekday),
            ),
          ),
        ],
      ],
    );
  }
}

class _WeekdayToggleChip extends StatelessWidget {
  const _WeekdayToggleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected
            ? context.colorTokens.primary
            : context.colorTokens.scaffold.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? context.colorTokens.primary
              : context.colorTokens.borderUnfocused,
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodySmall.copyWith(
          color: isSelected
              ? context.colorTokens.white
              : context.colorTokens.textBody,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );
}

class _PreviewFrame extends StatelessWidget {
  const _PreviewFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: context.colorTokens.scaffold.withValues(alpha: 0.48),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: context.colorTokens.primaryVeryLight,
        width: 1.4,
      ),
    ),
    child: child,
  );
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
        color: context.colorTokens.white,
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
