import 'package:flutter_test/flutter_test.dart';
import 'package:piste/data/storage_exception.dart';
import 'package:piste/models/applications_summary.dart';
import 'package:piste/models/job_application.dart';
import 'package:piste/state/applications_controller.dart';

import 'fake_repository.dart';

JobApplication _draft(String company, {int? id}) => JobApplication(
  id: id,
  company: company,
  position: 'Développeur Flutter',
  createdAt: DateTime(2026, 11, 1),
  updatedAt: DateTime(2026, 11, 1),
);

void main() {
  late FakeJobApplicationRepository repository;
  late ApplicationsController controller;
  late List<LoadState> seen;

  setUp(() {
    repository = FakeJobApplicationRepository([_draft('Nexora', id: 1)]);
    controller = ApplicationsController(repository);
    seen = [];
    controller.addListener(() => seen.add(controller.state));
  });

  tearDown(() => controller.dispose());

  group('Loading (S1, S3)', () {
    test('starts in loading, then shows what storage holds', () async {
      expect(controller.state, LoadState.loading);

      await controller.load();

      expect(seen, [LoadState.loading, LoadState.success]);
      expect(controller.applications.single.company, 'Nexora');
    });

    test('T5 — a failed read is an error with a message, then a retry '
        'gives empty', () async {
      repository.failReads = true;
      await controller.load();

      expect(controller.state, LoadState.error);
      expect(controller.errorMessage, 'Chargement impossible.');
      expect(controller.applications, isEmpty);

      repository.failReads = false;
      await repository.delete(1);
      await controller.load();

      expect(controller.state, LoadState.empty);
      expect(controller.errorMessage, isNull);
    });
  });

  group('Writes', () {
    setUp(() async {
      await controller.load();
      seen.clear();
    });

    test('save without id stores it with the id given by storage', () async {
      await controller.save(_draft('Asteria'));

      expect(controller.applications, hasLength(2));
      expect(controller.applications.last.id, 2);
      expect(seen, [LoadState.success]);
    });

    test('save with an existing id replaces that application', () async {
      await controller.save(_draft('Nexora SA', id: 1));

      expect(controller.applications, hasLength(1));
      expect(controller.byId(1)?.company, 'Nexora SA');
      expect(seen, hasLength(1));
    });

    test('delete removes the application and notifies', () async {
      await controller.delete(1);

      expect(controller.applications, isEmpty);
      expect(controller.state, LoadState.empty);
      expect(seen, [LoadState.empty]);
    });

    test(
      'a failed write throws, changes nothing and notifies nobody',
      () async {
        repository.failWrites = true;

        await expectLater(
          controller.save(_draft('Asteria')),
          throwsA(isA<StorageException>()),
        );
        await expectLater(
          controller.delete(1),
          throwsA(isA<StorageException>()),
        );

        expect(controller.applications, hasLength(1));
        expect(seen, isEmpty);
      },
    );

    test('R4 — writing to an application that no longer exists throws '
        'and changes nothing', () async {
      await repository.delete(1);

      await expectLater(
        controller.save(_draft('Nexora SA', id: 1)),
        throwsA(isA<StorageException>()),
      );
      await expectLater(controller.delete(1), throwsA(isA<StorageException>()));

      expect(controller.byId(1)?.company, 'Nexora');
      expect(seen, isEmpty);
    });

    test('exposed list is read-only', () {
      expect(
        () => controller.applications.add(_draft('Pirate')),
        throwsUnsupportedError,
      );
    });
  });

  group('Filter', () {
    setUp(() async {
      await controller.save(
        JobApplication(
          company: 'Asteria',
          position: 'Développeuse backend',
          status: ApplicationStatus.interview,
          createdAt: DateTime(2026, 11, 2),
          updatedAt: DateTime(2026, 11, 2),
        ),
      );
      await controller.load();
      seen.clear();
    });

    test('T3 — search and status combine without changing the totals '
        '(F7, F8, F18)', () async {
      final now = DateTime(2026, 11, 5);
      final before = ApplicationsSummary.from(controller.applications, now);

      controller
        ..setQuery('  ASTER ')
        ..setStatus(ApplicationStatus.interview);

      expect(controller.visibleApplications.single.company, 'Asteria');
      final after = ApplicationsSummary.from(controller.applications, now);
      expect(after.total, before.total);
      expect(after.total, 2);
      expect(after.byStatus, before.byStatus);

      controller.setStatus(ApplicationStatus.sent);
      expect(controller.visibleApplications, isEmpty);
      expect(controller.state, LoadState.success);
    });

    test('a change notifies once, the same value does not', () {
      controller
        ..setQuery('nex')
        ..setQuery('nex');

      expect(seen, hasLength(1));
    });

    test('clearFilter shows everything again', () {
      controller
        ..setQuery('nex')
        ..setStatus(ApplicationStatus.offer)
        ..clearFilter();

      expect(controller.filter.isActive, isFalse);
      expect(controller.visibleApplications, hasLength(2));
    });

    test('a saved application follows the filter', () async {
      controller.setQuery('kaleo');
      expect(controller.visibleApplications, isEmpty);

      await controller.save(_draft('Kaleo'));

      expect(controller.visibleApplications.single.company, 'Kaleo');
    });
  });
}
