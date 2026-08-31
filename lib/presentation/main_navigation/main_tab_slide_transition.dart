import "package:flutter/widgets.dart";
import "package:get/get.dart";

/// Route-level transition that makes adjacent main tabs move as one strip.
///
/// Unlike GetX's one-sided slide transitions, this uses both the primary and
/// secondary route animations: the destination enters while the current tab
/// leaves by the same distance in the opposite direction.
class MainTabSlideTransition extends CustomTransition {
  double _direction = 1;

  void setDirection({required bool forward}) {
    _direction = forward ? 1 : -1;
  }

  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final Animatable<Offset> incomingTween = Tween<Offset>(
      begin: Offset(_direction, 0),
      end: Offset.zero,
    ).chain(CurveTween(curve: curve ?? Curves.linear));
    final Animatable<Offset> outgoingTween = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(-_direction, 0),
    ).chain(CurveTween(curve: curve ?? Curves.linear));

    return SlideTransition(
      position: outgoingTween.animate(secondaryAnimation),
      child: SlideTransition(
        position: incomingTween.animate(animation),
        child: child,
      ),
    );
  }
}
