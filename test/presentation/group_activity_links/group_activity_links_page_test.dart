import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/domain/entities/group_activity_link_options.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/group_activity_links/group_activity_links_page.dart";

class _Repository implements GroupsRepository {
  bool failSave = true;
  bool failLoad = false;
  List<String>? submitted;
  bool? createdNew;

  @override
  Future<Either<AppError, List<GroupActivityLinkOptions>>>
  getActivityLinkOptions(String groupId) async {
    if (failLoad) {
      return Left(
        GenericAppError(
          error: StateError('offline'),
          stackTrace: StackTrace.current,
        ),
      );
    }
    return const Right([
      GroupActivityLinkOptions(
        activityId: 'activity',
        payload: {},
        name: 'Academia',
        isReading: false,
        selectedIds: {'upper'},
        options: [
          GroupActivitySourceOption(id: 'upper', name: 'Superior'),
          GroupActivitySourceOption(id: 'lower', name: 'Inferior'),
        ],
      ),
    ]);
  }

  @override
  Future<Either<AppError, void>> setActivityLinks({
    required String activityId,
    required List<String> sourceIds,
    bool createNew = false,
  }) async {
    submitted = sourceIds;
    createdNew = createNew;
    return failSave
        ? Left(
            GenericAppError(
              error: StateError('offline'),
              stackTrace: StackTrace.current,
            ),
          )
        : const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester, _Repository repository) async {
  Get.put<GroupsRepository>(repository);
  await tester.pumpWidget(
    const GetMaterialApp(
      locale: Locale('pt'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: GroupActivityLinksPage(
        group: GroupEntity(
          id: 'group',
          name: 'Academia',
          theme: GroupThemeType.exercises,
          members: [],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  tearDown(Get.reset);
  testWidgets(
    'member selects multiple sources and keeps selection on save failure',
    (tester) async {
      final repository = _Repository();
      await _pump(tester, repository);
      await tester.tap(find.byKey(const ValueKey('source_lower')));
      await tester.pump();
      await tester.ensureVisible(find.text('Salvar vínculos'));
      await tester.tap(find.text('Salvar vínculos'));
      await tester.pumpAndSettle();
      expect(repository.submitted, ['upper', 'lower']);
      expect(repository.createdNew, false);
      expect(
        tester
            .widget<CheckboxListTile>(
              find.byKey(const ValueKey('source_lower')),
            )
            .value,
        true,
      );
      expect(find.textContaining('Não foi possível salvar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('create mode sends no previous selections', (tester) async {
    final repository = _Repository();
    await _pump(tester, repository);
    await tester.tap(find.text('Criar atividade'));
    await tester.pump();
    await tester.tap(find.text('Salvar vínculos'));
    await tester.pumpAndSettle();
    expect(repository.submitted, isEmpty);
    expect(repository.createdNew, true);
  });

  testWidgets('loading failure can be retried without joining again', (
    tester,
  ) async {
    final repository = _Repository()..failLoad = true;
    await _pump(tester, repository);
    expect(find.textContaining('Não foi possível carregar'), findsOneWidget);
    repository.failLoad = false;
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    expect(find.text('Superior'), findsOneWidget);
    expect(find.text('Inferior'), findsOneWidget);
  });
}
