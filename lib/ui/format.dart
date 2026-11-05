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
