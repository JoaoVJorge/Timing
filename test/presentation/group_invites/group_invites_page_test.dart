import "package:dartz/dartz.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/app/app_constants.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/entities/group_invite_option_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/group_invites/group_invites_controller.dart";
import "package:timing/presentation/group_invites/group_invites_page.dart";
import "package:timing/theme/theme.dart";

const GroupEntity _group = GroupEntity(
  id: "group-1",
  name: "Grupo",
  theme: GroupThemeType.studying,
  members: [],
  inviteCode: "abc123",
);

class _Repository implements GroupsRepository {
  List<GroupInviteOptionEntity> options = const [];

  @override
  Future<Either<AppError, List<GroupInviteOptionEntity>>> getGroupInviteOptions(
    String groupId,
  ) async => Right(options);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Navigator implements AppNavigator {
  @override
  Object? get arguments => _group;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

GroupInviteOptionEntity _option(String name, GroupInviteStatus status) =>
    GroupInviteOptionEntity(
      friendId: name,
      friendName: name,
      accentColorValue: 1,
      status: status,
    );

Future<AppLocalizations> _pumpPage(
  WidgetTester tester, {
  List<GroupInviteOptionEntity> options = const [],
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(430, 1600);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(Get.reset);

  final _Repository repository = _Repository()..options = options;
  Get.put<AppNavigator>(_Navigator());
  Get.put<GroupInvitesController>(
    GroupInvitesController(
      groupsRepository: repository,
      appNavigator: Get.find<AppNavigator>(),
    ),
  );

  await tester.pumpWidget(
    GetMaterialApp(
      locale: const Locale("en"),
      theme: AppThemes.build(seed: Colors.blue, brightness: Brightness.light),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const GroupInvitesPage(),
    ),
  );
  await tester.pumpAndSettle();
  return lookupAppLocalizations(const Locale("en"));
}

void main() {
  testWidgets("the group's link sits above the friends to invite", (
    tester,
  ) async {
    final AppLocalizations l10n = await _pumpPage(
      tester,
      options: [_option("Ana", GroupInviteStatus.available)],
    );

    expect(find.text(l10n.groupShareLinkTitle), findsOneWidget);
    expect(find.text(AppConstants.groupLink("abc123")), findsOneWidget);
    expect(find.text(l10n.groupShareLinkButton), findsOneWidget);
    expect(
      tester.getTopLeft(find.text(l10n.groupShareLinkTitle)).dy,
      lessThan(tester.getTopLeft(find.text("Ana")).dy),
    );
  });

  testWidgets("the link is there even with nobody to invite", (tester) async {
    final AppLocalizations l10n = await _pumpPage(tester);

    expect(find.text(l10n.groupShareLinkTitle), findsOneWidget);
    expect(find.text(l10n.groupInvitesNoFriendsTitle), findsOneWidget);
  });

  testWidgets("someone already waiting for the leader is not invited again", (
    tester,
  ) async {
    final AppLocalizations l10n = await _pumpPage(
      tester,
      options: [_option("Ana", GroupInviteStatus.requested)],
    );

    expect(find.text(l10n.groupJoinRequestsTitle), findsOneWidget);
    expect(find.text(l10n.selectButton), findsNothing);
  });
}
