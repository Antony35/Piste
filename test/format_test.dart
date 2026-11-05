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
}
