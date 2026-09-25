import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:timing/core/services/local_storage/app_local_storage_service.dart";
import "package:timing/core/services/local_storage/local_storage_keys.dart";
import "package:timing/core/services/supabase/supabase_service.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences preferences;
  late AppLocalStorageService storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    storage = AppLocalStorageService(
      localStorage: preferences,
      secureStorage: const FlutterSecureStorage(),
      supabaseService: await SupabaseService.initialize(),
    );
  });

  test("encrypts user-scoped data and decrypts it on read", () async {
    const clearText = '{"email":"private@example.com"}';

    await storage.write(LocalStorageKeys.appConfig, clearText);

    final String? persisted = preferences.getString("user.guest.appConfig");
    expect(persisted, startsWith("enc.v1:"));
    expect(persisted, isNot(contains("private@example.com")));
    expect(await storage.read<String>(LocalStorageKeys.appConfig), clearText);
  });

  test("migrates a legacy plaintext value after reading it", () async {
    await preferences.setString("user.guest.subjects", "legacy-private-data");

    expect(
      await storage.read<String>(LocalStorageKeys.subjects),
      "legacy-private-data",
    );
    expect(preferences.getString("user.guest.subjects"), startsWith("enc.v1:"));
  });

  test("deletes all data scoped to the current user", () async {
    await storage.write(LocalStorageKeys.appConfig, "profile");
    await storage.write(LocalStorageKeys.subjects, "notes");

    await storage.deleteCurrentUserData();

    expect(preferences.getString("user.guest.appConfig"), isNull);
    expect(preferences.getString("user.guest.subjects"), isNull);
  });
}
