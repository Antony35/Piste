import 'package:flutter_test/flutter_test.dart';
import 'package:piste/data/storage_exception.dart';
import 'package:piste/models/preferences.dart';
import 'package:piste/state/preferences_controller.dart';

import 'fake_preferences_repository.dart';

void main() {
  late FakePreferencesRepository repository;
  late PreferencesController controller;
  late int notifications;

  setUp(() {
    repository = FakePreferencesRepository(
      const Preferences(firstName: 'Antony', theme: ThemePreference.dark),
    );
    controller = PreferencesController(repository);
    notifications = 0;
    controller.addListener(() => notifications++);
  });

  tearDown(() => controller.dispose());

  test('starts with the defaults, then load reads the saved values', () async {
    expect(controller.firstName, '');
    expect(controller.theme, ThemePreference.system);

    await controller.load();

    expect(controller.firstName, 'Antony');
    expect(controller.theme, ThemePreference.dark);
    expect(notifications, 1);
  });

  test('a failed load keeps the defaults and does not throw', () async {
    repository.failReads = true;

    await controller.load();

    expect(controller.firstName, '');
    expect(controller.theme, ThemePreference.system);
    expect(notifications, 0);
  });

  test('F22 — the first name is saved trimmed, then shown', () async {
    await controller.setFirstName('  Camille ');

    expect(controller.firstName, 'Camille');
    expect(repository.stored.firstName, 'Camille');
    expect(notifications, 1);
  });

  test('F23 — the theme is saved, then applied', () async {
    await controller.setTheme(ThemePreference.light);

    expect(controller.theme, ThemePreference.light);
    expect(repository.stored.theme, ThemePreference.light);
    expect(notifications, 1);
  });

  test('saving one setting keeps the other', () async {
    await controller.load();

    await controller.setTheme(ThemePreference.light);
    await controller.setFirstName('Camille');

    expect(repository.stored.firstName, 'Camille');
    expect(repository.stored.theme, ThemePreference.light);
  });

  test('an unchanged value is neither saved nor notified', () async {
    await controller.setFirstName('   ');
    await controller.setTheme(ThemePreference.system);

    expect(repository.stored.firstName, 'Antony');
    expect(notifications, 0);
  });

  test('a failed save throws and leaves the values unchanged', () async {
    repository.failWrites = true;

    await expectLater(
      controller.setFirstName('Camille'),
      throwsA(isA<StorageException>()),
    );
    await expectLater(
      controller.setTheme(ThemePreference.dark),
      throwsA(isA<StorageException>()),
    );

    expect(controller.firstName, '');
    expect(controller.theme, ThemePreference.system);
    expect(notifications, 0);
  });
}
