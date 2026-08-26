import "package:dartz/dartz.dart";
import "package:timing/core/data/repositories/subjects_repository.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/utils/id_generator.dart";

class AddSubjectUseCase {
  AddSubjectUseCase({required this._subjectsRepository});

  final SubjectsRepository _subjectsRepository;

  Future<Either<AppError, SubjectEntity>> call({
    required String name,
    required TimeCategoryType category,
    required int colorValue,
    required int goalSeconds,
    int goalPages = 0,
    String iconName = "",
    int restMinutes = SubjectEntity.defaultRestMinutes,
    int focusSessionCount = 1,
    int wallpaperIndex = 0,
    SubjectActivityType activityType = SubjectActivityType.daily,
    bool reuseMatchingSubject = false,
    String? groupId,
    String? groupActivityId,
    String? id,
  }) async {
    final Either<AppError, List<SubjectEntity>> getResult =
        await _subjectsRepository.getSubjects();

    return getResult.fold((error) async => Left(error), (subjects) async {
      if (reuseMatchingSubject) {
        final String normalizedName = name.trim().toLowerCase();
        final int matchIndex = subjects.indexWhere(
          (subject) =>
              subject.name.trim().toLowerCase() == normalizedName &&
              subject.category == category &&
              subject.goalSeconds == goalSeconds &&
              subject.goalPages == goalPages &&
              subject.activityType == activityType,
        );
        if (matchIndex != -1) {
          final SubjectEntity match = subjects[matchIndex];
          if (groupId != null &&
              (match.groupId != groupId ||
                  match.groupActivityId != groupActivityId)) {
            final SubjectEntity linked = match.copyWith(
              groupId: groupId,
              groupActivityId: groupActivityId,
            );
            final List<SubjectEntity> updatedSubjects = [...subjects]
              ..[matchIndex] = linked;
            final Either<AppError, void> saveResult = await _subjectsRepository
                .saveSubjects(updatedSubjects);
            return saveResult.fold(Left.new, (_) => Right(linked));
          }
          return Right(match);
        }
      }

      final SubjectEntity newSubject = SubjectEntity(
        id: id ?? generateEntityId(),
        name: name,
        category: category,
        colorValue: colorValue,
        totalSeconds: 0,
        goalSeconds: goalSeconds,
        currentPages: 0,
        goalPages: goalPages,
        notes: "",
        iconName: iconName,
        restMinutes: restMinutes,
        focusSessionCount: focusSessionCount,
        wallpaperIndex: wallpaperIndex,
        activityType: activityType,
        createdAt: DateTime.now(),
        groupId: groupId,
        groupActivityId: groupActivityId,
      );

      final Either<AppError, void> saveResult = await _subjectsRepository
          .saveSubjects([...subjects, newSubject]);

      return saveResult.fold(Left.new, (_) => Right(newSubject));
    });
  }
}
