import "package:dartz/dartz.dart";
import "package:get/get.dart";
import "package:help_out/app/app_controller.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/core/domain/entities/profile_stats_entity.dart";
import "package:help_out/core/domain/entities/schedule_entry_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/get_profile_stats_use_case.dart";
import "package:help_out/core/domain/use_cases/get_schedule_entries_use_case.dart";

class ProfileController extends GetxController {
  ProfileController({
    required this._getProfileStatsUseCase,
    required this._getScheduleEntriesUseCase,
    required this._appController,
    required this._appNavigator,
  });

  final GetProfileStatsUseCase _getProfileStatsUseCase;
  final GetScheduleEntriesUseCase _getScheduleEntriesUseCase;
  final AppController _appController;
  final AppNavigator _appNavigator;

  RxString get userName => _appController.userName;

  final Rx<ProfileStatsEntity> stats = const ProfileStatsEntity(
    studyingTotalSeconds: 0,
    workingTotalSeconds: 0,
    readingTotalSeconds: 0,
    topStudyingSubject: null,
    topReadingSubjects: [],
  ).obs;
  final RxList<ScheduleEntryEntity> scheduleEntries = <ScheduleEntryEntity>[].obs;
  final RxBool isLoading = true.obs;

  List<ScheduleEntryEntity> get sortedScheduleEntries =>
      List.of(scheduleEntries)..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));

  @override
  void onInit() {
    super.onInit();
    loadStats();
    loadScheduleEntries();
  }

  Future<void> loadStats() async {
    isLoading.value = true;
    final Either<AppError, ProfileStatsEntity> result = await _getProfileStatsUseCase();
    result.fold((error) => null, (value) => stats.value = value);
    isLoading.value = false;
  }

  Future<void> loadScheduleEntries() async {
    final Either<AppError, List<ScheduleEntryEntity>> result = await _getScheduleEntriesUseCase();
    result.fold((error) => scheduleEntries.clear(), (value) => scheduleEntries.value = value);
  }

  Future<void> onTapSchedule() async {
    await _appNavigator.toNamed(AppRoutes.schedule);
    await loadScheduleEntries();
  }
}
