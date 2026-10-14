import "dart:async";

import "package:flutter_test/flutter_test.dart";
import "package:timing/app/app_constants.dart";
import "package:timing/core/services/deep_links/invite_link_service.dart";

void main() {
  late StreamController<Uri> links;
  late List<String> opened;
  late bool signedIn;
  late InviteLinkService service;

  setUp(() {
    links = StreamController<Uri>.broadcast();
    opened = [];
    signedIn = true;
    service = InviteLinkService(
      links: links.stream,
      isSignedIn: () => signedIn,
      openJoinGroupScreen: (code) async => opened.add("group:$code"),
      openAddFriendScreen: (code) async => opened.add("friend:$code"),
    );
  });

  tearDown(() async {
    await service.dispose();
    await links.close();
  });

  test("a group link opens the join screen with its code", () async {
    service.start();

    links.add(Uri.parse("com.moonstone.timing://join-group?code=abc123"));
    await pumpEventQueue();

    expect(opened, ["group:ABC123"]);
  });

  test("the shared group URI is accepted by the group link handler", () async {
    service.start();

    links.add(AppConstants.groupUri(" abc123 "));
    await pumpEventQueue();

    expect(
      AppConstants.groupLink(" abc123 "),
      "com.moonstone.timing://join-group?code=ABC123",
    );
    expect(opened, ["group:ABC123"]);
  });

  test("a friend link opens the add-friend screen with its code", () async {
    service.start();

    links.add(AppConstants.friendUri(" a1b2c3d4e5 "));
    await pumpEventQueue();

    expect(
      AppConstants.friendLink(" a1b2c3d4e5 "),
      "com.moonstone.timing://add-friend?code=A1B2C3D4E5",
    );
    expect(opened, ["friend:A1B2C3D4E5"]);
  });

  test("other deep links are left to their own listeners", () async {
    service.start();

    links
      ..add(Uri.parse("com.moonstone.timing://login-callback?code=abc123"))
      ..add(Uri.parse("helpout://calendar-callback"))
      ..add(Uri.parse("https://example.com/join-group?code=abc123"))
      ..add(Uri.parse("com.moonstone.timing://join-group"))
      ..add(Uri.parse("com.moonstone.timing://add-friend?code="));
    await pumpEventQueue();

    expect(opened, isEmpty);
  });

  test("a link followed while signed out opens after the sign-in", () async {
    signedIn = false;
    service.start();

    links.add(Uri.parse("com.moonstone.timing://join-group?code=ABC123"));
    await pumpEventQueue();
    expect(opened, isEmpty);

    await service.flushPendingLink();
    expect(opened, isEmpty, reason: "still signed out");

    signedIn = true;
    await service.flushPendingLink();
    expect(opened, ["group:ABC123"]);

    // It is followed once, not on every later sign-in.
    await service.flushPendingLink();
    expect(opened, ["group:ABC123"]);
  });

  test("only the last link followed while signed out opens", () async {
    signedIn = false;
    service.start();

    links
      ..add(AppConstants.groupUri("H0123456789"))
      ..add(AppConstants.friendUri("A1B2C3D4E5"));
    await pumpEventQueue();

    signedIn = true;
    await service.flushPendingLink();
    expect(opened, ["friend:A1B2C3D4E5"]);
  });
}
