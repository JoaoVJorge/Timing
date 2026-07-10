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
  final RxInt selectedWeekday = DateTime.now().weekday.obs;

  List<ScheduleEntryEntity> get sortedEntries =>
      _sortedEntriesForWeekday(selectedWeekday.value);

  List<ScheduleEntryEntity> get todayEntries =>
      _sortedEntriesForWeekday(DateTime.now().weekday);

  List<ScheduleEntryEntity> _sortedEntriesForWeekday(int weekday) =>
      entries.where((entry) => entry.weekday == weekday).toList()
        ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));

  @override
  void onInit() {
    super.onInit();
    loadEntries();
  }

  void onSelectWeekday(int weekday) => selectedWeekday.value = weekday;

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
      arguments: selectedWeekday.value,
    );
    final AddScheduleEntryResult? result = rawResult as AddScheduleEntryResult?;

    if (result == null) {
      return;
    }

    final Either<AppError, ScheduleEntryEntity> addResult =
        await _addScheduleEntryUseCase(
          title: result.title,
          weekday: result.weekday,
          startMinutes: result.startMinutes,
          endMinutes: result.endMinutes,
          colorValue: result.colorValue,
        );
    addResult.fold((error) => _appNavigator.showErrorSnackBar(error.message), (
      entry,
    ) {
      entries.add(entry);
      selectedWeekday.value = entry.weekday;
      entries.refresh();
    });
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
