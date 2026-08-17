import "package:timing/core/services/analytics/analytics_event.dart";

/// Provider-agnostic entry point for product analytics. Swap the concrete
/// implementation (currently [LoggingAnalyticsService]) for one backed by a
/// real analytics SDK without touching call sites.
abstract class AnalyticsService {
  void track(AnalyticsEvent event);
}
