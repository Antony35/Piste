import 'package:flutter_test/flutter_test.dart';
import 'package:piste/models/applications_summary.dart';
import 'package:piste/models/job_application.dart';

void main() {
  final now = DateTime(2026, 11, 5, 12);

  JobApplication app(
    int id,
    ApplicationStatus status, {
    int createdDaysAgo = 30,
    int updatedDaysAgo = 30,
    DateTime? followUp,
  }) => JobApplication(
    id: id,
    company: 'Entreprise $id',
    position: 'Poste $id',
    status: status,
    nextFollowUp: followUp,
    createdAt: now.subtract(Duration(days: createdDaysAgo)),
    updatedAt: now.subtract(Duration(days: updatedDaysAgo)),
  );

  test('empty list gives zeros, not errors', () {
    final summary = ApplicationsSummary.from([], now);

    expect(summary.total, 0);
    expect(summary.active, 0);
    expect(summary.recent, isEmpty);
    for (final status in ApplicationStatus.values) {
      expect(summary.count(status), 0);
    }
  });

  test('active excludes offers and rejections', () {
    final summary = ApplicationsSummary.from([
      app(1, ApplicationStatus.sent),
      app(2, ApplicationStatus.interview),
      app(3, ApplicationStatus.offer),
      app(4, ApplicationStatus.rejected),
    ], now);

    expect(summary.total, 4);
    expect(summary.active, 2);
    expect(summary.count(ApplicationStatus.interview), 1);
    expect(summary.count(ApplicationStatus.inProgress), 0);
  });

  test('created last week counts the last 7 days only', () {
    final summary = ApplicationsSummary.from([
      app(1, ApplicationStatus.sent, createdDaysAgo: 0),
      app(2, ApplicationStatus.sent, createdDaysAgo: 6),
      app(3, ApplicationStatus.sent, createdDaysAgo: 8),
    ], now);

    expect(summary.createdLastWeek, 2);
  });

  test('follow-ups due reuse the D3 rule', () {
    final summary = ApplicationsSummary.from([
      app(1, ApplicationStatus.sent, followUp: DateTime(2026, 11, 1)),
      app(2, ApplicationStatus.offer, followUp: DateTime(2026, 11, 1)),
      app(3, ApplicationStatus.sent, followUp: DateTime(2026, 12, 1)),
    ], now);

    expect(summary.followUpsDue, 1);
  });

  test('recent keeps the 3 most recently updated, newest first', () {
    final summary = ApplicationsSummary.from([
      app(1, ApplicationStatus.sent, updatedDaysAgo: 5),
      app(2, ApplicationStatus.sent, updatedDaysAgo: 1),
      app(3, ApplicationStatus.sent, updatedDaysAgo: 9),
      app(4, ApplicationStatus.sent, updatedDaysAgo: 2),
    ], now);

    expect(summary.recent.map((a) => a.id), [2, 4, 1]);
  });

  test('F19 — with no application, every share is 0, not NaN', () {
    final summary = ApplicationsSummary.from([], now);

    for (final status in ApplicationStatus.values) {
      expect(summary.share(status), 0);
      expect(summary.percent(status), 0);
    }
  });

  test('share and percent follow the counts', () {
    final summary = ApplicationsSummary.from([
      app(1, ApplicationStatus.sent),
      app(2, ApplicationStatus.interview),
      app(3, ApplicationStatus.interview),
    ], now);

    expect(summary.share(ApplicationStatus.interview), closeTo(2 / 3, 1e-9));
    expect(summary.percent(ApplicationStatus.interview), 67);
    expect(summary.percent(ApplicationStatus.sent), 33);
    expect(summary.percent(ApplicationStatus.offer), 0);
  });
}
