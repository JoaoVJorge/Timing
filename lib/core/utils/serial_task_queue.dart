/// Runs async operations one at a time, in the order they were enqueued.
///
/// A failed operation is swallowed so it cannot break the chain for
/// operations enqueued after it; callers that care about the outcome should
/// await the future returned by [run].
class SerialTaskQueue {
  Future<void> _tail = Future<void>.value();

  Future<void> run(Future<void> Function() operation) {
    final Future<void> scheduled = _tail.then((_) => operation());
    _tail = scheduled.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return scheduled;
  }

  /// Waits for every operation enqueued so far to finish, without
  /// scheduling any work of its own.
  Future<void> join() => _tail;
}
