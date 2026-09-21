import "dart:convert";

import "package:timing/core/domain/entities/active_timer_session_entity.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/utils/serial_task_queue.dart";

class ActiveTimerSessionService {
  ActiveTimerSessionService({required this.localStorageService});

  final AppLocalStorageService localStorageService;
  final SerialTaskQueue _writeQueue = SerialTaskQueue();

  Future<ActiveTimerSessionEntity?> restore() async {
    try {
      await _writeQueue.join();
      final String? encoded = await localStorageService.read<String?>(
        LocalStorageKeys.activeTimerSession,
      );
      if (encoded == null) {
        return null;
      }
      final ActiveTimerSessionEntity session = ActiveTimerSessionEntity.fromMap(
        jsonDecode(encoded) as Map<String, dynamic>,
      );
      if (session.sessionSeconds == 0 && !session.isRunning) {
        await clear();
        return null;
      }
      return session;
    } catch (_) {
      await clear();
      return null;
    }
  }

  Future<void> save(ActiveTimerSessionEntity session) => _writeQueue.run(
    () => localStorageService.write(
      LocalStorageKeys.activeTimerSession,
      jsonEncode(session.toMap()),
    ),
  );

  Future<void> clear() => _writeQueue.run(
    () => localStorageService.delete(LocalStorageKeys.activeTimerSession),
  );
}
