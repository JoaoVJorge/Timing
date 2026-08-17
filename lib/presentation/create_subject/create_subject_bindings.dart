import "package:get/get.dart";
import "package:timing/app/route_arguments.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/presentation/create_subject/create_subject_controller.dart";

class CreateSubjectBindings extends Bindings {
  @override
  void dependencies() {
    final Object? arguments = Get.arguments;
    final SubjectEntity? subject = arguments is SubjectEntity
        ? arguments
        : null;
    final CreateSubjectRouteArguments? createArguments =
        arguments is CreateSubjectRouteArguments ? arguments : null;
    final TimeCategoryType category =
        subject?.category ??
        createArguments?.category ??
        arguments as TimeCategoryType;

    Get.put<CreateSubjectController>(
      CreateSubjectController(
        addSubjectUseCase: Get.find(),
        updateSubjectUseCase: Get.find(),
        appNavigator: Get.find(),
        achievementUnlockService: Get.find(),
        category: category,
        editingSubject: subject,
        initialName: createArguments?.initialName,
      ),
    );
  }
}
