import "dart:convert";
import "dart:typed_data";

import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/core/domain/entities/group_activity_progress_entity.dart";
import "package:timing/core/domain/entities/friend_entity.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/domain/entities/group_image_message_entity.dart";
import "package:timing/core/domain/entities/group_member_entity.dart";
import "package:timing/core/domain/entities/subject_entity.dart";
import "package:timing/core/domain/enums/group_theme_type.dart";
import "package:timing/core/domain/enums/leaderboard_period_type.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/shared/extensions/enum_localization_extensions.dart";
import "package:timing/presentation/groups/group_leaderboard_formatters.dart";
import "package:timing/presentation/groups/groups_controller.dart";
import "package:timing/presentation/groups/widgets/current_user_rank_card.dart";
import "package:timing/presentation/groups/widgets/group_member_avatar.dart";
import "package:timing/presentation/groups/widgets/groups_header.dart";
import "package:timing/presentation/groups/widgets/leaderboard_tile.dart";
import "package:timing/shared/functions/format_duration.dart";
import "package:timing/shared/functions/format_schedule_time.dart";
import "package:timing/shared/widgets/animated_segmented_tabs.dart";
import "package:timing/shared/widgets/app_empty_state.dart";
import "package:timing/shared/widgets/app_icon.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_skeleton.dart";
import "package:timing/shared/widgets/app_top_bar.dart";
import "package:timing/shared/widgets/bounce_tap.dart";
import "package:timing/shared/widgets/swipe_reveal_actions.dart";
import "package:timing/theme/app_spacing.dart";
import "package:timing/theme/app_surfaces.dart";

part "groups_page_ranking.dart";
part "groups_page_manage_members.dart";
part "groups_page_details.dart";
part "groups_page_goals_tab.dart";
part "groups_page_chat.dart";
part "groups_page_actions_sheet.dart";
part "groups_page_placeholders.dart";

/// Answers "how am I doing next to other people?". Owns both the group
/// leaderboards and the friends area they are built from.
class GroupsPage extends StatelessWidget {
  const GroupsPage({this.showGroupFlowOnly = false, super.key});

  final bool showGroupFlowOnly;

  @override
  Widget build(BuildContext context) {
    final GroupsController controller = Get.find();

    if (showGroupFlowOnly) {
      return Obx(() {
        if (controller.isShowingMemberManagement.value) {
          return AppScaffold(body: _ManageMembersView(controller: controller));
        }
        return AppScaffold(body: _GroupDetailsView(controller: controller));
      });
    }

    return AppScaffold(body: _GroupsHomeView(controller: controller));
  }
}

class _GroupsHomeView extends StatelessWidget {
  const _GroupsHomeView({required this.controller});

  final GroupsController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Gap(16),
      GroupsHeader(onTapCreateGroup: controller.onTapCreateGroup),
      const Gap(AppSpacing.betweenSections),
      Expanded(
        child: Obx(() {
          if (controller.isLoading.value && controller.groups.isEmpty) {
            return const _GroupsLoadingSkeleton();
          }

          if (controller.didFailLoadingGroups.value &&
              controller.groups.isEmpty) {
            return _GroupsLoadErrorState(onRetry: controller.loadGroups);
          }

          if (controller.groups.isEmpty) {
            return _GroupsEmptyState(
              onCreateGroup: controller.onTapCreateGroup,
              onTapFriends: controller.onTapFriends,
            );
          }

          return _GroupsList(
            groups: controller.groups,
            friends: controller.friends,
            isLoading: controller.isLoading.value,
            isLoadingFriends: controller.isLoadingFriends.value,
            onTapFriends: controller.onTapFriends,
            onSelectGroup: controller.onSelectGroup,
          );
        }),
      ),
    ],
  );
}

class _GroupDetailsView extends StatelessWidget {
  const _GroupDetailsView({required this.controller});

  final GroupsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final GroupEntity? group = controller.selectedGroup.value;
      final List<GroupMemberEntity> members = controller.rankedMembers;

      if (group == null || members.isEmpty) {
        return Center(
          child: Text(
            context.l10n.noGroupSelected,
            style: context.textStyles.caption,
          ),
        );
      }

