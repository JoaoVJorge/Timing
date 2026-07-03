import "package:get/get.dart";

typedef FaqEntry = ({String question, String answer});

class FaqController extends GetxController {
  final List<FaqEntry> entries = const [
    (
      question: "How does the study timer work?",
      answer: "Pick a subject, tap play, and the timer tracks your current session while adding it to that subject's "
          "total time. Tap pause any time to stop and save your progress.",
    ),
    (
      question: "What is the break countdown?",
      answer: "Each session follows a classic Pomodoro cycle: a 25 minute countdown to your next break. When it "
          "reaches zero it simply resets, it's a reminder, not a hard stop.",
    ),
    (
      question: "How do I add a new subject?",
      answer: "Open a category from Home, then tap \"Add Subject\" at the bottom of the list. You can pick a "
          "color and set an estimated hours goal for it.",
    ),
    (
      question: "How are groups and the leaderboard calculated?",
      answer: "Groups show a scoreboard of everyone's studied hours. Switch between Today, This Week and This "
          "Month to see who studied the most in that period.",
    ),
    (
      question: "Can I change the app's color theme?",
      answer: "Yes, go to Settings > My Profile and pick any theme color. Every gradient, button and highlight "
          "across the app updates to match it, including dark mode.",
    ),
  ];
}
