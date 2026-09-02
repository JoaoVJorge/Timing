import "dart:async";

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
  static const Duration _transitionSettleDelay = Duration(milliseconds: 150);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1350),
  );
  Animation<double>? _routeAnimation;
  AnimationStatusListener? _routeStatusListener;
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    // Starting the shimmer sweep immediately makes its ShaderMask (a saveLayer)
    // animate on the same frames as an incoming route or lazy-tab transition.
    // Wait for the route plus one short tab-transition window before sweeping;
    // the static boxes in the meantime read as a normal skeleton.
    WidgetsBinding.instance.addPostFrameCallback((_) => _startWhenSettled());
  }

  void _startWhenSettled() {
    if (!mounted) {
      return;
    }
    final Animation<double>? routeAnimation = ModalRoute.of(context)?.animation;
    if (routeAnimation == null ||
        routeAnimation.status == AnimationStatus.completed ||
        routeAnimation.status == AnimationStatus.dismissed) {
      _scheduleStart();
      return;
    }

    _routeAnimation = routeAnimation;
    void onStatus(AnimationStatus status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _removeRouteStatusListener();
        _scheduleStart();
      }
    }

    _routeStatusListener = onStatus;
    routeAnimation.addStatusListener(onStatus);
  }

  void _scheduleStart() {
    _startTimer?.cancel();
    _startTimer = Timer(_transitionSettleDelay, () {
      if (mounted && !_controller.isAnimating) {
        _controller.repeat();
      }
    });
  }

  void _removeRouteStatusListener() {
    final Animation<double>? animation = _routeAnimation;
    final AnimationStatusListener? listener = _routeStatusListener;
    if (animation != null && listener != null) {
      animation.removeStatusListener(listener);
    }
    _routeAnimation = null;
    _routeStatusListener = null;
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _removeRouteStatusListener();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: AnimatedBuilder(
      animation: _controller,
      builder: _buildSweep,
      child: widget.child,
    ),
  );

  Widget _buildSweep(BuildContext context, Widget? child) {
    final double sweep = _controller.value * 2.4 - 0.7;
    final bool isDark = context.isDarkMode;
    final Color base = context.colorTokens.surfaceInnerLayer.withValues(
      alpha: isDark ? 0.46 : 0.22,
    );
    final Color highlight = isDark
        ? Color.lerp(
            context.colorTokens.surfaceInnerLayer,
            context.colorTokens.borderUnfocused,
            0.7,
          )!.withValues(alpha: 0.82)
        : context.colorTokens.white.withValues(alpha: 0.7);
    final Color shoulder = isDark
        ? Color.lerp(base, highlight, 0.42)!
        : highlight;
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: isDark
            ? [base, shoulder, highlight, shoulder, base]
            : [base, highlight, base],
        stops: isDark
            ? [
                (sweep - 0.32).clamp(0.0, 1.0),
                (sweep - 0.16).clamp(0.0, 1.0),
                sweep.clamp(0.0, 1.0),
                (sweep + 0.16).clamp(0.0, 1.0),
                (sweep + 0.32).clamp(0.0, 1.0),
              ]
            : [
                (sweep - 0.18).clamp(0.0, 1.0),
                sweep.clamp(0.0, 1.0),
                (sweep + 0.18).clamp(0.0, 1.0),
              ],
      ).createShader(bounds),
      child: child,
    );
  }
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