      return Column(
        children: [
          const Gap(4),
          _GroupDetailsHeader(
            group: group,
            isLoading: controller.isLoading.value,
            onBack: controller.onBackToGroupList,
            onActions: () => _showGroupActionsSheet(context, controller),
          ),
          const Gap(8),
          _GroupDetailsTabsScope(controller: controller),
          const Gap(10),
          Expanded(
            child: _GroupDetailsContent(
              controller: controller,
              group: group,
              members: members,
            ),
          ),
        ],
      );
    });
  }
}

class _GroupsList extends StatelessWidget {
  const _GroupsList({
    required this.groups,
    required this.friends,
    required this.isLoading,
    required this.isLoadingFriends,
    required this.onTapFriends,
    required this.onSelectGroup,
  });

  final List<GroupEntity> groups;
  final List<FriendEntity> friends;
  final bool isLoading;
  final bool isLoadingFriends;
  final VoidCallback onTapFriends;
  final ValueChanged<GroupEntity> onSelectGroup;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.only(bottom: AppSpacing.betweenSections),
    itemCount: groups.length + 1,
    separatorBuilder: (_, _) => const Gap(AppSpacing.betweenRelated),
    itemBuilder: (context, index) {
      if (index == 0) {
        return _FriendsCard(
          groupCount: groups.length,
          friends: friends,
          isLoading: isLoading || isLoadingFriends,
          onTap: onTapFriends,
        );
      }
      final GroupEntity group = groups[index - 1];
      return _GroupCard(group: group, onTap: () => onSelectGroup(group));
    },
  );
}

class _GroupSectionTitle extends StatelessWidget {
  const _GroupSectionTitle({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 5,
        height: 22,
        decoration: BoxDecoration(
          color: context.colorTokens.primary,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      const Gap(10),
      Expanded(
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.sectionTitle.copyWith(
            color: context.colorTokens.textBody,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      if (trailing != null) ...[const Gap(12), trailing!],
    ],
  );
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group, required this.onTap});

  final GroupEntity group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String description = group.description.trim();

    return BounceTap(
      key: ValueKey<String>("group-card-${group.id}"),
      onTap: onTap,
      pressedScale: 0.98,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppSurfaces.content(context.colorTokens),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GroupIcon(theme: group.theme, size: 72, iconSize: 34),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizedGroupName(context, group),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.black20.copyWith(fontSize: 22),
                  ),
                  if (description.isNotEmpty) ...[
                    const Gap(4),
                    Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodyMedium.copyWith(
                        height: 1.28,
                      ),
                    ),
                  ],
                  const Gap(12),
                  _OverlappingMembers(members: group.members),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendsCard extends StatelessWidget {
  const _FriendsCard({
    required this.groupCount,
    required this.friends,
    required this.isLoading,
    required this.onTap,
  });

  final int groupCount;
  final List<FriendEntity> friends;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BounceTap(
    key: const ValueKey<String>("friends-card"),
    onTap: onTap,
    pressedScale: 0.98,
    child: Container(
      constraints: const BoxConstraints(minHeight: 78),
      padding: const EdgeInsets.all(14),
      decoration: AppSurfaces.content(context.colorTokens),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: context.colorTokens.primaryVeryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline_rounded,
              size: 26,
              color: context.colorTokens.primary,
            ),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.l10n.groupsFriendsTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.cardTitle.copyWith(
                    color: context.colorTokens.primary,
                  ),
                ),
                const Gap(3),
                if (isLoading)
                  const AppSkeleton(
                    child: AppSkeletonBox(height: 14, width: 170, radius: 4),
                  )
                else
                  Text(
                    friendsCardSubtitle(context, groupCount),
                    key: const ValueKey<String>("friends-card-description"),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colorTokens.textBody,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (isLoading || friends.isNotEmpty) ...[
                  const Gap(8),
                  SizedBox(
                    key: const ValueKey<String>("friends-card-avatar-slot"),
                    width: 90,
                    height: 30,
                    child: isLoading
                        ? const AppSkeleton(
                            child: AppSkeletonBox(height: 30, radius: 999),
                          )
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: _OverlappingFriends(friends: friends),
                          ),
                  ),
                ],
              ],
            ),
          ),
          const Gap(12),
          Icon(
            Icons.chevron_right_rounded,
            size: 28,
            color: context.colorTokens.textHint,
          ),
        ],
      ),
    ),
  );
}

