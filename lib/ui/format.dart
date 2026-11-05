/// French relative age shown on cards, e.g. « il y a 3 j ».
String relativeAge(DateTime date, DateTime now) {
  final days = DateTime(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime(date.year, date.month, date.day)).inDays;
  if (days <= 0) return "aujourd'hui";
  if (days == 1) return 'hier';
  if (days < 7) return 'il y a $days j';
  return 'il y a ${days ~/ 7} sem.';
}

/// French long date for the home greeting, e.g. « Jeudi 5 novembre ».
String longDate(DateTime date) =>
    '${_weekdays[date.weekday - 1]} ${date.day} ${_months[date.month - 1]}';

const _weekdays = [
  'Lundi',
  'Mardi',
  'Mercredi',
  'Jeudi',
  'Vendredi',
  'Samedi',
  'Dimanche',
];

const _months = [
  'janvier',
  'février',
  'mars',
  'avril',
  'mai',
  'juin',
  'juillet',
  'août',
  'septembre',
  'octobre',
  'novembre',
  'décembre',
];

/// French numeric date, e.g. « 05/11/2026 ».
String shortDate(DateTime date) =>
    '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year}';

/// French date and time, e.g. « 05/11/2026 à 14:30 ».
String shortDateTime(DateTime date) =>
    '${shortDate(date)} à ${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';

String _twoDigits(int n) => n.toString().padLeft(2, '0');
