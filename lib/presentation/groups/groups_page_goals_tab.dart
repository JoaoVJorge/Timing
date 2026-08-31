part of "groups_page.dart";

// The "goals" tab: a group's shared activity progress and statistics.

class _GoalsTab extends StatefulWidget {
  const _GoalsTab({required this.controller, required this.group});

  final GroupsController controller;
  final GroupEntity group;

  @override
  State<_GoalsTab> createState() => _GoalsTabState();
}

class _GoalsTabState extends State<_GoalsTab> {
  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  @override
  void didUpdateWidget(_GoalsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.group.id != widget.group.id) {
      _loadProgress();
    }
  }

  void _loadProgress() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.controller.loadActivityProgress();
      }
    });
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _GroupActivityDataView(
        controller: widget.controller,
        group: widget.group,
      ),
    ],
  );
}

class _GroupActivityDataView extends StatelessWidget {
  const _GroupActivityDataView({required this.controller, required this.group});

  final GroupsController controller;
  final GroupEntity group;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<GroupActivityProgressEntity> headers =
          controller.activityHeaders;
      if (controller.isLoadingActivityProgress.value && headers.isEmpty) {
        return const _InlineLoadingIndicator();
      }
      if (headers.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        children: [
          for (final GroupActivityProgressEntity header in headers) ...[
            _activityData(context, controller, header),
            const Gap(AppSpacing.betweenSections),
          ],
        ],
      );
    });
  }

  Widget _activityData(
    BuildContext context,
    GroupsController controller,
    GroupActivityProgressEntity header,
  ) {
    if (header.isGoal) {
      return _goalData(context, controller, header);
    }

    final LeaderboardPeriodType period = controller.selectedPeriod.value;
    final int total = group.members.length;
    final int focusSeconds = header.focusSeconds > 0
        ? header.focusSeconds
        : header.target;
    final int targetPerMember = _targetForPeriod(
      header.target > 0 ? header.target : focusSeconds,
      period,
      since: group.createdAt,
    );
    final Map<String, int> progressByMember = {
      for (final GroupMemberEntity member in group.members)
        member.id: member.secondsFor(period),
    };
    final List<GroupMemberEntity> completedMembers = group.members
        .where(
          (member) => (progressByMember[member.id] ?? 0) >= targetPerMember,
        )
        .toList();
    final List<GroupMemberEntity> pendingMembers = group.members
        .where((member) => (progressByMember[member.id] ?? 0) < targetPerMember)
        .toList();
    final int reached = completedMembers.length;
    final int totalPeriodValue = group.members.fold<int>(
      0,
      (sum, member) => sum + (progressByMember[member.id] ?? 0),
    );

    return Column(
      children: [
        _ParticipantsProgressCard(
          total: total,
          completedMembers: completedMembers,
          pendingMembers: pendingMembers,
          progressByMember: progressByMember,
          targetPerMember: targetPerMember,
          targetByMember: const {},
          unit: group.theme.unit,
        ),
        const Gap(AppSpacing.betweenRelated),
        _GroupStatisticsCard(
          totalPeriodValue: totalPeriodValue,
          completedSessions: reached,
          participants: total,
          unit: group.theme.unit,
          period: period,
        ),
        const Gap(AppSpacing.betweenRelated),
        _ActivityOverviewCard(
          group: group,
          header: header,
          focusSeconds: focusSeconds,
          goalProgress: 0,
          goalTarget: 0,
        ),
      ],
    );
  }

  Widget _goalData(
    BuildContext context,
    GroupsController controller,
    GroupActivityProgressEntity header,
  ) {
    final List<GroupActivityProgressEntity> rows = controller.activityProgress
        .where((item) => item.activityId == header.activityId)
        .toList();
    final Map<String, GroupActivityProgressEntity> progressByMemberId = {
      for (final GroupActivityProgressEntity item in rows) item.memberId: item,
    };
    final int fallbackTarget = rows.fold<int>(
      header.target,
      (largest, item) => item.target > largest ? item.target : largest,
    );
    final Map<String, int> progressByMember = {
      for (final GroupMemberEntity member in group.members)
        member.id: progressByMemberId[member.id]?.progress ?? 0,
    };
    final Map<String, int> targetByMember = {
      for (final GroupMemberEntity member in group.members)
        member.id: (progressByMemberId[member.id]?.target ?? 0) > 0
            ? progressByMemberId[member.id]!.target
            : fallbackTarget,
    };
    final List<GroupMemberEntity> completedMembers = group.members
        .where((member) => progressByMemberId[member.id]?.reached ?? false)
        .toList();
    final List<GroupMemberEntity> pendingMembers = group.members
        .where((member) => !(progressByMemberId[member.id]?.reached ?? false))
        .toList();
    final int currentUserProgress =
        progressByMember[controller.currentUserId] ?? 0;

    return Column(
      children: [
        _ParticipantsProgressCard(
          total: group.members.length,
          completedMembers: completedMembers,
          pendingMembers: pendingMembers,
          progressByMember: progressByMember,
          targetPerMember: fallbackTarget,
          targetByMember: targetByMember,
          unit: GroupMetricUnit.days,
        ),
        const Gap(AppSpacing.betweenRelated),
        _ActivityOverviewCard(
          group: group,
          header: header,
          focusSeconds: 0,
          goalProgress: currentUserProgress,
          goalTarget: fallbackTarget,
        ),
      ],
    );
  }
}

