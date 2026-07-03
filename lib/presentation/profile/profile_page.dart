import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/profile/profile_controller.dart";
import "package:help_out/presentation/profile/widgets/stat_card.dart";
import "package:help_out/presentation/profile/widgets/top_theme_tile.dart";
import "package:help_out/shared/functions/format_duration.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find();

    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(16),
            Text("Your Progress", style: context.textStyles.titleFont),
            const Gap(4),
            Obx(
              () => Text(
                controller.userName.value.isEmpty ? "Accomplishments" : "Great work, ${controller.userName.value}",
                style: context.textStyles.bodyMedium.copyWith(color: context.colorTokens.textHint),
              ),
            ),
            const Gap(24),
            Obx(() {
              final stats = controller.stats.value;
              return GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  mainAxisExtent: 148,
                ),
                children: [
                  StatCard(
                    icon: Icons.school_outlined,
                    label: "Hours studied",
                    value: formatDurationLong(Duration(seconds: stats.studyingTotalSeconds)),
                  ),
                  StatCard(
                    icon: Icons.emoji_events_outlined,
                    label: "Top subject",
                    value: stats.topStudyingSubject?.name ?? "—",
                  ),
                  StatCard(
                    icon: Icons.work_outline,
                    label: "Hours worked",
                    value: formatDurationLong(Duration(seconds: stats.workingTotalSeconds)),
                  ),
                  StatCard(
                    icon: Icons.menu_book_outlined,
                    label: "Hours read",
                    value: formatDurationLong(Duration(seconds: stats.readingTotalSeconds)),
                  ),
                ],
              );
            }),
            const Gap(24),
            Text("Most read themes", style: context.textStyles.extraBold20),
            const Gap(12),
            Obx(() {
              final topReadingSubjects = controller.stats.value.topReadingSubjects;

              if (topReadingSubjects.isEmpty) {
                return Text(
                  "Read something to see your top themes here.",
                  style: context.textStyles.bodyMedium.copyWith(color: context.colorTokens.textHint),
                );
              }

              return Column(
                children: [
                  for (int index = 0; index < topReadingSubjects.length; index++) ...[
                    if (index > 0) const Gap(12),
                    TopThemeTile(rank: index + 1, subject: topReadingSubjects[index]),
                  ],
                ],
              );
            }),
            const Gap(24),
          ],
        ),
      ),
    );
  }
}
