import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/app/route_arguments.dart";
import "package:timing/core/domain/entities/schedule_entry_entity.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/schedule/widgets/schedule_date_strip.dart";
import "package:timing/presentation/schedule/widgets/schedule_entry_tile.dart";
import "package:timing/shared/functions/format_calendar_labels.dart";
import "package:timing/shared/functions/format_schedule_time.dart";
import "package:timing/shared/widgets/app_icon.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_top_bar.dart";
import "package:timing/shared/widgets/bounce_tap.dart";
import "package:timing/shared/widgets/creation/creation_form_widgets.dart";
import "package:timing/theme/app_spacing.dart";
import "package:timing/theme/decoration.dart";
import "package:timing/theme/subject_colors.dart";
import "package:intl/intl.dart";

part "add_schedule_entry_page_form_sections.dart";
part "add_schedule_entry_page_time_field.dart";
part "add_schedule_entry_page_date_range.dart";
part "add_schedule_entry_page_date_picker_dialog.dart";

typedef AddScheduleEntryResult = ({
  String title,
  List<int> weekdays,
  int? startMinutes,
  int? endMinutes,
  int colorValue,
  DateTime activeFrom,
  DateTime? activeUntil,
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

  final ScheduleEntryEntity? _editingEntry =
      RouteArguments.maybeOf<ScheduleEntryEntity>();

  late DateTime _activeFrom = _initialDate();
  DateTime? _activeUntil;
  late final Set<int> _selectedWeekdays = {_initialDate().weekday};
  Color _selectedColor = SubjectColors.values.first;
  bool _hasInitializedThemeColor = false;

  bool get _isEditing => _editingEntry != null;

  @override
  void initState() {
    super.initState();
    _prefillFromEntry();
    _titleController.addListener(_rebuildPreview);
    _startTimeController.addListener(_rebuildPreview);
    _endTimeController.addListener(_rebuildPreview);
    _startTimeFocusNode.addListener(_onStartFocusChanged);
    _endTimeFocusNode.addListener(_onEndFocusChanged);
  }

  void _onStartFocusChanged() {
    if (!_startTimeFocusNode.hasFocus) {
      _completeTime(_startTimeController);
    }
  }

  void _onEndFocusChanged() {
    if (!_endTimeFocusNode.hasFocus) {
      _completeTime(_endTimeController);
    }
  }

  /// Fills in the minutes a partial time is missing, so typing just an hour
  /// ("10") settles into a full "10:00" once the field is left or submitted.
  void _completeTime(TextEditingController controller) {
    final String? formatted = completePartialTime(controller.text);
    if (formatted != null && formatted != controller.text) {
      controller.text = formatted;
    }
  }

  void _prefillFromEntry() {
    final ScheduleEntryEntity? entry = _editingEntry;
    if (entry == null) {
      return;
    }
    _titleController.text = entry.title;
    if (entry.startMinutes != null) {
      _startTimeController.text = _formatMinutes(entry.startMinutes!);
    }
    if (entry.endMinutes != null) {
      _endTimeController.text = _formatMinutes(entry.endMinutes!);
    }
    _selectedWeekdays
      ..clear()
      ..add(entry.weekday);
    _activeFrom = DateTime(
      entry.activeFrom.year,
      entry.activeFrom.month,
      entry.activeFrom.day,
    );
    _activeUntil = entry.activeUntil == null
        ? null
        : DateTime(
            entry.activeUntil!.year,
            entry.activeUntil!.month,
            entry.activeUntil!.day,
          );
    _selectedColor = Color(entry.colorValue);
    // Keep the entry's own color instead of overriding it with the theme accent.
    _hasInitializedThemeColor = true;
  }

  static String _formatMinutes(int minutes) =>
      "${(minutes ~/ 60).toString().padLeft(2, "0")}:"
      "${(minutes % 60).toString().padLeft(2, "0")}";

  @override
  void dispose() {
    _titleController.removeListener(_rebuildPreview);
    _startTimeController.removeListener(_rebuildPreview);
    _endTimeController.removeListener(_rebuildPreview);
    _startTimeFocusNode.removeListener(_onStartFocusChanged);
    _endTimeFocusNode.removeListener(_onEndFocusChanged);
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
    _completeTime(_startTimeController);
    _completeTime(_endTimeController);
    final String title = _titleController.text.trim();
    final ({int hour, int minute})? startTime = _parseTime(
      _startTimeController.text,
    );
    final ({int hour, int minute})? endTime = _parseTime(
      _endTimeController.text,
    );

    if (title.isEmpty) {
      appNavigator.showErrorSnackBar(context.l10n.incompleteScheduleEntryError);
      return;
    }

    final int? startMinutes = startTime == null
        ? null
        : startTime.hour * 60 + startTime.minute;
    final int? endMinutes = endTime == null
        ? null
        : endTime.hour * 60 + endTime.minute;
    if (startMinutes != null &&
        endMinutes != null &&
        endMinutes <= startMinutes) {
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
        activeFrom: _activeFrom,
        activeUntil: _activeUntil,
      ),
    );
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
  Widget build(BuildContext context) => AppScaffold(
    topBar: AppTopBar(
      title: _isEditing
          ? context.l10n.editButton
          : context.l10n.addScheduleEntryTitle,
      showBackButton: true,
    ),
    bottomBar: _SubmitButton(
      isEnabled: _isComplete,
      label: _isEditing
          ? context.l10n.saveChangesButton
          : context.l10n.createScheduleEntryButton,
      hint: _isComplete ? null : _missingFieldsHint(context),
      onTap: _onSubmit,
    ),
    body: SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: AppSpacing.betweenSections),
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
                  textInputAction: TextInputAction.next,
                  decoration: AppInputDecoration.withBorder(
                    tokens: context.colorTokens,
                    hintText: context.l10n.scheduleTitleHint,
                  ),
                ),
              ],
            ),
          ),
          const Gap(AppSpacing.page),
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
                        onPickTime: () => _pickTime(_startTimeController),
                        onCompleted: () => FocusScope.of(
                          context,
                        ).requestFocus(_endTimeFocusNode),
                      ),
                    ),
                    const Gap(AppSpacing.betweenRelated),
                    Expanded(
                      child: _TimeTextField(
                        label: context.l10n.endTimeOptionalLabel,
                        controller: _endTimeController,
                        focusNode: _endTimeFocusNode,
                        onPickTime: () => _pickTime(_endTimeController),
                      ),
                    ),
                  ],
                ),
                const Gap(14),
                _DateRangeSelector(
                  activeFrom: _activeFrom,
                  activeUntil: _activeUntil,
                  onPickStart: () => _pickActiveDate(isStart: true),
                  onPickEnd: () => _pickActiveDate(isStart: false),
                  onClearEnd: () => setState(() => _activeUntil = null),
                ),
                if (_durationLabel(context) != null) ...[
                  const Gap(AppSpacing.betweenRelated),
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
          const Gap(AppSpacing.page),
          _FormSection(
            title: context.l10n.scheduleColorSection,
            icon: Icons.palette_rounded,
            child: _ScheduleColorSelector(
              selectedColor: _selectedColor,
              onSelected: (color) => setState(() => _selectedColor = color),
            ),
          ),
          const Gap(AppSpacing.page),
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

  bool get _isComplete {
    final int? start = _startMinutes;
    final int? end = _endMinutes;
    return _titleController.text.trim().isNotEmpty &&
        (start == null || end == null || end > start);
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final ({int hour, int minute})? current = _parseTime(controller.text);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: current == null
          ? TimeOfDay.now()
          : TimeOfDay(hour: current.hour % 24, minute: current.minute),
    );
    if (picked == null) {
      return;
    }
    controller.text =
        "${picked.hour.toString().padLeft(2, "0")}:"
        "${picked.minute.toString().padLeft(2, "0")}";
  }

  String get _previewTitle {
    final String title = _titleController.text.trim();
    return title.isEmpty ? context.l10n.scheduleTitleHint : title;
  }

  ScheduleEntryEntity get _previewEntry => ScheduleEntryEntity(
    id: "schedule-preview",
    title: _previewTitle,
    weekday: _selectedWeekdays.first,
    startMinutes: _startMinutes,
    endMinutes: _endMinutes,
    colorValue: _selectedColor.toARGB32(),
    activeFrom: _activeFrom,
    activeUntil: _activeUntil,
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

  static DateTime _todayDate() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime _initialDate() {
    final DateTime? selectedDate = RouteArguments.maybeOf<DateTime>();
    if (selectedDate == null) {
      return _todayDate();
    }
    return DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
  }

  Future<void> _pickActiveDate({required bool isStart}) async {
    final DateTime initialDate = isStart
        ? _activeFrom
        : (_activeUntil ?? _activeFrom);
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      barrierColor: context.colorTokens.black.withValues(alpha: 0.54),
      builder: (context) => _ScheduleDatePickerDialog(
        initialDate: initialDate,
        firstDate: isStart ? DateTime(2020) : _activeFrom,
      ),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      final DateTime date = DateTime(picked.year, picked.month, picked.day);
      if (isStart) {
        _activeFrom = date;
        if (_activeUntil != null && _activeUntil!.isBefore(date)) {
          _activeUntil = null;
        }
        return;
      }
      _activeUntil = date;
    });
  }

  String? _durationLabel(BuildContext context) {
    final int? start = _startMinutes;
    final int? end = _endMinutes;
    if (start == null || end == null || end <= start) {
      return null;
    }

    final int totalMinutes = (end - start) * _selectedWeekdays.length;
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

  String _missingFieldsHint(BuildContext context) {
    if (_titleController.text.trim().isEmpty) {
      return context.l10n.scheduleTitleRequiredError;
    }
    return context.l10n.endTimeBeforeStartError;
  }
}