class _ActivityOverviewCard extends StatelessWidget {
  const _ActivityOverviewCard({
    required this.group,
    required this.header,
    required this.focusSeconds,
    required this.goalProgress,
    required this.goalTarget,
  });

  final GroupEntity group;
  final GroupActivityProgressEntity header;
  final int focusSeconds;
  final int goalProgress;
  final int goalTarget;

  @override
  Widget build(BuildContext context) {
    final Color accent = _groupDataAccent(context);

    return _GroupDataCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _DataSectionIcon(
                color: accent,
                child: header.isGoal
                    ? Icon(Icons.flag_rounded, size: 20, color: accent)
                    : AppIcon(group.theme.iconName, size: 20, color: accent),
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  header.isGoal
                      ? header.name
                      : localizedGroupName(context, group),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.black20.copyWith(
                    color: context.colorTokens.textBody,
                    fontSize: 18,
                  ),
                ),
              ),
              const Gap(8),
              _FrequencyBadge(label: context.l10n.dailyLabel),
            ],
          ),
          const Gap(14),
          _GroupDataDivider(),
          const Gap(14),
          Text(
            group.description.trim().isEmpty
                ? context.l10n.goalLabel
                : group.description.trim(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.bodyMedium.copyWith(
              color: context.colorTokens.textHint,
              fontSize: 15,
              height: 1.18,
            ),
          ),
          const Gap(16),
          _GroupDataDivider(),
          const Gap(16),
          IntrinsicHeight(
            child: Row(
              children: header.isGoal
                  ? [
                      Expanded(
                        child: _ActivityDataTile(
                          icon: Icons.flag_outlined,
                          label: context.l10n.groupGoalTargetDataLabel,
                          value: context.l10n.unitDays(goalTarget),
                        ),
                      ),
                      _MetricDivider(),
                      Expanded(
                        child: _ActivityDataTile(
                          icon: Icons.today_outlined,
                          label: context.l10n.groupGoalCurrentDayDataLabel,
                          value: context.l10n.taskDaysProgress(
                            goalProgress,
                            goalTarget,
                          ),
                        ),
                      ),
                    ]
                  : [
                      Expanded(
                        child: _ActivityDataTile(
                          icon: Icons.timer_outlined,
                          label: context.l10n.groupActivityFocusDataLabel,
                          value: formatDurationTotalMinutes(
                            Duration(seconds: focusSeconds),
                          ),
                        ),
                      ),
                      if (group.theme != GroupThemeType.hobbies) ...[
                        _MetricDivider(),
                        Expanded(
                          child: _ActivityDataTile(
                            icon: Icons.coffee_outlined,
                            label: context.l10n.groupActivityPauseDataLabel,
                            value: _formatRestValue(
                              context,
                              group.theme,
                              header.restMinutes,
                            ),
                          ),
                        ),
                        _MetricDivider(),
                        Expanded(
                          child: _ActivityDataTile(
                            icon: Icons.repeat_rounded,
                            label: context.l10n.groupActivitySessionsDataLabel,
                            value: header.focusSessionCount.toString(),
                          ),
                        ),
                      ],
                    ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatRestValue(BuildContext context, GroupThemeType theme, int value) {
  if (theme == GroupThemeType.exercises) {
    final int seconds = value <= 20 ? value * 60 : value;
    return "${seconds}s";
  }
  final int minutes = value > 0 ? value : SubjectEntity.defaultRestMinutes;
  return context.l10n.restMinutesChip(minutes);
}

class _ParticipantsProgressCard extends StatelessWidget {
  const _ParticipantsProgressCard({
    required this.total,
    required this.completedMembers,
    required this.pendingMembers,
    required this.progressByMember,
    required this.targetPerMember,
    required this.targetByMember,
    required this.unit,
  });

  final int total;
  final List<GroupMemberEntity> completedMembers;
  final List<GroupMemberEntity> pendingMembers;
  final Map<String, int> progressByMember;
  final int targetPerMember;
  final Map<String, int> targetByMember;
  final GroupMetricUnit unit;

  @override
  Widget build(BuildContext context) => _GroupDataCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _DataSectionIcon(
              color: context.colorTokens.primary,
              child: Icon(
                Icons.groups_2_outlined,
                size: 24,
                color: context.colorTokens.primary,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Text(
                context.l10n.groupParticipantsDataTitle(total),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.black20.copyWith(
                  color: context.colorTokens.textBody,
                  fontSize: 19,
                ),
              ),
            ),
          ],
        ),
        const Gap(24),
        _ParticipantsSectionLabel(
          label: context.l10n.groupCompletedMembersTitle(
            completedMembers.length,
          ),
          color: _groupDataAccent(context),
        ),
        const Gap(14),
        if (completedMembers.isEmpty)
          _ParticipantsEmptyState(
            title: context.l10n.groupNoCompletedMembersTitle,
            subtitle: context.l10n.groupNoCompletedMembersSubtitle,
          )
        else
          for (final GroupMemberEntity member in completedMembers) ...[
            _ParticipantProgressRow(
              member: member,
              current: progressByMember[member.id] ?? 0,
              target: targetByMember[member.id] ?? targetPerMember,
              unit: unit,
              isCompleted: true,
            ),
            const Gap(10),
          ],
        const Gap(22),
        _ParticipantsSectionLabel(
          label: context.l10n.groupPendingMembersTitle(pendingMembers.length),
          color: context.colorTokens.primary,
        ),
        const Gap(14),
        if (pendingMembers.isEmpty)
          Text(
            context.l10n.groupActivityAllCompletedToday,
            style: context.textStyles.bodyMedium.copyWith(fontSize: 13),
          )
        else
          for (final GroupMemberEntity member in pendingMembers) ...[
            _ParticipantProgressRow(
              member: member,
              current: progressByMember[member.id] ?? 0,
              target: targetByMember[member.id] ?? targetPerMember,
              unit: unit,
              isCompleted: false,
            ),
            const Gap(10),
          ],
      ],
    ),
  );
}

