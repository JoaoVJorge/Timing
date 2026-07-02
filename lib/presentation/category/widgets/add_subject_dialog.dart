import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:help_out/app/app_navigator.dart";
import "package:help_out/core/utils/extensions/context_extensions.dart";

class AddSubjectDialog extends StatefulWidget {
  const AddSubjectDialog({super.key});

  @override
  State<AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<AddSubjectDialog> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text("Add Subject"),
    content: TextField(
      controller: _nameController,
      autofocus: true,
      decoration: const InputDecoration(hintText: "Subject name"),
    ),
    actions: [
      TextButton(onPressed: () => appNavigator.back<String>(), child: const Text("Cancel")),
      const Gap(4),
      FilledButton(
        style: FilledButton.styleFrom(backgroundColor: context.colorTokens.primary),
        onPressed: () => appNavigator.back<String>(result: _nameController.text),
        child: const Text("Add"),
      ),
    ],
  );
}
