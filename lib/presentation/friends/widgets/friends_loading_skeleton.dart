import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

class FriendsLoadingSkeleton extends StatelessWidget {
  const FriendsLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Gap(14),
      const Row(
        children: [
          Expanded(child: _FriendsSkeletonBox(height: 50, radius: 18)),
          Gap(8),
          Expanded(child: _FriendsSkeletonBox(height: 50, radius: 18)),
        ],
      ),
      const Gap(18),
      const _FriendsSkeletonBox(width: 120, height: 15, radius: 6),
      const Gap(12),
      const Column(
        children: [
          _FriendSkeletonRow(),
          Gap(10),
          _FriendSkeletonRow(),
          Gap(10),
          _FriendSkeletonRow(),
        ],
      ),
    ],
  );
}

class _FriendSkeletonRow extends StatelessWidget {
  const _FriendSkeletonRow();

  @override
  Widget build(BuildContext context) => Container(
    height: 72,
    padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
    decoration: BoxDecoration(
      color: context.colorTokens.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: context.colorTokens.borderUnfocused),
      boxShadow: [
        BoxShadow(
          color: context.colorTokens.surfaceShadow.withValues(alpha: 0.08),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.colorTokens.surfaceInnerLayer,
            shape: BoxShape.circle,
          ),
        ),
        const Gap(10),
        const _FriendsSkeletonBox(width: 132, height: 14, radius: 6),
      ],
    ),
  );
}

class _FriendsSkeletonBox extends StatelessWidget {
  const _FriendsSkeletonBox({
    required this.height,
    this.width,
    this.radius = 8,
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
