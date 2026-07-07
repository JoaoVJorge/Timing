import "package:equatable/equatable.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";

class ProfileStatsEntity extends Equatable {
  const ProfileStatsEntity({
    required this.studyingTotalSeconds,
    required this.exercisesTotalSeconds,
    required this.readingTotalSeconds,
    required this.topStudyingSubject,
    required this.topReadingSubjects,
  });

  factory ProfileStatsEntity.fromSubjects(List<SubjectEntity> subjects) {
    final List<SubjectEntity> studyingSubjects = _byCategory(subjects, TimeCategoryType.studying);
    final List<SubjectEntity> readingSubjects = _byCategory(subjects, TimeCategoryType.reading)
      ..sort((a, b) => b.totalSeconds.compareTo(a.totalSeconds));

    return ProfileStatsEntity(
      studyingTotalSeconds: _sumSeconds(studyingSubjects),
      exercisesTotalSeconds: _sumSeconds(_byCategory(subjects, TimeCategoryType.exercises)),
      readingTotalSeconds: _sumSeconds(readingSubjects),
      topStudyingSubject: _topSubject(studyingSubjects),
      topReadingSubjects: readingSubjects.take(3).toList(),
    );
  }

  static List<SubjectEntity> _byCategory(List<SubjectEntity> subjects, TimeCategoryType category) =>
      subjects.where((subject) => subject.category == category).toList();

  static int _sumSeconds(List<SubjectEntity> subjects) =>
      subjects.fold(0, (total, subject) => total + subject.totalSeconds);

  static SubjectEntity? _topSubject(List<SubjectEntity> subjects) {
    if (subjects.isEmpty) {
      return null;
    }
    return subjects.reduce((a, b) => b.totalSeconds > a.totalSeconds ? b : a);
  }

  final int studyingTotalSeconds;
  final int exercisesTotalSeconds;
  final int readingTotalSeconds;
  final SubjectEntity? topStudyingSubject;
  final List<SubjectEntity> topReadingSubjects;

  @override
  List<Object?> get props => [
    studyingTotalSeconds,
    exercisesTotalSeconds,
    readingTotalSeconds,
    topStudyingSubject,
    topReadingSubjects,
  ];
}
