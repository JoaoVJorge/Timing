import "package:flutter/widgets.dart";
import "package:flutter_test/flutter_test.dart";
import "package:timing/core/domain/errors/app_error.dart";
import "package:timing/l10n/app_localizations.dart";
import "package:timing/shared/extensions/app_error_localization_extensions.dart";

void main() {
  final AppLocalizations en = lookupAppLocalizations(const Locale("en"));

  test("each kind of failure has its own explanation", () {
    expect(const OfflineError().localizedMessage(en), en.errorOfflineMessage);
    expect(
      const SignedOutError().localizedMessage(en),
      en.errorSignedOutMessage,
    );
    expect(
      const RejectedError(code: "23505").localizedMessage(en),
      en.errorRejectedMessage,
    );
    expect(
      const UnexpectedError().localizedMessage(en),
      en.genericErrorMessage,
    );
    expect(const LocalDataError().localizedMessage(en), en.genericErrorMessage);
  });

  test("the diagnostics never reach the user", () {
    final AppError error = UnexpectedError(
      operation: "rpc public.create_group_with_members",
      cause: StateError("create_group_with_members returned no group row."),
      stackTrace: StackTrace.current,
    );

    for (final Locale locale in AppLocalizations.supportedLocales) {
      final String shown = error.localizedMessage(
        lookupAppLocalizations(locale),
      );

      expect(shown, isNot(contains("create_group")));
      expect(shown, isNot(contains("StateError")));
      expect(shown, isNot(contains("#0")));
    }
  });

  test("every language explains a missing connection in its own words", () {
    final Set<String> messages = {
      for (final Locale locale in AppLocalizations.supportedLocales)
        const OfflineError().localizedMessage(lookupAppLocalizations(locale)),
    };

    expect(messages, hasLength(AppLocalizations.supportedLocales.length));
  });
}
