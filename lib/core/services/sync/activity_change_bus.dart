import "dart:async";

/// A user activity tied to a group changed (focus seconds, pages, or a task
/// check). Carries the affected group so listeners can refresh just that group.
class GroupActivityChange {
  const GroupActivityChange({this.groupId});

  final String? groupId;
}

/// Decouples the controllers that record activity (timer, daily goals) from the
/// ones that react to it (groups). Producers call
/// [notifyGroupActivityChanged]; [GroupsController] listens on [stream] instead
/// of being reached into through the service locator.
class ActivityChangeBus {
  final StreamController<GroupActivityChange> _controller =
      StreamController<GroupActivityChange>.broadcast();

  Stream<GroupActivityChange> get stream => _controller.stream;

  void notifyGroupActivityChanged({String? groupId}) {
    if (_controller.isClosed) {
      return;
    }
    _controller.add(GroupActivityChange(groupId: groupId));
  }

  void dispose() {
    unawaited(_controller.close());
  }
}
