import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/presentation/faq/faq_controller.dart";
import "package:help_out/shared/widgets/app_scaffold.dart";
import "package:help_out/shared/widgets/app_top_bar.dart";

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FaqController controller = Get.find();
    final List<FaqEntry> entries = controller.entries(context);

    return AppScaffold(
      topBar: AppTopBar(title: context.l10n.faqTitle, showBackButton: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: entries.length,
              separatorBuilder: (context, index) => const Gap(12),
              itemBuilder: (context, index) {
                final FaqEntry entry = entries[index];
                return _FaqExpansionCard(entry: entry);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqExpansionCard extends StatefulWidget {
  const _FaqExpansionCard({required this.entry});

  final FaqEntry entry;

  @override
  State<_FaqExpansionCard> createState() => _FaqExpansionCardState();
}

class _FaqExpansionCardState extends State<_FaqExpansionCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => setState(() => isExpanded = !isExpanded),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: isExpanded ? 4 : 12,
          left: 4,
          right: 4,
          top: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.entry.question,
                      style: context.textStyles.cardTitle,
                    ),
                  ),
                  const Gap(12),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: context.colorTokens.primary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: context.colorTokens.surfaceShadow,
                  ),
                  child: Text(
                    widget.entry.answer,
                    style: context.textStyles.caption.copyWith(height: 1.4),
                  ),
                ),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 180),
              sizeCurve: Curves.easeOutCubic,
            ),
          ],
        ),
      ),
    ),
  );
}
