import 'package:flutter/services.dart';
import 'package:piste/data/preferences_repository.dart';
import 'package:piste/data/storage_exception.dart';
import 'package:piste/models/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores the settings with `shared_preferences`, made for a few small
/// values like these (rule R6).
class SharedPreferencesRepository implements PreferencesRepository {
  /// Keys are stored on the device: renaming one loses the saved value.
  static const _firstNameKey = 'firstName';
  static const _themeKey = 'themeMode';

  final _store = SharedPreferencesAsync();

  @override
  Future<Preferences> load() => _run(
    'read the preferences',
    () async => Preferences(
      firstName: await _store.getString(_firstNameKey) ?? '',
      theme: ThemePreference.fromName(await _store.getString(_themeKey)),
    ),
  );

  @override
  Future<void> saveFirstName(String firstName) => _run(
    'save the first name',
    () => _store.setString(_firstNameKey, firstName),
  );

  /// Saves the enum's `name`, not its label, so rewording a label cannot
  /// break saved data.
  @override
  Future<void> saveTheme(ThemePreference theme) =>
      _run('save the theme', () => _store.setString(_themeKey, theme.name));

  /// Runs [body] and turns every storage failure into a [StorageException].
  Future<T> _run<T>(String action, Future<T> Function() body) async {
    try {
      return await body();
    } on PlatformException catch (e) {
      throw StorageException('Could not $action.', e);
    } on TypeError catch (e) {
      // A key holds a value of another type.
      throw StorageException('Could not $action: unexpected value.', e);
    }
  }
}
