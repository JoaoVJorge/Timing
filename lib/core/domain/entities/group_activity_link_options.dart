class GroupActivitySourceOption {
  const GroupActivitySourceOption({required this.id, required this.name});

  factory GroupActivitySourceOption.fromMap(Map<String, dynamic> map) =>
      GroupActivitySourceOption(
        id: map['id'] as String,
        name: map['name'] as String,
      );

  final String id;
  final String name;
}

class GroupActivityLinkOptions {
  const GroupActivityLinkOptions({
    required this.activityId,
    required this.payload,
    required this.name,
    required this.isReading,
    required this.selectedIds,
    required this.options,
  });

  factory GroupActivityLinkOptions.fromMap(Map<String, dynamic> map) {
    final payload = Map<String, dynamic>.from(map['payload'] as Map);
    return GroupActivityLinkOptions(
      activityId: map['id'] as String,
      payload: payload,
      name: payload['name'] as String? ?? '',
      isReading: payload['category'] == 'reading',
      selectedIds: Set<String>.from(map['selected_ids'] as List),
      options: (map['options'] as List)
          .map(
            (item) => GroupActivitySourceOption.fromMap(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }

  final String activityId;
  final Map<String, dynamic> payload;
  final String name;
  final bool isReading;
  final Set<String> selectedIds;
  final List<GroupActivitySourceOption> options;
}
