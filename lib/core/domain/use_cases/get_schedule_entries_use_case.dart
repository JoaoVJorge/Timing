import "package:dartz/dartz.dart";
import "package:help_out/core/data/repositories/schedule_repository.dart";
import "package:help_out/core/domain/entities/schedule_entry_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class GetScheduleEntriesUseCase {
  GetScheduleEntriesUseCase({required this._scheduleRepository});

  final ScheduleRepository _scheduleRepository;

  Future<Either<AppError, List<ScheduleEntryEntity>>> call() => _scheduleRepository.getEntries();
}
