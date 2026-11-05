import 'package:flutter_test/flutter_test.dart';
import 'package:piste/ui/form_validators.dart';

void main() {
  test('required company: empty, blank or null is refused', () {
    for (final value in [null, '', '   ']) {
      expect(validateCompany(value), "Indiquez le nom de l'entreprise.");
    }
    expect(validateCompany('Nexora'), isNull);
  });

  test('required position follows the same rule', () {
    expect(validatePosition('  '), "Indiquez l'intitulé du poste.");
    expect(validatePosition('Développeur'), isNull);
  });

  test('url is optional', () {
    expect(validateUrl(null), isNull);
    expect(validateUrl('  '), isNull);
  });

  test('url must start with http:// or https://', () {
    expect(validateUrl('https://nexora.example/offre'), isNull);
    expect(validateUrl('http://nexora.example'), isNull);
    expect(validateUrl('www.nexora.example'), isNotNull);
  });

  test('F13 — url needs a site name after the scheme', () {
    const message =
        'Indiquez une adresse complète, par exemple https://exemple.fr';
    expect(validateUrl('http://'), message);
    expect(validateUrl('https://  '), message);
    expect(validateUrl('https://nexora example.fr'), message);
    expect(validateUrl('HTTPS://Nexora.example'), isNull);
    expect(validateUrl('ftp://nexora.example'), isNot(message));
  });
}
