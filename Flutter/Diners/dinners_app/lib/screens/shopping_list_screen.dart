import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/weekly_list_provider.dart';
import '../providers/meal_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/lists/shopping_header.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  bool _hasSynced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

        if (!_hasSynced) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final weeklyListProvider = Provider.of<WeeklyListProvider>(context, listen: false);
        final mealProvider = Provider.of<MealProvider>(context, listen: false);

        // Synchronisation SANS effacer les données existantes comme les cases cochées
        final newWeeklyLists = mealProvider.generateWeeklyIngredientLists();
        newWeeklyLists.forEach((weekKey, newItems) {
          final existingList = weeklyListProvider.getList(weekKey);
          for (var newItem in newItems) {
            final index = existingList.indexWhere((item) => item['name'] == newItem['name']);
            if (index != -1) {
              existingList[index]['quantity'] = newItem['quantity'];
              existingList[index]['checked'] = existingList[index]['checked'] ?? false;
            } else {
              existingList.add({...newItem, 'checked': false});
            }
          }
        });

        weeklyListProvider.updateAll(newWeeklyLists); // <- ✅ Nouvelle méthode pour mettre à jour l'état avec persistance
      });
      _hasSynced = true;
    }
  }

  String formatWeekRange(DateTime startOfWeek) {
    final formatter = DateFormat('d MMMM', 'fr_FR');
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return 'Du ${formatter.format(startOfWeek)} au ${formatter.format(endOfWeek)}';
  }

  @override
  Widget build(BuildContext context) {
    final weeklyListProvider = Provider.of<WeeklyListProvider>(context);
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final nextWeekStart = currentWeekStart.add(const Duration(days: 7));
    final currentWeekKey = weeklyListProvider.currentWeekKey;
    final currentWeekList = weeklyListProvider.getList(currentWeekKey);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryGreen, AppColors.lightGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShoppingHeader(),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildListButton(
                      context,
                      label: "Historique",
                      color: Colors.grey.shade300,
                      textColor: Colors.black54,
                      onTap: () => Navigator.pushNamed(context, "/history"),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(thickness: 1.2, indent: 8, endIndent: 8, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    _buildGradientButton(
                      context,
                      label: "Semaine Actuelle\n${formatWeekRange(currentWeekStart)}",
                      height: 300,
                      gradientColors: [AppColors.darkOrange, AppColors.primaryOrange],
                      textColor: Colors.white,
                      onTap: () => Navigator.pushNamed(context, "/week", arguments: currentWeekStart),
                    ),
                    const SizedBox(height: 20),
                    _buildGradientButton(
                      context,
                      label: "Semaine Prochaine\n${formatWeekRange(nextWeekStart)}",
                      height: 200,
                      gradientColors: [AppColors.primaryGreen, AppColors.lightGreen],
                      textColor: Colors.white,
                      onTap: () => Navigator.pushNamed(context, "/week", arguments: nextWeekStart),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListButton(BuildContext context,
      {required String label,
      required Color color,
      required Color textColor,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton(
    BuildContext context, {
    required String label,
    required double height,
    required List<Color> gradientColors,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
