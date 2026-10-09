import "package:flutter/widgets.dart";
import "package:get/get.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";

typedef FaqEntry = ({String question, String answer});

class FaqController extends GetxController {
  /// Ordered from the questions a new user asks first (the timer, creating an
  /// activity) to the ones that only come up later (groups, sync, looks).
  List<FaqEntry> entries(BuildContext context) => [
    (question: context.l10n.faqQ1, answer: context.l10n.faqA1),
    (question: context.l10n.faqQ2, answer: context.l10n.faqA2),
    (question: context.l10n.faqQ3, answer: context.l10n.faqA3),
    (question: context.l10n.faqQ4, answer: context.l10n.faqA4),
    (question: context.l10n.faqQ5, answer: context.l10n.faqA5),
    (question: context.l10n.faqQ6, answer: context.l10n.faqA6),
    (question: context.l10n.faqQ7, answer: context.l10n.faqA7),
    (question: context.l10n.faqQ8, answer: context.l10n.faqA8),
    (question: context.l10n.faqQ9, answer: context.l10n.faqA9),
    (question: context.l10n.faqQ10, answer: context.l10n.faqA10),
    (question: context.l10n.faqQ11, answer: context.l10n.faqA11),
    (question: context.l10n.faqQ12, answer: context.l10n.faqA12),
    (question: context.l10n.faqQ13, answer: context.l10n.faqA13),
  ];
}
