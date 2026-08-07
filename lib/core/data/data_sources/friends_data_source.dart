import "package:dartz/dartz.dart";
import "package:help_out/core/domain/entities/friend_entity.dart";
import "package:help_out/core/domain/entities/friend_suggestion_entity.dart";
import "package:help_out/core/domain/entities/friends_social_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/services/supabase/supabase_service.dart";
import "package:help_out/theme/group_colors.dart";

class FriendsDataSource {
  FriendsDataSource({required this._supabaseService});

  final SupabaseService _supabaseService;

  Future<Either<AppError, FriendsSocialEntity>> getSocial() async {
    try {
      final String? userId = _supabaseService.currentUserId;
      if (userId == null) {
        return const Right(FriendsSocialEntity.empty());
      }

      final Map<String, dynamic>? profileRow = await _supabaseService
          .requireClient
          .from("profiles")
          .select("friend_code")
          .eq("id", userId)
          .maybeSingle();
      final List<Map<String, dynamic>> incomingRows = await _selectRows(
        table: "friendships",
        filters: (query) =>
            query.eq("addressee_id", userId).eq("status", "pending"),
      );
      final List<Map<String, dynamic>> outgoingRows = await _selectRows(
        table: "friendships",
        filters: (query) =>
            query.eq("requester_id", userId).eq("status", "pending"),
      );
      final List<Map<String, dynamic>> friendRows = await _selectRows(
        table: "friendships",
        filters: (query) => query
            .eq("status", "accepted")
            .or("requester_id.eq.$userId,addressee_id.eq.$userId"),
      );
      final Set<String> profileIds = {
        for (final Map<String, dynamic> row in incomingRows)
          row["requester_id"] as String,
        for (final Map<String, dynamic> row in outgoingRows)
          row["addressee_id"] as String,
        for (final Map<String, dynamic> row in friendRows)
          row["requester_id"] == userId
              ? row["addressee_id"] as String
              : row["requester_id"] as String,
      };
      final Map<String, Map<String, dynamic>> profilesById =
          await _profilesById(profileIds.toList());

      return Right(
        FriendsSocialEntity(
          inviteCode:
              profileRow?["friend_code"] as String? ??
              userId.substring(0, 8).toUpperCase(),
          requests: incomingRows.map((row) {
            final String requesterId = row["requester_id"] as String;
            return _friendFromRow(
              userId: requesterId,
              friendshipId: row["id"] as String,
              profileRow: profilesById[requesterId],
            );
          }).toList(),
          sentRequests: outgoingRows.map((row) {
            final String addresseeId = row["addressee_id"] as String;
            return _friendFromRow(
              userId: addresseeId,
              friendshipId: row["id"] as String,
              profileRow: profilesById[addresseeId],
            );
          }).toList(),
          friends: friendRows.map((row) {
            final String friendId = row["requester_id"] == userId
                ? row["addressee_id"] as String
                : row["requester_id"] as String;
            return _friendFromRow(
              userId: friendId,
              friendshipId: row["id"] as String,
              profileRow: profilesById[friendId],
            );
          }).toList(),
        ),
      );
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, void>> sendFriendRequest(String addresseeId) async {
    try {
      final String? userId = _supabaseService.currentUserId;
      if (userId == null) {
        return _signedOut("send a friend request");
      }
      await _supabaseService.requireClient.from("friendships").insert({
        "requester_id": userId,
        "addressee_id": addresseeId,
        "status": "pending",
      });
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, void>> acceptRequest(String friendshipId) async {
    try {
      await _supabaseService.requireClient
          .from("friendships")
          .update({"status": "accepted"})
          .eq("id", friendshipId);
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, void>> declineRequest(String friendshipId) async {
    try {
      await _supabaseService.requireClient
          .from("friendships")
          .delete()
          .eq("id", friendshipId);
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, void>> cancelSentRequest({
    required String addresseeId,
    String friendshipId = "",
  }) async {
    try {
      if (friendshipId.isNotEmpty) {
        await _supabaseService.requireClient
            .from("friendships")
            .delete()
            .eq("id", friendshipId);
        return const Right(null);
      }
      final String? userId = _supabaseService.currentUserId;
      if (userId == null) {
        return _signedOut("cancel a friend request");
      }
      await _supabaseService.requireClient
          .from("friendships")
          .delete()
          .eq("requester_id", userId)
          .eq("addressee_id", addresseeId)
          .eq("status", "pending");
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, void>> removeFriend({
    required String friendId,
    String friendshipId = "",
  }) async {
    try {
      if (friendshipId.isNotEmpty) {
        await _supabaseService.requireClient
            .from("friendships")
            .delete()
            .eq("id", friendshipId);
        return const Right(null);
      }
      final String? userId = _supabaseService.currentUserId;
      if (userId == null) {
        return _signedOut("remove a friend");
      }
      await _supabaseService.requireClient
          .from("friendships")
          .delete()
          .eq("status", "accepted")
          .or(
            "and(requester_id.eq.$userId,addressee_id.eq.$friendId),"
            "and(requester_id.eq.$friendId,addressee_id.eq.$userId)",
          );
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Future<Either<AppError, FriendSuggestionEntity?>> findByCode(
    String code,
  ) async {
    try {
      final String lookupCode = code.trim().replaceAll("@", "");
      if (lookupCode.isEmpty) {
        return const Right(null);
      }
      final dynamic response = await _supabaseService.requireClient.rpc(
        "find_profile_by_friend_code",
        params: {"lookup_code": lookupCode},
      );
      final List<dynamic> rows = response as List<dynamic>;
      if (rows.isEmpty) {
        return const Right(null);
      }
      return Right(
        _suggestionFromRow(Map<String, dynamic>.from(rows.first as Map)),
      );
    } catch (error, stackTrace) {
      return Left(GenericAppError(error: error, stackTrace: stackTrace));
    }
  }

  Left<AppError, T> _signedOut<T>(String action) => Left(
    GenericAppError(
      error: StateError("User must be signed in to $action."),
      stackTrace: StackTrace.current,
    ),
  );

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
    final List<Map<String, dynamic>> rows = await _selectRows(
      table: "profiles",
      filters: (query) => query.inFilter("id", ids),
    );
    return {
      for (final Map<String, dynamic> row in rows) row["id"] as String: row,
    };
  }

  FriendEntity _friendFromRow({
    required String userId,
    required String friendshipId,
    required Map<String, dynamic>? profileRow,
  }) => FriendEntity(
    id: userId,
    friendshipId: friendshipId,
    name: _displayName(profileRow),
    handle: _handleFor(userId, profileRow),
    colorValue: _colorFor(userId, profileRow),
  );

  FriendSuggestionEntity _suggestionFromRow(Map<String, dynamic> row) {
    final String id = row["id"] as String;
    return FriendSuggestionEntity(
      id: id,
      name: _displayName(row),
      handle: _handleFor(id, row),
      colorValue: _colorFor(id, row),
    );
  }

  String _displayName(Map<String, dynamic>? row) {
    final String userName = (row?["user_name"] as String? ?? "").trim();
    if (userName.isNotEmpty) {
      return userName;
    }
    final String nickName = (row?["nick_name"] as String? ?? "").trim();
    if (nickName.isNotEmpty) {
      return nickName;
    }
    return "HelpOut User";
  }

  String _handleFor(String userId, Map<String, dynamic>? row) {
    final String code =
        row?["friend_code"] as String? ?? userId.substring(0, 8);
    return "@${code.toLowerCase()}";
  }

  int _colorFor(String userId, Map<String, dynamic>? row) =>
      (row?["accent_color_value"] as num?)?.toInt() ??
      GroupAvatarColors.byIndex(userId.hashCode);
}
