import "dart:async";

import "package:timing/core/domain/entities/friend_entity.dart";
import "package:timing/core/domain/entities/friend_presence_entity.dart";
import "package:timing/core/domain/entities/friend_suggestion_entity.dart";
import "package:timing/core/domain/entities/friends_social_entity.dart";
import "package:timing/core/services/log/app_logger_service.dart";
import "package:timing/core/services/supabase/supabase_service.dart";
import "package:timing/core/utils/profile_display_name.dart";
import "package:timing/theme/group_colors.dart";

/// The friendship tables and RPCs on the backend. Every call goes straight to
/// Supabase and throws whatever it fails with: caching, queueing for a retry
/// and turning the failure into an `AppError` belong to `FriendsRepository`.
class FriendsDataSource {
  FriendsDataSource({required this._supabaseService, required this._logger});

  final SupabaseService _supabaseService;
  final AppLoggerService _logger;
  // A remote call must fail fast on a "connected but no real internet"
  // network so its caller can queue the write for retry or surface the
  // offline notice, instead of hanging on the platform's own (much longer)
  // socket timeout.
  static const Duration _remoteCallTimeout = Duration(seconds: 10);

  String? get currentUserId => _supabaseService.currentUserId;

  Future<List<FriendPresenceEntity>> fetchPresences(
    List<String> friendIds,
  ) async {
    final List<Map<String, dynamic>> rows = await _selectRows(
      table: "profile_presence_status",
      columns: "id, is_online, last_seen_at",
      filters: (query) => query.inFilter("id", friendIds),
    );
    return rows
        .map(
          (row) => FriendPresenceEntity(
            id: row["id"] as String,
            isOnline: row["is_online"] as bool? ?? false,
            lastSeenAt: DateTime.tryParse(row["last_seen_at"] as String? ?? ""),
          ),
        )
        .toList();
  }

  Future<FriendsSocialEntity> fetchSocial(String userId) async {
    final Map<String, dynamic>? profileRow = await _supabaseService
        .requireClient
        .from("profiles")
        .select("friend_code")
        .eq("id", userId)
        .maybeSingle();
    _logger.logResponse("select public.profiles (friend_code)", profileRow);
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
    final Map<String, Map<String, dynamic>> profilesById = await _profilesById(
      profileIds.toList(),
    );

    return FriendsSocialEntity(
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
    );
  }

  Future<void> sendFriendRequest({
    required String userId,
    required String addresseeId,
  }) async {
    await _supabaseService.requireClient
        .from("friendships")
        .insert({
          "requester_id": userId,
          "addressee_id": addresseeId,
          "status": "pending",
        })
        .timeout(_remoteCallTimeout);
  }

  Future<void> acceptRequest(String friendshipId) async {
    await _supabaseService.requireClient
        .from("friendships")
        .update({"status": "accepted"})
        .eq("id", friendshipId)
        .timeout(_remoteCallTimeout);
  }

  Future<void> declineRequest(String friendshipId) async {
    await _supabaseService.requireClient
        .from("friendships")
        .delete()
        .eq("id", friendshipId)
        .timeout(_remoteCallTimeout);
  }

  /// Without a [friendshipId] the pending request is found by its two ends,
  /// which needs the signed-in [userId].
  Future<void> cancelSentRequest({
    required String? userId,
    required String addresseeId,
    required String friendshipId,
  }) async {
    if (friendshipId.isNotEmpty) {
      await _supabaseService.requireClient
          .from("friendships")
          .delete()
          .eq("id", friendshipId)
          .timeout(_remoteCallTimeout);
      return;
    }
    await _supabaseService.requireClient
        .from("friendships")
        .delete()
        .eq("requester_id", userId!)
        .eq("addressee_id", addresseeId)
        .eq("status", "pending")
        .timeout(_remoteCallTimeout);
  }

  /// Without a [friendshipId] the friendship is found by its two ends, which
  /// needs the signed-in [userId].
  Future<void> removeFriend({
    required String? userId,
    required String friendId,
    required String friendshipId,
  }) async {
    if (friendshipId.isNotEmpty) {
      await _supabaseService.requireClient
          .from("friendships")
          .delete()
          .eq("id", friendshipId)
          .timeout(_remoteCallTimeout);
      return;
    }
    await _supabaseService.requireClient
        .from("friendships")
        .delete()
        .eq("status", "accepted")
        .or(
          "and(requester_id.eq.$userId,addressee_id.eq.$friendId),"
          "and(requester_id.eq.$friendId,addressee_id.eq.$userId)",
        )
        .timeout(_remoteCallTimeout);
  }

