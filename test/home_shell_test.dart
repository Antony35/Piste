import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piste/main.dart';
import 'package:piste/models/job_application.dart';
import 'package:piste/ui/theme/app_theme.dart';

JobApplication _application(int id, String position, int daysAgo) {
  final date = DateTime.now().subtract(Duration(days: daysAgo));
  return JobApplication(
    id: id,
    company: 'Entreprise $id',
    position: position,
    createdAt: date,
    updatedAt: date,
  );
}

void main() {
  testWidgets('bottom bar switches to the applications tab', (tester) async {
    await tester.pumpWidget(
      PisteApp(applications: [_application(1, 'Développeur Flutter', 1)]),
    );

    expect(find.text('Développeur Flutter'), findsNothing);

    await tester.tap(find.text('Candidatures'));
    await tester.pumpAndSettle();

    expect(find.text('Développeur Flutter'), findsOneWidget);
    expect(find.byTooltip('Ajouter une candidature'), findsOneWidget);
  });

  testWidgets('applications are listed most recent first', (tester) async {
    await tester.pumpWidget(
      PisteApp(
        applications: [
          _application(1, 'Ancienne', 10),
          _application(2, 'Récente', 1),
        ],
      ),
    );
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

    await tester.pumpWidget(
      PisteApp(applications: [_application(1, 'Ingénieur logiciel ' * 6, 1)]),
    );
    await tester.tap(find.text('Candidatures'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
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
}
