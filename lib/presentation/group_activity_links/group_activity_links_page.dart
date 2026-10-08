import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:get/get.dart";
import "package:timing/core/data/repositories/groups_repository.dart";
import "package:timing/core/domain/entities/group_activity_link_options.dart";
import "package:timing/core/domain/entities/group_entity.dart";
import "package:timing/core/utils/extensions/context_extensions.dart";
import "package:timing/presentation/group_activity_links/activity_source_selector.dart";
import "package:timing/core/services/sync/group_activity_link_sync.dart";
import "package:timing/shared/widgets/app_empty_state.dart";
import "package:timing/shared/widgets/app_icon.dart";
import "package:timing/shared/widgets/app_scaffold.dart";
import "package:timing/shared/widgets/app_skeleton.dart";
import "package:timing/shared/widgets/app_top_bar.dart";
import "package:timing/shared/widgets/bounce_tap.dart";
import "package:timing/theme/app_spacing.dart";
import "package:timing/theme/app_surfaces.dart";
import "package:timing/theme/colors.dart";

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
    if (_saving) return;
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
    child: AppScaffold(
      backgroundColor: context.creationPageBackground,
      topBar: AppTopBar(
        title: context.l10n.groupLinksTitle,
        showBackButton: true,
        onBack: () {
          if (!_saving) Navigator.of(context).maybePop();
        },
      ),
      bottomBar: !_loading && !_failed && _activities.isNotEmpty
          ? _saveButton(context)
          : null,
      body: _loading
          ? const _LinksLoading()
          : SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: AppSpacing.betweenSections,
              ),
              child: _failed
                  ? AppEmptyState(
                      icon: Icons.cloud_off_rounded,
                      title: context.l10n.groupLinksTitle,
                      description: context.l10n.groupLinksSyncError,
                      actionLabel: context.l10n.groupLinksRetry,
                      onTapAction: _load,
                    )
                  : AbsorbPointer(
                      absorbing: _saving,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _groupHeader(context),
                          const Gap(AppSpacing.betweenSections),
                          if (_activities.isEmpty)
                            AppEmptyState(
                              icon: Icons.link_off_rounded,
                              title: context.l10n.groupLinksSharedTarget,
                              description: context.l10n.groupLinksEmpty,
                            ),
                          for (final activity in _activities) ...[
                            ActivitySourceSelector(
                              title: activity.name,
                              accent: _activityAccent(context, activity),
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
                            const Gap(AppSpacing.betweenRelated),
                          ],
                        ],
                      ),
                    ),
            ),
    ),
  );

  Color _activityAccent(
    BuildContext context,
    GroupActivityLinkOptions activity,
  ) {
    final value = activity.payload["color_value"] as num?;
    if (value == null) return context.colorTokens.primary;
    return AppColorTokens.fromSeed(
      seed: Color(value.toInt()),
      isDark: Theme.of(context).brightness == Brightness.dark,
    ).primary;
  }

  Widget _groupHeader(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: AppSurfaces.content(context.colorTokens),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.colorTokens.primaryVeryLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: AppIcon(
            widget.group.theme.iconName,
            size: 25,
            color: context.colorTokens.primary,
          ),
        ),
        const Gap(14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.group.name, style: context.textStyles.cardTitle),
              const Gap(4),
              Text(
                context.l10n.groupLinksSharedTarget,
                style: context.textStyles.caption,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _saveButton(BuildContext context) => Semantics(
    button: true,
    enabled: !_saving,
    child: BounceTap(
      behavior: HitTestBehavior.opaque,
      pressedScale: 0.98,
      onTap: _save,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: context.colorTokens.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: _saving
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.colorTokens.primaryForeground,
                ),
              )
            : Text(
                context.l10n.groupLinksSave,
                textAlign: TextAlign.center,
                style: context.textStyles.textPrimaryButton,
              ),
      ),
    ),
  );
}

class _LinksLoading extends StatelessWidget {
  const _LinksLoading();

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.only(top: 8),
    child: AppSkeleton(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSkeletonBox(height: 92, radius: 20),
          const Gap(AppSpacing.betweenSections),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppSurfaces.content(context.colorTokens),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonBox(height: 22, width: 180, radius: 6),
                Gap(16),
                AppSkeletonBox(height: 60, radius: 12),
                Gap(10),
                AppSkeletonBox(height: 60, radius: 12),
                Gap(24),
                AppSkeletonBox(height: 18, width: 140, radius: 6),
                Gap(12),
                AppSkeletonBox(height: 64, radius: 12),
                Gap(8),
                AppSkeletonBox(height: 64, radius: 12),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
