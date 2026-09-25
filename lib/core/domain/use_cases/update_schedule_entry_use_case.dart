import "package:dartz/dartz.dart";
import "package:timing/core/data/repositories/schedule_repository.dart";
import "package:timing/core/domain/entities/schedule_entry_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/utils/id_generator.dart";

class UpdateScheduleEntryUseCase {
  UpdateScheduleEntryUseCase({required this._scheduleRepository});

  final ScheduleRepository _scheduleRepository;

  /// Replaces every weekday occurrence belonging to the same schedule series
  /// as [entryId]. Existing ids are retained whenever their weekday remains;
  /// newly selected weekdays are materialized as new entries.
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
      final ScheduleEntryEntity? original = entries
          .where((entry) => entry.id == entryId)
          .firstOrNull;
      if (original == null) {
        return Left(
          GenericAppError(
            error: "Schedule entry $entryId was not found",
            stackTrace: StackTrace.current,
          ),
        );
      }

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

      final List<ScheduleEntryEntity> seriesEntries = entries
          .where(original.belongsToSameSeriesAs)
          .toList();
      final Map<int, String> idsByWeekday = {
        for (final ScheduleEntryEntity entry in seriesEntries)
          entry.weekday: entry.id,
      };
      final List<int> normalizedWeekdays = weekdays.toSet().toList()..sort();
      bool reusedOriginalId = false;
      String idFor(int weekday) {
        final String? existingId = idsByWeekday[weekday];
        if (existingId != null) {
          if (existingId == entryId) {
            reusedOriginalId = true;
          }
          return existingId;
        }
        if (!reusedOriginalId &&
            !normalizedWeekdays.any((item) => idsByWeekday[item] == entryId)) {
          reusedOriginalId = true;
          return entryId;
        }
        return generateEntityId();
      }

      final List<ScheduleEntryEntity> replacements = [
        for (final int weekday in normalizedWeekdays)
          build(idFor(weekday), weekday),
      ];

      final List<ScheduleEntryEntity> updatedEntries = [
        for (final ScheduleEntryEntity entry in entries)
          if (!seriesEntries.any((seriesEntry) => seriesEntry.id == entry.id))
            entry,
        ...replacements,
      ];

      final Either<AppError, void> saveResult = await _scheduleRepository
          .saveEntries(updatedEntries);
      return saveResult.fold(Left.new, (_) => Right(updatedEntries));
    });
  }
}
