import "dart:async";

import "package:timing/app/app_constants.dart";

/// Opens the join screen when the app is started or resumed by a group's
/// link (`com.moonstone.timing://join-group?code=ABC123`).
///
/// A link that arrives before anyone is signed in is held, not dropped, so it
/// still opens once the user is in. The code only ever asks the group's
/// leader to let the user in, so following a link is not an irreversible act.
class GroupLinkService {
  GroupLinkService({
    required Stream<Uri> links,
    required Future<void> Function(String inviteCode) openJoinScreen,
    required bool Function() isSignedIn,
  }) : _links = links,
       _openJoinScreen = openJoinScreen,
       _isSignedIn = isSignedIn;

  // ignore_for_file: prefer_initializing_formals

  final Stream<Uri> _links;
  final Future<void> Function(String inviteCode) _openJoinScreen;
  final bool Function() _isSignedIn;

  StreamSubscription<Uri>? _subscription;
  String? _pendingCode;

  void start() {
    _subscription ??= _links.listen(handleLink);
  }

  /// The code in [uri] when it is a group link, otherwise null. Other deep
  /// links (sign-in and calendar callbacks) belong to their own listeners.
  static String? inviteCodeIn(Uri uri) {
    if (uri.scheme.toLowerCase() != AppConstants.deepLinkScheme ||
        uri.host.toLowerCase() != AppConstants.joinGroupLinkHost) {
      return null;
    }
    final String code = (uri.queryParameters["code"] ?? "").trim();
    return code.isEmpty ? null : code.toUpperCase();
  }

  void handleLink(Uri uri) {
    final String? code = inviteCodeIn(uri);
    if (code == null) {
      return;
    }
    if (!_isSignedIn()) {
      _pendingCode = code;
      return;
    }
    unawaited(_openJoinScreen(code));
  }

  /// Follows a link that arrived while signed out, once the user is in.
  Future<void> flushPendingLink() async {
    final String? code = _pendingCode;
    if (code == null || !_isSignedIn()) {
      return;
    }
    _pendingCode = null;
    await _openJoinScreen(code);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
