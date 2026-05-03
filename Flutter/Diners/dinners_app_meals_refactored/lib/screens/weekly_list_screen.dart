import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';

class WeeklyListScreen extends StatelessWidget {
  final DateTime weekStart;

  const WeeklyListScreen({super.key, required this.weekStart});

  String get formattedRange {
    final formatter = DateFormat('d MMMM', 'fr_FR');
    final endOfWeek = weekStart.add(const Duration(days: 6));
    return 'Du ${formatter.format(weekStart)} au ${formatter.format(endOfWeek)}';
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Liste $formattedRange'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: mealProvider.getWeeklyIngredients(weekStart),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
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
                  Text('Ingrédients', style: Theme.of(context).textTheme.titleLarge),
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
                                  value: item['checked'] ?? false,
                                  onChanged: (val) {
                                    mealProvider.toggleIngredientChecked(item, val ?? false);
                                  },
                                ),
                                title: Text('${item['name']}'),
                                trailing: Text('x${(item['quantity'] is num && item['quantity'] == item['quantity'].roundToDouble()) ? item['quantity'].toInt() : item['quantity']}'),
                              );
                            },
                          ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
