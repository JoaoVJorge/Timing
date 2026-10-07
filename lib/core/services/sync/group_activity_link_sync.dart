import "package:get/get.dart";
import "package:timing/core/data/data_sources/subjects_data_source.dart";
import "package:timing/core/data/data_sources/daily_tasks_data_source.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";

/// Upload pending sources before taking the server's history baseline. Never
/// discard local caches: they may still contain offline work.
Future<bool> preparePersonalActivitiesForLinking() async {
  if (Get.isRegistered<SubjectsDataSource>()) {
    await Get.find<SubjectsDataSource>().flushPendingSync();
  }
  if (Get.isRegistered<DailyTasksDataSource>()) {
    await Get.find<DailyTasksDataSource>().flushPendingSync();
  }
  if (!Get.isRegistered<PendingSyncStore>()) return true;
  final pending = Get.find<PendingSyncStore>();
  return !pending.contains(PendingSyncDataset.subjects) &&
      !pending.contains(PendingSyncDataset.dailyTasks);
}

Future<void> refreshPersonalActivitiesAfterLinking() async {
  if (Get.isRegistered<SubjectsDataSource>()) {
    await Get.find<SubjectsDataSource>().reconcileWithRemote();
  }
  if (Get.isRegistered<DailyTasksDataSource>()) {
    await Get.find<DailyTasksDataSource>().refreshAfterGroupLinkChange();
  }
}
