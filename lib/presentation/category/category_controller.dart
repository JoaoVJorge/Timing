import "package:dartz/dartz.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/add_subject_use_case.dart";
import "package:help_out/core/domain/use_cases/get_subjects_use_case.dart";
import "package:help_out/presentation/category/widgets/add_subject_dialog.dart";

class CategoryController extends GetxController {
  CategoryController({
    required this._getSubjectsUseCase,
    required this._addSubjectUseCase,
    required this._appNavigator,
  }) : category = Get.arguments as TimeCategoryType;

  final GetSubjectsUseCase _getSubjectsUseCase;
  final AddSubjectUseCase _addSubjectUseCase;
  final AppNavigator _appNavigator;

  final TimeCategoryType category;
  final RxList<SubjectEntity> subjects = <SubjectEntity>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadSubjects();
  }

  Future<void> loadSubjects() async {
    isLoading.value = true;
    final Either<AppError, List<SubjectEntity>> result = await _getSubjectsUseCase();
    result.fold(
      (error) => subjects.clear(),
      (allSubjects) => subjects.value = allSubjects.where((subject) => subject.category == category).toList(),
    );
    isLoading.value = false;
  }

  void onTapSubject(SubjectEntity subject) => _appNavigator.toNamed(AppRoutes.timer, arguments: subject);

  Future<void> onTapAddSubject() async {
    final AddSubjectResult? dialogResult = await _appNavigator.dialog<AddSubjectResult>(child: const AddSubjectDialog());

    if (dialogResult == null) {
      return;
    }

    final Either<AppError, SubjectEntity> result = await _addSubjectUseCase(
      name: dialogResult.name,
      category: category,
      colorValue: dialogResult.colorValue,
      goalSeconds: dialogResult.goalSeconds,
    );
    result.fold((error) => _appNavigator.showErrorSnackBar(), subjects.add);
  }
}
