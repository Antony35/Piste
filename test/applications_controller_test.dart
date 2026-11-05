import 'package:flutter_test/flutter_test.dart';
import 'package:piste/models/job_application.dart';
import 'package:piste/state/applications_controller.dart';

JobApplication _draft(String company, {int? id}) => JobApplication(
  id: id,
  company: company,
  position: 'Développeur Flutter',
  createdAt: DateTime(2026, 11, 1),
  updatedAt: DateTime(2026, 11, 1),
);

void main() {
  late ApplicationsController controller;
  late int notifications;

  setUp(() {
    controller = ApplicationsController([_draft('Nexora', id: 1)]);
    notifications = 0;
    controller.addListener(() => notifications++);
  });

  tearDown(() => controller.dispose());

  test('save without id creates with a new unique id and notifies', () async {
    await controller.save(_draft('Asteria'));

    expect(controller.applications, hasLength(2));
    expect(controller.applications.last.id, 2);
    expect(notifications, 1);
  });

  test('ids are never reused after a deletion', () async {
    await controller.save(_draft('Asteria'));
    await controller.delete(2);
    await controller.save(_draft('Kaleo'));

    expect(controller.byId(2), isNull);
    expect(controller.applications.last.id, 3);
  });

  test('save with an existing id replaces that application', () async {
    await controller.save(_draft('Nexora SA', id: 1));

    expect(controller.applications, hasLength(1));
    expect(controller.byId(1)?.company, 'Nexora SA');
    expect(notifications, 1);
  });

  test('delete removes the application and notifies', () async {
    await controller.delete(1);

    expect(controller.applications, isEmpty);
    expect(notifications, 1);
  });

  test('unknown id fails loudly and notifies nobody (R4)', () async {
    await expectLater(controller.save(_draft('X', id: 99)), throwsStateError);
    await expectLater(controller.delete(99), throwsStateError);

    expect(controller.applications, hasLength(1));
    expect(notifications, 0);
  });

  test('exposed list is read-only', () {
    expect(
      () => controller.applications.add(_draft('Pirate')),
      throwsUnsupportedError,
    );
  });

  test('the initial list is copied, not shared', () {
    final source = [_draft('Nexora', id: 1)];
    final owned = ApplicationsController(source);
    source.clear();

    expect(owned.applications, hasLength(1));
    owned.dispose();
  });
}
