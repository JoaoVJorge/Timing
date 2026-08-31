import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/presentation/main_navigation/main_tab_slide_transition.dart";

void main() {
  testWidgets("moves the incoming and outgoing tabs as one horizontal strip", (
    tester,
  ) async {
    final MainTabSlideTransition transition = MainTabSlideTransition();

    Future<List<Offset>> positions({
      required double primary,
      required double secondary,
    }) async {
      late SlideTransition outgoingSlide;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              outgoingSlide =
                  transition.buildTransition(
                        context,
                        Curves.linear,
                        null,
                        AlwaysStoppedAnimation<double>(primary),
                        AlwaysStoppedAnimation<double>(secondary),
                        const ColoredBox(color: Colors.blue),
                      )
                      as SlideTransition;
              return outgoingSlide;
            },
          ),
        ),
      );
      final SlideTransition incomingSlide =
          outgoingSlide.child! as SlideTransition;
      return [outgoingSlide.position.value, incomingSlide.position.value];
    }

    expect(await positions(primary: 0, secondary: 0), const [
      Offset.zero,
      Offset(1, 0),
    ]);
    expect(await positions(primary: 1, secondary: 1), const [
      Offset(-1, 0),
      Offset.zero,
    ]);

    transition.setDirection(forward: false);
    expect(await positions(primary: 0, secondary: 0), const [
      Offset.zero,
      Offset(-1, 0),
    ]);
    expect(await positions(primary: 1, secondary: 1), const [
      Offset(1, 0),
      Offset.zero,
    ]);
  });
}
