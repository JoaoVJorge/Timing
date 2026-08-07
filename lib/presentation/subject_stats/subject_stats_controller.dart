import "package:get/get.dart";
import "package:help_out/core/domain/entities/daily_progress_entity.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/services/daily_progress/subject_daily_history_service.dart";

typedef SubjectComparatives = ({
  List<int> values,
  int currentTotal,
  int previousTotal,
});

class SubjectStatsController extends GetxController {
  SubjectStatsController({
    required this.subject,
    required SubjectDailyHistoryService subjectDailyHistoryService,
  }) : _history = subjectDailyHistoryService;

  final SubjectEntity subject;
  final SubjectDailyHistoryService _history;

  final RxBool isMonth = false.obs;

  bool get isReading => subject.category == TimeCategoryType.reading;

  int get overviewCurrent =>
      isReading ? subject.currentPages : subject.totalSeconds;

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

  int goalPercent(int current, int goal) {
    if (goal <= 0) {
      return 0;
    }
    return ((current / goal).clamp(0, 1) * 100).round();
  }

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

  int _metric(DailyProgressEntity day) =>
      isReading ? day.pages : day.focusSeconds;
}
