import 'package:flutter/foundation.dart';
import 'package:piste/data/preferences_repository.dart';
import 'package:piste/data/storage_exception.dart';
import 'package:piste/models/preferences.dart';

/// Owns the user's settings and tells listeners when they change.
///
/// Call [load] once after creating it.
class PreferencesController extends ChangeNotifier {
  PreferencesController(this._repository);

  final PreferencesRepository _repository;

  Preferences _preferences = const Preferences();

  /// Empty when not given.
  String get firstName => _preferences.firstName;

  ThemePreference get theme => _preferences.theme;

  /// Reads the saved settings. Never throws: on failure the defaults stay, as
  /// a lost setting is not worth blocking the app with an error screen.
  Future<void> load() async {
    try {
      _preferences = await _repository.load();
    } on StorageException {
      return;
    }
    notifyListeners();
  }

  /// Saves [firstName] trimmed, then shows it everywhere (F22).
  ///
  /// Throws a [StorageException] on failure, leaving the value unchanged.
  Future<void> setFirstName(String firstName) async {
    final trimmed = firstName.trim();
    if (trimmed == this.firstName) return;
    await _repository.saveFirstName(trimmed);
    _preferences = Preferences(firstName: trimmed, theme: theme);
    notifyListeners();
  }

  /// Saves [theme], then applies it (F23).
  ///
  /// Throws a [StorageException] on failure, leaving the theme unchanged.
  Future<void> setTheme(ThemePreference theme) async {
    if (theme == this.theme) return;
    await _repository.saveTheme(theme);
    _preferences = Preferences(firstName: firstName, theme: theme);
    notifyListeners();
  }
}
