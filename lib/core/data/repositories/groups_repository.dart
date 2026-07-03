import "package:dartz/dartz.dart";
import "package:help_out/core/data/data_sources/groups_data_source.dart";
import "package:help_out/core/domain/entities/group_entity.dart";
import "package:help_out/core/domain/errors/app_error.dart";

class GroupsRepository {
  GroupsRepository({required this._groupsDataSource});

  final GroupsDataSource _groupsDataSource;

  Future<Either<AppError, List<GroupEntity>>> getGroups() => _groupsDataSource.getGroups();
}
