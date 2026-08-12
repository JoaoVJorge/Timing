import "package:dartz/dartz.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/domain/errors/app_error.dart";

class DeclineGroupInvitationUseCase {
  DeclineGroupInvitationUseCase({required this._groupsRepository});

  final GroupsRepository _groupsRepository;

  Future<Either<AppError, void>> call(String invitationId) =>
      _groupsRepository.declineInvitation(invitationId);
}
