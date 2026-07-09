import "package:dartz/dartz.dart";
import "package:help_out/core/data/repositories/subjects_repository.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/domain/errors/app_error.dart";

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
    int wallpaperIndex = 0,
  }) async {
    final Either<AppError, List<SubjectEntity>> getResult =
        await _subjectsRepository.getSubjects();

    return getResult.fold((error) async => Left(error), (subjects) async {
      final SubjectEntity newSubject = SubjectEntity(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
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
        wallpaperIndex: wallpaperIndex,
      );

      final Either<AppError, void> saveResult = await _subjectsRepository
          .saveSubjects([...subjects, newSubject]);

      return saveResult.fold(Left.new, (_) => Right(newSubject));
    });
  }
}
