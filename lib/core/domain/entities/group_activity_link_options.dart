/// One of the member's own activities (or goals) that fits a group's theme.
class GroupActivitySourceOption {
  const GroupActivitySourceOption({required this.id, required this.name});

  factory GroupActivitySourceOption.fromMap(Map<String, dynamic> map) =>
      GroupActivitySourceOption(
        id: map["id"] as String,
        name: map["name"] as String,
      );

  final String id;
  final String name;
}

/// What the member can link to a group: their activities of the group's
/// theme, and the ones linked right now.
class GroupActivityLinkOptions {
  const GroupActivityLinkOptions({
    required this.selectedIds,
    required this.options,
  });

  factory GroupActivityLinkOptions.fromMap(Map<String, dynamic> map) =>
      GroupActivityLinkOptions(
        selectedIds: Set<String>.from(map["selected_ids"] as List? ?? const []),
        options: (map["options"] as List? ?? const [])
            .map(
              (item) => GroupActivitySourceOption.fromMap(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList(),
      );

  final Set<String> selectedIds;
  final List<GroupActivitySourceOption> options;
}
