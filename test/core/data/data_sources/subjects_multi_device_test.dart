import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:timing/core/data/data_sources/subjects_data_source.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";

import "../../../support/supabase_test_harness.dart";

SubjectEntity _subject(
  String id, {
  String name = "Matéria",
  int totalSeconds = 0,
  int currentPages = 0,
  String? groupActivityId,
  int goalSeconds = 0,
}) => SubjectEntity(
  id: id,
  name: name,
  category: TimeCategoryType.studying,
  colorValue: 1,
  totalSeconds: totalSeconds,
  goalSeconds: goalSeconds,
  currentPages: currentPages,
  goalPages: 0,
  notes: "",
  iconName: "",
  restMinutes: 5,
  focusSessionCount: 1,
  wallpaperIndex: 0,
  groupId: groupActivityId == null ? null : "g1",
  groupActivityId: groupActivityId,
);

Map<String, dynamic> _row(SubjectEntity s) => {
  "id": s.id,
  "user_id": "user-1",
  "name": s.name,
  "category": s.category.name,
  "color_value": s.colorValue,
  "total_seconds": s.totalSeconds,
  "goal_seconds": s.goalSeconds,
  "current_pages": s.currentPages,
  "goal_pages": s.goalPages,
  "notes": s.notes,
  "icon_name": s.iconName,
  "rest_minutes": s.restMinutes,
  "focus_session_count": s.focusSessionCount,
  "wallpaper_index": s.wallpaperIndex,
  "activity_type": s.activityType.name,
  "group_id": s.groupId,
  "group_activity_id": s.groupActivityId,
};

class _Rig {
  _Rig() {
    backend = TestBackend((request) async {
      requests.add(
        "${request.method} ${request.url.path}?${Uri.decodeQueryComponent(request.url.query)}",
      );
      final bool isRead = request.method == "GET";
      if ((isRead && failReads) || (!isRead && failWrites)) {
        return jsonResponse(request, {"message": "down"}, 503);
      }
      if (request.method == "GET") {
        return jsonResponse(request, remote.map(_row).toList());
      }
      return http.Response(
        "",
        request.method == "DELETE" ? 204 : 201,
        request: request,
      );
    });
    store = PendingSyncStore(localStorageService: storage);
    dataSource = SubjectsDataSource(
      localStorageService: storage,
      supabaseService: TestSupabaseService(backend.client),
      logger: AppLoggerService(),
      pendingSyncStore: store,
    );
  }

  final MemoryStorage storage = MemoryStorage();
  final List<String> requests = [];
  List<SubjectEntity> remote = [];
  bool failReads = false;
  bool failWrites = false;
  late final TestBackend backend;
  late final PendingSyncStore store;
  late final SubjectsDataSource dataSource;

  List<String> writes(String method) =>
      requests.where((r) => r.startsWith(method)).toList();

  void seedLocal(List<SubjectEntity> subjects) {
    storage.data[LocalStorageKeys.subjects] = jsonEncode(
      subjects.map((s) => s.toMap()).toList(),
    );
  }

  List<SubjectEntity> local() =>
      (jsonDecode(storage.data[LocalStorageKeys.subjects]! as String) as List)
          .map((m) => SubjectEntity.fromMap(m as Map<String, dynamic>))
          .toList();
}

