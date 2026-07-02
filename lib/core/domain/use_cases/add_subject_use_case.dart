import "package:dartz/dartz.dart";
import "package:help_out/core/data/repositories/subjects_repository.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/theme/subject_colors.dart";

class AddSubjectUseCase {
  AddSubjectUseCase({required this._subjectsRepository});

  final SubjectsRepository _subjectsRepository;

  Future<Either<AppError, SubjectEntity>> call({required String name, required TimeCategoryType category}) async {
    final Either<AppError, List<SubjectEntity>> getResult = await _subjectsRepository.getSubjects();

    return getResult.fold((error) async => Left(error), (subjects) async {
      final SubjectEntity newSubject = SubjectEntity(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        category: category,
        colorValue: SubjectColors.byIndex(subjects.length).toARGB32(),
        totalSeconds: 0,
      );

      final Either<AppError, void> saveResult = await _subjectsRepository.saveSubjects([...subjects, newSubject]);

      return saveResult.fold(Left.new, (_) => Right(newSubject));
    });
  }
}
