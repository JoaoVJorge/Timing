String formatDurationLong(Duration duration) {
  final int hours = duration.inHours;
  final int minutes = duration.inMinutes.remainder(60);

  if (hours > 0) {
    return "${hours}h ${minutes}m";
  }
  return "${minutes}m";
}

String formatDurationClock(Duration duration) {
  final int minutes = duration.inMinutes.remainder(60);
  final int seconds = duration.inSeconds.remainder(60);
  final String hours = duration.inHours > 0
      ? "${duration.inHours.toString().padLeft(2, "0")}:"
      : "";

  return "$hours${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}";
}