class _OverlappingFriends extends StatelessWidget {
  const _OverlappingFriends({required this.friends});

  final List<FriendEntity> friends;

  @override
  Widget build(BuildContext context) {
    const int visibleCount = 3;
    const double size = 30;
    const double overlap = 10;
    final List<FriendEntity> visibleFriends = friends
        .take(visibleCount)
        .toList();
    final int extraCount = friends.length - visibleFriends.length;

    return SizedBox(
      height: size,
      width:
          size +
          (visibleFriends.length - 1) * (size - overlap) +
          (extraCount > 0 ? size - overlap : 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int index = 0; index < visibleFriends.length; index++)
            Positioned(
              left: index * (size - overlap),
              child: GroupMemberAvatar(
                key: ValueKey<String>(
                  "friends-card-avatar-${visibleFriends[index].id}",
                ),
                name: visibleFriends[index].name,
                colorValue: visibleFriends[index].colorValue,
                avatarIconIndex: visibleFriends[index].avatarIconIndex,
                avatar: visibleFriends[index].profilePhotoBase64,
                size: size,
                borderColor: context.colorTokens.surface,
                useSolidFallbackBackground: true,
              ),
            ),
          if (extraCount > 0)
            Positioned(
              left: visibleFriends.length * (size - overlap),
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colorTokens.primaryVeryLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.colorTokens.surface,
                    width: 2,
                  ),
                ),
                child: Text(
                  "+$extraCount",
                  style: context.textStyles.bodyTiny.copyWith(
                    color: context.colorTokens.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OverlappingMembers extends StatelessWidget {
  const _OverlappingMembers({required this.members});

  final List<GroupMemberEntity> members;

  @override
  Widget build(BuildContext context) {
    const int visibleCount = 3;
    const double size = 30;
    const double overlap = 10;
    final List<GroupMemberEntity> visibleMembers = members
        .take(visibleCount)
        .toList();
    final int extraCount = members.length - visibleMembers.length;

    return SizedBox(
      height: size,
      width: visibleMembers.isEmpty
          ? 0
          : size +
                (visibleMembers.length - 1) * (size - overlap) +
                (extraCount > 0 ? size - overlap : 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int index = 0; index < visibleMembers.length; index++)
            Positioned(
              left: index * (size - overlap),
              child: GroupMemberAvatar(
                name: visibleMembers[index].name,
                colorValue: visibleMembers[index].avatarColorValue,
                avatar: visibleMembers[index].avatar,
                avatarIconIndex: visibleMembers[index].avatarIconIndex,
                size: size,
                borderColor: context.colorTokens.surface,
              ),
            ),
          if (extraCount > 0)
            Positioned(
              left: visibleMembers.length * (size - overlap),
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colorTokens.primaryVeryLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.colorTokens.surface,
                    width: 2,
                  ),
                ),
                child: Text(
                  "+$extraCount",
                  maxLines: 1,
                  style: context.textStyles.bodyTiny.copyWith(
                    color: context.colorTokens.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GroupIcon extends StatelessWidget {
  const _GroupIcon({
    required this.theme,
    required this.size,
    required this.iconSize,
  });

  final GroupThemeType theme;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: context.colorTokens.primaryGradient,
      shape: BoxShape.circle,
    ),
    child: Center(
      child: AppIcon(
        theme.iconName,
        size: iconSize,
        color: context.colorTokens.primaryForeground,
      ),
    ),
  );
}

GroupMemberEntity? _leaderFor(GroupEntity group) {
  for (final GroupMemberEntity member in group.members) {
    if (member.id == group.ownerId || member.role == "owner") {
      return member;
    }
  }
  return group.members.isEmpty ? null : group.members.first;
}
