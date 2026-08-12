import "package:dartz/dartz.dart";
import "package:help_out/core/data/repositories/groups_repository.dart";
import "package:help_out/core/domain/entities/group_invitation_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class GetGroupInvitationsUseCase {
  GetGroupInvitationsUseCase({required this._groupsRepository});

  final GroupsRepository _groupsRepository;

  Future<Either<AppError, List<GroupInvitationEntity>>> call() =>
      _groupsRepository.getPendingInvitations();
}
