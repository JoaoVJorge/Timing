import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/core/domain/entities/schedule_entry_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/add_schedule_entry_use_case.dart";
import "package:help_out/core/domain/use_cases/delete_schedule_entry_use_case.dart";
import "package:help_out/core/domain/use_cases/get_schedule_entries_use_case.dart";
import "package:help_out/presentation/schedule/add_schedule_entry_page.dart";
import "package:help_out/presentation/schedule/widgets/schedule_entry_tile.dart";

class ScheduleController extends GetxController {
  ScheduleController({
    required this._getScheduleEntriesUseCase,
    required this._addScheduleEntryUseCase,
    required this._deleteScheduleEntryUseCase,
    required this._appNavigator,
  });

  final GetScheduleEntriesUseCase _getScheduleEntriesUseCase;
  final AddScheduleEntryUseCase _addScheduleEntryUseCase;
  final DeleteScheduleEntryUseCase _deleteScheduleEntryUseCase;
  final AppNavigator _appNavigator;

  final RxList<ScheduleEntryEntity> entries = <ScheduleEntryEntity>[].obs;
  final RxBool isLoading = true.obs;
  final Rx<DateTime> selectedDate = _todayDate().obs;

  int get selectedWeekday => selectedDate.value.weekday;

  List<ScheduleEntryEntity> get sortedEntries =>
      _sortedEntriesForWeekday(selectedWeekday);

  List<ScheduleEntryEntity> get todayEntries =>
      _sortedEntriesForWeekday(DateTime.now().weekday);

  bool get isViewingToday => _isSameDate(selectedDate.value, _todayDate());

  static DateTime _todayDate() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  ScheduleEntryStatus statusOf(ScheduleEntryEntity entry) {
    final DateTime viewedDate = selectedDate.value;
    final DateTime today = _todayDate();
    if (viewedDate.isBefore(today)) {
      return ScheduleEntryStatus.past;
    }
    if (viewedDate.isAfter(today)) {
      return ScheduleEntryStatus.upcoming;
    }

    final DateTime now = DateTime.now();
    final int nowMinutes = now.hour * 60 + now.minute;
    final int? startMinutes = entry.startMinutes;
    if (startMinutes == null) {
      return ScheduleEntryStatus.upcoming;
    }
    final int endMinutes = entry.endMinutes ?? startMinutes;
    if (nowMinutes >= endMinutes && nowMinutes > startMinutes) {
      return ScheduleEntryStatus.past;
    }
    if (nowMinutes >= startMinutes) {
      return ScheduleEntryStatus.current;
    }
    return ScheduleEntryStatus.upcoming;
  }

  DateTime _nextDateForWeekday(int weekday) {
    final DateTime today = _todayDate();
    final int diff = (weekday - today.weekday + 7) % 7;
    return today.add(Duration(days: diff));
  }

  bool hasEntriesForDate(DateTime date) =>
      entries.any((entry) => entry.weekday == date.weekday);

  Color? firstEntryColorForDate(DateTime date) {
    final List<ScheduleEntryEntity> dayEntries = _sortedEntriesForWeekday(
      date.weekday,
    );
    if (dayEntries.isEmpty) {
      return null;
    }
    return Color(dayEntries.first.colorValue);
  }

  List<Color> entryColorsForDate(DateTime date) => [
    for (final ScheduleEntryEntity entry in _sortedEntriesForWeekday(
      date.weekday,
    ))
      Color(entry.colorValue),
  ];

  List<ScheduleEntryEntity> _sortedEntriesForWeekday(int weekday) =>
      entries.where((entry) => entry.weekday == weekday).toList()..sort((a, b) {
        final int aMinutes = a.startMinutes ?? 24 * 60 + 1;
        final int bMinutes = b.startMinutes ?? 24 * 60 + 1;
        return aMinutes.compareTo(bMinutes);
      });

  @override
  void onInit() {
    super.onInit();
    loadEntries();
  }

  void onSelectDate(DateTime date) =>
      selectedDate.value = DateTime(date.year, date.month, date.day);

  void onSelectMonth(int year, int month) {
    final int clampedDay = selectedDate.value.day.clamp(
      1,
      DateUtils.getDaysInMonth(year, month),
    );
    selectedDate.value = DateTime(year, month, clampedDay);
  }

  Future<void> loadEntries() async {
    isLoading.value = true;
    final Either<AppError, List<ScheduleEntryEntity>> result =
        await _getScheduleEntriesUseCase();
    result.fold((error) {
      entries.clear();
      _appNavigator.showErrorSnackBar(error.message);
    }, (value) => entries.value = value);
    isLoading.value = false;
  }

  Future<void> onTapAddEntry() async {
    final dynamic rawResult = await _appNavigator.toNamed<dynamic>(
      AppRoutes.addScheduleEntry,
      arguments: selectedWeekday,
    );
    final AddScheduleEntryResult? result = rawResult as AddScheduleEntryResult?;

    if (result == null) {
      return;
    }

    final List<ScheduleEntryEntity> addedEntries = [];
    for (final int weekday in result.weekdays) {
      final Either<AppError, ScheduleEntryEntity> addResult =
          await _addScheduleEntryUseCase(
            title: result.title,
            weekday: weekday,
            startMinutes: result.startMinutes,
            endMinutes: result.endMinutes,
            colorValue: result.colorValue,
          );
      final bool hasError = addResult.fold(
        (error) {
          _appNavigator.showErrorSnackBar(error.message);
          return true;
        },
        (entry) {
          addedEntries.add(entry);
          return false;
        },
      );
      if (hasError) {
        break;
      }
    }

    if (addedEntries.isEmpty) {
      return;
    }

    entries.addAll(addedEntries);
    selectedDate.value = _nextDateForWeekday(addedEntries.first.weekday);
    entries.refresh();
  }

  Future<void> onDeleteEntry(String entryId) async {
    final List<ScheduleEntryEntity> previousEntries = entries.toList();
    entries.removeWhere((entry) => entry.id == entryId);
    final Either<AppError, void> result = await _deleteScheduleEntryUseCase(
      entryId,
    );
    result.fold((error) {
      entries.value = previousEntries;
      _appNavigator.showErrorSnackBar(error.message);
    }, (_) {});
  }
}