void main() {
  late _Rig rig;
  setUp(() => rig = _Rig());
  tearDown(() => rig.backend.dispose());

  group("saving", () {
    test("never deletes a subject this device has not seen", () async {
      rig.remote = [_subject("elsewhere")];
      rig.seedLocal([_subject("a")]);

      await rig.dataSource.saveSubjects([_subject("a"), _subject("b")]);

      expect(rig.writes("DELETE"), isEmpty);
      expect(rig.writes("POST"), hasLength(1));
    });

    test("deletes exactly what the user removed, by id", () async {
      rig.seedLocal([_subject("a"), _subject("b")]);

      await rig.dataSource.saveSubjects([_subject("a")]);

      expect(rig.writes("DELETE"), hasLength(1));
      expect(rig.writes("DELETE").single, contains("id=in.(\"b\")"));
    });

    test(
      "a removed subject is deleted once, not on every later save",
      () async {
        rig.seedLocal([_subject("a"), _subject("b")]);
        await rig.dataSource.saveSubjects([_subject("a")]);
        rig.requests.clear();

        await rig.dataSource.saveSubjects([_subject("a")]);

        expect(rig.writes("DELETE"), isEmpty);
      },
    );

    test("a deletion that could not be sent is retried", () async {
      rig.seedLocal([_subject("a"), _subject("b")]);
      rig.failWrites = true;
      await rig.dataSource.saveSubjects([_subject("a")]);
      expect(rig.store.contains(PendingSyncDataset.subjects), isTrue);

      rig.failWrites = false;
      rig.requests.clear();
      await rig.dataSource.flushPendingSync();

      expect(rig.writes("DELETE").single, contains("id=in.(\"b\")"));
      expect(rig.store.contains(PendingSyncDataset.subjects), isFalse);
    });

    test("re-adding a removed subject cancels its deletion", () async {
      rig.seedLocal([_subject("a"), _subject("b")]);
      rig.failWrites = true;
      await rig.dataSource.saveSubjects([_subject("a")]);

      rig.failWrites = false;
      rig.requests.clear();
      await rig.dataSource.saveSubjects([_subject("a"), _subject("b")]);

      expect(rig.writes("DELETE"), isEmpty);
    });
  });

  group("reconcileWithRemote", () {
    test("adds a subject created on another device", () async {
      rig.remote = [_subject("a"), _subject("elsewhere", name: "Do outro")];
      rig.seedLocal([_subject("a")]);

      final bool changed = await rig.dataSource.reconcileWithRemote();

      expect(changed, isTrue);
      expect(rig.local().map((s) => s.id), ["a", "elsewhere"]);
    });

    test("keeps the larger total and page count", () async {
      rig.remote = [_subject("a", totalSeconds: 5000, currentPages: 3)];
      rig.seedLocal([_subject("a", totalSeconds: 1000, currentPages: 40)]);

      await rig.dataSource.reconcileWithRemote();

      expect(rig.local().single.totalSeconds, 5000);
      expect(rig.local().single.currentPages, 40);
    });

    test("adopts the owner's edit of a group activity", () async {
      rig.remote = [
        _subject(
          "grp_x",
          name: "Nome novo",
          goalSeconds: 7200,
          groupActivityId: "x",
        ),
      ];
      rig.seedLocal([
        _subject(
          "grp_x",
          name: "Nome velho",
          goalSeconds: 3600,
          groupActivityId: "x",
        ),
      ]);

      await rig.dataSource.reconcileWithRemote();

      expect(rig.local().single.name, "Nome novo");
      expect(rig.local().single.goalSeconds, 7200);
    });

    test("keeps this device's own edit of a personal activity", () async {
      rig.remote = [_subject("a", name: "Nome no servidor")];
      rig.seedLocal([_subject("a", name: "Nome local")]);

      await rig.dataSource.reconcileWithRemote();

      expect(rig.local().single.name, "Nome local");
    });

    test("removes a subject the other device deleted", () async {
      rig.seedLocal([_subject("a"), _subject("b")]);
      // Both were on the server after this device's last sync.
      rig.remote = [_subject("a"), _subject("b")];
      await rig.dataSource.reconcileWithRemote();

      rig.remote = [_subject("a")];
      final bool changed = await rig.dataSource.reconcileWithRemote();

      expect(changed, isTrue);
      expect(rig.local().map((s) => s.id), ["a"]);
    });

    test("keeps a subject created here that has not synced yet", () async {
      rig.remote = [_subject("a")];
      rig.seedLocal([_subject("a"), _subject("fresh")]);

      await rig.dataSource.reconcileWithRemote();

      expect(rig.local().map((s) => s.id), ["a", "fresh"]);
    });

    test("keeps everything when the backend answers with nothing", () async {
      rig.seedLocal([_subject("a"), _subject("b")]);
      rig.remote = [_subject("a"), _subject("b")];
      await rig.dataSource.reconcileWithRemote();

      rig.remote = [];
      final bool changed = await rig.dataSource.reconcileWithRemote();

      expect(changed, isFalse);
      expect(rig.local().map((s) => s.id), ["a", "b"]);
    });

    test("waits while a sync is pending", () async {
      rig.remote = [_subject("elsewhere")];
      rig.seedLocal([_subject("a")]);
      await rig.store.markPending(PendingSyncDataset.subjects);

      final bool changed = await rig.dataSource.reconcileWithRemote();

      expect(changed, isFalse);
      expect(rig.requests, isEmpty);
    });

    test("changes nothing when the backend cannot be read", () async {
      rig.failReads = true;
      rig.seedLocal([_subject("a")]);

      final bool changed = await rig.dataSource.reconcileWithRemote();

      expect(changed, isFalse);
      expect(rig.local().map((s) => s.id), ["a"]);
    });

    test("is idempotent", () async {
      rig.remote = [_subject("a"), _subject("elsewhere")];
      rig.seedLocal([_subject("a")]);
      await rig.dataSource.reconcileWithRemote();

      expect(await rig.dataSource.reconcileWithRemote(), isFalse);
    });
  });
}
