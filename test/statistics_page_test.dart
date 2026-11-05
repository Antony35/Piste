import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piste/main.dart';
import 'package:piste/models/job_application.dart';

import 'fake_repository.dart';

JobApplication _app(int id, String company, ApplicationStatus status) =>
    JobApplication(
      id: id,
      company: company,
      position: 'Développeur Flutter',
      status: status,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

final _applications = [
  _app(1, 'Nexora', ApplicationStatus.interview),
  _app(2, 'Kaleo', ApplicationStatus.interview),
  _app(3, 'Asteria', ApplicationStatus.sent),
  _app(4, 'Lumen', ApplicationStatus.rejected),
];

Future<void> _openStatistics(
  WidgetTester tester, [
  List<JobApplication> applications = const [],
]) async {
  await tester.pumpWidget(
    PisteApp(repository: FakeJobApplicationRepository(applications)),
  );
  await tester.pump();
  await tester.tap(find.text('Statistiques'));
  await tester.pumpAndSettle();
}

/// The figures of one status row, as read by a screen reader.
Finder _row(String text) => find.bySemanticsLabel(text);

/// Values of the bars, in status order.
List<double?> _bars(WidgetTester tester) => tester
    .widgetList<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
    .map((bar) => bar.value)
    .toList();

void main() {
  setUpAll(() => WidgetController.hitTestWarningShouldBeFatal = true);

  testWidgets('F17 — total, then count, share and bar per status', (
    tester,
  ) async {
    await _openStatistics(tester, _applications);

    expect(_row('4 candidatures au total'), findsOneWidget);
    expect(_row('Entretien : 2, 50 %'), findsOneWidget);
    expect(_row('Envoyée : 1, 25 %'), findsOneWidget);
    expect(_row('Refusée : 1, 25 %'), findsOneWidget);
    expect(_row('Offre : 0, 0 %'), findsOneWidget);
    // sent, inProgress, interview, offer, rejected
    expect(_bars(tester), [0.25, 0, 0.5, 0, 0.25]);
  });

  testWidgets('F18 — an active filter does not change the figures', (
    tester,
  ) async {
    await tester.pumpWidget(
      PisteApp(repository: FakeJobApplicationRepository(_applications)),
    );
    await tester.pump();
    await tester.tap(find.text('Candidatures'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(SearchBar), 'nexora');
    await tester.pump();
    expect(find.text('Kaleo'), findsNothing);

    await tester.tap(find.text('Statistiques'));
    await tester.pumpAndSettle();

    expect(_row('4 candidatures au total'), findsOneWidget);
    expect(_row('Entretien : 2, 50 %'), findsOneWidget);
  });

  testWidgets('F19 — with no application, every figure is 0', (tester) async {
    await _openStatistics(tester);

    expect(_row('0 candidatures au total'), findsOneWidget);
    for (final status in ApplicationStatus.values) {
      expect(_row('${status.label} : 0, 0 %'), findsOneWidget);
    }
    expect(_bars(tester), everyElement(0));
    expect(find.textContaining('NaN'), findsNothing);
  });

  testWidgets('statistics fit a small screen with large text', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _openStatistics(tester, _applications);

    expect(tester.takeException(), isNull);
  });
}
