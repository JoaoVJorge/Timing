import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/presentation/edit_group/edit_group_controller.dart";
import "package:timing/theme/subject_colors.dart";

typedef _Edit = ({String name, String description, int? colorValue});

class _Repository implements GroupsRepository {
  final List<_Edit> edits = [];

  @override
  Future<Either<AppError, GroupEntity>> updateGroup({
    required GroupEntity group,
    required String name,
    required String description,
    int? colorValue,
  }) async {
    edits.add((name: name, description: description, colorValue: colorValue));
    return Right(group);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Navigator implements AppNavigator {
  _Navigator(this.arguments);

  @override
  final dynamic arguments;
  int errors = 0;
  GroupEntity? returned;

  @override
  void showErrorSnackBar([String? text]) => errors++;

  @override
  void back<T>({
    T? result,
    bool closeOverlays = false,
    bool canPop = true,
    int? id,
  }) => returned = result as GroupEntity?;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

GroupEntity _group({int? colorValue}) => GroupEntity(
  id: "group-1",
  name: "Academia",
  theme: GroupThemeType.exercises,
  description: "Treino",
  members: const [],
  colorValue: colorValue,
);

void main() {
  (EditGroupController, _Repository, _Navigator) build(GroupEntity group) {
    final repository = _Repository();
    final navigator = _Navigator(group);
    final controller = EditGroupController(
      groupsRepository: repository,
      appNavigator: navigator,
    )..onInit();
    addTearDown(controller.onClose);
    return (controller, repository, navigator);
  }

  test("starts from the group's name, description and color", () {
    final Color orange = SubjectColors.values[6];
    final (controller, _, _) = build(_group(colorValue: orange.toARGB32()));

    expect(controller.nameController.text, "Academia");
    expect(controller.descriptionController.text, "Treino");
    expect(controller.selectedColor.value.toARGB32(), orange.toARGB32());

    // The viewer's accent never replaces a color the group already has.
    controller.initializeThemeColor(Colors.purple);
    expect(controller.selectedColor.value.toARGB32(), orange.toARGB32());
  });

  test("saves the name and description, keeping the group's color", () async {
    final int orange = SubjectColors.values[6].toARGB32();
    final (controller, repository, navigator) = build(
      _group(colorValue: orange),
    );
    controller.nameController.text = "  Musculação ";
    controller.descriptionController.text = "Seg a sex";

    await controller.save();

    expect(repository.edits.single, (
      name: "Musculação",
      description: "Seg a sex",
      colorValue: orange,
    ));
    expect(navigator.returned, isNotNull);
  });

  test(
    "a group without a color keeps following each viewer's accent",
    () async {
      final (controller, repository, _) = build(_group());
      controller.initializeThemeColor(Colors.purple);

      await controller.save();

      expect(repository.edits.single.colorValue, isNull);
    },
  );

  test("picking a color gives the group one of its own", () async {
    final Color green = SubjectColors.values[2];
    final (controller, repository, _) = build(_group());
    controller.initializeThemeColor(Colors.purple);

    controller.onSelectColor(green);
    await controller.save();

    expect(repository.edits.single.colorValue, green.toARGB32());
  });

  test("does not save a group without a name", () async {
    final (controller, repository, navigator) = build(_group());
    controller.nameController.text = "   ";

    await controller.save();

    expect(repository.edits, isEmpty);
    expect(navigator.errors, 1);
  });
}
