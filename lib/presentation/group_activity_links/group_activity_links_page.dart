import "package:timing/core/services/sync/group_activity_link_sync.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/domain/entities/group_activity_link_options.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/group_activity_links/activity_source_selector.dart";

Future<void> showGroupActivityLinks(GroupEntity group) async {
  if (Get.context == null) return;
  await Navigator.of(Get.context!, rootNavigator: true).push<void>(
    MaterialPageRoute(builder: (_) => GroupActivityLinksPage(group: group)),
  );
}

class GroupActivityLinksPage extends StatefulWidget {
  const GroupActivityLinksPage({super.key, required this.group});
  final GroupEntity group;

  @override
  State<GroupActivityLinksPage> createState() => _GroupActivityLinksPageState();
}

class _GroupActivityLinksPageState extends State<GroupActivityLinksPage> {
  final _repository = Get.find<GroupsRepository>();
  List<GroupActivityLinkOptions> _activities = [];
  final Map<String, Set<String>> _selected = {};
  final Map<String, bool> _useExisting = {};
  bool _loading = true;
  bool _saving = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    if (!await preparePersonalActivitiesForLinking()) {
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
      return;
    }
    final result = await _repository.getActivityLinkOptions(widget.group.id);
    if (!mounted) return;
    setState(() {
      _loading = false;
      result.fold((_) => _failed = true, (activities) {
        _activities = activities;
        for (final activity in activities) {
          _selected[activity.activityId] = {...activity.selectedIds};
          _useExisting[activity.activityId] =
              activity.selectedIds.isNotEmpty || activity.options.isNotEmpty;
        }
      });
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    if (!await preparePersonalActivitiesForLinking()) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.groupLinksSyncError)),
        );
      }
      return;
    }
    for (final activity in _activities) {
      final existing = _useExisting[activity.activityId]!;
      final result = await _repository.setActivityLinks(
        activityId: activity.activityId,
        sourceIds: existing ? _selected[activity.activityId]!.toList() : [],
        createNew: !existing,
      );
      if (!mounted) return;
      if (result.isLeft()) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.groupLinksSaveError)),
        );
        return;
      }
    }
    await refreshPersonalActivitiesAfterLinking();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: Scaffold(
      appBar: AppBar(title: Text(context.l10n.groupLinksTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _failed
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(context.l10n.groupLinksSyncError),
                  ),
                  TextButton(
                    onPressed: _load,
                    child: Text(context.l10n.groupLinksRetry),
                  ),
                ],
              ),
            )
          : AbsorbPointer(
              absorbing: _saving,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    widget.group.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  for (final activity in _activities) ...[
                    Text(
                      activity.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    ActivitySourceSelector(
                      useExisting: _useExisting[activity.activityId]!,
                      options: activity.options,
                      selectedIds: _selected[activity.activityId]!,
                      isReading: activity.isReading,
                      onModeChanged: (value) => setState(
                        () => _useExisting[activity.activityId] = value,
                      ),
                      onToggle: (id) => setState(() {
                        final ids = _selected[activity.activityId]!;
                        if (!ids.remove(id)) ids.add(id);
                      }),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_activities.isEmpty) Text(context.l10n.groupLinksEmpty),
                  if (_activities.isNotEmpty)
                    FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(),
                            )
                          : Text(context.l10n.groupLinksSave),
                    ),
                ],
              ),
            ),
    ),
  );
}
