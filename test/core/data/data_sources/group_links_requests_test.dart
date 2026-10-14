import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:timing/core/data/data_sources/groups_data_source.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/services/log/app_logger_service.dart";

import "../../../support/supabase_test_harness.dart";

/// What the app sends to each group RPC, by name: a parameter the backend
/// does not declare makes PostgREST reject the whole call.
void main() {
  final Map<String, Map<String, dynamic>> calls = {};
  final Map<String, Object?> answers = {};
  late TestBackend backend;
  late GroupsDataSource dataSource;

  setUp(() {
    calls.clear();
    answers.clear();
    backend = TestBackend((http.Request request) async {
      final String path = request.url.path;
      if (path.startsWith("/rest/v1/rpc/")) {
        final String name = path.split("/").last;
        calls[name] = jsonDecode(request.body) as Map<String, dynamic>;
        return jsonResponse(request, answers[name]);
      }
      return jsonResponse(request, []);
    });
    dataSource = GroupsDataSource(
      supabaseService: TestSupabaseService(backend.client),
      logger: AppLoggerService(),
    );
  });
  tearDown(() => backend.dispose());

  final String today = DateTime.now().toIso8601String().substring(0, 10);

  test("reads the member's activities of the group's theme", () async {
    answers["group_activity_link_options"] = {
      "theme": "exercises",
      "selected_ids": ["upper"],
      "options": [
        {"id": "lower", "name": "Inferior"},
        {"id": "upper", "name": "Superior"},
      ],
    };

    final links = await dataSource.fetchActivityLinkOptions("group-1");

    expect(calls["group_activity_link_options"], {
      "target_group_id": "group-1",
    });
    expect(links.selectedIds, {"upper"});
    expect(links.options.map((option) => option.name), [
      "Inferior",
      "Superior",
    ]);
  });

  test("links activities to the group itself", () async {
    await dataSource.setActivityLinks(
      groupId: "group-1",
      sourceIds: ["upper", "lower"],
    );

    expect(calls["set_group_activity_links"], {
      "target_group_id": "group-1",
      "source_ids": ["upper", "lower"],
      "local_date": today,
    });
  });

  test("creates a group from its theme, with no activity of its own", () async {
    answers["create_group_with_members"] = [
      {
        "id": "group-1",
        "name": "Academia",
        "theme": "exercises",
        "description": "",
        "invite_code": "H1",
        "privacy": "inviteOnly",
        "created_at": "2026-10-13T00:00:00Z",
      },
    ];

    final GroupEntity group = await dataSource.createGroup(
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
      linkedSourceIds: const ["upper"],
    );

    expect(calls["create_group_with_members"], {
      "group_name": "Academia",
      "group_theme": "exercises",
      "invited_friend_ids": ["friend-1"],
      "group_description": "",
      "source_ids": ["upper"],
      "local_date": today,
    });
    expect(group.id, "group-1");
    expect(group.theme, GroupThemeType.exercises);
    expect(group.colorValue, isNull);
  });

  test("edits the group's name, description and color", () async {
    answers["update_group"] = [
      {
        "id": "group-1",
        "name": "Novo nome",
        "theme": "exercises",
        "description": "Treino",
        "color_value": 0xFFFF7A30,
      },
    ];
    const GroupEntity current = GroupEntity(
      id: "group-1",
      name: "Academia",
      theme: GroupThemeType.exercises,
      members: [],
    );

    final GroupEntity updated = await dataSource.updateGroup(
      groupId: "group-1",
      name: "Novo nome",
      description: "Treino",
      colorValue: 0xFFFF7A30,
      fallbackGroup: current,
    );

    expect(calls["update_group"], {
      "target_group_id": "group-1",
      "group_name": "Novo nome",
      "group_description": "Treino",
      "group_color_value": 0xFFFF7A30,
    });
    expect(updated.name, "Novo nome");
    expect(updated.colorValue, 0xFFFF7A30);
  });
}
