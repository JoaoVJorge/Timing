import "package:equatable/equatable.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";

class ProfileStatsEntity extends Equatable {
  const ProfileStatsEntity({
    required this.studyingTotalSeconds,
    required this.studyingGoalSeconds,
    required this.exercisesTotalSeconds,
    required this.exercisesGoalSeconds,
    required this.hobbiesTotalSeconds,
    required this.readingTotalPages,
    required this.readingGoalPages,
    required this.topStudyingSubject,
    required this.topReadingSubjects,
  });

  factory ProfileStatsEntity.fromSubjects(List<SubjectEntity> subjects) {
    final List<SubjectEntity> studyingSubjects = _byCategory(
      subjects,
      TimeCategoryType.studying,
    );
    final List<SubjectEntity> exerciseSubjects = _byCategory(
      subjects,
      TimeCategoryType.exercises,
    );
    final List<SubjectEntity> hobbySubjects = _byCategory(
      subjects,
      TimeCategoryType.hobbies,
    );
    // Reading is measured in pages, not time — a tap on a reading subject logs
    // pages via a dialog while the other categories run a timer. So it is
    // ranked by [currentPages], and its totals/goals are page counts.
    final List<SubjectEntity> readingSubjects =
        _byCategory(subjects, TimeCategoryType.reading)
          ..sort((a, b) => b.currentPages.compareTo(a.currentPages));

    return ProfileStatsEntity(
      studyingTotalSeconds: _sumSeconds(studyingSubjects),
      studyingGoalSeconds: _sumGoalSeconds(studyingSubjects),
      exercisesTotalSeconds: _sumSeconds(exerciseSubjects),
      exercisesGoalSeconds: _sumGoalSeconds(exerciseSubjects),
      hobbiesTotalSeconds: _sumSeconds(hobbySubjects),
      readingTotalPages: _sumPages(readingSubjects),
      readingGoalPages: _sumGoalPages(readingSubjects),
      topStudyingSubject: _topSubject(studyingSubjects),
      topReadingSubjects: readingSubjects
          .where((subject) => subject.currentPages > 0)
          .take(3)
          .toList(),
    );
  }

  static List<SubjectEntity> _byCategory(
    List<SubjectEntity> subjects,
    TimeCategoryType category,
  ) => subjects.where((subject) => subject.category == category).toList();

  static int _sumSeconds(List<SubjectEntity> subjects) =>
      subjects.fold(0, (total, subject) => total + subject.totalSeconds);

  static int _sumGoalSeconds(List<SubjectEntity> subjects) =>
      subjects.fold(0, (total, subject) => total + subject.goalSeconds);

  static int _sumPages(List<SubjectEntity> subjects) =>
      subjects.fold(0, (total, subject) => total + subject.currentPages);

  static int _sumGoalPages(List<SubjectEntity> subjects) =>
      subjects.fold(0, (total, subject) => total + subject.goalPages);

  static SubjectEntity? _topSubject(List<SubjectEntity> subjects) {
    if (subjects.isEmpty) {
      return null;
    }
    return subjects.reduce((a, b) => b.totalSeconds > a.totalSeconds ? b : a);
  }

  final int studyingTotalSeconds;
  final int studyingGoalSeconds;
  final int exercisesTotalSeconds;
  final int exercisesGoalSeconds;
  final int hobbiesTotalSeconds;
  final int readingTotalPages;
  final int readingGoalPages;
  final SubjectEntity? topStudyingSubject;
  final List<SubjectEntity> topReadingSubjects;

  /// Timed focus across the categories tracked by a timer (reading is excluded
  /// because it is page-based, not time-based).
  int get totalFocusSeconds =>
      studyingTotalSeconds + exercisesTotalSeconds + hobbiesTotalSeconds;

  int get totalFocusGoalSeconds =>
      studyingGoalSeconds + exercisesGoalSeconds;

  /// Whether the top studying subject has any tracked time to highlight.
  bool get hasTopStudyingSubject =>
      topStudyingSubject != null && topStudyingSubject!.totalSeconds > 0;

  /// True when the user has not registered any focus time or reading yet.
  bool get isEmpty => totalFocusSeconds == 0 && readingTotalPages == 0;

  @override
  List<Object?> get props => [
    studyingTotalSeconds,
    studyingGoalSeconds,
    exercisesTotalSeconds,
    exercisesGoalSeconds,
    hobbiesTotalSeconds,
    readingTotalPages,
    readingGoalPages,
    topStudyingSubject,
    topReadingSubjects,
  ];
}
