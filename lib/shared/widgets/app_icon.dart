import "package:flutter/widgets.dart";
import "package:flutter_svg/flutter_svg.dart";

class AppIcon extends StatelessWidget {
  const AppIcon(this.name, {this.size = 24, this.color, super.key});

  final String name;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    "assets/icons/$name.svg",
    width: size,
    height: size,
    colorFilter: color == null
        ? null
        : ColorFilter.mode(color!, BlendMode.srcIn),
  );
}
