import "package:supabase_flutter/supabase_flutter.dart" show PostgrestException;

/// Whether a failed queued action was rejected by the server for good, as
/// opposed to failing because the network was unavailable.
///
/// Retrying a rejected action can never succeed, so leaving it at the head of
/// a retry queue would block every later action forever. Network failures,
/// timeouts and gateway errors carry no SQLSTATE and stay retryable.
bool isPermanentSyncFailure(Object error) {
  if (error is! PostgrestException) {
    return false;
  }
  final String code = error.code ?? "";
  return code.startsWith("22") || // data exception (e.g. a malformed uuid)
      code.startsWith("23") || // integrity violation (e.g. duplicate row)
      code == "42501" || // row-level security / insufficient privilege
      code == "P0001"; // exception raised by an RPC function
}

/// Whether a failed write or read may use the offline fallback (retry queue or
/// cached data).
///
/// The fallback exists for a backend that cannot be reached, so it is only
/// taken when the app is flagged offline or the failure is not a definitive
/// server answer. A permanent rejection while flagged online is a real error
/// the user must see: queueing it would report a false success and the replay
/// would later drop it silently.
///
/// [isBackendReachable] is the app's connectivity flag; when absent the
/// backend is assumed reachable.
bool shouldUseOfflineFallback(
  Object error, {
  bool Function()? isBackendReachable,
}) {
  final bool isFlaggedOffline = !(isBackendReachable?.call() ?? true);
  return isFlaggedOffline || !isPermanentSyncFailure(error);
}
