extension DateTimeDateX on DateTime {
  /// Same date at local midnight, dropping the time of day.
  DateTime get dateOnly => DateTime(year, month, day);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}
