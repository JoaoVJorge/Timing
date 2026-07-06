import "dart:convert";

import "package:dartz/dartz.dart";
import "package:help_out/core/domain/entities/schedule_entry_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/services/local_storage/app_local_storage_service.dart";
import "package:help_out/core/services/local_storage/local_storage_keys.dart";

class ScheduleDataSource {
  ScheduleDataSource({required this._localStorageService});

  final AppLocalStorageService _localStorageService;

  Future<Either<AppError, List<ScheduleEntryEntity>>> getEntries() async {
    try {
      final String? saved = await _localStorageService.read<String?>(LocalStorageKeys.scheduleEntries);

      if (saved == null) {
        return const Right([]);
      }

      final List<dynamic> decoded = jsonDecode(saved) as List<dynamic>;
      return Right(decoded.map((item) => ScheduleEntryEntity.fromMap(item as Map<String, dynamic>)).toList());
    } catch (error, stackTrace) {
      return Left(SerializationAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, void>> saveEntries(List<ScheduleEntryEntity> entries) async {
    try {
      final String encoded = jsonEncode(entries.map((entry) => entry.toMap()).toList());
      await _localStorageService.write(LocalStorageKeys.scheduleEntries, encoded);
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }
}
