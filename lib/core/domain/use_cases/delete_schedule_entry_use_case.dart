import "package:dartz/dartz.dart";
import "package:help_out/core/data/repositories/schedule_repository.dart";
import "package:help_out/core/domain/entities/schedule_entry_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class DeleteScheduleEntryUseCase {
  DeleteScheduleEntryUseCase({required this._scheduleRepository});

  final ScheduleRepository _scheduleRepository;

  Future<Either<AppError, void>> call(String entryId) async {
    final Either<AppError, List<ScheduleEntryEntity>> getResult = await _scheduleRepository.getEntries();

    return getResult.fold(
      (error) async => Left(error),
      (entries) => _scheduleRepository.saveEntries(entries.where((entry) => entry.id != entryId).toList()),
    );
  }
}