  Future<FriendSuggestionEntity?> findByCode(String code) async {
    final String lookupCode = _normalizeLookupCode(code);
    if (lookupCode.isEmpty) {
      return null;
    }
    final dynamic response = await _supabaseService.requireClient
        .rpc("find_profile_by_friend_code", params: {"lookup_code": lookupCode})
        .timeout(_remoteCallTimeout);
    _logger.logResponse("rpc public.find_profile_by_friend_code", response);
    final List<dynamic> rows = response as List<dynamic>;
    if (rows.isEmpty) {
      return null;
    }
    return _suggestionFromRow(Map<String, dynamic>.from(rows.first as Map));
  }

  Future<List<Map<String, dynamic>>> _selectRows({
    required String table,
    String columns = "*",
    required dynamic Function(dynamic query) filters,
  }) async {
    final dynamic query = filters(
      _supabaseService.requireClient.from(table).select(columns),
    );
    final dynamic response = await query.timeout(_remoteCallTimeout);
    _logger.logResponse("select public.$table", response);
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
    name: profileDisplayName(profileRow, fallback: "Timing User"),
    handle: _handleFor(userId, profileRow),
    colorValue: _colorFor(userId, profileRow),
    avatarIconIndex: (profileRow?["avatar_icon_index"] as num?)?.toInt(),
    profilePhotoBase64: (profileRow?["profile_photo_base64"] as String? ?? "")
        .trim(),
    isOnline: profileRow?["is_online"] as bool? ?? false,
    lastSeenAt: DateTime.tryParse(profileRow?["last_seen_at"] as String? ?? ""),
  );

  FriendSuggestionEntity _suggestionFromRow(Map<String, dynamic> row) {
    final String id = row["id"] as String;
    return FriendSuggestionEntity(
      id: id,
      name: profileDisplayName(row, fallback: "Timing User"),
      handle: _handleFor(id, row),
      colorValue: _colorFor(id, row),
      avatarIconIndex: (row["avatar_icon_index"] as num?)?.toInt(),
      profilePhotoBase64: (row["profile_photo_base64"] as String? ?? "").trim(),
    );
  }

  String _handleFor(String userId, Map<String, dynamic>? row) {
    final String code =
        row?["friend_code"] as String? ?? userId.substring(0, 8);
    return "@${code.toLowerCase()}";
  }

  int _colorFor(String userId, Map<String, dynamic>? row) =>
      (row?["accent_color_value"] as num?)?.toInt() ??
      GroupAvatarColors.byIndex(userId.hashCode);

  String _normalizeLookupCode(String code) =>
      _withoutDiacritics(code.trim().replaceAll("@", "").toLowerCase());

  String _withoutDiacritics(String value) {
    const Map<String, String> replacements = {
      "á": "a",
      "à": "a",
      "ã": "a",
      "â": "a",
      "ä": "a",
      "å": "a",
      "ā": "a",
      "ă": "a",
      "ą": "a",
      "ç": "c",
      "ć": "c",
      "č": "c",
      "ď": "d",
      "é": "e",
      "è": "e",
      "ê": "e",
      "ë": "e",
      "ē": "e",
      "ė": "e",
      "ę": "e",
      "í": "i",
      "ì": "i",
      "î": "i",
      "ï": "i",
      "ī": "i",
      "ł": "l",
      "ñ": "n",
      "ń": "n",
      "ó": "o",
      "ò": "o",
      "õ": "o",
      "ô": "o",
      "ö": "o",
      "ø": "o",
      "ō": "o",
      "ř": "r",
      "ś": "s",
      "š": "s",
      "ß": "ss",
      "ť": "t",
      "ú": "u",
      "ù": "u",
      "û": "u",
      "ü": "u",
      "ū": "u",
      "ý": "y",
      "ÿ": "y",
      "ž": "z",
      "ź": "z",
      "ż": "z",
    };

    final StringBuffer buffer = StringBuffer();
    for (final int codePoint in value.runes) {
      final String character = String.fromCharCode(codePoint);
      buffer.write(replacements[character] ?? character);
    }
    return buffer.toString();
  }
}
