import 'package:piste/models/preferences.dart';

/// Where the user's settings are stored. Every method throws a
/// `StorageException` on failure, and nothing else.
abstract interface class PreferencesRepository {
  /// The saved settings, with defaults for those never saved.
  Future<Preferences> load();

  Future<void> saveFirstName(String firstName);

  Future<void> saveTheme(ThemePreference theme);
}
