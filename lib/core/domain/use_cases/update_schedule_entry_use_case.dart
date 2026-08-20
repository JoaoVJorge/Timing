import "package:dartz/dartz.dart";
import "package:timing/core/data/repositories/schedule_repository.dart";
import "package:timing/core/domain/entities/schedule_entry_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/utils/id_generator.dart";

class UpdateScheduleEntryUseCase {
  UpdateScheduleEntryUseCase({required this._scheduleRepository});

  final ScheduleRepository _scheduleRepository;

  /// Replaces the entry identified by [entryId] with the edited values. The
  /// first weekday keeps the original id (so a plain edit stays the same row),
  /// while any extra weekdays are materialized as new entries — matching how
  /// the add flow spreads a single form across several days.
  Future<Either<AppError, List<ScheduleEntryEntity>>> call({
    required String entryId,
    required String title,
    required List<int> weekdays,
    required int? startMinutes,
    required int? endMinutes,
    required int colorValue,
    required DateTime activeFrom,
    required DateTime? activeUntil,
  }) async {
    if (weekdays.isEmpty) {
      return Left(
        GenericAppError(
          error: "No weekday selected for schedule entry $entryId",
          stackTrace: StackTrace.current,
        ),
      );
    }

    final Either<AppError, List<ScheduleEntryEntity>> getResult =
        await _scheduleRepository.getEntries();

    return getResult.fold((error) async => Left(error), (entries) async {
      final DateTime normalizedFrom = DateTime(
        activeFrom.year,
        activeFrom.month,
        activeFrom.day,
      );
      final DateTime? normalizedUntil = activeUntil == null
          ? null
          : DateTime(activeUntil.year, activeUntil.month, activeUntil.day);

      ScheduleEntryEntity build(String id, int weekday) => ScheduleEntryEntity(
        id: id,
        title: title,
        weekday: weekday,
        startMinutes: startMinutes,
        endMinutes: endMinutes,
        colorValue: colorValue,
        activeFrom: normalizedFrom,
        activeUntil: normalizedUntil,
      );

      final List<ScheduleEntryEntity> replacements = [
        build(entryId, weekdays.first),
        for (final int weekday in weekdays.skip(1))
          build(generateEntityId(), weekday),
      ];

      final List<ScheduleEntryEntity> updatedEntries = [
        for (final ScheduleEntryEntity entry in entries)
          if (entry.id == entryId) replacements.first else entry,
        ...replacements.skip(1),
      ];

      final Either<AppError, void> saveResult = await _scheduleRepository
          .saveEntries(updatedEntries);
      return saveResult.fold(Left.new, (_) => Right(updatedEntries));
    });
  }
}
