import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";
import "package:help_out/shared/widgets/app_icon.dart";

class DialogTopBar extends StatelessWidget {
  const DialogTopBar({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    const double size = 15;

    return Row(
      children: [
        GestureDetector(
          onTap: appNavigator.back,
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            color: Colors.transparent,
            child: AppIcon(
              "left_back",
              size: size,
              color: context.colorTokens.textBody,
            ),
          ),
        ),
        const Gap(8),
        Expanded(
          child: Text(
            title,
            style: context.textStyles.extraBold20,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
