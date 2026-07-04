import "package:flutter/widgets.dart";
import "package:get/get.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

typedef FaqEntry = ({String question, String answer});

class FaqController extends GetxController {
  List<FaqEntry> entries(BuildContext context) => [
    (question: context.l10n.faqQ1, answer: context.l10n.faqA1),
    (question: context.l10n.faqQ2, answer: context.l10n.faqA2),
    (question: context.l10n.faqQ3, answer: context.l10n.faqA3),
    (question: context.l10n.faqQ4, answer: context.l10n.faqA4),
    (question: context.l10n.faqQ5, answer: context.l10n.faqA5),
  ];
}
