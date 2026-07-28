import "package:dartz/dartz.dart";
import "package:help_out/core/domain/entities/friend_option.dart";
import "package:help_out/core/domain/entities/group_entity.dart";
import "package:help_out/core/domain/entities/group_member_entity.dart";
import "package:help_out/core/domain/enums/group_theme_type.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/services/supabase/supabase_service.dart";
import "package:help_out/theme/group_colors.dart";

class GroupsDataSource {
  GroupsDataSource({required this._supabaseService});

  final SupabaseService _supabaseService;

  Future<Either<AppError, List<GroupEntity>>> getGroups() async {
    try {
      final String? userId = _supabaseService.currentUserId;
      if (userId == null) {
        return const Right([]);
      }

      final List<Map<String, dynamic>> currentMemberships = await _selectRows(
        table: "group_members",
        filters: (query) => query.eq("user_id", userId),
      );
      final List<String> groupIds = currentMemberships
          .map((row) => row["group_id"] as String)
          .toList();
      if (groupIds.isEmpty) {
        return const Right([]);
      }

      final List<Map<String, dynamic>> groupRows = await _selectRows(
        table: "groups",
        filters: (query) => query.inFilter("id", groupIds),
      );
      final List<Map<String, dynamic>> memberRows = await _selectRows(
        table: "group_members",
        filters: (query) => query.inFilter("group_id", groupIds),
      );
      final List<String> memberIds = memberRows
          .map((row) => row["user_id"] as String)
          .toSet()
          .toList();
      final Map<String, Map<String, dynamic>> profilesById =
          await _profilesById(memberIds);
      final List<Map<String, dynamic>> activityRows = memberIds.isEmpty
          ? []
          : await _selectRows(
              table: "activity_entries",
              filters: (query) => query
                  .inFilter("user_id", memberIds)
                  .gte("occurred_at", _monthStart().toIso8601String()),
            );

      final Map<String, List<Map<String, dynamic>>> membersByGroup = {};
      for (final Map<String, dynamic> row in memberRows) {
        final String groupId = row["group_id"] as String;
        membersByGroup.putIfAbsent(groupId, () => []).add(row);
      }

      return Right(
        groupRows.map((row) {
          final GroupThemeType theme = GroupThemeType.byName(
            row["theme"] as String?,
          );
          final String groupId = row["id"] as String;
          final List<GroupMemberEntity> members =
              membersByGroup[groupId]
                  ?.map(
                    (memberRow) => _memberFromRows(
                      memberRow: memberRow,
                      profileRow: profilesById[memberRow["user_id"]],
                      activityRows: activityRows,
                      theme: theme,
                    ),
                  )
                  .toList() ??
              [];

          return GroupEntity(
            id: groupId,
            name: row["name"] as String? ?? "",
            theme: theme,
            members: members,
            ownerId: row["owner_id"] as String? ?? "",
            createdAt: DateTime.tryParse(row["created_at"] as String? ?? ""),
            inviteCode: row["invite_code"] as String? ?? "",
            privacy: row["privacy"] as String? ?? "inviteOnly",
          );
        }).toList(),
      );
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, List<FriendOption>>> getInvitableFriends() async {
    try {
      final String? userId = _supabaseService.currentUserId;
      if (userId == null) {
        return const Right([]);
      }

      final List<Map<String, dynamic>> friendshipRows = await _selectRows(
        table: "friendships",
        filters: (query) => query
            .eq("status", "accepted")
            .or("requester_id.eq.$userId,addressee_id.eq.$userId"),
      );
      final List<String> friendIds = friendshipRows
          .map((row) {
            final String requesterId = row["requester_id"] as String;
            final String addresseeId = row["addressee_id"] as String;
            return requesterId == userId ? addresseeId : requesterId;
          })
          .toSet()
          .toList();
      final Map<String, Map<String, dynamic>> profilesById =
          await _profilesById(friendIds);

      return Right(
        friendIds
            .map(
              (id) => (
                id: id,
                name: _displayName(profilesById[id], fallback: "Friend"),
              ),
            )
            .toList(),
      );
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, GroupEntity>> createGroup({
    required String name,
    required GroupThemeType theme,
    required List<FriendOption> invitedFriends,
  }) async {
    try {
      final String? userId = _supabaseService.currentUserId;
      if (userId == null) {
        return Left(
          GenericAppError(
            error: StateError("User must be signed in to create a group."),
            stackTrace: StackTrace.current,
          ),
        );
      }

      final DateTime now = DateTime.now().toUtc();
      final Map<String, dynamic> groupRow = await _supabaseService.requireClient
          .from("groups")
          .insert({
            "owner_id": userId,
            "name": name,
            "theme": theme.name,
            "invite_code": _inviteCodeFor(now),
            "privacy": "inviteOnly",
          })
          .select()
          .single();

      final String groupId = groupRow["id"] as String;
      await _supabaseService.requireClient.from("group_members").insert([
        {"group_id": groupId, "user_id": userId, "role": "owner"},
        for (final FriendOption friend in invitedFriends)
          {"group_id": groupId, "user_id": friend.id, "role": "member"},
      ]);

      final Map<String, Map<String, dynamic>> profilesById =
          await _profilesById([
            userId,
            ...invitedFriends.map((item) => item.id),
          ]);
      final List<GroupMemberEntity> members = [
        _memberFromRows(
          memberRow: {
            "user_id": userId,
            "role": "owner",
            "joined_at": now.toIso8601String(),
          },
          profileRow: profilesById[userId],
          activityRows: const [],
          theme: theme,
        ),
        for (int index = 0; index < invitedFriends.length; index++)
          GroupMemberEntity(
            id: invitedFriends[index].id,
            name: invitedFriends[index].name,
            avatarColorValue: GroupAvatarColors.byIndex(index),
            todaySeconds: 0,
            weekSeconds: 0,
            monthSeconds: 0,
          ),
      ];

      return Right(
        GroupEntity(
          id: groupId,
          name: name,
          theme: theme,
          members: members,
          ownerId: userId,
          createdAt: DateTime.tryParse(groupRow["created_at"] as String? ?? ""),
          inviteCode: groupRow["invite_code"] as String? ?? "",
          privacy: groupRow["privacy"] as String? ?? "inviteOnly",
        ),
      );
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<List<Map<String, dynamic>>> _selectRows({
    required String table,
    required dynamic Function(dynamic query) filters,
  }) async {
    final dynamic response = await filters(
      _supabaseService.requireClient.from(table).select(),
    );
    return (response as List<dynamic>)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
  }

  Future<Map<String, Map<String, dynamic>>> _profilesById(
    List<String> ids,
  ) async {
    if (ids.isEmpty) {
      return const {};
    }
    final List<Map<String, dynamic>> profileRows = await _selectRows(
      table: "profiles",
      filters: (query) => query.inFilter("id", ids),
    );
    return {
      for (final Map<String, dynamic> row in profileRows)
        row["id"] as String: row,
    };
  }

  GroupMemberEntity _memberFromRows({
    required Map<String, dynamic> memberRow,
    required Map<String, dynamic>? profileRow,
    required List<Map<String, dynamic>> activityRows,
    required GroupThemeType theme,
  }) {
    final String userId = memberRow["user_id"] as String;
    final _PeriodScores scores = _scoresFor(
      userId: userId,
      theme: theme,
      activityRows: activityRows,
    );

    return GroupMemberEntity(
      id: userId,
      name: _displayName(profileRow, fallback: "User"),
      avatarColorValue:
          (profileRow?["accent_color_value"] as num?)?.toInt() ??
          GroupAvatarColors.byIndex(userId.hashCode.abs()),
      avatar: profileRow?["profile_photo_base64"] as String? ?? "",
      todaySeconds: scores.today,
      weekSeconds: scores.week,
      monthSeconds: scores.month,
      role: memberRow["role"] as String? ?? "member",
      joinedAt: DateTime.tryParse(memberRow["joined_at"] as String? ?? ""),
    );
  }

  _PeriodScores _scoresFor({
    required String userId,
    required GroupThemeType theme,
    required List<Map<String, dynamic>> activityRows,
  }) {
    final DateTime todayStart = _todayStart();
    final DateTime weekStart = _weekStart();
    final DateTime monthStart = _monthStart();
    int today = 0;
    int week = 0;
    int month = 0;

    for (final Map<String, dynamic> row in activityRows) {
      if (row["user_id"] != userId || row["category"] != theme.name) {
        continue;
      }
      final DateTime? occurredAt = DateTime.tryParse(
        row["occurred_at"] as String? ?? "",
      )?.toUtc();
      if (occurredAt == null || occurredAt.isBefore(monthStart)) {
        continue;
      }

      final int value = _scoreValue(row, theme);
      month += value;
      if (!occurredAt.isBefore(weekStart)) {
        week += value;
      }
      if (!occurredAt.isBefore(todayStart)) {
        today += value;
      }
    }

    return _PeriodScores(today: today, week: week, month: month);
  }

  int _scoreValue(Map<String, dynamic> row, GroupThemeType theme) =>
      switch (theme.unit) {
        GroupMetricUnit.hours => (row["seconds"] as num?)?.toInt() ?? 0,
        GroupMetricUnit.pages => (row["pages"] as num?)?.toInt() ?? 0,
        GroupMetricUnit.days => (row["completed_tasks"] as num?)?.toInt() ?? 0,
      };

  String _displayName(Map<String, dynamic>? row, {required String fallback}) {
    if (row == null) {
      return fallback;
    }
    final String nickName = row["nick_name"] as String? ?? "";
    if (nickName.trim().isNotEmpty) {
      return nickName.trim();
    }
    final String userName = row["user_name"] as String? ?? "";
    if (userName.trim().isNotEmpty) {
      return userName.trim();
    }
    return fallback;
  }

  DateTime _todayStart() {
    final DateTime now = DateTime.now().toUtc();
    return DateTime.utc(now.year, now.month, now.day);
  }

  DateTime _weekStart() {
    final DateTime today = _todayStart();
    return today.subtract(Duration(days: today.weekday - 1));
  }

  DateTime _monthStart() {
    final DateTime now = DateTime.now().toUtc();
    return DateTime.utc(now.year, now.month);
  }

  static String _inviteCodeFor(DateTime dateTime) =>
      "H${dateTime.microsecondsSinceEpoch.toRadixString(36).toUpperCase()}";
}

class _PeriodScores {
  const _PeriodScores({
    required this.today,
    required this.week,
    required this.month,
  });

  final int today;
  final int week;
  final int month;
}
