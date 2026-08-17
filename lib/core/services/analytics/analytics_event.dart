import "package:equatable/equatable.dart";
import "package:timing/core/domain/enums/time_category_type.dart";

/// A single product-analytics event. Kept provider-agnostic: [name] and
/// [properties] map cleanly onto any backend (Amplitude, PostHog, Firebase…)
/// if one is wired up later. Use the named constructors so event names and
/// property keys stay consistent across the app.
class AnalyticsEvent extends Equatable {
  const AnalyticsEvent(this.name, {this.properties = const {}});

  /// The user started a focus/reading session.
  factory AnalyticsEvent.focusSessionStarted({
    required TimeCategoryType category,
  }) => AnalyticsEvent(
    "focus_session_started",
    properties: {"category": category.name},
  );

  /// A focus/reading session ended, either by completing all sections or by
  /// the user finishing it early.
  factory AnalyticsEvent.focusSessionCompleted({
    required TimeCategoryType category,
    required int seconds,
    required bool completedAllSections,
  }) => AnalyticsEvent(
    "focus_session_completed",
    properties: {
      "category": category.name,
      "seconds": seconds,
      "completed_all_sections": completedAllSections,
    },
  );

  /// A new subject/activity was created.
  factory AnalyticsEvent.subjectCreated({
    required TimeCategoryType category,
  }) => AnalyticsEvent(
    "subject_created",
    properties: {"category": category.name},
  );

  final String name;
  final Map<String, Object?> properties;

  @override
  List<Object?> get props => [name, properties];
}
