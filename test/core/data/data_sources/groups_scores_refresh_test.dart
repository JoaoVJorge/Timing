import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:timing/core/data/data_sources/groups_data_source.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/entities/group_member_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";

import "../../../support/supabase_test_harness.dart";

GroupMemberEntity _member(String id, {int today = 0, int total = 0}) =>
    GroupMemberEntity(
      id: id,
      name: "Membro $id",
      avatarColorValue: 1,
      todaySeconds: today,
      weekSeconds: 0,
      monthSeconds: 0,
      totalSeconds: total,
      avatar: "foto-$id",
      role: id == "me" ? "owner" : "member",
    );

GroupEntity _group() => GroupEntity(
  id: "g1",
  name: "Grupo",
  theme: GroupThemeType.dailyGoals,
  members: [_member("me"), _member("other", total: 9)],
  ownerId: "me",
  inviteCode: "H1",
);

void main() {
  late List<String> requests;
  late MemoryStorage storage;

  GroupsDataSource build(Future<http.Response> Function(http.Request) handler) {
    final backend = TestBackend((request) {
      requests.add("${request.method} ${request.url.path}");
      return handler(request);
    });
    addTearDown(backend.dispose);
    return GroupsDataSource(
      supabaseService: TestSupabaseService(backend.client),
      logger: AppLoggerService(),
      localStorageService: storage,
      pendingSyncStore: PendingSyncStore(localStorageService: storage),
    );
  }

  setUp(() {
    requests = [];
    storage = MemoryStorage();
  });

  test("re-reads only the leaderboard, in a single request", () async {
    final dataSource = build(
      (request) async => jsonResponse(request, [
        {
          "group_id": "g1",
          "user_id": "me",
          "today_score": 1,
          "week_score": 3,
          "month_score": 5,
          "total_score": 8,
        },
      ]),
    );

    final result = await dataSource.refreshGroupScores([_group()]);

    expect(requests, ["POST /rest/v1/rpc/group_leaderboard_scores"]);
    final groups = result.fold((_) => fail("expected Right"), (g) => g);
    final me = groups.single.members.firstWhere((m) => m.id == "me");
    expect(me.todaySeconds, 1);
    expect(me.weekSeconds, 3);
    expect(me.monthSeconds, 5);
    expect(me.totalSeconds, 8);
  });

  test("keeps everything that is not a score", () async {
    final dataSource = build(
      (request) async => jsonResponse(request, [
        {"group_id": "g1", "user_id": "me", "total_score": 8},
      ]),
    );

    final result = await dataSource.refreshGroupScores([_group()]);

    final group = result.fold((_) => fail("expected Right"), (g) => g.single);
    expect(group.name, "Grupo");
    expect(group.ownerId, "me");
    final me = group.members.firstWhere((m) => m.id == "me");
    expect(me.avatar, "foto-me");
    expect(me.role, "owner");
  });

  test("a member absent from the answer goes back to zero", () async {
    final dataSource = build((request) async => jsonResponse(request, []));

    final result = await dataSource.refreshGroupScores([_group()]);

    final group = result.fold((_) => fail("expected Right"), (g) => g.single);
    expect(group.members.firstWhere((m) => m.id == "other").totalSeconds, 0);
  });

  test("saves the refreshed scores for the offline view", () async {
    final dataSource = build(
      (request) async => jsonResponse(request, [
        {"group_id": "g1", "user_id": "me", "total_score": 8},
      ]),
    );

    await dataSource.refreshGroupScores([_group()]);

    expect(
      storage.data[LocalStorageKeys.cachedGroups],
      contains('"totalSeconds":8'),
    );
  });

  test("a failed read is reported, not turned into zeros", () async {
    final dataSource = build(
      (request) async => jsonResponse(request, {"message": "down"}, 503),
    );

    final result = await dataSource.refreshGroupScores([_group()]);

    expect(result.isLeft(), isTrue);
    expect(storage.data[LocalStorageKeys.cachedGroups], isNull);
  });
}
