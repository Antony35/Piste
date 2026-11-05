import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piste/main.dart';
import 'package:piste/models/job_application.dart';
import 'package:piste/models/preferences.dart';
import 'package:piste/state/preferences_controller.dart';

import 'fake_preferences_repository.dart';
import 'fake_repository.dart';

JobApplication _app(int id, ApplicationStatus status) => JobApplication(
  id: id,
  company: 'Entreprise $id',
  position: 'Développeur Flutter',
  status: status,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

final _applications = [
  _app(1, ApplicationStatus.sent),
  _app(2, ApplicationStatus.interview),
  _app(3, ApplicationStatus.offer),
];

/// Starts the app as `main()` does: settings loaded before the first frame.
Future<FakePreferencesRepository> _pumpApp(
  WidgetTester tester, {
  Preferences stored = const Preferences(),
  FakeJobApplicationRepository? repository,
}) async {
  final preferencesRepository = FakePreferencesRepository(stored);
  final preferences = PreferencesController(preferencesRepository);
  await preferences.load();
  await tester.pumpWidget(
    PisteApp(
      repository: repository ?? FakeJobApplicationRepository(_applications),
      preferences: preferences,
    ),
  );
  await tester.pump();
  return preferencesRepository;
}

Future<void> _openFromDrawer(WidgetTester tester, String entry) async {
  await tester.tap(find.byTooltip('Ouvrir le menu de navigation'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(entry));
  await tester.pumpAndSettle();
}

Brightness _brightness(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(Scaffold).last)).brightness;

void main() {
  setUpAll(() => WidgetController.hitTestWarningShouldBeFatal = true);

  group('Side menu', () {
    testWidgets('N1 — it holds only the secondary screens', (tester) async {
      await _pumpApp(tester);
      await tester.tap(find.byTooltip('Ouvrir le menu de navigation'));
      await tester.pumpAndSettle();

      final drawer = find.byType(Drawer);
      for (final entry in ['Profil', 'Paramètres', 'À propos']) {
        expect(
          find.descendant(of: drawer, matching: find.text(entry)),
          findsOneWidget,
        );
      }
      for (final tab in ['Accueil', 'Candidatures', 'Statistiques']) {
        expect(
          find.descendant(of: drawer, matching: find.text(tab)),
          findsNothing,
        );
      }
    });

    testWidgets('N2 — back from a screen returns to the tab, menu closed', (
      tester,
    ) async {
      await _pumpApp(tester);
      await _openFromDrawer(tester, 'Profil');
      expect(find.text('Compte (bientôt disponible)'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('Récentes'), findsOneWidget);
      expect(find.byType(Drawer), findsNothing);
    });
  });

  group('Profile', () {
    testWidgets('F20 — first name, initials and personal figures', (
      tester,
    ) async {
      await _pumpApp(tester, stored: const Preferences(firstName: 'Antony'));
      await _openFromDrawer(tester, 'Profil');

      expect(find.text('Antony'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      Finder counter(String label) =>
          find.ancestor(of: find.text(label), matching: find.byType(Card));
      expect(
        find.descendant(of: counter('Candidatures'), matching: find.text('3')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: counter('Offres'), matching: find.text('1')),
        findsOneWidget,
      );
    });

    testWidgets('F20 — with no first name, it invites to enter one', (
      tester,
    ) async {
      await _pumpApp(tester);
      await _openFromDrawer(tester, 'Profil');

      expect(find.text('Prénom non renseigné'), findsOneWidget);
      await tester.tap(find.text('Renseigner votre prénom'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, 'Prénom'), findsOneWidget);
    });

    testWidgets('F20 — after a read error, no figure is invented (S1)', (
      tester,
    ) async {
      await _pumpApp(
        tester,
        repository: FakeJobApplicationRepository(_applications)
          ..failReads = true,
      );
      await _openFromDrawer(tester, 'Profil');

      expect(find.textContaining('Chiffres indisponibles'), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });

    testWidgets('F21 — the account slot is disabled, with no fake data', (
      tester,
    ) async {
      await _pumpApp(tester, stored: const Preferences(firstName: 'Antony'));
      await _openFromDrawer(tester, 'Profil');

      final account = tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'Compte (bientôt disponible)'),
      );
      expect(account.enabled, isFalse);
      expect(account.onTap, isNull);
      expect(find.textContaining('@'), findsNothing);
      expect(find.textContaining('Déconnexion'), findsNothing);
    });
  });

  group('Settings', () {
    testWidgets('F22 — the saved first name greets on the home screen', (
      tester,
    ) async {
      final stored = await _pumpApp(tester);
      expect(find.text('Bonjour'), findsOneWidget);
      await _openFromDrawer(tester, 'Paramètres');

      await tester.enterText(find.byType(TextField), '  Camille ');
      await tester.pump();
      await tester.tap(find.text('Enregistrer'));
      await tester.pump();

      expect(find.text('Prénom enregistré.'), findsOneWidget);
      expect(stored.stored.firstName, 'Camille');

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Bonjour Camille'), findsOneWidget);
    });

    testWidgets('« Enregistrer » is disabled until the name changes', (
      tester,
    ) async {
      await _pumpApp(tester, stored: const Preferences(firstName: 'Camille'));
      await _openFromDrawer(tester, 'Paramètres');
      FilledButton save() =>
          tester.widget(find.widgetWithText(FilledButton, 'Enregistrer'));

      expect(save().onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'Camille ');
      await tester.pump();
      expect(save().onPressed, isNull, reason: 'same name once trimmed');

      await tester.enterText(find.byType(TextField), 'Camila');
      await tester.pump();
      expect(save().onPressed, isNotNull);
    });

    testWidgets('F23 — the theme applies at once and is saved', (tester) async {
      final stored = await _pumpApp(tester);
      await _openFromDrawer(tester, 'Paramètres');
      expect(_brightness(tester), Brightness.light);

      await tester.tap(find.text('Sombre'));
      await tester.pumpAndSettle();

      expect(_brightness(tester), Brightness.dark);
      expect(stored.stored.theme, ThemePreference.dark);

      await tester.tap(find.text('Clair'));
      await tester.pumpAndSettle();
      expect(_brightness(tester), Brightness.light);
    });

    testWidgets('F23 — « Système » follows the phone setting', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await _pumpApp(tester);

      expect(_brightness(tester), Brightness.dark);
    });

    testWidgets('a failed save says so and keeps the current theme', (
      tester,
    ) async {
      final stored = await _pumpApp(tester);
      stored.failWrites = true;
      await _openFromDrawer(tester, 'Paramètres');

      await tester.tap(find.text('Sombre'));
      await tester.pumpAndSettle();

      expect(
        find.text('Enregistrement impossible. Réessayez.'),
        findsOneWidget,
      );
      expect(_brightness(tester), Brightness.light);
    });

    testWidgets('recette 10 — first name and theme survive a restart', (
      tester,
    ) async {
      final stored = await _pumpApp(tester);
      await _openFromDrawer(tester, 'Paramètres');
      await tester.enterText(find.byType(TextField), 'Camille');
      await tester.pump();
      await tester.tap(find.text('Enregistrer'));
      await tester.pump();
      await tester.tap(find.text('Sombre'));
      await tester.pumpAndSettle();

      // A new app on the same storage, as after closing and relaunching.
      await tester.pumpWidget(const SizedBox());
      await _pumpApp(tester, stored: stored.stored);

      expect(find.text('Bonjour Camille'), findsOneWidget);
      expect(_brightness(tester), Brightness.dark);
    });
  });

  group('About', () {
    testWidgets('F24 — version from pubspec.yaml, privacy and licenses', (
      tester,
    ) async {
      await _pumpApp(tester);
      await _openFromDrawer(tester, 'À propos');

      expect(find.text('Version 1.0.0 (1)'), findsOneWidget);
      expect(find.text('Vos données restent sur cet appareil'), findsOneWidget);

      await tester.tap(find.text('Licences'));
      // The license page shows a spinner while it gathers the licenses.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(LicensePage), findsOneWidget);
    });
  });

  testWidgets('secondary screens fit a small screen with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _pumpApp(
      tester,
      stored: Preferences(firstName: 'Marie-Bérénice ' * 2),
    );
    expect(tester.takeException(), isNull);

    for (final entry in ['Profil', 'Paramètres', 'À propos']) {
      await _openFromDrawer(tester, entry);
      expect(tester.takeException(), isNull, reason: entry);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
    }
  });
}
