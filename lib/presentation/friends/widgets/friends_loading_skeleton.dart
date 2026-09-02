import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/widgets/app_skeleton.dart";

class FriendsLoadingSkeleton extends StatelessWidget {
  const FriendsLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const AppSkeleton(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(14),
        Row(
          children: [
            Expanded(child: AppSkeletonBox(height: 50, radius: 18)),
            Gap(8),
            Expanded(child: AppSkeletonBox(height: 50, radius: 18)),
          ],
        ),
        Gap(18),
        AppSkeletonBox(width: 120, height: 15, radius: 6),
        Gap(12),
        Column(
          children: [
            _FriendSkeletonRow(),
            Gap(10),
            _FriendSkeletonRow(),
          ],
        ),
      ],
    ),
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
    child: const Row(
      children: [
        AppSkeletonCircle(size: 40),
        Gap(10),
        AppSkeletonBox(width: 132, height: 14, radius: 6),
      ],
    ),
  );
}
