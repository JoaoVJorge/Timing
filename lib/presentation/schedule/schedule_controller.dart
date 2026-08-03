import "package:dartz/dartz.dart";
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

  /// Only meaningful for today: on other days every entry is simply upcoming.
  ScheduleEntryStatus statusOf(ScheduleEntryEntity entry) {
    if (!isViewingToday) {
      return ScheduleEntryStatus.upcoming;
    }
    final DateTime now = DateTime.now();
    final int nowMinutes = now.hour * 60 + now.minute;
    final int endMinutes = entry.endMinutes ?? entry.startMinutes;
    if (nowMinutes >= endMinutes && nowMinutes > entry.startMinutes) {
      return ScheduleEntryStatus.past;
    }
    if (nowMinutes >= entry.startMinutes) {
      return ScheduleEntryStatus.current;
    }
    return ScheduleEntryStatus.upcoming;
  }

  DateTime _nextDateForWeekday(int weekday) {
    final DateTime today = _todayDate();
    final int diff = (weekday - today.weekday + 7) % 7;
    return today.add(Duration(days: diff));
  }

  List<ScheduleEntryEntity> _sortedEntriesForWeekday(int weekday) =>
      entries.where((entry) => entry.weekday == weekday).toList()
        ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));

  @override
  void onInit() {
    super.onInit();
    loadEntries();
  }

  void onSelectDate(DateTime date) =>
      selectedDate.value = DateTime(date.year, date.month, date.day);

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
