import "dart:math";

final Random _random = Random.secure();

/// Generates a collision-resistant id for a locally-created entity.
///
/// Entities are stored on the backend under a `(user_id, id)` primary key and
/// saved with `upsert`, so two entities that share an id silently overwrite
/// each other. A bare `DateTime.now().microsecondsSinceEpoch` is not safe for
/// that: two entities created in the same instant collide — and on the web
/// `DateTime` only has millisecond resolution, making it far more likely.
///
/// Combining the timestamp with random bits keeps ids roughly time-ordered
/// while making a collision effectively impossible. The result contains only
/// `[0-9a-z-]`, so it stays safe inside the string-built `in (...)` filters the
/// data sources use.
String generateEntityId() {
  final int timestamp = DateTime.now().microsecondsSinceEpoch;
  final String randomSuffix = _random
      .nextInt(1 << 32)
      .toRadixString(36)
      .padLeft(7, "0");
  return "$timestamp-$randomSuffix";
}
