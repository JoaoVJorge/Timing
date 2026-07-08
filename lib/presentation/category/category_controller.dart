import "package:dartz/dartz.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/app/app_routes.dart";
import "package:help_out/core/domain/entities/subject_entity.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";
import "package:help_out/core/domain/errors/app_error.dart";
import "package:help_out/core/domain/use_cases/delete_subject_use_case.dart";
import "package:help_out/core/domain/use_cases/get_subjects_use_case.dart";
import "package:help_out/core/domain/use_cases/update_subject_pages_use_case.dart";
import "package:help_out/core/services/daily_progress/daily_progress_service.dart";
import "package:help_out/presentation/category/widgets/log_pages_dialog.dart";

class CategoryController extends GetxController {
  CategoryController({
    required this._getSubjectsUseCase,
    required this._updateSubjectPagesUseCase,
    required this._deleteSubjectUseCase,
    required this._dailyProgressService,
    required this._appNavigator,
    required this.category,
  });

  final GetSubjectsUseCase _getSubjectsUseCase;
  final UpdateSubjectPagesUseCase _updateSubjectPagesUseCase;
  final DeleteSubjectUseCase _deleteSubjectUseCase;
  final DailyProgressService _dailyProgressService;
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
    final Either<AppError, List<SubjectEntity>> result =
        await _getSubjectsUseCase();
    result.fold(
      (error) => subjects.clear(),
      (allSubjects) => subjects.value = allSubjects
          .where((subject) => subject.category == category)
          .toList(),
    );
    isLoading.value = false;
  }

  Future<void> onTapSubject(SubjectEntity subject) async {
    if (isPageBased) {
      final int? updatedPages = await _appNavigator.dialog<int>(
        child: LogPagesDialog(subject: subject),
      );
      if (updatedPages == null) {
        return;
      }

      final int index = subjects.indexWhere((item) => item.id == subject.id);
      if (index != -1) {
        subjects[index] = subjects[index].copyWith(currentPages: updatedPages);
      }
      await _updateSubjectPagesUseCase(
        subjectId: subject.id,
        currentPages: updatedPages,
      );
      await _dailyProgressService.addPages(updatedPages - subject.currentPages);
      return;
    }

    _appNavigator.toNamed(AppRoutes.timer, arguments: subject);
  }

  Future<void> onTapNotes(SubjectEntity subject) async {
    final dynamic result = await _appNavigator.toNamed(
      AppRoutes.notes,
      arguments: subject,
    );
    final String? updatedNotes = result as String?;
    if (updatedNotes == null) {
      return;
    }

    final int index = subjects.indexWhere((item) => item.id == subject.id);
    if (index != -1) {
      subjects[index] = subjects[index].copyWith(notes: updatedNotes);
    }
  }

  Future<void> onDeleteSubject(SubjectEntity subject) async {
    subjects.removeWhere((item) => item.id == subject.id);
    await _deleteSubjectUseCase(subjectId: subject.id);
  }

  Future<void> onTapAddSubject() async {
    final dynamic result = await _appNavigator.toNamed(
      AppRoutes.createSubject,
      arguments: category,
    );
    final SubjectEntity? createdSubject = result as SubjectEntity?;
    if (createdSubject != null) {
      subjects.add(createdSubject);
    }
  }
}
