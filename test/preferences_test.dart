import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:piste/models/app_version.dart';
import 'package:piste/models/preferences.dart';

void main() {
  group('ThemePreference', () {
    test('every stored name reads back as the same theme', () {
      for (final theme in ThemePreference.values) {
        expect(ThemePreference.fromName(theme.name), theme);
      }
    });

    test('an unknown or missing value reads as system', () {
      expect(ThemePreference.fromName('sepia'), ThemePreference.system);
      expect(ThemePreference.fromName(null), ThemePreference.system);
    });

    test('defaults are an empty first name and the system theme', () {
      const preferences = Preferences();
      expect(preferences.firstName, '');
      expect(preferences.theme, ThemePreference.system);
    });
  });

  group('AppVersion (F24)', () {
    test('reads the name and the build number', () {
      final version = AppVersion.parse('name: piste\nversion: 1.2.3+45\n');
      expect(version?.name, '1.2.3');
      expect(version?.build, '45');
      expect(version?.label, '1.2.3 (45)');
    });

    test('a version without build number, or quoted, is read too', () {
      expect(AppVersion.parse('version: 2.0.0')?.label, '2.0.0');
      expect(AppVersion.parse('version: "2.0.0+3"')?.label, '2.0.0 (3)');
    });

    test('ignores indented version keys and comments', () {
      const pubspec = '''
# version: 9.9.9
dependencies:
  some_package:
    version: 5.0.0
version: 1.0.0+1 # first release
''';
      expect(AppVersion.parse(pubspec)?.label, '1.0.0 (1)');
    });

    test('returns null when there is no version', () {
      expect(AppVersion.parse('name: piste\n'), isNull);
    });

    test("reads the project's own pubspec.yaml", () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(AppVersion.parse(pubspec)?.label, '1.0.0 (1)');
    });
  });
}
