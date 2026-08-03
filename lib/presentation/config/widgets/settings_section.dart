import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/theme/app_spacing.dart";
import "package:help_out/theme/app_surfaces.dart";

/// Groups related settings behind a single border with dividers, so a screen of
/// options does not read as a screen of equally important cards.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.sectionTitle.copyWith(fontSize: 16),
      ),
      const Gap(AppSpacing.betweenRelated),
      Container(
        clipBehavior: Clip.antiAlias,
        decoration: AppSurfaces.rowGroup(context.colorTokens),
        child: Column(
          children: [
            for (int index = 0; index < children.length; index++) ...[
              if (index > 0)
                Divider(
                  height: 1,
                  indent: 70,
                  endIndent: 16,
                  color: context.colorTokens.divider,
                ),
              children[index],
            ],
          ],
        ),
      ),
    ],
  );
}
