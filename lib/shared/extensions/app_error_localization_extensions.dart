import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/l10n/app_localizations.dart";

extension AppErrorLocalizationX on AppError {
  /// What to tell the user about this failure. The only place an [AppError]
  /// becomes on-screen text: its diagnostics stay in the log.
  String localizedMessage(AppLocalizations l10n) => switch (this) {
    OfflineError() => l10n.errorOfflineMessage,
    SignedOutError() => l10n.errorSignedOutMessage,
    RejectedError() => l10n.errorRejectedMessage,
    LocalDataError() ||
    UnexpectedError() ||
    RouteArgumentError() => l10n.genericErrorMessage,
  };
}
