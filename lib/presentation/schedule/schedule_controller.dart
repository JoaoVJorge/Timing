import "package:dartz/dartz.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/domain/entities/schedule_entry_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/add_schedule_entry_use_case.dart";
import "package:help_out/core/domain/use_cases/delete_schedule_entry_use_case.dart";
import "package:help_out/core/domain/use_cases/get_schedule_entries_use_case.dart";
import "package:help_out/presentation/schedule/widgets/add_schedule_entry_dialog.dart";

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

  List<ScheduleEntryEntity> get sortedEntries =>
      List.of(entries)..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));

  @override
  void onInit() {
    super.onInit();
    loadEntries();
  }

  Future<void> loadEntries() async {
    isLoading.value = true;
    final Either<AppError, List<ScheduleEntryEntity>> result = await _getScheduleEntriesUseCase();
    result.fold((error) => entries.clear(), (value) => entries.value = value);
    isLoading.value = false;
  }

  Future<void> onTapAddEntry() async {
    final AddScheduleEntryResult? result = await _appNavigator.dialog<AddScheduleEntryResult>(
      child: const AddScheduleEntryDialog(),
    );

    if (result == null) {
      return;
    }

    final Either<AppError, ScheduleEntryEntity> addResult = await _addScheduleEntryUseCase(
      title: result.title,
      startMinutes: result.startMinutes,
      endMinutes: result.endMinutes,
      colorValue: result.colorValue,
    );
    addResult.fold((error) => _appNavigator.showErrorSnackBar(), entries.add);
  }

  Future<void> onDeleteEntry(String entryId) async {
    entries.removeWhere((entry) => entry.id == entryId);
    await _deleteScheduleEntryUseCase(entryId);
  }
}
