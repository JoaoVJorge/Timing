import "dart:math";

final EntityIdGenerator _entityIdGenerator = EntityIdGenerator();

/// Injection seam for deterministic tests. Production code should call
/// [generateEntityId] so the process-wide secure generator is reused.
class EntityIdGenerator {
  EntityIdGenerator({Random? random, int Function()? timestampMicros})
    : _random = random ?? Random.secure(),
      _timestampMicros =
          timestampMicros ?? (() => DateTime.now().microsecondsSinceEpoch);

  final Random _random;
  final int Function() _timestampMicros;

  String generate() {
    final int timestamp = _timestampMicros();
    final String randomSuffix = "${_randomChunk()}${_randomChunk()}";
    return "$timestamp-$randomSuffix";
  }

  String _randomChunk() {
    const int wordLimit = 0x10000;
    final int value =
        _random.nextInt(wordLimit) * wordLimit + _random.nextInt(wordLimit);
    return value.toRadixString(36).padLeft(7, "0");
  }
}

/// Generates a collision-resistant id for a locally-created entity.
///
/// Entities are stored on the backend under a `(user_id, id)` primary key and
/// saved with `upsert`, so two entities that share an id silently overwrite
/// each other. A bare `DateTime.now().microsecondsSinceEpoch` is not safe for
/// that: two entities created in the same instant collide — and on the web
/// `DateTime` only has millisecond resolution, making it far more likely.
///
/// Combining the timestamp with 64 random bits keeps ids roughly time-ordered
/// while making collisions negligible even when the web clock groups many ids
/// under the same millisecond. The result contains only `[0-9a-z-]`, so it
/// stays safe inside the string-built `in (...)` filters the data sources use.
String generateEntityId() => _entityIdGenerator.generate();

final Random _uuidRandom = Random.secure();

/// Generates a random RFC 4122 version 4 UUID.
///
/// Use this instead of [generateEntityId] for any row whose `id` column is a
/// Postgres `uuid` (e.g. `activity_entries`) — [generateEntityId]'s
/// timestamp-prefixed format is not valid UUID syntax and Postgrest rejects
/// it with a `22P02` error.
String generateUuidV4() {
  final List<int> bytes = List<int>.generate(16, (_) => _uuidRandom.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  String hex(int start, int end) => bytes
      .sublist(start, end)
      .map((byte) => byte.toRadixString(16).padLeft(2, "0"))
      .join();
  return "${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}";
}
