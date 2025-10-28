import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/weekly_list_provider.dart';

class WeeklyListScreen extends StatelessWidget {
  final DateTime weekStart;

  const WeeklyListScreen({super.key, required this.weekStart});

  String get weekKey {
    final year = DateFormat('yyyy').format(weekStart);
    final weekNumber = ((weekStart.difference(DateTime(weekStart.year, 1, 1)).inDays + DateTime(weekStart.year, 1, 1).weekday) / 7).ceil();
    return "$year-W$weekNumber";
  }

  String get formattedRange {
    final formatter = DateFormat('d MMMM', 'fr_FR');
    final endOfWeek = weekStart.add(const Duration(days: 6));
    return 'Du ${formatter.format(weekStart)} au ${formatter.format(endOfWeek)}';
  }

  @override
  Widget build(BuildContext context) {
    final listProvider = Provider.of<WeeklyListProvider>(context);
    final items = listProvider.getList(weekKey);

    return Scaffold(
      appBar: AppBar(
        title: Text('Liste $formattedRange'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ingrédients', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: items.isEmpty
                    ? const Center(child: Text('Aucun ingrédient pour cette semaine.'))
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return ListTile(
                            leading: Checkbox(
                              value: item['checked'],
                              onChanged: (_) => listProvider.toggleCheck(weekKey, index),
                            ),
                            title: Text('${item['name']}'),
                            trailing: Text('x${item['quantity']}'),
                          );
                        },
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
