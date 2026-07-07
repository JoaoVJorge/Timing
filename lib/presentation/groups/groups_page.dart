import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/domain/entities/group_entity.dart";
import "package:help_out/core/domain/entities/group_member_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/groups/groups_controller.dart";
import "package:help_out/presentation/groups/widgets/create_group_chip.dart";
import "package:help_out/presentation/groups/widgets/group_chip.dart";
import "package:help_out/presentation/groups/widgets/leaderboard_tile.dart";
import "package:help_out/presentation/groups/widgets/period_selector.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GroupsController controller = Get.find();

    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(16),
          Text(context.l10n.groupsTitle, style: context.textStyles.titleFont),
          const Gap(16),
          Obx(() {
            final List<GroupEntity> groups = controller.groups;
            final String? selectedGroupId = controller.selectedGroup.value?.id;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int index = 0; index < groups.length; index++) ...[
                    if (index > 0) const Gap(8),
                    GroupChip(
                      group: groups[index],
                      isSelected: groups[index].id == selectedGroupId,
                      onTap: () => controller.onSelectGroup(groups[index]),
                    ),
                  ],
                  if (groups.isNotEmpty) const Gap(8),
                  CreateGroupChip(onTap: controller.onTapCreateGroup),
                ],
              ),
            );
          }),
          const Gap(20),
          Obx(
            () => PeriodSelector(
              selectedPeriod: controller.selectedPeriod.value,
              onSelectPeriod: controller.onSelectPeriod,
            ),
          ),
          const Gap(20),
          Expanded(
            child: Obx(() {
              final List<GroupMemberEntity> members = controller.rankedMembers;
              final GroupEntity? group = controller.selectedGroup.value;

              if (members.isEmpty || group == null) {
                return Center(
                  child: Text(
                    context.l10n.noGroupSelected,
                    style: context.textStyles.bodyMedium.copyWith(
                      color: context.colorTokens.textHint,
                    ),
                  ),
                );
              }

              return ListView.separated(
                itemCount: members.length,
                separatorBuilder: (context, index) => const Gap(12),
                itemBuilder: (context, index) => LeaderboardTile(
                  rank: index + 1,
                  member: members[index],
                  theme: group.theme,
                  value: members[index].secondsFor(
                    controller.selectedPeriod.value,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
