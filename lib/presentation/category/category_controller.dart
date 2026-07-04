import "package:dartz/dartz.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/add_subject_use_case.dart";
import "package:help_out/core/domain/use_cases/get_subjects_use_case.dart";
import "package:help_out/core/domain/use_cases/update_subject_pages_use_case.dart";
import "package:help_out/presentation/category/widgets/add_subject_dialog.dart";
import "package:help_out/presentation/category/widgets/log_pages_dialog.dart";

class CategoryController extends GetxController {
  CategoryController({
    required this._getSubjectsUseCase,
    required this._addSubjectUseCase,
    required this._updateSubjectPagesUseCase,
    required this._appNavigator,
  }) : category = Get.arguments as TimeCategoryType;

  final GetSubjectsUseCase _getSubjectsUseCase;
  final AddSubjectUseCase _addSubjectUseCase;
  final UpdateSubjectPagesUseCase _updateSubjectPagesUseCase;
  final AppNavigator _appNavigator;

  final TimeCategoryType category;
  final RxList<SubjectEntity> subjects = <SubjectEntity>[].obs;
  final RxBool isLoading = true.obs;

  bool get isPageBased => category == TimeCategoryType.reading;

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

  Future<void> onTapSubject(SubjectEntity subject) async {
    if (isPageBased) {
      final int? updatedPages = await _appNavigator.dialog<int>(child: LogPagesDialog(subject: subject));
      if (updatedPages == null) {
        return;
      }

      final int index = subjects.indexWhere((item) => item.id == subject.id);
      if (index != -1) {
        subjects[index] = subjects[index].copyWith(currentPages: updatedPages);
      }
      await _updateSubjectPagesUseCase(subjectId: subject.id, currentPages: updatedPages);
      return;
    }

    _appNavigator.toNamed(AppRoutes.timer, arguments: subject);
  }

  Future<void> onTapAddSubject() async {
    final AddSubjectResult? result = await _appNavigator.dialog<AddSubjectResult>(
      child: AddSubjectDialog(category: category),
    );

    if (result == null) {
      return;
    }

    final Either<AppError, SubjectEntity> addResult = await _addSubjectUseCase(
      name: result.name,
      category: category,
      colorValue: result.colorValue,
      goalSeconds: result.goalSeconds,
      goalPages: result.goalPages,
    );
    addResult.fold((error) => _appNavigator.showErrorSnackBar(), subjects.add);
  }
}
