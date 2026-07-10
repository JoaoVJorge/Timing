import "package:flutter/material.dart";
import "package:help_out/core/domain/enums/time_category_type.dart";

class SubjectIcons {
  const SubjectIcons._();

  static const Map<String, IconData> _all = {
    "school": Icons.school_rounded,
    "calculate": Icons.calculate_rounded,
    "science": Icons.science_rounded,
    "translate": Icons.translate_rounded,
    "computer": Icons.computer_rounded,
    "history": Icons.history_edu_rounded,
    "psychology": Icons.psychology_rounded,
    "fitness": Icons.fitness_center_rounded,
    "run": Icons.directions_run_rounded,
    "bike": Icons.directions_bike_rounded,
    "pool": Icons.pool_rounded,
    "yoga": Icons.self_improvement_rounded,
    "soccer": Icons.sports_soccer_rounded,
    "basketball": Icons.sports_basketball_rounded,
    "book": Icons.menu_book_rounded,
    "stories": Icons.auto_stories_rounded,
    "article": Icons.article_rounded,
    "bookmark": Icons.bookmark_rounded,
    "piano": Icons.piano_rounded,
    "game": Icons.videogame_asset_rounded,
    "cooking": Icons.restaurant_rounded,
    "plant": Icons.park_rounded,
  };

  static List<String> suggestionsFor(TimeCategoryType category) =>
      switch (category) {
        TimeCategoryType.studying => const [
          "school",
          "calculate",
          "science",
          "translate",
          "computer",
          "history",
          "psychology",
        ],
        TimeCategoryType.exercises => const [
          "fitness",
          "run",
          "bike",
          "pool",
          "yoga",
          "soccer",
          "basketball",
        ],
        TimeCategoryType.reading => const [
          "book",
          "stories",
          "article",
          "bookmark",
          "history",
          "science",
          "psychology",
        ],
        TimeCategoryType.hobbies => const [
          "music",
          "brush",
          "gaming-pad",
          "camera",
          "cutlery",
          "scissor",
          "yin-yang",
          "cinema",
          "magnifying-glass",
        ],
      };

  static IconData? byName(String name) => _all[name];

  static bool isSvgName(String name) => !_all.containsKey(name);
}
