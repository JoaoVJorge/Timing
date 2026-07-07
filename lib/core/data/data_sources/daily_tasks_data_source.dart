import "dart:convert";

import "package:dartz/dartz.dart";
import "package:help_out/core/domain/entities/daily_task_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/services/local_storage/app_local_storage_service.dart";
import "package:help_out/core/services/local_storage/local_storage_keys.dart";

class DailyTasksDataSource {
  DailyTasksDataSource({required this._localStorageService});

  final AppLocalStorageService _localStorageService;

  Future<Either<AppError, List<DailyTaskEntity>>> getTasks() async {
    try {
      final String? savedTasks = await _localStorageService.read<String?>(LocalStorageKeys.dailyTasks);

      if (savedTasks == null) {
        return const Right([]);
      }

      final List<dynamic> decoded = jsonDecode(savedTasks) as List<dynamic>;
      return Right(decoded.map((item) => DailyTaskEntity.fromMap(item as Map<String, dynamic>)).toList());
    } catch (error, stackTrace) {
      return Left(SerializationAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, void>> saveTasks(List<DailyTaskEntity> tasks) async {
    try {
      final String encoded = jsonEncode(tasks.map((task) => task.toMap()).toList());
      await _localStorageService.write(LocalStorageKeys.dailyTasks, encoded);
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }
}
