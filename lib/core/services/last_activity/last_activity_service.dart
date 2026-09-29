import "package:get/get.dart";
import "package:timing/core/domain/entities/last_activity_entity.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";

class LastActivityService {
  LastActivityService({required this._localStorageService});

  final AppLocalStorageService _localStorageService;

  final Rx<LastActivityEntity?> lastActivity = Rx<LastActivityEntity?>(null);

  Future<void> load() async {
    try {
      final String? saved = await _localStorageService.read<String?>(
        LocalStorageKeys.lastActivity,
      );
      lastActivity.value = saved == null
          ? null
          : LastActivityEntity.fromJson(saved);
    } catch (_) {
      lastActivity.value = null;
    }
  }

  Future<void> record(String label, {String? subjectId}) async {
    final LastActivityEntity activity = LastActivityEntity(
      label: label,
      timestamp: DateTime.now(),
      subjectId: subjectId,
    );
    lastActivity.value = activity;
    await _localStorageService.write(
      LocalStorageKeys.lastActivity,
      activity.toJson(),
    );
  }

  /// Drops the last activity when it came from [subjectId], so Home stops
  /// offering to resume an activity whose data was deleted.
  Future<void> forgetSubject(String subjectId) async {
    if (lastActivity.value?.subjectId != subjectId) {
      return;
    }
    lastActivity.value = null;
    await _localStorageService.delete(LocalStorageKeys.lastActivity);
  }
}
