import "dart:convert";

import "package:dartz/dartz.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/services/local_storage/app_local_storage_service.dart";
import "package:help_out/core/services/local_storage/local_storage_keys.dart";

class SubjectsDataSource {
  SubjectsDataSource({required this._localStorageService});

  final AppLocalStorageService _localStorageService;

  Future<Either<AppError, List<SubjectEntity>>> getSubjects() async {
    try {
      final String? savedSubjects = await _localStorageService.read<String?>(LocalStorageKeys.subjects);

      if (savedSubjects == null) {
        return const Right([]);
      }

      final List<dynamic> decoded = jsonDecode(savedSubjects) as List<dynamic>;
      return Right(decoded.map((item) => SubjectEntity.fromMap(item as Map<String, dynamic>)).toList());
    } catch (error, stackTrace) {
      return Left(SerializationAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, void>> saveSubjects(List<SubjectEntity> subjects) async {
    try {
      final String encoded = jsonEncode(subjects.map((subject) => subject.toMap()).toList());
      await _localStorageService.write(LocalStorageKeys.subjects, encoded);
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }
}
