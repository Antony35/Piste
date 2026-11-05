import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piste/models/job_application.dart';
import 'package:piste/state/applications_controller.dart';
import 'package:piste/ui/home_shell.dart';
import 'package:piste/ui/theme/app_theme.dart';

import 'fake_repository.dart';

JobApplication _nexora() => JobApplication(
  id: 1,
  company: 'Nexora',
  position: 'Développeur Flutter',
  status: ApplicationStatus.interview,
  nextFollowUp: DateTime(2026, 11, 10),
  url: 'https://nexora.example/offre',
  createdAt: DateTime(2026, 10, 14, 9, 30),
  updatedAt: DateTime(2026, 11, 4, 18, 5),
);

Future<void> _pumpShell(
  WidgetTester tester,
  ApplicationsController controller,
) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: HomeShell(controller: controller),
  ),
);

/// Opens the detail from the applications tab, as a user would.
Future<void> _openDetail(
  WidgetTester tester,
  ApplicationsController controller,
) async {
  await _pumpShell(tester, controller);
  await tester.tap(find.text('Candidatures'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Développeur Flutter'));
  await tester.pumpAndSettle();
}

Future<void> _confirmDeletion(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Supprimer'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Supprimer'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => WidgetController.hitTestWarningShouldBeFatal = true);

  late FakeJobApplicationRepository repository;
  late ApplicationsController controller;

  setUp(() async {
    repository = FakeJobApplicationRepository([_nexora()]);
    controller = ApplicationsController(repository);
    await controller.load();
  });
  tearDown(() => controller.dispose());

  testWidgets('F9 — tapping a card shows every field, read-only', (
    tester,
  ) async {
    await _openDetail(tester, controller);

    expect(find.text('Développeur Flutter'), findsOneWidget);
    expect(find.text('Nexora'), findsOneWidget);
    expect(find.text('Entretien'), findsOneWidget);
    expect(find.text('Non renseignée'), findsOneWidget);
    expect(find.text('10/11/2026'), findsOneWidget);
    expect(find.text('https://nexora.example/offre'), findsOneWidget);
    expect(find.text('Aucune note'), findsOneWidget);
    expect(find.text('14/10/2026 à 09:30'), findsOneWidget);
    expect(find.text('04/11/2026 à 18:05'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('a card on the home screen opens the detail too', (tester) async {
    await _pumpShell(tester, controller);

    await tester.tap(find.text('Développeur Flutter'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Modifier'), findsOneWidget);
  });

  testWidgets('F10 — edit opens the prefilled form, then shows the update', (
    tester,
  ) async {
    await _openDetail(tester, controller);

    await tester.tap(find.byTooltip('Modifier'));
    await tester.pumpAndSettle();
    expect(find.text('Modifier la candidature'), findsOneWidget);
    expect(find.text('Nexora'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Entreprise *'),
      'Nexora SA',
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Enregistrer les modifications'));
    await tester.pump();
    await tester.tap(find.text('Enregistrer les modifications'));
    await tester.pumpAndSettle();

    expect(find.text('Modifier la candidature'), findsNothing);
    expect(find.text('Nexora SA'), findsOneWidget);
    expect(controller.byId(1)?.company, 'Nexora SA');
  });

  testWidgets('F11 — the dialog names the application; cancel keeps it', (
    tester,
  ) async {
    await _openDetail(tester, controller);

    await tester.tap(find.byTooltip('Supprimer'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'La candidature « Développeur Flutter » chez Nexora '
        'sera supprimée définitivement.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byTooltip('Modifier'), findsOneWidget);
    expect(controller.applications, hasLength(1));
  });

  testWidgets('F11 — confirming deletes and returns to the list', (
    tester,
  ) async {
    await _openDetail(tester, controller);

    await _confirmDeletion(tester);

    expect(controller.applications, isEmpty);
    expect(find.byTooltip('Modifier'), findsNothing);
    expect(find.text('Développeur Flutter'), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('a failed deletion keeps the detail open with a message', (
    tester,
  ) async {
    await _openDetail(tester, controller);
    repository.failWrites = true;

    await _confirmDeletion(tester);

    expect(find.text('Suppression impossible. Réessayez.'), findsOneWidget);
    expect(controller.applications, hasLength(1));
    final delete = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.delete_rounded),
    );
    expect(delete.onPressed, isNotNull);
  });
}
