/// Theme chosen in the settings (F23).
enum ThemePreference {
  system('Système'),
  light('Clair'),
  dark('Sombre');

  const ThemePreference(this.label);

  /// Text shown to the user.
  final String label;

  /// Reads a stored value. Unknown or missing values fall back to [system],
  /// like statuses do (rule D1).
  static ThemePreference fromName(String? name) =>
      values.asNameMap()[name] ?? system;
}

/// The user's settings, stored apart from the applications (rule R6).
class Preferences {
  const Preferences({this.firstName = '', this.theme = ThemePreference.system});

  /// Trimmed, and empty when not given.
  final String firstName;

  final ThemePreference theme;
}
