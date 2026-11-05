import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piste/main.dart';
import 'package:piste/models/job_application.dart';
import 'package:piste/ui/theme/app_theme.dart';

import 'fake_repository.dart';

/// WCAG contrast ratio, from 1 (same color) to 21 (black on white).
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// WCAG AA minimum for normal-size text.
const _textContrast = 4.5;

final _long = JobApplication(
  id: 1,
  company: 'Compagnie internationale de développement logiciel et mobile',
  position: 'Ingénieure logicielle senior spécialisée Flutter et Android',
  status: ApplicationStatus.interview,
  url: 'https://recrutement.compagnie-internationale.example/offres/123456',
  notes:
      'Entretien technique prévu avec deux personnes de l’équipe mobile. ' * 4,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

/// Narrow phone and the largest text Android offers by default.
void _smallScreenLargeText(WidgetTester tester) {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = 2;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

void main() {
  group('Contrast (course § 19)', () {
    for (final (name, theme, piste) in [
      ('light', AppTheme.light, PisteColors.light),
      ('dark', AppTheme.dark, PisteColors.dark),
    ]) {
      final scheme = theme.colorScheme;

      test('$name — text on the main surfaces is readable', () {
        final pairs = {
          'onSurface': (scheme.onSurface, scheme.surface),
          'onSurfaceVariant': (scheme.onSurfaceVariant, scheme.surface),
          'onPrimary': (scheme.onPrimary, scheme.primary),
          'onSecondary': (scheme.onSecondary, scheme.secondary),
          'error': (scheme.error, scheme.surface),
          'onSummaryCard': (piste.onSummaryCard, piste.summaryCard),
          'onSummaryCardMuted': (piste.onSummaryCardMuted, piste.summaryCard),
        };
        for (final MapEntry(key: role, value: (text, background))
            in pairs.entries) {
          expect(
            _contrast(text, background),
            greaterThanOrEqualTo(_textContrast),
            reason: role,
          );
        }
      });

      test('$name — every status pill is readable', () {
        for (final status in ApplicationStatus.values) {
          final colors = piste.of(status);
          expect(
            _contrast(colors.foreground, colors.background),
            greaterThanOrEqualTo(_textContrast),
            reason: status.name,
          );
        }
      });
    }
  });

  group('Very long names on a small screen with large text (course § 19)', () {
    Future<void> pumpApp(WidgetTester tester) async {
      _smallScreenLargeText(tester);
      await tester.pumpWidget(
        PisteApp(repository: FakeJobApplicationRepository([_long])),
      );
      await tester.pump();
    }

    testWidgets('home', (tester) async {
      await pumpApp(tester);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('applications list and statistics', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Candidatures'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Statistiques'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('detail and edit form', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Candidatures'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(_long.position));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Supprimer'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip('Modifier'));
      await tester.pumpAndSettle();
      expect(find.text('Modifier la candidature'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
