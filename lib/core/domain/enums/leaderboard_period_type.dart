enum LeaderboardPeriodType {
  today(label: "Today"),
  thisWeek(label: "This Week"),
  thisMonth(label: "This Month");

  const LeaderboardPeriodType({required this.label});

  final String label;
}
