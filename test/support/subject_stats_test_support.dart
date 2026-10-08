import "package:dartz/dartz.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/add_subject_time_use_case.dart";
import "package:timing/core/domain/use_cases/clear_subject_data_use_case.dart";
import "package:timing/core/domain/use_cases/remove_subject_time_use_case.dart";
import "package:timing/core/services/achievements/achievement_unlock_service.dart";
import "package:timing/core/services/daily_progress/subject_daily_history_service.dart";
import "package:timing/core/services/sync/activity_change_bus.dart";
import "package:timing/presentation/subject_stats/subject_stats_controller.dart";
import "package:timing/presentation/subject_stats/widgets/time_adjustment_dialog.dart";
import "package:timing/shared/widgets/clear_data_confirmation_dialog.dart";

/// A use case that only records that it was asked, and answers with [result]
/// (by default the subject with its numbers back at zero).
class FakeClearSubjectDataUseCase implements ClearSubjectDataUseCase {
  FakeClearSubjectDataUseCase({this.result});

  final List<String> calls = <String>[];
  Either<AppError, SubjectEntity>? result;

  /// The subject the fake answers with when [result] is not set.
  SubjectEntity? subject;

  @override
  Future<Either<AppError, SubjectEntity>> call({
    required String subjectId,
  }) async {
    calls.add(subjectId);
    return result ?? Right(subject!.copyWith(totalSeconds: 0, currentPages: 0));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Stands in for both "add time" and "remove time": records what it was asked
/// and answers with [subject] moved by that many seconds (never below zero),
/// or with [failure] when one is set.
class FakeSubjectTimeUseCase
    implements AddSubjectTimeUseCase, RemoveSubjectTimeUseCase {
  FakeSubjectTimeUseCase({required this.subject, required this.sign});

  SubjectEntity subject;

  /// +1 when it adds, -1 when it removes.
  final int sign;
  final List<int> calls = <int>[];
  AppError? failure;

  @override
  Future<Either<AppError, SubjectEntity>> call({
    required String subjectId,
    required int seconds,
  }) async {
    calls.add(seconds);
    final AppError? error = failure;
    if (error != null) {
      return Left(error);
    }
    final int total = subject.totalSeconds + sign * seconds;
    return Right(
      subject = subject.copyWith(totalSeconds: total < 0 ? 0 : total),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Counts how often the achievements were checked.
class FakeAchievementUnlockService implements AchievementUnlockService {
  int checks = 0;

  @override
  Future<void> checkForNewUnlocks() async => checks++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A navigator that records the snackbars it was asked to show.
class RecordingNavigator implements AppNavigator {
  final List<String> successMessages = <String>[];
  final List<String?> errorMessages = <String?>[];

  @override
  void showSuccessSnackBar(String text) => successMessages.add(text);

  @override
  void showErrorSnackBar([String? text]) => errorMessages.add(text);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<bool> _neverConfirm({
  required String itemName,
  required bool isGoal,
  required bool isFromGroup,
}) async => false;

Future<int?> _neverPickTime({
  required bool isRemoving,
  required int maxSeconds,
}) async => null;

/// A stats controller with every dependency stubbed unless overridden.
SubjectStatsController buildStatsController({
  required SubjectEntity subject,
  required SubjectDailyHistoryService history,
  ClearSubjectDataUseCase? clearUseCase,
  FakeSubjectTimeUseCase? addTimeUseCase,
  FakeSubjectTimeUseCase? removeTimeUseCase,
  FakeAchievementUnlockService? achievements,
  ActivityChangeBus? activityChangeBus,
  RecordingNavigator? navigator,
  ClearDataConfirmationCallback? confirmClearData,
  TimeAmountPicker? pickTimeAmount,
}) => SubjectStatsController(
  subject: subject,
  subjectDailyHistoryService: history,
  clearSubjectDataUseCase:
      clearUseCase ?? (FakeClearSubjectDataUseCase()..subject = subject),
  addSubjectTimeUseCase:
      addTimeUseCase ?? FakeSubjectTimeUseCase(subject: subject, sign: 1),
  removeSubjectTimeUseCase:
      removeTimeUseCase ?? FakeSubjectTimeUseCase(subject: subject, sign: -1),
  achievementUnlockService: achievements ?? FakeAchievementUnlockService(),
  activityChangeBus: activityChangeBus ?? ActivityChangeBus(),
  appNavigator: navigator ?? RecordingNavigator(),
  confirmClearData: confirmClearData ?? _neverConfirm,
  pickTimeAmount: pickTimeAmount ?? _neverPickTime,
);
