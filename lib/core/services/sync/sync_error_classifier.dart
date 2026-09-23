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
  return code.startsWith("23") || // integrity violation (e.g. duplicate row)
      code == "42501" || // row-level security / insufficient privilege
      code == "P0001"; // exception raised by an RPC function
}
