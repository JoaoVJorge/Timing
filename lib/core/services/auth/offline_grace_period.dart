/// Pure policy for how long a device may keep using a cached, signed-in
/// session without the app ever successfully reaching the backend.
///
/// Extracted from [AppController] so it's testable without standing up the
/// app's full DI graph.
class OfflineGracePeriod {
  const OfflineGracePeriod({this.duration = const Duration(days: 30)});

  final Duration duration;

  /// `false` when [lastVerifiedOnlineAt] is `null` — a device that has never
  /// recorded a successful backend contact is not treated as expired here;
  /// callers decide what to do with that case (see the grandfather clause in
  /// `AppController._hasGracePeriodExpired`).
  bool hasExpired({required DateTime? lastVerifiedOnlineAt, required DateTime now}) {
    if (lastVerifiedOnlineAt == null) {
      return false;
    }
    return now.toUtc().difference(lastVerifiedOnlineAt.toUtc()) > duration;
  }
}
