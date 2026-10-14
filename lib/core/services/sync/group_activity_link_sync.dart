import "package:get/get.dart";
import "package:timing/core/data/repositories/subjects_repository.dart";
import "package:timing/core/data/repositories/daily_tasks_repository.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";

/// Upload pending activities and goals before linking them: the backend can
/// only link what it already holds, and it takes its history baseline from
/// there. Never discard local caches: they may still contain offline work.
Future<bool> preparePersonalActivitiesForLinking() async {
  if (Get.isRegistered<SubjectsRepository>()) {
    await Get.find<SubjectsRepository>().flushPendingSync();
  }
  if (Get.isRegistered<DailyTasksRepository>()) {
    await Get.find<DailyTasksRepository>().flushPendingSync();
  }
  if (!Get.isRegistered<PendingSyncStore>()) return true;
  final pending = Get.find<PendingSyncStore>();
  return !pending.contains(PendingSyncDataset.subjects) &&
      !pending.contains(PendingSyncDataset.dailyTasks);
}