class _GroupStatisticsCard extends StatelessWidget {
  const _GroupStatisticsCard({
    required this.totalPeriodValue,
    required this.completedSessions,
    required this.participants,
    required this.unit,
    required this.period,
  });

  final int totalPeriodValue;
  final int completedSessions;
  final int participants;
  final GroupMetricUnit unit;
  final LeaderboardPeriodType period;

  @override
  Widget build(BuildContext context) => _GroupDataCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _DataSectionIcon(
              color: context.colorTokens.primary,
              child: Icon(
                Icons.trending_up_rounded,
                size: 24,
                color: context.colorTokens.primary,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Text(
                context.l10n.groupStatisticsTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.black20.copyWith(
                  color: context.colorTokens.textBody,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        const Gap(22),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.65,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _GroupStatItem(
              icon: Icons.local_fire_department_rounded,
              color: context.colorTokens.warning,
              value: context.l10n.unitDays(0),
              label: context.l10n.groupStreakStatLabel,
            ),
            _GroupStatItem(
              icon: Icons.access_time_rounded,
              color: context.colorTokens.primary,
              value: formatMetricValue(context, totalPeriodValue, unit),
              label: period == LeaderboardPeriodType.today
                  ? context.l10n.groupTodayTotalStatLabel
                  : context.l10n.groupPeriodTotalStatLabel,
            ),
            _GroupStatItem(
              icon: Icons.trending_up_rounded,
              color: _groupDataAccent(context),
              value: completedSessions.toString(),
              label: context.l10n.groupCompletedSessionsStatLabel,
            ),
            _GroupStatItem(
              icon: Icons.groups_2_outlined,
              color: context.colorTokens.info,
              value: participants.toString(),
              label: context.l10n.groupParticipantsStatLabel,
            ),
          ],
        ),
      ],
    ),
  );
}

class _GroupDataCard extends StatelessWidget {
  const _GroupDataCard({required this.child}) : padding = 20;

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(padding),
    decoration: AppSurfaces.content(context.colorTokens),
    child: child,
  );
}

