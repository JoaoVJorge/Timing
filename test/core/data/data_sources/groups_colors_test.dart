import "package:flutter_test/flutter_test.dart";
import "package:timing/core/data/data_sources/groups_data_source.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";

import "../../../support/supabase_test_harness.dart";

void main() {
  test(
    "loads group colors before opening details and restores them from cache",
    () async {
      var appearanceRequests = 0;
      final backend = TestBackend((request) async {
        final table = request.url.path.split('/').last;
        if (table == 'group_members') {
          return jsonResponse(request, [
            {'group_id': 'one', 'user_id': 'user-1', 'role': 'owner'},
            {'group_id': 'two', 'user_id': 'user-1', 'role': 'owner'},
          ]);
        }
        if (table == 'groups') {
          return jsonResponse(request, [
            {'id': 'one', 'name': 'One', 'theme': 'studying'},
            {'id': 'two', 'name': 'Two', 'theme': 'studying'},
          ]);
        }
        if (table == 'group_activities') {
          appearanceRequests++;
          expect(
            request.url.queryParameters['order'],
            startsWith('created_at.asc'),
          );
          return jsonResponse(request, [
            {
              'group_id': 'one',
              'payload': {'color_value': 0xFF2E6ADE},
            },
            {
              'group_id': 'one',
              'payload': {'color_value': 0xFFFF7A30},
            },
            {
              'group_id': 'two',
              'payload': {'color_value': 0xFF8325FF},
            },
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
      expect(groups.map((group) => group.colorValue), [0xFF2E6ADE, 0xFF8325FF]);
      expect(appearanceRequests, 1);

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
}
