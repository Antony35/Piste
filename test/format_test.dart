import 'package:flutter_test/flutter_test.dart';
import 'package:piste/ui/format.dart';

void main() {
  final now = DateTime(2026, 11, 5, 9);

  test('same day reads « aujourd\'hui »', () {
    expect(relativeAge(DateTime(2026, 11, 5, 8), now), "aujourd'hui");
  });

  test('yesterday late evening still reads « hier »', () {
    expect(relativeAge(DateTime(2026, 11, 4, 23), now), 'hier');
  });

  test('a few days reads in days', () {
    expect(relativeAge(DateTime(2026, 11, 2), now), 'il y a 3 j');
  });

  test('a week or more reads in weeks', () {
    expect(relativeAge(DateTime(2026, 10, 22), now), 'il y a 2 sem.');
  });

  test('long date names the right weekday and month', () {
    expect(longDate(DateTime(2026, 11, 5)), 'Jeudi 5 novembre');
    expect(longDate(DateTime(2026, 1, 5)), 'Lundi 5 janvier');
    expect(longDate(DateTime(2026, 12, 27)), 'Dimanche 27 décembre');
  });

  test('short date pads day and month to two digits', () {
    expect(shortDate(DateTime(2026, 11, 5)), '05/11/2026');
    expect(shortDate(DateTime(2026, 1, 31)), '31/01/2026');
  });

  test('short date-time pads hours and minutes', () {
    expect(shortDateTime(DateTime(2026, 11, 5, 9, 5)), '05/11/2026 à 09:05');
    expect(shortDateTime(DateTime(2026, 11, 5, 18, 30)), '05/11/2026 à 18:30');
  });

  test('F1 — greeting adds the first name only when there is one', () {
    expect(greeting(''), 'Bonjour');
    expect(greeting('Antony'), 'Bonjour Antony');
  });

  test('F20 — initials: one or two letters, upper case', () {
    expect(initials('antony'), 'A');
    expect(initials('Jean-Pierre'), 'JP');
    expect(initials('  marie   claire  louise '), 'MC');
    expect(initials(''), '');
  });

  test('initials keep a letter written with a separate accent mark', () {
    // « E » followed by U+0301, the combining acute accent.
    expect(initials('E\u0301milie'), 'E\u0301');
  });
}
