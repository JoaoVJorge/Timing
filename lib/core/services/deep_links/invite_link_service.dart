import "dart:async";

import "package:timing/core/services/deep_links/invite_code.dart";

/// Opens the screen an invite link is for when the app is started or resumed
/// by one: a group's link (`com.moonstone.timing://join-group?code=ABC123`)
/// opens the join screen, a friend's (`…://add-friend?code=ABC123`) the
/// add-friend screen, each with the code already filled in.
///
/// A link that arrives before anyone is signed in is held, not dropped, so it
/// still opens once the user is in. Neither screen acts on its own: a group
/// code only asks the leader to let the user in and a friend code only finds
/// the profile, so following a link is not an irreversible act.
class InviteLinkService {
  InviteLinkService({
    required Stream<Uri> links,
    required Future<void> Function(String inviteCode) openJoinGroupScreen,
    required Future<void> Function(String friendCode) openAddFriendScreen,
    required bool Function() isSignedIn,
  }) : _links = links,
       _openJoinGroupScreen = openJoinGroupScreen,
       _openAddFriendScreen = openAddFriendScreen,
       _isSignedIn = isSignedIn;

  // ignore_for_file: prefer_initializing_formals

  final Stream<Uri> _links;
  final Future<void> Function(String inviteCode) _openJoinGroupScreen;
  final Future<void> Function(String friendCode) _openAddFriendScreen;
  final bool Function() _isSignedIn;

  StreamSubscription<Uri>? _subscription;
  Future<void> Function()? _pendingLink;

  void start() {
    _subscription ??= _links.listen(handleLink);
  }

  /// Other deep links (sign-in and calendar callbacks) belong to their own
  /// listeners and are ignored here.
  void handleLink(Uri uri) {
    final Future<void> Function()? open = _opener(uri);
    if (open == null) {
      return;
    }
    if (!_isSignedIn()) {
      _pendingLink = open;
      return;
    }
    unawaited(open());
  }

  Future<void> Function()? _opener(Uri uri) {
    final String? inviteCode = InviteCodeKind.group.codeInLink(uri);
    if (inviteCode != null) {
      return () => _openJoinGroupScreen(inviteCode);
    }
    final String? friendCode = InviteCodeKind.friend.codeInLink(uri);
    if (friendCode != null) {
      return () => _openAddFriendScreen(friendCode);
    }
    return null;
  }

  /// Follows a link that arrived while signed out, once the user is in.
  Future<void> flushPendingLink() async {
    final Future<void> Function()? open = _pendingLink;
    if (open == null || !_isSignedIn()) {
      return;
    }
    _pendingLink = null;
    await open();
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
