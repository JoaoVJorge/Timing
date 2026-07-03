import "package:flutter/material.dart";

class AppAvatarPresets {
  const AppAvatarPresets._();

  static const List<IconData> values = [
    Icons.face_rounded,
    Icons.pets_rounded,
    Icons.rocket_launch_rounded,
    Icons.star_rounded,
    Icons.emoji_nature_rounded,
    Icons.sports_esports_rounded,
    Icons.music_note_rounded,
    Icons.local_fire_department_rounded,
  ];

  static IconData byIndex(int index) => values[index % values.length];
}
