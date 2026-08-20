import "package:flutter/material.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";

/// Wraps skeleton placeholder content with the app's single shimmer behavior.
///
/// Owns its own ticker, so screens only describe the placeholder layout with
/// [AppSkeletonBox] / [AppSkeletonCircle] and never re-implement the sweep.
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({required this.child, super.key});

  final Widget child;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1350),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    child: widget.child,
    builder: (context, child) {
      final double sweep = _controller.value * 2.4 - 0.7;
      return ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            context.colorTokens.surfaceInnerLayer.withValues(alpha: 0.22),
            context.colorTokens.white.withValues(alpha: 0.7),
            context.colorTokens.surfaceInnerLayer.withValues(alpha: 0.22),
          ],
          stops: [
            (sweep - 0.18).clamp(0.0, 1.0),
            sweep.clamp(0.0, 1.0),
            (sweep + 0.18).clamp(0.0, 1.0),
          ],
        ).createShader(bounds),
        child: child,
      );
    },
  );
}

/// Rounded placeholder block for a skeleton layout. Use inside an [AppSkeleton].
class AppSkeletonBox extends StatelessWidget {
  const AppSkeletonBox({
    required this.height,
    this.width,
    this.radius = 14,
    super.key,
  });

  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: context.colorTokens.surfaceInnerLayer,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

/// Circular placeholder (avatars, icons) for a skeleton layout.
class AppSkeletonCircle extends StatelessWidget {
  const AppSkeletonCircle({required this.size, this.color, super.key});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color ?? context.colorTokens.surfaceInnerLayer,
      shape: BoxShape.circle,
    ),
  );
}
