import "package:equatable/equatable.dart";
import "package:timing/core/domain/entities/group_entity.dart";

/// What came of using a group's link or accepting an invitation: either the
/// user is in the group, or the group's leader was asked to let them in.
///
/// Only an invitation sent by the leader joins straight away; the link and a
/// member's invitation both wait for an answer.
class GroupJoinOutcomeEntity extends Equatable {
  const GroupJoinOutcomeEntity.joined(GroupEntity this.group)
    : groupName = "",
      isPendingApproval = false;

  const GroupJoinOutcomeEntity.pendingApproval(this.groupName)
    : group = null,
      isPendingApproval = true;

  /// The group that was joined, or null while the request is pending.
  final GroupEntity? group;

  /// The group the request was sent to, for the message that says so.
  final String groupName;

  final bool isPendingApproval;

  @override
  List<Object?> get props => [group, groupName, isPendingApproval];
}
