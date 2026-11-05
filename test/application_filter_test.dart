import 'package:flutter_test/flutter_test.dart';
import 'package:piste/models/application_filter.dart';
import 'package:piste/models/job_application.dart';

JobApplication _app(
  int id,
  String company,
  String position, {
  ApplicationStatus status = ApplicationStatus.sent,
  int daysAgo = 0,
}) {
  final date = DateTime(2026, 11, 5).subtract(Duration(days: daysAgo));
  return JobApplication(
    id: id,
    company: company,
    position: position,
    status: status,
    createdAt: date,
    updatedAt: date,
  );
}

List<int?> _ids(List<JobApplication> applications) =>
    applications.map((a) => a.id).toList();

void main() {
  final all = [
    _app(1, 'Nexora', 'Développeur Flutter', daysAgo: 3),
    _app(2, 'Kaleo', 'Ingénieur mobile', status: ApplicationStatus.interview),
    _app(
      3,
      'Asteria',
      'Développeuse backend',
      status: ApplicationStatus.interview,
      daysAgo: 1,
    ),
  ];

  test('no filter keeps everything, most recently updated first', () {
    const filter = ApplicationFilter();

    expect(filter.isActive, isFalse);
    expect(_ids(filter.apply(all)), [2, 3, 1]);
  });

  test('F7 — search matches the company or the position', () {
    expect(_ids(const ApplicationFilter(query: 'kaleo').apply(all)), [2]);
    expect(_ids(const ApplicationFilter(query: 'flutter').apply(all)), [1]);
  });

  test('F7 — case and spaces around the text are ignored', () {
    const filter = ApplicationFilter(query: '  DÉVELOPP  ');

    expect(filter.isActive, isTrue);
    expect(_ids(filter.apply(all)), [3, 1]);
  });

  test('a query of spaces only filters nothing', () {
    const filter = ApplicationFilter(query: '   ');

    expect(filter.isActive, isFalse);
    expect(filter.apply(all), hasLength(3));
  });

  test('status chip keeps only that status', () {
    const filter = ApplicationFilter(status: ApplicationStatus.interview);

    expect(_ids(filter.apply(all)), [2, 3]);
  });

  test('F8 — search and status combine', () {
    const filter = ApplicationFilter(
      query: 'développ',
      status: ApplicationStatus.interview,
    );

    expect(_ids(filter.apply(all)), [3]);
  });

  test('withQuery and withStatus keep the other half', () {
    final filter = const ApplicationFilter()
        .withStatus(ApplicationStatus.offer)
        .withQuery('nex');

    expect(filter.query, 'nex');
    expect(filter.status, ApplicationStatus.offer);
    expect(filter.withStatus(null).query, 'nex');
  });

  test('result is read-only', () {
    expect(
      () => const ApplicationFilter().apply(all).clear(),
      throwsUnsupportedError,
    );
  });
}
