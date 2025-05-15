import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/weekly_list_provider.dart';
import 'weekly_list_screen.dart';

class HistoryListScreen extends StatelessWidget {
  const HistoryListScreen({super.key});

  String formatWeekRange(DateTime startOfWeek) {
    final formatter = DateFormat('d MMMM', 'fr_FR');
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return 'Du ${formatter.format(startOfWeek)} au ${formatter.format(endOfWeek)}';
  }

  DateTime getWeekStart(String weekKey) {
    final parts = weekKey.split('-W');
    final year = int.parse(parts[0]);
    final week = int.parse(parts[1]);
    return DateTime.utc(year, 1, 1 + (week - 1) * 7);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeeklyListProvider>(context);
    final now = DateTime.now();
    final currentWeekKey = provider.currentWeekKey;

    final pastWeeks = provider.allWeeklyLists.keys
        .where((key) => key != currentWeekKey) // exclure la semaine actuelle
        .toList()
      ..sort((a, b) => getWeekStart(b).compareTo(getWeekStart(a)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des listes'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: pastWeeks.length,
        itemBuilder: (context, index) {
          final weekKey = pastWeeks[index];
          final startDate = getWeekStart(weekKey);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(formatWeekRange(startDate)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WeeklyListScreen(weekStart: startDate),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
