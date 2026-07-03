import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/faq/faq_controller.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FaqController controller = Get.find();

    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(16),
          Row(
            children: [
              IconButton(onPressed: appNavigator.back, icon: Icon(Icons.arrow_back, color: context.colorTokens.textBody)),
              Text("FAQ", style: context.textStyles.titleFont),
            ],
          ),
          const Gap(16),
          Expanded(
            child: ListView.separated(
              itemCount: controller.entries.length,
              separatorBuilder: (context, index) => const Gap(12),
              itemBuilder: (context, index) {
                final FaqEntry entry = controller.entries[index];
                return Container(
                  decoration: BoxDecoration(color: context.colorTokens.surface, borderRadius: BorderRadius.circular(16)),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      expandedAlignment: Alignment.centerLeft,
                      iconColor: context.colorTokens.primary,
                      collapsedIconColor: context.colorTokens.textHint,
                      title: Text(entry.question, style: context.textStyles.bodyLarge),
                      children: [
                        Text(
                          entry.answer,
                          style: context.textStyles.bodyMedium.copyWith(color: context.colorTokens.textHint),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