class _FrequencyBadge extends StatelessWidget {
  const _FrequencyBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final Color accent = _groupDataAccent(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.colorTokens.primaryVeryLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: context.textStyles.bodySmall.copyWith(
          color: accent,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _DataSectionIcon extends StatelessWidget {
  const _DataSectionIcon({required this.child, required this.color});

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
    ),
    alignment: Alignment.center,
    child: child,
  );
}

class _GroupDataDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    height: 1,
    color: context.colorTokens.borderUnfocused.withValues(alpha: 0.55),
  );
}

class _ActivityDataTile extends StatelessWidget {
  const _ActivityDataTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final Color accent = _groupDataAccent(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: accent),
          const Gap(6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.textStyles.bodyMedium.copyWith(
              color: context.colorTokens.textHint,
              fontSize: 13,
              height: 1.1,
            ),
          ),
          const Gap(2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.textStyles.black20.copyWith(
              color: context.colorTokens.textBody,
              fontSize: 18,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    color: context.colorTokens.borderUnfocused.withValues(alpha: 0.55),
  );
}

class _ParticipantsSectionLabel extends StatelessWidget {
  const _ParticipantsSectionLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: context.textStyles.cardTitle.copyWith(color: color, fontSize: 15),
  );
}

class _ParticipantsEmptyState extends StatelessWidget {
  const _ParticipantsEmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    decoration: BoxDecoration(
      color: context.colorTokens.surfaceInnerLayer.withValues(alpha: 0.32),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        Icon(
          Icons.groups_2_outlined,
          color: context.colorTokens.textHint.withValues(alpha: 0.55),
          size: 28,
        ),
        const Gap(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.cardTitle.copyWith(
                  color: context.colorTokens.textHint,
                ),
              ),
              const Gap(2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.bodyMedium.copyWith(
                  color: context.colorTokens.textHint,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ParticipantProgressRow extends StatelessWidget {
  const _ParticipantProgressRow({
    required this.member,
    required this.current,
    required this.target,
    required this.unit,
    required this.isCompleted,
  });

  final GroupMemberEntity member;
  final int current;
  final int target;
  final GroupMetricUnit unit;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final Color accent = _groupDataAccent(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 70),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.colorTokens.surfaceInnerLayer.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          GroupMemberAvatar(
            name: member.name,
            colorValue: member.avatarColorValue,
            avatar: member.avatar,
            size: 38,
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  member.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.cardTitle,
                ),
                const Gap(2),
                Row(
                  children: [
                    _StatusPill(
                      label: isCompleted
                          ? context.l10n.completedLabel
                          : context.l10n.pendingLabel,
                      isCompleted: isCompleted,
                    ),
                    const Gap(6),
                    Expanded(
                      child: Text(
                        progressLabel(context, current, target, unit),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.bodyMedium.copyWith(
                          color: context.colorTokens.textHint,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(6),
          Icon(
            isCompleted
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 22,
            color: isCompleted ? accent : context.colorTokens.borderUnfocused,
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.isCompleted});

  final String label;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final Color accent = _groupDataAccent(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isCompleted
            ? context.colorTokens.primaryVeryLight
            : context.colorTokens.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textStyles.bodySmall.copyWith(
          color: isCompleted ? accent : context.colorTokens.textHint,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _GroupStatItem extends StatelessWidget {
  const _GroupStatItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: context.colorTokens.surfaceInnerLayer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 25),
          const Gap(8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.black20.copyWith(
                    color: color,
                    fontSize: 18,
                    height: 1,
                  ),
                ),
                const Gap(1),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colorTokens.textHint,
                    fontSize: 12,
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _groupDataAccent(BuildContext context) => context.colorTokens.primary;

int _targetForPeriod(
  int dailyTarget,
  LeaderboardPeriodType period, {
  DateTime? since,
}) => dailyTarget * _elapsedDaysForPeriod(period, since: since);

int _elapsedDaysForPeriod(LeaderboardPeriodType period, {DateTime? since}) {
  final DateTime now = DateTime.now();
  if (period == LeaderboardPeriodType.total) {
    if (since == null) {
      return 1;
    }
    final int elapsedDays = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(since.year, since.month, since.day)).inDays;
    return elapsedDays < 0 ? 1 : elapsedDays + 1;
  }
  return switch (period) {
    LeaderboardPeriodType.today => 1,
    LeaderboardPeriodType.thisWeek => now.weekday,
    LeaderboardPeriodType.thisMonth => now.day,
    LeaderboardPeriodType.total => 1,
  };
}
