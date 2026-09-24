import "dart:convert";

import "package:dartz/dartz.dart";
import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:timing/app/app_navigator.dart";
import "package:timing/core/data/data_sources/daily_tasks_data_source.dart";
import "package:timing/core/data/data_sources/groups_data_source.dart";
import "package:timing/core/data/repositories/daily_tasks_repository.dart";
import "package:timing/core/data/repositories/friends_repository.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/domain/entities/daily_task_entity.dart";
import "package:timing/core/domain/entities/friends_social_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/accept_friend_request_use_case.dart";
import "package:timing/core/domain/use_cases/cancel_friend_request_use_case.dart";
import "package:timing/core/domain/use_cases/get_friends_social_use_case.dart";
import "package:timing/core/domain/use_cases/get_groups_use_case.dart";
import "package:timing/core/domain/use_cases/remove_friend_use_case.dart";
import "package:timing/core/domain/use_cases/send_friend_request_use_case.dart";
import "package:timing/core/domain/use_cases/toggle_daily_task_check_use_case.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/sync/activity_change_bus.dart";
import "package:timing/core/services/sync/pending_sync_store.dart";
import "package:timing/presentation/groups/groups_controller.dart";

import "../../support/supabase_test_harness.dart";

class _Friends implements FriendsRepository {
  @override
  Future<Either<AppError, FriendsSocialEntity>> getSocial() async =>
      const Right(FriendsSocialEntity.empty());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Navigator implements AppNavigator {
  @override
  void showErrorSnackBar([String? text]) {}

  @override
  void showSuccessSnackBar(String text) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const DailyTaskEntity _groupGoal = DailyTaskEntity(
  id: "grp_ga1",
  name: "Meta do grupo",
  colorValue: 1,
  targetDays: 10,
  completedDates: [],
  groupId: "g1",
  groupActivityId: "ga1",
);

Future<http.Response> _backend(http.Request request) async {
  final String path = request.url.path;
  if (path == "/rest/v1/daily_goals") {
    return request.method == "GET"
        ? jsonResponse(request, [
            {
              ..._groupGoal.toMap(),
              "id": "grp_ga1",
              "user_id": "user-1",
              "color_value": 1,
              "target_days": 10,
              "completed_dates": [],
              "goal_type": "total",
              "sequence_type": "casual",
              "group_id": "g1",
              "group_activity_id": "ga1",
              "updated_at": "2026-09-20T00:00:00Z",
            },
          ])
        : http.Response("", 201, request: request);
  }
  if (path == "/rest/v1/group_members") {
    return jsonResponse(
      request,
      request.url.query.contains("user_id=eq")
          ? [
              {"group_id": "g1"},
            ]
          : [
              {
                "group_id": "g1",
                "user_id": "user-1",
                "role": "owner",
                "joined_at": "2026-09-01T00:00:00Z",
              },
            ],
    );
  }
  if (path == "/rest/v1/groups") {
    return jsonResponse(request, [
      {
        "id": "g1",
        "name": "Grupo",
        "theme": "dailyGoals",
        "description": "",
        "owner_id": "user-1",
        "created_at": "2026-09-01T00:00:00Z",
        "invite_code": "H1",
        "privacy": "inviteOnly",
      },
    ]);
  }
  if (path == "/rest/v1/profiles") {
    return jsonResponse(request, [
      {
        "id": "user-1",
        "nick_name": "",
        "user_name": "Eu",
        "accent_color_value": 1,
        "avatar_icon_index": 0,
        "profile_photo_base64": "FOTO",
      },
    ]);
  }
  return jsonResponse(request, []);
}

void main() {
  test(
    "completing a group goal makes the fewest requests that keep the group current",
    () async {
      final List<String> requests = [];
      final backend = TestBackend((request) {
        requests.add(
          "${request.method} ${request.url.path.replaceFirst("/rest/v1/", "")}",
        );
        return _backend(request);
      });
      addTearDown(backend.dispose);

      final storage = MemoryStorage()
        ..data[LocalStorageKeys.dailyTasks] = jsonEncode([_groupGoal.toMap()]);
      final store = PendingSyncStore(localStorageService: storage);
      final bus = ActivityChangeBus();
      addTearDown(bus.dispose);
      final service = TestSupabaseService(backend.client);
      final tasksDataSource = DailyTasksDataSource(
        localStorageService: storage,
        supabaseService: service,
        logger: AppLoggerService(),
        pendingSyncStore: store,
        activityChangeBus: bus,
      );
      final groupsRepository = GroupsRepository(
        groupsDataSource: GroupsDataSource(
          supabaseService: service,
          logger: AppLoggerService(),
          localStorageService: storage,
          pendingSyncStore: store,
          activityChangeBus: bus,
        ),
      );
      final friends = _Friends();
      final controller = GroupsController(
        getGroupsUseCase: GetGroupsUseCase(groupsRepository: groupsRepository),
        getFriendsSocialUseCase: GetFriendsSocialUseCase(
          friendsRepository: friends,
        ),
        sendFriendRequestUseCase: SendFriendRequestUseCase(
          friendsRepository: friends,
        ),
        cancelFriendRequestUseCase: CancelFriendRequestUseCase(
          friendsRepository: friends,
        ),
        acceptFriendRequestUseCase: AcceptFriendRequestUseCase(
          friendsRepository: friends,
        ),
        removeFriendUseCase: RemoveFriendUseCase(friendsRepository: friends),
        groupsRepository: groupsRepository,
        dailyTasksRepository: DailyTasksRepository(
          dailyTasksDataSource: tasksDataSource,
        ),
        appNavigator: _Navigator(),
        supabaseService: service,
        localStorageService: storage,
        activityChangeBus: bus,
      );
      addTearDown(controller.onClose);
      controller.onInit();
      await Future<void>.delayed(const Duration(milliseconds: 200));

      final toggle = ToggleDailyTaskCheckUseCase(
        dailyTasksRepository: DailyTasksRepository(
          dailyTasksDataSource: tasksDataSource,
        ),
      );

      Future<List<String>> complete(DateTime day) async {
        requests.clear();
        await toggle(taskId: "grp_ga1", date: day);
        // DailyGoalsController announces the change as soon as the save returns.
        bus.notifyGroupActivityChanged(groupId: "g1");
        // The groups screen waits for the burst to settle before refreshing.
        await Future<void>.delayed(const Duration(milliseconds: 3500));
        return List.of(requests);
      }

      // First completion of the session: the goals are read once before being
      // changed, so the upload can never delete what another phone added.
      expect(await complete(DateTime(2026, 9, 24)), [
        "GET daily_goals",
        "POST daily_goals",
        "POST rpc/group_leaderboard_scores",
      ]);

      // Every later one: the upload and the ranking, nothing else.
      expect(await complete(DateTime(2026, 9, 25)), [
        "POST daily_goals",
        "POST rpc/group_leaderboard_scores",
      ]);
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
