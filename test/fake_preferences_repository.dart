import 'package:piste/data/preferences_repository.dart';
import 'package:piste/data/storage_exception.dart';
import 'package:piste/models/preferences.dart';
import 'package:piste/state/preferences_controller.dart';

/// In-memory settings for tests, able to simulate a failing storage.
class FakePreferencesRepository implements PreferencesRepository {
  FakePreferencesRepository([this.stored = const Preferences()]);

  /// What a restarted app would read.
  Preferences stored;

  bool failReads = false;
  bool failWrites = false;

  @override
  Future<Preferences> load() async {
    if (failReads) throw const StorageException('Simulated read failure.');
    return stored;
  }

  @override
  Future<void> saveFirstName(String firstName) async {
    _checkWrite();
    stored = Preferences(firstName: firstName, theme: stored.theme);
  }

  @override
  Future<void> saveTheme(ThemePreference theme) async {
    _checkWrite();
    stored = Preferences(firstName: stored.firstName, theme: theme);
  }

  void _checkWrite() {
    if (failWrites) throw const StorageException('Simulated write failure.');
  }
}

/// Settings of a first launch: no first name, system theme.
PreferencesController defaultPreferences() =>
    PreferencesController(FakePreferencesRepository());
