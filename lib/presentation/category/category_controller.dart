import "package:dartz/dartz.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/app/app_routes.dart";
import "package:timing/app/route_arguments.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/time_category_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/core/domain/use_cases/delete_subject_use_case.dart";
import "package:timing/core/domain/use_cases/get_subjects_use_case.dart";
import "package:timing/core/domain/use_cases/pin_subject_to_start_use_case.dart";
import "package:timing/core/services/daily_progress/subject_daily_history_service.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/extensions/enum_localization_extensions.dart";
import "package:timing/shared/widgets/delete_confirmation_dialog.dart";

class CategoryController extends GetxController {
  CategoryController({
    required this._getSubjectsUseCase,
    required this._deleteSubjectUseCase,
    required this._pinSubjectToStartUseCase,
    required this._subjectDailyHistoryService,
    required this._appNavigator,
    required this.category,
  });

  final GetSubjectsUseCase _getSubjectsUseCase;
  final DeleteSubjectUseCase _deleteSubjectUseCase;
  final PinSubjectToStartUseCase _pinSubjectToStartUseCase;
  final SubjectDailyHistoryService _subjectDailyHistoryService;
  final AppNavigator _appNavigator;

  final TimeCategoryType category;
  final RxList<SubjectEntity> subjects = <SubjectEntity>[].obs;
  final RxBool isLoading = true.obs;

  bool get isPageBased => category == TimeCategoryType.reading;

  int progressSecondsFor(SubjectEntity subject) =>
      subject.activityType == SubjectActivityType.daily
      ? _subjectDailyHistoryService.todayForSubject(subject.id).focusSeconds
      : subject.totalSeconds;

  int progressPagesFor(SubjectEntity subject) =>
      subject.activityType == SubjectActivityType.daily
      ? _subjectDailyHistoryService.todayForSubject(subject.id).pages
      : subject.currentPages;

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
      (error) {
        subjects.clear();
        _appNavigator.showErrorSnackBar(error.message);
      },
      (allSubjects) => subjects.value = allSubjects
          .where((subject) => subject.category == category)
          .toList(),
    );
    isLoading.value = false;
  }

  Future<void> onTapSubject(SubjectEntity subject) async {
    if (isPageBased) {
      final dynamic result = await _appNavigator.toNamed(
        AppRoutes.timer,
        arguments: subject,
      );
      final SubjectEntity? updatedSubject = result as SubjectEntity?;
      if (updatedSubject == null) {
        await loadSubjects();
        return;
      }

      final int index = subjects.indexWhere((item) => item.id == subject.id);
      if (index != -1) {
        subjects[index] = updatedSubject;
      }
      await loadSubjects();
      return;
    }

    await _appNavigator.toNamed(AppRoutes.timer, arguments: subject);
    await loadSubjects();
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
    await loadSubjects();
  }

  Future<void> onTapSubjectStats(SubjectEntity subject) async {
    await _appNavigator.toNamed(AppRoutes.subjectStats, arguments: subject);
    await loadSubjects();
  }

  Future<void> onTapEditSubject(SubjectEntity subject) async {
    if (subject.isFromGroup) {
      _appNavigator.showErrorSnackBar(
        Get.context?.l10n.groupActivityEditBlockedMessage,
      );
      return;
    }

    final dynamic result = await _appNavigator.toNamed(
      AppRoutes.createSubject,
      arguments: subject,
    );
    final SubjectEntity? updatedSubject = result as SubjectEntity?;
    if (updatedSubject == null) {
      return;
    }

    final int index = subjects.indexWhere((item) => item.id == subject.id);
    if (index != -1) {
      subjects[index] = updatedSubject;
    }
    await loadSubjects();
  }

  Future<void> onDeleteSubject(SubjectEntity subject) async {
    if (subject.isFromGroup) {
      _appNavigator.showErrorSnackBar(
        Get.context?.l10n.groupActivityDeleteBlockedMessage,
      );
      return;
    }

    final bool confirmed = await showDeleteConfirmationDialog(
      itemName: subject.name,
      itemTypeName: Get.context == null
          ? null
          : category.itemNoun(Get.context!),
    );
    if (!confirmed) {
      return;
    }

    final List<SubjectEntity> previousSubjects = subjects.toList();
    subjects.removeWhere((item) => item.id == subject.id);
    final result = await _deleteSubjectUseCase(subjectId: subject.id);
    result.fold((error) {
      subjects.value = previousSubjects;
      _handleError(error);
    }, (_) {});
  }

  Future<void> onPinSubjectToStart(SubjectEntity subject) async {
    final int index = subjects.indexWhere((item) => item.id == subject.id);
    if (index > 0) {
      subjects
        ..removeAt(index)
        ..insert(0, subject);
    }

    final Either<AppError, void> result = await _pinSubjectToStartUseCase(
      subjectId: subject.id,
    );
    await result.fold((error) async {
      _handleError(error);
      await loadSubjects();
    }, (_) => loadSubjects());
  }

  Future<void> onTapAddSubject() => _openCreateSubject();

  Future<void> onTapSuggestion(String suggestion) =>
      _openCreateSubject(initialName: suggestion);

  Future<void> _openCreateSubject({String? initialName}) {
    final Future<dynamic>? route = _appNavigator.toNamed(
      AppRoutes.createSubject,
      arguments: initialName == null
          ? category
          : CreateSubjectRouteArguments(
              category: category,
              initialName: initialName,
            ),
    );

    return route?.then((result) async {
          final SubjectEntity? createdSubject = result as SubjectEntity?;
          await _addCreatedSubjectIfNeeded(createdSubject);
        }) ??
        Future<void>.value();
  }

  Future<void> _addCreatedSubjectIfNeeded(SubjectEntity? createdSubject) async {
    if (createdSubject != null) {
      final bool belongsToCurrentCategory = createdSubject.category == category;
      final bool isAlreadyListed = subjects.any(
        (subject) => subject.id == createdSubject.id,
      );
      if (belongsToCurrentCategory && !isAlreadyListed) {
        subjects.add(createdSubject);
      }
      await loadSubjects();
    }
  }

  void _handleError(AppError error) =>
      _appNavigator.showErrorSnackBar(error.message);
}
