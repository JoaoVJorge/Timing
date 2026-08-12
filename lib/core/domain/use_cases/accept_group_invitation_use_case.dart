import "package:dartz/dartz.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";

class AcceptGroupInvitationUseCase {
  AcceptGroupInvitationUseCase({required this._groupsRepository});

  final GroupsRepository _groupsRepository;

  Future<Either<AppError, GroupEntity>> call(String invitationId) =>
      _groupsRepository.acceptInvitation(invitationId);
}
