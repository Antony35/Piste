import 'package:flutter_test/flutter_test.dart';
import 'package:piste/models/job_application.dart';

void main() {
  final complete = JobApplication(
    id: 7,
    company: 'Nexora',
    position: 'Développeur Flutter',
    status: ApplicationStatus.interview,
    appliedOn: DateTime(2026, 10, 14),
    nextFollowUp: DateTime(2026, 11, 10),
    url: 'https://nexora.example/offre',
    notes: 'Premier entretien technique.',
    createdAt: DateTime(2026, 10, 14, 9, 30),
    updatedAt: DateTime(2026, 11, 4, 18, 5),
  );

  group('Serialization (D2)', () {
    test('T1 — round trip keeps every field', () {
      final restored = JobApplication.fromDatabase(complete.toDatabase());

      expect(restored.id, complete.id);
      expect(restored.company, complete.company);
      expect(restored.position, complete.position);
      expect(restored.status, complete.status);
      expect(restored.appliedOn, complete.appliedOn);
      expect(restored.nextFollowUp, complete.nextFollowUp);
      expect(restored.url, complete.url);
      expect(restored.notes, complete.notes);
      expect(restored.createdAt, complete.createdAt);
      expect(restored.updatedAt, complete.updatedAt);
    });

    test('T1 — round trip keeps empty optional fields empty', () {
      final minimal = JobApplication(
        id: 1,
        company: 'Asteria',
        position: 'Mobile developer',
        createdAt: DateTime(2026, 11, 1),
        updatedAt: DateTime(2026, 11, 1),
      );

      final restored = JobApplication.fromDatabase(minimal.toDatabase());

      expect(restored.status, ApplicationStatus.sent);
      expect(restored.appliedOn, isNull);
      expect(restored.nextFollowUp, isNull);
      expect(restored.url, isNull);
      expect(restored.notes, isNull);
    });

    test('an application without id sends no id key', () {
      final unsaved = JobApplication(
        company: 'Kaleo',
        position: 'Ingénieur logiciel',
        createdAt: DateTime(2026, 11, 5),
        updatedAt: DateTime(2026, 11, 5),
      );

      expect(unsaved.toDatabase().containsKey('id'), isFalse);
    });

    test('status is stored by its name, not its label', () {
      expect(complete.toDatabase()['status'], 'interview');
    });
  });

  group('Unknown status (D1)', () {
    test('T2 — an unknown value is read as sent', () {
      final row = complete.toDatabase()..['status'] = 'draft';

      expect(JobApplication.fromDatabase(row).status, ApplicationStatus.sent);
    });

    test('T2 — a missing value is read as sent', () {
      expect(ApplicationStatus.fromName(null), ApplicationStatus.sent);
    });
  });

  group('Follow-up (D3)', () {
    final now = DateTime(2026, 11, 5, 14, 30);

    JobApplication withFollowUp(DateTime? date, ApplicationStatus status) =>
        JobApplication(
          company: 'Nexora',
          position: 'Développeur Flutter',
          status: status,
          nextFollowUp: date,
          createdAt: DateTime(2026, 10, 1),
          updatedAt: DateTime(2026, 10, 1),
        );

    test('T4 — past date: due', () {
      final app = withFollowUp(
        DateTime(2026, 11, 4),
        ApplicationStatus.inProgress,
      );
      expect(app.needsFollowUp(now), isTrue);
    });

    test('T4 — today, even later in the day: due', () {
      final app = withFollowUp(
        DateTime(2026, 11, 5, 18),
        ApplicationStatus.sent,
      );
      expect(app.needsFollowUp(now), isTrue);
    });

    test('T4 — future date: not yet', () {
      final app = withFollowUp(
        DateTime(2026, 11, 6),
        ApplicationStatus.inProgress,
      );
      expect(app.needsFollowUp(now), isFalse);
    });

    test('T4 — closed application: never due', () {
      for (final status in [
        ApplicationStatus.offer,
        ApplicationStatus.rejected,
      ]) {
        final app = withFollowUp(DateTime(2026, 11, 1), status);
        expect(app.needsFollowUp(now), isFalse, reason: status.name);
      }
    });

    test('T4 — no follow-up date: never due', () {
      final app = withFollowUp(null, ApplicationStatus.inProgress);
      expect(app.needsFollowUp(now), isFalse);
    });
  });
}
