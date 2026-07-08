import "package:dartz/dartz.dart";
import "package:get/get.dart";
import "package:help_out/app/app_controller.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/core/domain/entities/profile_stats_entity.dart";
import "package:help_out/core/domain/entities/schedule_entry_entity.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/get_profile_stats_use_case.dart";
import "package:help_out/presentation/schedule/schedule_controller.dart";

class ProfileController extends GetxController {
  ProfileController({
    required this._getProfileStatsUseCase,
    required this._scheduleController,
    required this._appController,
    required this._appNavigator,
  });

  final GetProfileStatsUseCase _getProfileStatsUseCase;
  final ScheduleController _scheduleController;
  final AppController _appController;
  final AppNavigator _appNavigator;

  RxString get userName => _appController.userName;
  RxString get nickName => _appController.nickName;
  RxInt get avatarIconIndex => _appController.avatarIconIndex;

  final Rx<ProfileStatsEntity> stats = const ProfileStatsEntity(
    studyingTotalSeconds: 0,
    studyingGoalSeconds: 0,
    exercisesTotalSeconds: 0,
    exercisesGoalSeconds: 0,
    hobbiesTotalSeconds: 0,
    readingTotalPages: 0,
    readingGoalPages: 0,
    topStudyingSubject: null,
    topReadingSubjects: [],
  ).obs;
  final RxBool isLoading = true.obs;

  List<ScheduleEntryEntity> get sortedScheduleEntries =>
      _scheduleController.todayEntries;

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  Future<void> loadStats() async {
    isLoading.value = true;
    final Either<AppError, ProfileStatsEntity> result =
        await _getProfileStatsUseCase();
    result.fold((error) => null, (value) => stats.value = value);
    isLoading.value = false;
  }

  Future<void> onTapEditProfile() => _navigateAndRefresh(AppRoutes.editProfile);

  Future<void> onTapCategory(TimeCategoryType category) =>
      _navigateAndRefresh(AppRoutes.category, arguments: category);

  Future<void> onTapSchedule() => _navigateAndRefresh(AppRoutes.schedule);

  Future<void> onTapCreateGoal() => _navigateAndRefresh(AppRoutes.dailyGoals);

  Future<void> onAddScheduleEntry() => _scheduleController.onTapAddEntry();

  Future<void> _navigateAndRefresh(String route, {Object? arguments}) async {
    await (_appNavigator.toNamed(route, arguments: arguments) ??
        Future<void>.value());
    await loadStats();
  }
}
