import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/groups/groups_controller.dart";
import "package:timing/theme/subject_colors.dart";

/// The leader's edits to a group: its name, description and color. The theme
/// is fixed at creation, since every member's linked activities depend on it.
class EditGroupController extends GetxController {
  EditGroupController({
    required this.groupsRepository,
    required this.appNavigator,
  });

  final GroupsRepository groupsRepository;
  final AppNavigator appNavigator;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final Rx<GroupEntity?> group = Rx<GroupEntity?>(null);
  final RxBool isSaving = false.obs;

  final Rx<Color> selectedColor = SubjectColors.values.first.obs;

  /// A group without a color of its own follows each viewer's accent, and
  /// keeps doing so unless the leader picks one here.
  bool _hasOwnColor = false;

  /// Shows the viewer's accent as the starting swatch of a group that has no
  /// color of its own yet.
  void initializeThemeColor(Color color) {
    if (_hasOwnColor) {
      return;
    }
    selectedColor.value = SubjectColors.fromThemeAccent(color);
  }

  void onSelectColor(Color color) {
    _hasOwnColor = true;
    selectedColor.value = color;
  }

  @override
  void onInit() {
    super.onInit();
    final Object? args = appNavigator.arguments;
    final GroupEntity? initialGroup = args is GroupEntity
        ? args
        : Get.isRegistered<GroupsController>()
        ? Get.find<GroupsController>().selectedGroup.value
        : null;
    group.value = initialGroup;
    if (initialGroup == null) {
      return;
    }
    nameController.text = initialGroup.name;
    descriptionController.text = initialGroup.description;
    final int? colorValue = initialGroup.colorValue;
    if (colorValue != null) {
      _hasOwnColor = true;
      selectedColor.value = Color(colorValue);
    }
  }

  Future<void> save() async {
    if (isSaving.value) {
      return;
    }
    final GroupEntity? currentGroup = group.value;
    if (currentGroup == null) {
      appNavigator.showErrorSnackBar();
      return;
    }

    final String name = nameController.text.trim();
    if (name.isEmpty) {
      appNavigator.showErrorSnackBar(Get.context?.l10n.nameRequiredError);
      return;
    }

    isSaving.value = true;
    final Either<AppError, GroupEntity> result = await groupsRepository
        .updateGroup(
          group: currentGroup,
          name: name,
          description: descriptionController.text.trim(),
          colorValue: _hasOwnColor ? selectedColor.value.toARGB32() : null,
        );
    isSaving.value = false;

    result.fold(
      (error) => appNavigator.showError(error),
      (updatedGroup) => appNavigator.back<GroupEntity>(result: updatedGroup),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
