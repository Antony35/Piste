import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piste/main.dart';
import 'package:piste/models/job_application.dart';
import 'package:piste/ui/application_form_page.dart';
import 'package:piste/ui/theme/app_theme.dart';
import 'package:piste/ui/widgets/state_views.dart';

import 'fake_preferences_repository.dart';
import 'fake_repository.dart';

final _nexora = JobApplication(
  id: 1,
  company: 'Nexora',
  position: 'Développeur Flutter',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

final _spinner = find.byType(CircularProgressIndicator);
final _addButton = find.byTooltip('Ajouter une candidature');
final _emptyTitle = find.text('Aucune candidature');

// No pumpAndSettle while the spinner turns: it would never settle.
void main() {
  setUpAll(() => WidgetController.hitTestWarningShouldBeFatal = true);

  testWidgets('loading shows only a spinner, then the data', (tester) async {
    final gate = Completer<void>();
    final repository = FakeJobApplicationRepository([_nexora])..readGate = gate;
    await tester.pumpWidget(
      PisteApp(repository: repository, preferences: defaultPreferences()),
    );
    await tester.pump();

    expect(_spinner, findsOneWidget);
    expect(_emptyTitle, findsNothing);
    expect(_addButton, findsNothing);

    gate.complete();
    await tester.pump();

    expect(_spinner, findsNothing);
    expect(find.text('Développeur Flutter'), findsOneWidget);
    expect(_addButton, findsOneWidget);
  });

  testWidgets('S1 — a failed read shows the error, never an empty list', (
    tester,
  ) async {
    final repository = FakeJobApplicationRepository([_nexora])
      ..failReads = true;
    await tester.pumpWidget(
      PisteApp(repository: repository, preferences: defaultPreferences()),
    );
    await tester.pump();

    expect(find.text('Chargement impossible.'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
    expect(_emptyTitle, findsNothing);
    expect(_addButton, findsNothing);
  });

  testWidgets('« Réessayer » reloads: spinner, then the data', (tester) async {
    final repository = FakeJobApplicationRepository([_nexora])
      ..failReads = true;
    await tester.pumpWidget(
      PisteApp(repository: repository, preferences: defaultPreferences()),
    );
    await tester.pump();

    final gate = repository.readGate = Completer<void>();
    repository.failReads = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pump();

    expect(_spinner, findsOneWidget);
    expect(find.text('Réessayer'), findsNothing);

    gate.complete();
    await tester.pump();

    expect(find.text('Chargement impossible.'), findsNothing);
    expect(find.text('Développeur Flutter'), findsOneWidget);
  });

  testWidgets('S3 — the error screen shows the message it is given', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ErrorView(
            message: 'Connexion impossible.',
            onRetry: () => retries++,
          ),
        ),
      ),
    );

    expect(find.text('Connexion impossible.'), findsOneWidget);
    expect(find.text('Chargement impossible.'), findsNothing);

    await tester.tap(find.text('Réessayer'));
    expect(retries, 1);
  });

  testWidgets('empty shows the invitation on home and applications, '
      'not on statistics', (tester) async {
    await tester.pumpWidget(
      PisteApp(
        repository: FakeJobApplicationRepository(),
        preferences: defaultPreferences(),
      ),
    );
    await tester.pump();

    expect(_emptyTitle, findsOneWidget);

    await tester.tap(find.text('Candidatures'));
    await tester.pumpAndSettle();
    expect(_emptyTitle, findsOneWidget);

    await tester.tap(find.text('Statistiques'));
    await tester.pumpAndSettle();
    expect(_emptyTitle, findsNothing);
  });

  testWidgets('the empty state button opens the form', (tester) async {
    await tester.pumpWidget(
      PisteApp(
        repository: FakeJobApplicationRepository(),
        preferences: defaultPreferences(),
      ),
    );
    await tester.pump();

    await tester.tap(
      find.widgetWithText(FilledButton, 'Ajouter une candidature'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ApplicationFormPage), findsOneWidget);
  });

  testWidgets('state views do not overflow a small screen with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final repository = FakeJobApplicationRepository()..failReads = true;
    await tester.pumpWidget(
      PisteApp(repository: repository, preferences: defaultPreferences()),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);

    // The view scrolls: the button may start below the navigation bar.
    repository.failReads = false;
    await tester.ensureVisible(find.text('Réessayer'));
    await tester.tap(find.text('Réessayer'));
    await tester.pump();
    expect(_emptyTitle, findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
