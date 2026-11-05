import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piste/models/job_application.dart';
import 'package:piste/state/applications_controller.dart';
import 'package:piste/ui/application_form_page.dart';
import 'package:piste/ui/home_shell.dart';
import 'package:piste/ui/theme/app_theme.dart';

import 'fake_repository.dart';

Finder _field(String label) => find.widgetWithText(TextFormField, label);

Future<void> _openCreateForm(
  WidgetTester tester,
  ApplicationsController controller,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: HomeShell(controller: controller),
    ),
  );
  await tester.tap(find.byTooltip('Ajouter une candidature'));
  await tester.pumpAndSettle();
}

/// Scrolls to the button, then taps it.
///
/// Settles first: a focused field scrolls itself back into view, which would
/// push the button off screen again.
Future<void> _tapSave(WidgetTester tester, String label) async {
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text(label));
  await tester.pump();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => WidgetController.hitTestWarningShouldBeFatal = true);

  late FakeJobApplicationRepository repository;
  late ApplicationsController controller;

  setUp(() async {
    repository = FakeJobApplicationRepository();
    controller = ApplicationsController(repository);
    await controller.load();
  });
  tearDown(() => controller.dispose());

  testWidgets('T6 — empty form is refused with a message under the field', (
    tester,
  ) async {
    await _openCreateForm(tester, controller);

    await _tapSave(tester, 'Enregistrer');

    expect(find.text("Indiquez le nom de l'entreprise."), findsOneWidget);
    expect(find.text("Indiquez l'intitulé du poste."), findsOneWidget);
    expect(find.text('Nouvelle candidature'), findsOneWidget);
    expect(controller.applications, isEmpty);
  });

  testWidgets('T7 — a filled form creates a card in the list', (tester) async {
    await _openCreateForm(tester, controller);

    await tester.enterText(_field('Entreprise *'), '  Nexora  ');
    await tester.enterText(
      _field('Intitulé du poste *'),
      'Développeur Flutter',
    );
    await _tapSave(tester, 'Enregistrer');

    expect(find.text('Nouvelle candidature'), findsNothing);
    expect(find.text('Développeur Flutter'), findsOneWidget);
    expect(controller.applications.single.company, 'Nexora');
    expect(controller.applications.single.url, isNull);
  });

  testWidgets('F14 — two quick taps create a single application', (
    tester,
  ) async {
    final gate = repository.writeGate = Completer<void>();
    await _openCreateForm(tester, controller);
    await tester.enterText(_field('Entreprise *'), 'Nexora');
    await tester.enterText(
      _field('Intitulé du poste *'),
      'Développeur Flutter',
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.pump();

    await tester.tap(find.text('Enregistrer'));
    await tester.tap(find.text('Enregistrer'));
    gate.complete();
    await tester.pumpAndSettle();

    expect(repository.writes, 1);
    expect(controller.applications, hasLength(1));
  });

  testWidgets('leaving during a slow save neither crashes nor pops twice', (
    tester,
  ) async {
    final gate = repository.writeGate = Completer<void>();
    await _openCreateForm(tester, controller);
    await tester.enterText(_field('Entreprise *'), 'Nexora');
    await tester.enterText(
      _field('Intitulé du poste *'),
      'Développeur Flutter',
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.pump();
    await tester.tap(find.text('Enregistrer'));
    await tester.pump();

    await tester.pageBack();
    await tester.pumpAndSettle();
    gate.complete();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Récentes'), findsOneWidget);
    expect(controller.applications, hasLength(1));
  });

  testWidgets('F15 — failed save keeps the form open with its input', (
    tester,
  ) async {
    repository.failWrites = true;
    await _openCreateForm(tester, controller);
    await tester.enterText(_field('Entreprise *'), 'Nexora');
    await tester.enterText(
      _field('Intitulé du poste *'),
      'Développeur Flutter',
    );

    await _tapSave(tester, 'Enregistrer');

    expect(find.text('Nouvelle candidature'), findsOneWidget);
    expect(find.text('Enregistrement impossible. Réessayez.'), findsOneWidget);
    expect(find.text('Nexora'), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNotNull);
  });

  testWidgets('F12 — editing keeps id and creation date', (tester) async {
    final created = DateTime(2026, 10, 1, 9);
    final original = JobApplication(
      id: 1,
      company: 'Nexora',
      position: 'Développeur Flutter',
      createdAt: created,
      updatedAt: created,
    );
    final editing = ApplicationsController(
      FakeJobApplicationRepository([original]),
    );
    addTearDown(editing.dispose);
    await editing.load();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    ApplicationFormPage(controller: editing, initial: original),
              ),
            ),
            child: const Text('Ouvrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();

    expect(find.text('Modifier la candidature'), findsOneWidget);
    expect(find.text('Nexora'), findsOneWidget);

    await tester.enterText(_field('Entreprise *'), 'Nexora SA');
    await _tapSave(tester, 'Enregistrer les modifications');

    final saved = editing.applications.single;
    expect(saved.id, 1);
    expect(saved.company, 'Nexora SA');
    expect(saved.createdAt, created);
    expect(saved.updatedAt.isAfter(created), isTrue);
  });

  testWidgets('F13 — an incomplete link is refused with a message under '
      'the field', (tester) async {
    await _openCreateForm(tester, controller);
    await tester.enterText(_field('Entreprise *'), 'Nexora');
    await tester.enterText(
      _field('Intitulé du poste *'),
      'Développeur Flutter',
    );
    await tester.ensureVisible(_field("Lien vers l'offre"));
    await tester.enterText(_field("Lien vers l'offre"), 'https://');

    await _tapSave(tester, 'Enregistrer');

    expect(
      find.text(
        'Indiquez une adresse complète, par exemple https://exemple.fr',
      ),
      findsOneWidget,
    );
    expect(find.text('Nouvelle candidature'), findsOneWidget);
    expect(repository.writes, 0);
  });
}
