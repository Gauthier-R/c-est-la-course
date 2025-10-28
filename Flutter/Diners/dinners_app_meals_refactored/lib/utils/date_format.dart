/// utils/date_format.dart

int isoWeekNumber(DateTime date) {
  final thursday = date.add(Duration(days: 3 - date.weekday));
  final firstThursday = DateTime(thursday.year, 1, 4);
  final week1Start = firstThursday.subtract(Duration(days: firstThursday.weekday - 1));

  return ((thursday.difference(week1Start).inDays) / 7).floor() + 1;
}


/// Retourne une clé de type "2025-W15"
String getWeekKey(DateTime date) {
  final weekNumber = isoWeekNumber(date);
  return '${date.year}-W${weekNumber.toString().padLeft(2, '0')}';
}

/// Retourne la date du lundi de la semaine donnée
DateTime getStartOfWeekFromKey(String weekKey) {
  final match = RegExp(r'(\d{4})-W(\d{2})').firstMatch(weekKey);
  if (match != null) {
    final year = int.parse(match.group(1)!);
    final week = int.parse(match.group(2)!);

    final jan4 = DateTime(year, 1, 4);
    final firstWeekMonday = jan4.subtract(Duration(days: jan4.weekday - DateTime.monday));
    return firstWeekMonday.add(Duration(days: (week - 1) * 7));
  }
  throw FormatException("Invalid week key format: $weekKey");
}
