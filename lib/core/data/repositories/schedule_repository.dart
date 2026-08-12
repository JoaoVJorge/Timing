import "package:dartz/dartz.dart";
import "package:timing/core/data/data_sources/schedule_data_source.dart";
import "package:timing/core/domain/entities/schedule_entry_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";

class ScheduleRepository {
  ScheduleRepository({required this._scheduleDataSource});

  final ScheduleDataSource _scheduleDataSource;

  Future<Either<AppError, List<ScheduleEntryEntity>>> getEntries() =>
      _scheduleDataSource.getEntries();

  Future<Either<AppError, void>> saveEntries(
    List<ScheduleEntryEntity> entries,
  ) => _scheduleDataSource.saveEntries(entries);
}
