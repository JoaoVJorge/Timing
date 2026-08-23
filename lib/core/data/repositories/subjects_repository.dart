import "dart:async";

import "package:dartz/dartz.dart";
import "package:timing/core/data/data_sources/subjects_data_source.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";

class SubjectsRepository {
  SubjectsRepository({required this._subjectsDataSource});

  final SubjectsDataSource _subjectsDataSource;
  Future<void> _mutationTail = Future<void>.value();

  /// Runs a complete read-modify-write transaction after every previously
  /// started subject mutation. Without this queue, a timer autosave can read
  /// an old subject and overwrite configuration changes saved milliseconds
  /// earlier by the edit screen.
  Future<T> runSerializedMutation<T>(Future<T> Function() mutation) {
    final Completer<T> completer = Completer<T>();
    final Future<void> scheduled = _mutationTail.then((_) async {
      try {
        completer.complete(await mutation());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    _mutationTail = scheduled.catchError((Object _) {});
    return completer.future;
  }

  Future<Either<AppError, List<SubjectEntity>>> getSubjects() =>
      _subjectsDataSource.getSubjects();

  Future<Either<AppError, void>> saveSubjects(List<SubjectEntity> subjects) =>
      _subjectsDataSource.saveSubjects(subjects);
}
