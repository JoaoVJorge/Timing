import "package:timing/core/services/analytics/analytics_event.dart";
import "package:timing/core/services/analytics/analytics_service.dart";
import "package:timing/core/services/log/app_logger_service.dart";

/// Default [AnalyticsService] implementation: writes events to the app logger
/// (debug builds only, via [AppLoggerService]). It gives the app a real event
/// stream to reason about product decisions before any external SDK is added.
class LoggingAnalyticsService implements AnalyticsService {
  const LoggingAnalyticsService({required this._logger});

  final AppLoggerService _logger;

  @override
  void track(AnalyticsEvent event) {
    final String suffix = event.properties.isEmpty
        ? ""
        : " ${event.properties}";
    _logger.logInfo("[ANALYTICS] ${event.name}$suffix");
  }
}
