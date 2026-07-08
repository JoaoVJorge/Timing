import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/domain/entities/group_entity.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/groups/group_leaderboard_formatters.dart";
import "package:help_out/presentation/groups/widgets/create_group_chip.dart";
import "package:help_out/presentation/groups/widgets/group_chip.dart";

class GroupSelector extends StatelessWidget {
  const GroupSelector({
    required this.groups,
    required this.selectedGroupId,
    required this.onSelectGroup,
    required this.onCreateGroup,
    super.key,
  });

  final List<GroupEntity> groups;
  final String? selectedGroupId;
  final ValueChanged<GroupEntity> onSelectGroup;
  final VoidCallback onCreateGroup;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return const SizedBox.shrink();
    }

    return Semantics(
      label: context.l10n.groupsTitle,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int index = 0; index < groups.length; index++) ...[
              if (index > 0) const Gap(8),
              GroupChip(
                group: groups[index],
                label: localizedGroupName(context, groups[index]),
                isSelected: groups[index].id == selectedGroupId,
                onTap: () => onSelectGroup(groups[index]),
              ),
            ],
            const Gap(8),
            CreateGroupChip(onTap: onCreateGroup),
          ],
        ),
      ),
    );
  }
}
