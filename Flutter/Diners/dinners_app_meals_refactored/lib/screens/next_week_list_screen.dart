import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:dinners_app/utils/app_colors.dart';
import 'package:dinners_app/widgets/lists/weekly_ingredient_list.dart';
import 'package:provider/provider.dart';
import 'package:dinners_app/providers/meal_provider.dart';
import 'package:dinners_app/utils/date_format.dart';
import 'package:dinners_app/widgets/lists/edit_weekly_list_dialog.dart';
import 'package:dinners_app/utils/responsive_helper.dart';

class NextWeekListScreen extends StatelessWidget {
  const NextWeekListScreen({super.key});

  String formatWeekRange(DateTime startOfWeek) {
    final formatter = DateFormat('d MMMM', 'fr_FR');
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return 'Du ${formatter.format(startOfWeek)} au ${formatter.format(endOfWeek)}';
  }

  void _showAddIngredientDialog(BuildContext context, DateTime weekStart) {
    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    final weekKey = getWeekKey(weekStart);

    final nameController = TextEditingController();
    final qtyController = TextEditingController(text: '1');
    final List<String> units = ['QT', 'g', 'kg', 'mL', 'L'];
    String selectedUnit = 'QT';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Ajouter un ingrédient",
            style: GoogleFonts.poppins(
              fontSize: ResponsiveHelper.scalableFont(context, 16),
              fontWeight: FontWeight.w600,
            )),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 8,
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Ingrédient',
                          hintStyle: GoogleFonts.poppins(fontSize: 12),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.widthPercent(context, 0.01)),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: qtyController,
                        keyboardType: TextInputType.number,
                        onTap: () => qtyController.selection = TextSelection(baseOffset: 0, extentOffset: qtyController.text.length),
                        decoration: const InputDecoration(
                          prefixText: 'x',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.widthPercent(context, 0.01)),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedUnit,
                        items: units
                            .map((u) => DropdownMenuItem(
                                  value: u,
                                  child: Text(u,
                                      style: TextStyle(fontSize: ResponsiveHelper.scalableFont(context, 12))),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) selectedUnit = value;
                        },
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actionsPadding: EdgeInsets.only(
          left: ResponsiveHelper.widthPercent(context, 0.04),
          right: ResponsiveHelper.widthPercent(context, 0.04),
          bottom: ResponsiveHelper.heightPercent(context, 0.015),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(fontSize: ResponsiveHelper.scalableFont(context, 14))),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final qty = int.tryParse(qtyController.text.trim()) ?? 1;
              if (name.isNotEmpty) {
                await mealProvider.addWeeklyExtra(weekKey, name, qty, selectedUnit);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
            ),
            child: Text('Ajouter', style: TextStyle(fontSize: ResponsiveHelper.scalableFont(context, 14))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final nextWeekStart = now.subtract(Duration(days: now.weekday - 1)).add(const Duration(days: 7));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryGreen, AppColors.lightGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.widthPercent(context, 0.05),
          vertical: ResponsiveHelper.heightPercent(context, 0.05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: ResponsiveHelper.widthPercent(context, 0.05)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                SizedBox(width: ResponsiveHelper.widthPercent(context, 0.001)),
                Expanded(
                  child: Text(
                    formatWeekRange(nextWeekStart),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveHelper.scalableFont(context, 16),
                        ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add,
                      color: Colors.white,
                      size: ResponsiveHelper.widthPercent(context, 0.06)),
                  onPressed: () => _showAddIngredientDialog(context, nextWeekStart),
                ),
                IconButton(
                  icon: Icon(Icons.edit,
                      color: Colors.white,
                      size: ResponsiveHelper.widthPercent(context, 0.05)),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => EditWeeklyListDialog(weekStart: nextWeekStart),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: ResponsiveHelper.heightPercent(context, 0.02)),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(ResponsiveHelper.widthPercent(context, 0.04)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: WeeklyIngredientList(weekStart: nextWeekStart),
              ),
            ),
          ],
        ),
      ),
    );
  }
}