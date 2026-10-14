import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:timing/core/data/data_sources/groups_data_source.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";

import "../../../support/supabase_test_harness.dart";

void main() {
  test("uses the color returned when creating a linked group", () async {
    Map<String, dynamic>? createPayload;
    final backend = TestBackend((request) async {
      if (request.url.path.endsWith("/rpc/create_group_with_members")) {
        createPayload = jsonDecode(request.body) as Map<String, dynamic>;
        return jsonResponse(request, [
          {
            "id": "group-1",
            "name": "Academia",
            "theme": "exercises",
            "description": "",
            "invite_code": "H1",
            "privacy": "inviteOnly",
            "created_at": "2026-10-13T00:00:00Z",
            "color_value": 0xFF2196F3,
          },
        ]);
      }
      return jsonResponse(request, []);
    });
    addTearDown(backend.dispose);
    final source = GroupsDataSource(
      supabaseService: TestSupabaseService(backend.client),
      logger: AppLoggerService(),
    );

    final group = await source.createGroup(
      userId: "user-1",
      name: "Academia",
      theme: GroupThemeType.exercises,
      invitedFriends: const [
        (
          id: "friend-1",
          name: "Ana",
          colorValue: 1,
          avatarIconIndex: null,
          profilePhotoBase64: "",
        ),
      ],
      linkedSourceIds: const ["upper", "lower"],
    );

    expect(createPayload?["source_ids"], ["upper", "lower"]);
    expect(group.colorValue, 0xFF2196F3);
  });

  test(
    "loads each group's own color with the list and restores it from cache",
    () async {
      final backend = TestBackend((request) async {
        final table = request.url.path.split('/').last;
        if (table == 'group_members') {
          return jsonResponse(request, [
            {'group_id': 'one', 'user_id': 'user-1', 'role': 'owner'},
            {'group_id': 'two', 'user_id': 'user-1', 'role': 'owner'},
            {'group_id': 'plain', 'user_id': 'user-1', 'role': 'owner'},
          ]);
        }
        if (table == 'groups') {
          expect(
            request.url.queryParameters['select'],
            contains('color_value'),
          );
          return jsonResponse(request, [
            {
              'id': 'one',
              'name': 'One',
              'theme': 'studying',
              'color_value': 0xFF2E6ADE,
            },
            {
              'id': 'two',
              'name': 'Two',
              'theme': 'studying',
              'color_value': 0xFF8325FF,
            },
            // No color of its own: it follows the viewer's accent.
            {'id': 'plain', 'name': 'Plain', 'theme': 'reading'},
          ]);
        }
        return jsonResponse(request, []);
      });
      addTearDown(backend.dispose);
      final storage = MemoryStorage();
      GroupsRepository source() => GroupsRepository(
        groupsDataSource: GroupsDataSource(
          supabaseService: TestSupabaseService(backend.client),
          logger: AppLoggerService(),
        ),
        logger: AppLoggerService(),
        localStorageService: storage,
        pendingSyncStore: PendingSyncStore(localStorageService: storage),
      );

      final result = await source().getGroups();
      final groups = result.fold((error) => fail('$error'), (value) => value);
      expect(groups.map((group) => group.colorValue), [
        0xFF2E6ADE,
        0xFF8325FF,
        null,
      ]);

      // A fresh data source has no in-memory color state, as after an app restart.
      final cached = await source().getCachedGroups();
      expect(cached.fold((error) => fail('$error'), (value) => value), groups);
      expect(groups.first.copyWithMembers([]).colorValue, 0xFF2E6ADE);
    },
  );

  test('old cached groups without a color remain readable', () {
    const group = GroupEntity(
      id: 'old',
      name: 'Old',
      theme: GroupThemeType.studying,
      members: [],
    );
    final legacy = group.toMap()..remove('colorValue');
    expect(GroupEntity.fromMap(legacy).colorValue, isNull);
  });

  test('loads groups while an older backend has no color column', () async {
    var groupRequests = 0;
    final backend = TestBackend((request) async {
      final table = request.url.path.split('/').last;
      if (table == 'group_members') {
        return jsonResponse(request, [
          {'group_id': 'legacy', 'user_id': 'user-1', 'role': 'owner'},
        ]);
      }
      if (table == 'groups') {
        groupRequests++;
        final String selected = request.url.queryParameters['select'] ?? '';
        if (selected.contains('color_value')) {
          return jsonResponse(request, {
            'code': '42703',
            'message': 'column groups.color_value does not exist',
            'details': null,
            'hint': null,
          }, 400);
        }
        return jsonResponse(request, [
          {'id': 'legacy', 'name': 'Legacy', 'theme': 'studying'},
        ]);
      }
      return jsonResponse(request, []);
    });
    addTearDown(backend.dispose);
    final source = GroupsDataSource(
      supabaseService: TestSupabaseService(backend.client),
      logger: AppLoggerService(),
    );

    final groups = await source.fetchGroups('user-1');

    expect(groupRequests, 2);
    expect(groups, hasLength(1));
    expect(groups.single.name, 'Legacy');
    expect(groups.single.colorValue, isNull);
  });
}
