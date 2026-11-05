import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piste/main.dart';
import 'package:piste/models/job_application.dart';

import 'fake_repository.dart';

JobApplication _app(
  int id,
  String company,
  String position, [
  ApplicationStatus status = ApplicationStatus.sent,
]) => JobApplication(
  id: id,
  company: company,
  position: position,
  status: status,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now().subtract(Duration(hours: id)),
);

final _applications = [
  _app(1, 'Nexora', 'Développeur Flutter'),
  _app(2, 'Kaleo', 'Ingénieur mobile', ApplicationStatus.interview),
  _app(3, 'Asteria', 'Développeuse backend', ApplicationStatus.interview),
];

/// Starts the app and opens the applications tab.
Future<void> _openList(WidgetTester tester) async {
  await tester.pumpWidget(
    PisteApp(repository: FakeJobApplicationRepository(_applications)),
  );
  await tester.pump();
  await tester.tap(find.text('Candidatures'));
  await tester.pumpAndSettle();
}

Future<void> _search(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(SearchBar), text);
  await tester.pump();
}

Finder _chip(String label) => find.widgetWithText(FilterChip, label);

/// The chip row scrolls sideways: the last chips start off screen.
Future<void> _tapChip(WidgetTester tester, String label) async {
  await tester.ensureVisible(_chip(label));
  await tester.tap(_chip(label));
  await tester.pump();
}

void main() {
  setUpAll(() => WidgetController.hitTestWarningShouldBeFatal = true);

  testWidgets('F7 — typing filters on company and position', (tester) async {
    await _openList(tester);

    await _search(tester, ' KALEO ');
    expect(find.text('Ingénieur mobile'), findsOneWidget);
    expect(find.text('Développeur Flutter'), findsNothing);

    await _search(tester, 'développ');
    expect(find.text('Développeur Flutter'), findsOneWidget);
    expect(find.text('Développeuse backend'), findsOneWidget);
    expect(find.text('Ingénieur mobile'), findsNothing);
  });

  testWidgets('F8 — a status chip combines with the search', (tester) async {
    await _openList(tester);

    await _tapChip(tester, 'Entretien');
    expect(find.text('Ingénieur mobile'), findsOneWidget);
    expect(find.text('Développeuse backend'), findsOneWidget);
    expect(find.text('Développeur Flutter'), findsNothing);

    await _search(tester, 'développ');
    expect(find.text('Développeuse backend'), findsOneWidget);
    expect(find.text('Ingénieur mobile'), findsNothing);

    await _tapChip(tester, 'Toutes');
    expect(find.text('Développeur Flutter'), findsOneWidget);
  });

  testWidgets('tapping the selected chip again goes back to « Toutes »', (
    tester,
  ) async {
    await _openList(tester);

    await _tapChip(tester, 'Entretien');
    await _tapChip(tester, 'Entretien');

    expect(tester.widget<FilterChip>(_chip('Toutes')).selected, isTrue);
    expect(find.text('Développeur Flutter'), findsOneWidget);
  });

  testWidgets('S2 — no match shows « Aucun résultat », not the empty state, '
      'and clearing brings the list back', (tester) async {
    await _openList(tester);

    await _tapChip(tester, 'Refusée');
    await _search(tester, 'zzz');

    expect(find.text('Aucun résultat'), findsOneWidget);
    expect(find.text('Aucune candidature'), findsNothing);
    // The search stays visible, so it can be changed.
    expect(find.byType(SearchBar), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Effacer la recherche'));
    await tester.pump();

    expect(find.text('Aucun résultat'), findsNothing);
    expect(find.text('Développeur Flutter'), findsOneWidget);
    expect(find.widgetWithText(SearchBar, 'zzz'), findsNothing);
    expect(tester.widget<FilterChip>(_chip('Toutes')).selected, isTrue);
  });

  testWidgets('the clear icon empties the field only', (tester) async {
    await _openList(tester);
    await _tapChip(tester, 'Entretien');
    await _search(tester, 'kaleo');

    await tester.tap(find.byTooltip('Effacer la recherche'));
    await tester.pump();

    expect(find.text('Développeuse backend'), findsOneWidget);
    expect(find.text('Développeur Flutter'), findsNothing);
  });

  testWidgets('the search survives a tab change', (tester) async {
    await _openList(tester);
    await _search(tester, 'kaleo');

    await tester.tap(find.text('Accueil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Candidatures'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(SearchBar, 'kaleo'), findsOneWidget);
    expect(find.text('Développeur Flutter'), findsNothing);
  });

  testWidgets('F5 — the home search opens the list with the field focused', (
    tester,
  ) async {
    await tester.pumpWidget(
      PisteApp(repository: FakeJobApplicationRepository(_applications)),
    );
    await tester.pump();

    await tester.tap(find.bySemanticsLabel('Rechercher une candidature'));
    await tester.pumpAndSettle();

    expect(find.byType(SearchBar), findsOneWidget);
    final field = tester.widget<EditableText>(find.byType(EditableText));
    expect(field.focusNode.hasFocus, isTrue);
  });

  testWidgets('chips and search fit a small screen with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _openList(tester);
    await _search(tester, 'zzz');

    expect(tester.takeException(), isNull);
  });
}
