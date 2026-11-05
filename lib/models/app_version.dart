/// Version of the app, as declared in `pubspec.yaml` (`version: 1.0.0+1`).
class AppVersion {
  const AppVersion(this.name, [this.build]);

  /// Shown to users, e.g. `1.0.0`.
  final String name;

  /// Increases with every published build, e.g. `1`.
  final String? build;

  /// e.g. « 1.0.0 (1) ».
  String get label => build == null ? name : '$name ($build)';

  /// Reads the top-level `version:` line of a `pubspec.yaml`, or returns
  /// `null` if there is none. Indented `version:` keys are ignored.
  static AppVersion? parse(String pubspec) {
    final match = _versionLine.firstMatch(pubspec);
    return match == null ? null : AppVersion(match[1]!, match[2]);
  }

  static final _versionLine = RegExp(
    r'''^version:\s*["']?([^\s"'+#]+)(?:\+(\d+))?''',
    multiLine: true,
  );
}
