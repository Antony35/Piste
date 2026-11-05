import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piste/main.dart';
import 'package:piste/models/job_application.dart';
import 'package:piste/state/applications_controller.dart';
import 'package:piste/ui/format.dart';
import 'package:piste/ui/home_shell.dart';
import 'package:piste/ui/theme/app_theme.dart';

import 'fake_repository.dart';

JobApplication _application(int? id, String position, int daysAgo) {
  final date = DateTime.now().subtract(Duration(days: daysAgo));
  return JobApplication(
    id: id,
    company: 'Entreprise $id',
    position: position,
    createdAt: date,
    updatedAt: date,
  );
}

/// Starts the real app on [applications], then lets the first load finish.
Future<void> _pumpApp(
  WidgetTester tester,
  List<JobApplication> applications,
) async {
  await tester.pumpWidget(
    PisteApp(repository: FakeJobApplicationRepository(applications)),
  );
  await tester.pump();
}

void main() {
  testWidgets('bottom bar switches to the applications tab', (tester) async {
    await _pumpApp(tester, [_application(1, 'Développeur Flutter', 1)]);

    expect(find.text('Récentes'), findsOneWidget);

    await tester.tap(find.text('Candidatures'));
    await tester.pumpAndSettle();

    expect(find.text('Récentes'), findsNothing);
    expect(find.text('Développeur Flutter'), findsOneWidget);
    expect(find.byTooltip('Ajouter une candidature'), findsOneWidget);
  });

  testWidgets("F1 — home greets and shows today's date", (tester) async {
    await _pumpApp(tester, [_application(1, 'Développeur Flutter', 1)]);

    expect(find.text('Bonjour'), findsOneWidget);
    expect(find.text(longDate(DateTime.now())), findsOneWidget);
  });

  testWidgets('home shows the summary figures', (tester) async {
    final interview = JobApplication(
      id: 1,
      company: 'Nexora',
      position: 'Développeur Flutter',
      status: ApplicationStatus.interview,
      nextFollowUp: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final offer = JobApplication(
      id: 2,
      company: 'Kaleo',
      position: 'Ingénieur logiciel',
      status: ApplicationStatus.offer,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(days: 20)),
    );

    await _pumpApp(tester, [interview, offer]);

    Finder counter(String label) =>
        find.ancestor(of: find.text(label), matching: find.byType(Card));
    expect(
      find.descendant(of: counter('Entretiens'), matching: find.text('1')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: counter('Offres'), matching: find.text('1')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: counter('À relancer'), matching: find.text('1')),
      findsOneWidget,
    );
    expect(find.text('+1 cette semaine'), findsOneWidget);
  });

  testWidgets('« Tout voir » opens the applications tab', (tester) async {
    await _pumpApp(tester, [_application(1, 'Développeur Flutter', 1)]);

    await tester.tap(find.text('Tout voir'));
    await tester.pumpAndSettle();

    expect(find.text('Récentes'), findsNothing);
    expect(find.text('Développeur Flutter'), findsOneWidget);
  });

  testWidgets('home has no overflow on a small screen with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _pumpApp(tester, [_application(1, 'Développeur Flutter', 1)]);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('applications are listed most recent first', (tester) async {
    await _pumpApp(tester, [
      _application(1, 'Ancienne', 10),
      _application(2, 'Récente', 1),
    ]);
    await tester.tap(find.text('Candidatures'));
    await tester.pumpAndSettle();

    final recentY = tester.getTopLeft(find.text('Récente')).dy;
    final olderY = tester.getTopLeft(find.text('Ancienne')).dy;
    expect(recentY, lessThan(olderY));
  });

  testWidgets('a very long position does not overflow a small screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpApp(tester, [_application(1, 'Ingénieur logiciel ' * 6, 1)]);
    await tester.tap(find.text('Candidatures'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('screens follow controller changes', (tester) async {
    final controller = ApplicationsController(FakeJobApplicationRepository());
    addTearDown(controller.dispose);
    await controller.load();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: HomeShell(controller: controller),
      ),
    );
    expect(find.text('Développeur Flutter'), findsNothing);

    await controller.save(_application(null, 'Développeur Flutter', 0));
    await tester.pump();

    expect(find.text('Développeur Flutter'), findsOneWidget);
  });

  test('every status has colors in both themes', () {
    for (final colors in [PisteColors.light, PisteColors.dark]) {
      for (final status in ApplicationStatus.values) {
        expect(
          colors.statuses.containsKey(status),
          isTrue,
          reason: status.name,
        );
      }
    }
  });

  testWidgets('closing the app closes the repository (R1)', (tester) async {
    final repository = FakeJobApplicationRepository();
    await tester.pumpWidget(PisteApp(repository: repository));

    await tester.pumpWidget(const SizedBox());

    expect(repository.closed, isTrue);
  });
}
