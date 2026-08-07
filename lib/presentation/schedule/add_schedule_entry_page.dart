import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:gap/gap.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/route_arguments.dart";
import "package:help_out/core/domain/entities/schedule_entry_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/schedule/widgets/schedule_date_strip.dart";
import "package:help_out/presentation/schedule/widgets/schedule_entry_tile.dart";
import "package:help_out/shared/widgets/app_icon.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";
import "package:help_out/shared/widgets/bounce_tap.dart";
import "package:help_out/shared/widgets/creation/creation_form_widgets.dart";
import "package:help_out/theme/app_spacing.dart";
import "package:help_out/theme/decoration.dart";
import "package:help_out/theme/subject_colors.dart";
import "package:intl/intl.dart";

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

  late DateTime _activeFrom = _initialDate();
  DateTime? _activeUntil;
  late final Set<int> _selectedWeekdays = {_initialDate().weekday};
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
      title: context.l10n.addScheduleEntryTitle,
      showBackButton: true,
    ),
    bottomBar: _SubmitButton(
      isEnabled: _isComplete,
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
      return switch (context.languageCode) {
        "pt" => "Preencha o titulo para continuar",
        "es" => "Completa el titulo para continuar",
        "fr" => "Ajoutez un titre pour continuer",
        "de" => "Titel ausfuellen, um fortzufahren",
        _ => "Fill in the title to continue",
      };
    }
    return context.l10n.endTimeBeforeStartError;
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
  Widget build(BuildContext context) => Wrap(
    spacing: 10,
    runSpacing: 10,
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

class _DateRangeSelector extends StatelessWidget {
  const _DateRangeSelector({
    required this.activeFrom,
    required this.activeUntil,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onClearEnd,
  });

  final DateTime activeFrom;
  final DateTime? activeUntil;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback onClearEnd;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    return Row(
      children: [
        Expanded(
          child: _DateChip(
            label: _startLabel(context),
            value: DateFormat.yMd(locale).format(activeFrom),
            icon: Icons.event_available_rounded,
            onTap: onPickStart,
          ),
        ),
        const Gap(AppSpacing.betweenRelated),
        Expanded(
          child: _DateChip(
            label: _endLabel(context),
            value: activeUntil == null
                ? _optionalLabel(context)
                : DateFormat.yMd(locale).format(activeUntil!),
            icon: Icons.event_busy_rounded,
            onTap: onPickEnd,
            onClear: activeUntil == null ? null : onClearEnd,
          ),
        ),
      ],
    );
  }

  String _startLabel(BuildContext context) => switch (context.languageCode) {
    "pt" => "Começa em",
    "es" => "Comienza",
    _ => "Starts",
  };

  String _endLabel(BuildContext context) => switch (context.languageCode) {
    "pt" => "Termina em",
    "es" => "Termina",
    _ => "Ends",
  };

  String _optionalLabel(BuildContext context) => switch (context.languageCode) {
    "pt" => "Opcional",
    "es" => "Opcional",
    _ => "Optional",
  };
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    pressedScale: 0.98,
    child: Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: context.colorTokens.scaffold.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colorTokens.borderUnfocused),
      ),
      child: Row(
        children: [
          Icon(icon, color: context.colorTokens.primary, size: 20),
          const Gap(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colorTokens.textHint,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Gap(2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyMedium.copyWith(
                    color: context.colorTokens.textBody,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          if (onClear != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onClear,
              child: Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(
                  Icons.close_rounded,
                  color: context.colorTokens.textHint,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _ScheduleDatePickerDialog extends StatefulWidget {
  const _ScheduleDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
  });

  final DateTime initialDate;
  final DateTime firstDate;

  @override
  State<_ScheduleDatePickerDialog> createState() =>
      _ScheduleDatePickerDialogState();
}

class _ScheduleDatePickerDialogState extends State<_ScheduleDatePickerDialog> {
  late DateTime _selectedDate = _dateOnly(widget.initialDate);

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    return Dialog(
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      backgroundColor: context.colorTokens.dialogSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _title(context),
              textAlign: TextAlign.center,
              style: context.textStyles.extraBold24.copyWith(
                color: context.colorTokens.dialogText,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Gap(18),
            _CalendarMonthHeader(
              label: _monthLabel(locale, _selectedDate),
              onPrevious: _onPreviousMonth,
              onNext: _onNextMonth,
            ),
            const Gap(22),
            ScheduleDateStrip(
              selectedDate: _selectedDate,
              onSelectDate: _onSelectDate,
              hasEntryForDate: (_) => false,
              eventColorsForDate: (_) => const [],
            ),
            const Gap(16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: context.colorTokens.surfaceInnerLayer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    color: context.colorTokens.primary,
                    size: 18,
                  ),
                  const Gap(8),
                  Flexible(
                    child: Text(
                      _hint(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodyMedium.copyWith(
                        color: context.colorTokens.dialogTextMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(18),
            Row(
              children: [
                Expanded(
                  child: _DialogSecondaryButton(
                    label: _todayLabel(context),
                    onTap: () => _onSelectDate(_todayDate()),
                  ),
                ),
                const Gap(14),
                Expanded(
                  flex: 2,
                  child: _DialogPrimaryButton(
                    label: _confirmLabel(context),
                    onTap: () => Navigator.of(context).pop(_selectedDate),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onPreviousMonth() {
    final DateTime previous = _clampedMonth(_selectedDate, -1);
    if (previous.isBefore(_dateOnly(widget.firstDate))) {
      setState(() => _selectedDate = _dateOnly(widget.firstDate));
      return;
    }
    setState(() => _selectedDate = previous);
  }

  void _onNextMonth() =>
      setState(() => _selectedDate = _clampedMonth(_selectedDate, 1));

  void _onSelectDate(DateTime date) {
    final DateTime normalized = _dateOnly(date);
    if (normalized.isBefore(_dateOnly(widget.firstDate))) {
      return;
    }
    setState(() => _selectedDate = normalized);
  }

  DateTime _clampedMonth(DateTime value, int monthDelta) {
    final DateTime monthStart = DateTime(value.year, value.month + monthDelta);
    final int day = value.day.clamp(
      1,
      DateUtils.getDaysInMonth(monthStart.year, monthStart.month),
    );
    return DateTime(monthStart.year, monthStart.month, day);
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static DateTime _todayDate() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  String _monthLabel(String locale, DateTime date) {
    final String raw = DateFormat.yMMMM(locale).format(date);
    if (raw.isEmpty) {
      return raw;
    }
    return raw.replaceFirst(raw[0], raw[0].toUpperCase());
  }

  String _title(BuildContext context) => switch (context.languageCode) {
    "pt" => "Selecionar data",
    "es" => "Seleccionar fecha",
    _ => "Select date",
  };

  String _hint(BuildContext context) => switch (context.languageCode) {
    "pt" => "Toque em um dia para selecionar",
    "es" => "Toca un dia para seleccionar",
    _ => "Tap a day to select",
  };

  String _todayLabel(BuildContext context) => switch (context.languageCode) {
    "pt" => "Hoje",
    "es" => "Hoy",
    _ => "Today",
  };

  String _confirmLabel(BuildContext context) => switch (context.languageCode) {
    "pt" => "Confirmar",
    "es" => "Confirmar",
    _ => "Confirm",
  };
}

class _CalendarMonthHeader extends StatelessWidget {
  const _CalendarMonthHeader({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => Container(
    height: 58,
    padding: const EdgeInsets.symmetric(horizontal: 6),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: context.colorTokens.borderUnfocused),
      boxShadow: [
        BoxShadow(
          color: context.colorTokens.surfaceShadow.withValues(alpha: 0.10),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        _MonthArrowButton(icon: Icons.chevron_left_rounded, onTap: onPrevious),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.extraBold20.copyWith(
              color: context.colorTokens.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        _MonthArrowButton(icon: Icons.chevron_right_rounded, onTap: onNext),
      ],
    ),
  );
}

class _MonthArrowButton extends StatelessWidget {
  const _MonthArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    pressedScale: 0.92,
    child: SizedBox(
      width: 46,
      height: 46,
      child: Icon(icon, color: context.colorTokens.primary, size: 34),
    ),
  );
}

class _DialogSecondaryButton extends StatelessWidget {
  const _DialogSecondaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    pressedScale: 0.97,
    child: Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colorTokens.borderUnfocused),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodyMedium.copyWith(
          color: context.colorTokens.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );
}

class _DialogPrimaryButton extends StatelessWidget {
  const _DialogPrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    onTap: onTap,
    pressedScale: 0.97,
    child: Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: context.colorTokens.primaryGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.textPrimaryButton.copyWith(
          color: context.colorTokens.primaryForeground,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
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

/// Pinned above the keyboard. When it is disabled it says *why*, instead of
/// leaving the user tapping a dead button.
class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.isEnabled,
    required this.hint,
    required this.onTap,
  });

  final bool isEnabled;
  final String? hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (hint != null) ...[
        Text(
          hint!,
          textAlign: TextAlign.center,
          style: context.textStyles.caption.copyWith(fontSize: 12),
        ),
        const Gap(AppSpacing.titleToDescription),
      ],
      Semantics(
        button: true,
        enabled: isEnabled,
        child: BounceTap(
          pressedScale: isEnabled ? 0.97 : 1,
          onTap: onTap,
          child: Opacity(
            opacity: isEnabled ? 1 : 0.45,
            child: Container(
              width: double.infinity,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: context.colorTokens.primaryGradient,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppIcon(
                    "schedule",
                    color: context.colorTokens.primaryForeground,
                  ),
                  const Gap(AppSpacing.titleToDescription),
                  Flexible(
                    child: Text(
                      context.l10n.createScheduleEntryButton,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.textPrimaryButton.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
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
    required this.onPickTime,
    this.onCompleted,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onPickTime;
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
        decoration:
            AppInputDecoration.withBorder(
              tokens: context.colorTokens,
              hintText: "00:00",
            ).copyWith(
              suffixIcon: IconButton(
                onPressed: onPickTime,
                tooltip: label,
                icon: Icon(
                  Icons.schedule_rounded,
                  size: 20,
                  color: context.colorTokens.primary,
                ),
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            ),
      ),
    ],
  );
}
