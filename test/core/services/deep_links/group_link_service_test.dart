import "dart:async";

import "package:flutter_test/flutter_test.dart";
import "package:timing/core/services/deep_links/group_link_service.dart";

void main() {
  late StreamController<Uri> links;
  late List<String> opened;
  late bool signedIn;
  late GroupLinkService service;

  setUp(() {
    links = StreamController<Uri>.broadcast();
    opened = [];
    signedIn = true;
    service = GroupLinkService(
      links: links.stream,
      isSignedIn: () => signedIn,
      openJoinScreen: (code) async => opened.add(code),
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

    expect(opened, ["ABC123"]);
  });

  test("other deep links are left to their own listeners", () async {
    service.start();

    links
      ..add(Uri.parse("com.moonstone.timing://login-callback?code=abc123"))
      ..add(Uri.parse("helpout://calendar-callback"))
      ..add(Uri.parse("https://example.com/join-group?code=abc123"))
      ..add(Uri.parse("com.moonstone.timing://join-group"));
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
    expect(opened, ["ABC123"]);

    // It is followed once, not on every later sign-in.
    await service.flushPendingLink();
    expect(opened, ["ABC123"]);
  });
}
