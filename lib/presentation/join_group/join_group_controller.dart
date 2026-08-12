import "package:dartz/dartz.dart";
import "package:flutter/widgets.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";

class JoinGroupController extends GetxController {
  JoinGroupController(this._groupsRepository, this._appNavigator);

  final GroupsRepository _groupsRepository;
  final AppNavigator _appNavigator;

  final TextEditingController codeController = TextEditingController();
  final RxBool isLoading = false.obs;

  Future<void> join() async {
    final BuildContext? context = Get.context;
    final String code = codeController.text.trim();
    if (code.isEmpty || isLoading.value || context == null) {
      return;
    }

    isLoading.value = true;
    final Either<AppError, GroupEntity> result = await _groupsRepository
        .joinGroupByInviteCode(code);
    isLoading.value = false;

    result.fold(
      (error) => _appNavigator.showErrorSnackBar(context.l10n.joinGroupError),
      (group) => _appNavigator.back<GroupEntity>(result: group),
    );
  }

  @override
  void onClose() {
    codeController.dispose();
    super.onClose();
  }
}
