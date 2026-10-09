import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:timing/app/app_navigator.dart";
import "package:timing/core/domain/entities/friend_entity.dart";
import "package:timing/core/domain/entities/group_invitation_entity.dart";
import "package:timing/core/domain/entities/sent_group_invitation_entity.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/presentation/friends/friends_controller.dart";
import "package:timing/presentation/friends/friends_page.dart";
import "package:timing/theme/theme.dart";

class _PageController extends GetxController implements FriendsController {
  @override
  final RxBool isLoading = false.obs;
  @override
  final RxString inviteCode = "ABC123".obs;
  @override
  final RxList<FriendEntity> friends = <FriendEntity>[].obs;
  @override
  final RxList<FriendEntity> requests = <FriendEntity>[].obs;
  @override
  final RxList<GroupInvitationEntity> groupInvitations =
      <GroupInvitationEntity>[].obs;
  @override
  final RxList<SentGroupInvitationEntity> sentGroupInvitations =
      <SentGroupInvitationEntity>[].obs;
  @override
  final Rx<DateTime> presenceNow = DateTime.utc(2026, 10, 9).obs;

  int refreshes = 0;
  final Completer<void> refreshed = Completer<void>();

  @override
  Future<void> loadSocial() {
    refreshes++;
    return refreshed.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  tearDown(Get.reset);

  testWidgets("pulling from blank space refreshes a short friends list", (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final controller = _PageController();
    Get.put<AppNavigator>(AppNavigator());
    Get.put<FriendsController>(controller);
    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale("pt"),
        theme: AppThemes.build(
          seed: Colors.green,
          brightness: Brightness.light,
        ),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const FriendsPage(),
      ),
    );
    await tester.pumpAndSettle();

    final viewport = tester.getRect(find.byType(ListView));
    final refreshArea = tester.getRect(find.byType(RefreshIndicator));
    expect(viewport.bottom, refreshArea.bottom);
    await tester.dragFrom(
      Offset(viewport.center.dx, viewport.bottom - 400),
      const Offset(0, 600),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(controller.refreshes, 1);
    controller.refreshed.complete();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
