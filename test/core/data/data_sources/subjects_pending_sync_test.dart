import "package:flutter_test/flutter_test.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:timing/core/data/data_sources/subjects_data_source.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";

class _MemStorage implements AppLocalStorageService {
  final Map<LocalStorageKeys, Object?> data = {};

  @override
  Future<T?> read<T>(LocalStorageKeys key) async => data[key] as T?;

  @override
  Future<void> write<T>(LocalStorageKeys key, T value) async {
    data[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Signed-in user whose backend is unreachable: `requireClient` throws, as it
/// would offline.
class _OfflineSupabase implements SupabaseService {
  @override
  String? get currentUserId => "user-1";

  @override
  SupabaseClient get requireClient => throw StateError("offline");

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _SignedOutSupabase implements SupabaseService {
  @override
  String? get currentUserId => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

SubjectEntity _subject() => const SubjectEntity(
  id: "s1",
  name: "Matemática",
  category: TimeCategoryType.studying,
  colorValue: 0xFF000000,
  totalSeconds: 0,
  goalSeconds: 1800,
  currentPages: 0,
  goalPages: 0,
  notes: "",
  iconName: "clock",
  restMinutes: 5,
  focusSessionCount: 1,
  wallpaperIndex: 0,
  activityType: SubjectActivityType.permanent,
);

Future<(SubjectsDataSource, PendingSyncStore, _MemStorage)> _build(
  SupabaseService supabase,
) async {
  final storage = _MemStorage();
  final store = PendingSyncStore(localStorageService: storage);
  await store.load();
  final dataSource = SubjectsDataSource(
    localStorageService: storage,
    supabaseService: supabase,
    logger: AppLoggerService(),
    pendingSyncStore: store,
  );
  return (dataSource, store, storage);
}

void main() {
  group("SubjectsDataSource offline sync", () {
    test("saves locally and marks pending when the remote sync fails", () async {
      final (dataSource, store, storage) = await _build(_OfflineSupabase());

      final result = await dataSource.saveSubjects([_subject()]);

      expect(result.isRight(), isTrue);
      expect(storage.data[LocalStorageKeys.subjects], isNotNull);
      expect(store.contains(PendingSyncDataset.subjects), isTrue);
    });

    test("keeps the dataset pending while the retry still fails", () async {
      final (dataSource, store, _) = await _build(_OfflineSupabase());
      await dataSource.saveSubjects([_subject()]);

      await dataSource.flushPendingSync();

      expect(store.contains(PendingSyncDataset.subjects), isTrue);
    });

    test("does not mark pending when there is no signed-in user", () async {
      final (dataSource, store, _) = await _build(_SignedOutSupabase());

      final result = await dataSource.saveSubjects([_subject()]);

      expect(result.isRight(), isTrue);
      expect(store.contains(PendingSyncDataset.subjects), isFalse);
    });
  });
}
