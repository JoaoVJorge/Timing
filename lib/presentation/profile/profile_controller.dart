import "package:dartz/dartz.dart";
import "package:get/get.dart";
import "package:help_out/app/app_controller.dart";
import "package:help_out/core/domain/entities/profile_stats_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/get_profile_stats_use_case.dart";

class ProfileController extends GetxController {
  ProfileController({required this._getProfileStatsUseCase, required this._appController});

  final GetProfileStatsUseCase _getProfileStatsUseCase;
  final AppController _appController;

  RxString get userName => _appController.userName;

  final Rx<ProfileStatsEntity> stats = const ProfileStatsEntity(
    studyingTotalSeconds: 0,
    workingTotalSeconds: 0,
    readingTotalSeconds: 0,
    topStudyingSubject: null,
    topReadingSubjects: [],
  ).obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  Future<void> loadStats() async {
    isLoading.value = true;
    final Either<AppError, ProfileStatsEntity> result = await _getProfileStatsUseCase();
    result.fold((error) => null, (value) => stats.value = value);
    isLoading.value = false;
  }
}
