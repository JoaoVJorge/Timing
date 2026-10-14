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
import "package:timing/theme/theme.dart";

class _Repository implements GroupsRepository {
  bool failSave = true;
  bool failLoad = false;
  bool empty = false;
  Set<String> selectedIds = {'upper'};
  String? submittedGroupId;
  List<String>? submitted;

  @override
  Future<Either<AppError, GroupActivityLinkOptions>> getActivityLinkOptions(
    String groupId,
  ) async {
    if (failLoad) {
      return Left(
        UnexpectedError(
          cause: StateError('offline'),
          stackTrace: StackTrace.current,
        ),
      );
    }
    if (empty) {
      return const Right(
        GroupActivityLinkOptions(selectedIds: {}, options: []),
      );
    }
    return Right(
      GroupActivityLinkOptions(
        selectedIds: selectedIds,
        options: const [
          GroupActivitySourceOption(id: 'upper', name: 'Superior'),
          GroupActivitySourceOption(id: 'lower', name: 'Inferior'),
        ],
      ),
    );
  }

  @override
  Future<Either<AppError, void>> setActivityLinks({
    required String groupId,
    required List<String> sourceIds,
  }) async {
    submittedGroupId = groupId;
    submitted = sourceIds;
    return failSave
        ? Left(
            UnexpectedError(
              cause: StateError('offline'),
              stackTrace: StackTrace.current,
            ),
          )
        : const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(
  WidgetTester tester,
  _Repository repository, {
  Brightness brightness = Brightness.light,
  double textScale = 1,
  GroupThemeType theme = GroupThemeType.exercises,
  int? groupColorValue,
}) async {
  Get.put<GroupsRepository>(repository);
  await tester.pumpWidget(
    GetMaterialApp(
      theme: AppThemes.build(seed: Colors.blue, brightness: brightness),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      locale: const Locale('pt'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: GroupActivityLinksPage(
        group: GroupEntity(
          id: 'group',
          name: 'Academia',
          theme: theme,
          members: const [],
          colorValue: groupColorValue,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _source(String id) => find.byKey(ValueKey('source_$id'));

/// The mark a source shows: a checkbox where several can be linked, a radio
/// where the group takes a single one.
Icon _mark(WidgetTester tester, String id) => tester.widget<Icon>(
  find.descendant(of: _source(id), matching: find.byType(Icon)),
);

bool _isSelected(WidgetTester tester, String id) {
  final IconData? icon = _mark(tester, id).icon;
  return icon == Icons.check_box_rounded ||
      icon == Icons.radio_button_checked_rounded;
}

Future<void> _tapSource(WidgetTester tester, String id) async {
  await tester.ensureVisible(_source(id));
  await tester.tap(_source(id));
  await tester.pumpAndSettle();
}

Future<void> _save(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Salvar vínculos'));
  await tester.tap(find.text('Salvar vínculos'));
  await tester.pumpAndSettle();
}

void main() {
  tearDown(Get.reset);

  testWidgets('says what can be linked and offers no way to create one', (
    tester,
  ) async {
    await _pump(tester, _Repository());

    expect(find.text('Atividades vinculadas'), findsWidgets);
    expect(
      find.text(
        'Escolha quais das suas atividades de exercício contam para este '
        'grupo.',
      ),
      findsOneWidget,
    );
    expect(find.text('Criar atividade'), findsNothing);
    expect(find.text('Usar minhas atividades'), findsNothing);
    expect(_isSelected(tester, 'upper'), isTrue);
    expect(_isSelected(tester, 'lower'), isFalse);
  });

  testWidgets('with nothing to link, explains it and hides the save button', (
    tester,
  ) async {
    await _pump(tester, _Repository()..empty = true);
    expect(
      find.textContaining('Você ainda não tem atividades deste tema'),
      findsOneWidget,
    );
    expect(find.text('Salvar vínculos'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final brightness in Brightness.values) {
    testWidgets('links fit a narrow screen with larger text ($brightness)', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 700);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await _pump(
        tester,
        _Repository(),
        brightness: brightness,
        textScale: 1.4,
      );
      final savePosition = tester.getRect(find.text('Salvar vínculos'));
      expect(savePosition.bottom, lessThanOrEqualTo(700));
      await tester.ensureVisible(_source('lower'));
      await tester.tapAt(
        tester.getRect(_source('lower')).centerRight - const Offset(8, 0),
      );
      await tester.pumpAndSettle();
      expect(_isSelected(tester, 'lower'), isTrue);
      expect(tester.getRect(find.text('Salvar vínculos')), savePosition);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'member selects multiple sources and keeps selection on save failure',
    (tester) async {
      final repository = _Repository();
      await _pump(tester, repository);
      await _tapSource(tester, 'lower');
      await _save(tester);
      expect(repository.submittedGroupId, 'group');
      expect(repository.submitted, ['upper', 'lower']);
      expect(_isSelected(tester, 'lower'), isTrue);
      expect(find.textContaining('Não foi possível salvar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('unlinking everything pauses the participation', (tester) async {
    final repository = _Repository()..failSave = false;
    await _pump(tester, repository);
    await _tapSource(tester, 'upper');
    expect(find.text('Nenhuma atividade selecionada.'), findsOneWidget);
    await _save(tester);
    expect(repository.submitted, isEmpty);
  });

  group('a daily-goals group', () {
    testWidgets('takes one goal: choosing another replaces it', (tester) async {
      final repository = _Repository()..failSave = false;
      await _pump(tester, repository, theme: GroupThemeType.dailyGoals);

      expect(find.textContaining('Cada pessoa vincula uma só'), findsOneWidget);
      expect(_mark(tester, 'upper').icon, Icons.radio_button_checked_rounded);
      await _tapSource(tester, 'lower');
      expect(_isSelected(tester, 'upper'), isFalse);
      expect(_isSelected(tester, 'lower'), isTrue);
      expect(find.text('1 meta selecionada.'), findsOneWidget);

      await _save(tester);
      expect(repository.submitted, ['lower']);
    });

    testWidgets('tapping the chosen goal clears it', (tester) async {
      final repository = _Repository()..failSave = false;
      await _pump(tester, repository, theme: GroupThemeType.dailyGoals);

      await _tapSource(tester, 'upper');
      expect(find.text('Nenhuma meta selecionada.'), findsOneWidget);

      await _save(tester);
      expect(repository.submitted, isEmpty);
    });

    testWidgets('never shows two goals linked at once', (tester) async {
      // Links made while a group still accepted several goals.
      final repository = _Repository()..selectedIds = {'upper', 'lower'};
      await _pump(tester, repository, theme: GroupThemeType.dailyGoals);

      expect(_isSelected(tester, 'upper'), isTrue);
      expect(_isSelected(tester, 'lower'), isFalse);
    });

    testWidgets('with no goal yet, says so', (tester) async {
      await _pump(
        tester,
        _Repository()..empty = true,
        theme: GroupThemeType.dailyGoals,
      );
      expect(find.textContaining('Você ainda não tem metas'), findsOneWidget);
    });
  });

  testWidgets('link controls use the app accent instead of the group color', (
    tester,
  ) async {
    await _pump(tester, _Repository(), groupColorValue: Colors.red.toARGB32());

    final Color? markColor = _mark(tester, 'upper').color;
    expect(markColor, Colors.blue);
    expect(markColor, isNot(Colors.red));
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
