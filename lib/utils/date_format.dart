/// utils/date_format.dart
import 'package:intl/intl.dart';

int isoWeekNumber(DateTime date) {
  final thursday = date.add(Duration(days: 3 - date.weekday));
  final firstThursday = DateTime(thursday.year, 1, 4);
  final week1Start = firstThursday.subtract(Duration(days: firstThursday.weekday - 1));

  return ((thursday.difference(week1Start).inDays) / 7).floor() + 1;
}


/// Retourne le début de la semaine pour une date et un jour de début donnés
DateTime getWeekStart(DateTime date, int startDay) {
  int diff = date.weekday - startDay;
  if (diff < 0) diff += 7;
  return DateTime(date.year, date.month, date.day).subtract(Duration(days: diff));
}

/// Retourne une clé unique pour la semaine
/// Si startDay est 1 (Lundi), on garde le format ISO pour la compatibilité
/// Sinon, on utilise un format basé sur la date de début : "W-YYYY-MM-DD"
String getWeekKey(DateTime date, [int startDay = 1]) {
  if (startDay == 1) {
    final thursday = date.add(Duration(days: 3 - date.weekday));
    final firstThursday = DateTime(thursday.year, 1, 4);
    final week1Start = firstThursday.subtract(Duration(days: firstThursday.weekday - 1));
    final weekNumber = ((thursday.difference(week1Start).inDays) / 7).floor() + 1;
    return '${date.year}-W${weekNumber.toString().padLeft(2, '0')}';
  } else {
    final start = getWeekStart(date, startDay);
    return 'W-${DateFormat('yyyy-MM-dd').format(start)}';
  }
}

/// Retourne la date du début de la semaine à partir de la clé
DateTime getStartOfWeekFromKey(String weekKey, [int startDay = 1]) {
  if (weekKey.startsWith('W-')) {
    return DateTime.parse(weekKey.substring(2));
  }
  
  final match = RegExp(r'(\d{4})-W(\d{2})').firstMatch(weekKey);
  if (match != null) {
    final year = int.parse(match.group(1)!);
    final week = int.parse(match.group(2)!);

    final jan4 = DateTime(year, 1, 4);
    final firstWeekMonday = jan4.subtract(Duration(days: jan4.weekday - DateTime.monday));
    final targetMonday = firstWeekMonday.add(Duration(days: (week - 1) * 7));
    
    if (startDay == 1) return targetMonday;
    // Si on demande un autre jour de début, on trouve le début de semaine (startDay) 
    // correspondant à ce lundi.
    return getWeekStart(targetMonday, startDay);
  }
  throw FormatException("Invalid week key format: $weekKey");
}
