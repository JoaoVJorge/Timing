import "package:dartz/dartz.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/core/data/repositories/subjects_repository.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/add_subject_use_case.dart";

class _FakeSubjectsRepository implements SubjectsRepository {
  _FakeSubjectsRepository(this._subjects);

  List<SubjectEntity> _subjects;
  List<SubjectEntity>? savedSubjects;

  @override
  Future<Either<AppError, List<SubjectEntity>>> getSubjects() async =>
      Right(_subjects);

  @override
  Future<Either<AppError, void>> saveSubjects(
    List<SubjectEntity> subjects,
  ) async {
    savedSubjects = subjects;
    _subjects = subjects;
    return const Right(null);
  }
}

SubjectEntity _reading({
  String id = "existing",
  String name = "Bíblia",
  String? groupId,
}) => SubjectEntity(
  id: id,
  name: name,
  category: TimeCategoryType.reading,
  colorValue: 1,
  totalSeconds: 0,
  goalSeconds: 0,
  currentPages: 0,
  goalPages: 10,
  notes: "",
  iconName: "book",
  restMinutes: 5,
  focusSessionCount: 1,
  wallpaperIndex: 0,
  groupId: groupId,
);

void main() {
  group("AddSubjectUseCase group link", () {
    test("stamps groupId on a freshly created group reading", () async {
      final repository = _FakeSubjectsRepository([]);
      final useCase = AddSubjectUseCase(subjectsRepository: repository);

      final result = await useCase(
        name: "Bíblia",
        category: TimeCategoryType.reading,
        colorValue: 1,
        goalSeconds: 0,
        goalPages: 10,
        groupId: "group-123",
      );

      final SubjectEntity created = result.getOrElse(
        () => throw StateError("expected subject"),
      );
      expect(created.groupId, "group-123");
      expect(created.isFromGroup, true);
    });

    test(
      "links an existing matching reading to the group when reused",
      () async {
        final repository = _FakeSubjectsRepository([_reading()]);
        final useCase = AddSubjectUseCase(subjectsRepository: repository);

        final result = await useCase(
          name: "Bíblia",
          category: TimeCategoryType.reading,
          colorValue: 1,
          goalSeconds: 0,
          goalPages: 10,
          iconName: "book",
          reuseMatchingSubject: true,
          groupId: "group-123",
        );

        final SubjectEntity linked = result.getOrElse(
          () => throw StateError("expected subject"),
        );
        expect(linked.id, "existing");
        expect(linked.isFromGroup, true);
        expect(repository.savedSubjects?.single.groupId, "group-123");
      },
    );
  });
}
