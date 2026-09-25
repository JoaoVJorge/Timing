import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/domain/entities/daily_progress_entity.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/use_cases/clear_subject_data_use_case.dart";
import "package:timing/core/services/daily_progress/subject_daily_history_service.dart";
import "package:timing/core/services/sync/activity_change_bus.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/widgets/clear_data_confirmation_dialog.dart";

typedef SubjectComparatives = ({
  List<int> values,
  int currentTotal,
  int previousTotal,
});

class SubjectStatsController extends GetxController {
  SubjectStatsController({
    required SubjectEntity subject,
    required SubjectDailyHistoryService subjectDailyHistoryService,
    required this._clearSubjectDataUseCase,
    required this._activityChangeBus,
    required this._appNavigator,
    this._confirmClearData = showClearDataConfirmationDialog,
  }) : _subject = subject.obs,
       _history = subjectDailyHistoryService;

  final Rx<SubjectEntity> _subject;
  final SubjectDailyHistoryService _history;
  final ClearSubjectDataUseCase _clearSubjectDataUseCase;
  final ActivityChangeBus _activityChangeBus;
  final AppNavigator _appNavigator;
  final ClearDataConfirmationCallback _confirmClearData;

  /// The activity being shown. Observable, so the screen redraws from zero
  /// when its data is deleted.
  SubjectEntity get subject => _subject.value;

  final RxBool isClearingData = false.obs;

  final RxBool isMonth = false.obs;

  bool get isReading => subject.category == TimeCategoryType.reading;

  bool get isHobby => subject.category == TimeCategoryType.hobbies;

  /// A daily activity renews every day: its goal is met (or not) by what was
  /// done today. A permanent one accumulates until the goal is reached.
  bool get isDaily => subject.activityType == SubjectActivityType.daily;

  /// What counts toward the goal: today's progress for a daily activity (the
  /// same rule the activity list, home and timer use), the running total for a
  /// permanent one.
  int get overviewCurrent {
    if (isReading) {
      return isDaily ? pagesReadToday : subject.currentPages;
    }
    return isDaily
        ? _history.todayForSubject(subject.id).focusSeconds
        : subject.totalSeconds;
  }

  int get overviewGoal =>
      isReading ? subject.goalPages : subject.totalGoalSeconds;

  double get progress {
    if (overviewGoal <= 0) {
      return 0;
    }
    return (overviewCurrent / overviewGoal).clamp(0, 1).toDouble();
  }

  int get pagesReadToday =>
      isReading ? _history.historyForLastDays(subject.id, 1).first.pages : 0;

  /// The day this goal started, in the device's time zone, or null for
  /// subjects saved before creation dates were recorded. Synced subjects come
  /// back from the backend as UTC, so it is converted before its calendar day
  /// is read.
  DateTime? get goalStartDate => subject.createdAt?.toLocal();

  int get days => isMonth.value ? 30 : 7;

  SubjectComparatives get comparatives {
    final int windowDays = days;
    final List<DailyProgressEntity> full = _history.historyForLastDays(
      subject.id,
      windowDays * 2,
    );
    final List<int> values = [
      for (final DailyProgressEntity day in full.sublist(windowDays))
        _metric(day),
    ];
    final int currentTotal = values.fold(0, (sum, value) => sum + value);
    final int previousTotal = full
        .sublist(0, windowDays)
        .fold(0, (sum, day) => sum + _metric(day));
    return (
      values: values,
      currentTotal: currentTotal,
      previousTotal: previousTotal,
    );
  }

  void selectPeriod({required bool isMonth}) => this.isMonth.value = isMonth;

  /// Deletes what the user did on this activity (time, pages and every logged
  /// session) after asking, and keeps the activity itself. For a group
  /// activity that is also what takes the user's share out of the ranking.
  Future<void> onClearData() async {
    if (isClearingData.value) {
      return;
    }
    final SubjectEntity current = subject;
    final bool confirmed = await _confirmClearData(
      itemName: current.name,
      isGoal: false,
      isFromGroup: current.isFromGroup,
    );
    if (!confirmed) {
      return;
    }

    isClearingData.value = true;
    try {
      final result = await _clearSubjectDataUseCase(subjectId: current.id);
      result.fold((error) => _appNavigator.showErrorSnackBar(error.message), (
        cleared,
      ) {
        _subject.value = cleared;
        if (cleared.isFromGroup) {
          _activityChangeBus.notifyGroupActivityChanged(
            groupId: cleared.groupId,
          );
        }
        _appNavigator.showSuccessSnackBar(
          Get.context?.l10n.clearDataSuccessMessage ?? "Data deleted.",
        );
      });
    } finally {
      isClearingData.value = false;
    }
  }

  int _metric(DailyProgressEntity day) =>
      isReading ? day.pages : day.focusSeconds;
}
