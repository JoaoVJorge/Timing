import "package:dartz/dartz.dart";
import "package:help_out/core/data/repositories/schedule_repository.dart";
import "package:help_out/core/domain/entities/schedule_entry_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class AddScheduleEntryUseCase {
  AddScheduleEntryUseCase({required this._scheduleRepository});

  final ScheduleRepository _scheduleRepository;

  Future<Either<AppError, ScheduleEntryEntity>> call({
    required String title,
    required int weekday,
    required int startMinutes,
    required int endMinutes,
    required int colorValue,
  }) async {
    final Either<AppError, List<ScheduleEntryEntity>> getResult =
        await _scheduleRepository.getEntries();

    return getResult.fold((error) async => Left(error), (entries) async {
      final ScheduleEntryEntity newEntry = ScheduleEntryEntity(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        weekday: weekday,
        startMinutes: startMinutes,
        endMinutes: endMinutes,
        colorValue: colorValue,
      );

      final Either<AppError, void> saveResult = await _scheduleRepository
          .saveEntries([...entries, newEntry]);
      return saveResult.fold(Left.new, (_) => Right(newEntry));
    });
  }
}
