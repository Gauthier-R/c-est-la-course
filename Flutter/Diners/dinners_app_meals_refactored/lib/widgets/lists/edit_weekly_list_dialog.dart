import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dinners_app/providers/meal_provider.dart';
import 'package:dinners_app/utils/date_format.dart';
import 'package:dinners_app/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:dinners_app/utils/responsive_helper.dart';

class EditWeeklyListDialog extends StatefulWidget {
  final DateTime weekStart;

  const EditWeeklyListDialog({super.key, required this.weekStart});

  @override
  State<EditWeeklyListDialog> createState() => _EditWeeklyListDialogState();
}

class _EditWeeklyListDialogState extends State<EditWeeklyListDialog> {
  List<Map<String, dynamic>> ingredients = [];
  bool isLoading = true;
  List<Map<String, dynamic>> originalIngredients = [];
  final List<String> units = ['QT', 'g', 'kg', 'mL', 'L'];

  @override
  void initState() {
    super.initState();
    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    mealProvider.getWeeklyIngredients(widget.weekStart).then((data) {
      setState(() {
        ingredients = data.map((e) => Map<String, dynamic>.from(e)).toList();
        for (final item in ingredients) {
          item['unit'] ??= 'QT';
        }
        originalIngredients = List.from(ingredients);
        isLoading = false;
      });
    });
  }

  void _addIngredient() {
    setState(() {
      ingredients.add({
        'name': '',
        'quantity': 1,
        'unit': 'QT',
        'checked': false,
        'moment': 'extra',
        'date': DateTime.now()
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    final weekKey = getWeekKey(widget.weekStart);

    return AlertDialog(
      title: Text(
        "Modifier la liste",
        style: GoogleFonts.poppins(
          fontSize: ResponsiveHelper.scalableFont(context, 16),
          fontWeight: FontWeight.w600,
        ),
      ),
      content: isLoading
          ? SizedBox(
              height: ResponsiveHelper.heightPercent(context, 0.5),
              child: const Center(child: CircularProgressIndicator()),
            )
          : SizedBox(
              height: ResponsiveHelper.heightPercent(context, 0.5),
              width: double.maxFinite,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _addIngredient,
                    child: Row(
                      children: [
                        const Icon(Icons.add_circle_outline, color: Colors.green, size: 15),
                        SizedBox(width: ResponsiveHelper.widthPercent(context, 0.02)),
                        Text(
                          'Ajouter Ingrédient',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: ResponsiveHelper.scalableFont(context, 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.heightPercent(context, 0.015)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: ingredients.length,
                      itemBuilder: (context, index) {
                        final item = ingredients[index];
                        final nameCtrl = TextEditingController(text: item['name']);
                        final qtyCtrl = TextEditingController(text: item['quantity'].toString());
                        final selectedUnit = item['unit'] ?? 'QT';

                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.heightPercent(context, 0.005)),
                          child: Row(
                            children: [
                              // Nom de l'ingrédient (50%)
                              Expanded(
                                flex: 7,
                                child: TextField(
                                  controller: nameCtrl,
                                  decoration: InputDecoration(
                                    hintText: 'Ingrédient',
                                    hintStyle: GoogleFonts.poppins(fontSize: 10),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                  ),
                                  onChanged: (value) => ingredients[index]['name'] = value,
                                  style: TextStyle(fontSize: ResponsiveHelper.scalableFont(context, 12)),
                                ),
                              ),
                              SizedBox(width: ResponsiveHelper.widthPercent(context, 0.01)),

                              // Quantité (15%)
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: qtyCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    prefixText: 'x',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                                  ),
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  onTap: () => qtyCtrl.selection = TextSelection(baseOffset: 0, extentOffset: qtyCtrl.text.length),
                                  onTapOutside: (_) {
                                    if (qtyCtrl.text.isEmpty) qtyCtrl.text = '1';
                                  },
                                  onChanged: (value) => ingredients[index]['quantity'] = int.tryParse(value) ?? 1,
                                  style: TextStyle(fontSize: ResponsiveHelper.scalableFont(context, 12)),
                                ),
                              ),
                              SizedBox(width: ResponsiveHelper.widthPercent(context, 0.01)),

                              // Unité (20%)
                              Expanded(
                                flex: 3,
                                child: DropdownButtonFormField<String>(
                                  value: selectedUnit,
                                  items: units.map((u) => DropdownMenuItem(
                                    value: u,
                                    child: Text(u, style: TextStyle(fontSize: ResponsiveHelper.scalableFont(context, 12), color: Colors.black)),
                                  )).toList(),
                                  onChanged: (value) => setState(() => ingredients[index]['unit'] = value),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                                  ),
                                  style: TextStyle(fontSize: ResponsiveHelper.scalableFont(context, 5)),
                                  isExpanded: true,
                                ),
                              ),
                              SizedBox(width: ResponsiveHelper.widthPercent(context, 0.01)),

                              // Bouton de suppression (15%)
                              Expanded(
                              flex: 1,
                              child: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red, size: ResponsiveHelper.scalableFont(context, 18)),
                                onPressed: () => setState(() => ingredients.removeAt(index)),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              )
                              
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
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
          child: Text("Annuler", style: TextStyle(fontSize: ResponsiveHelper.scalableFont(context, 12))),
        ),
        ElevatedButton(
          onPressed: () async {
            final extras = ingredients
                .where((e) => e['moment'] == 'extra' && (e['name']?.toString().trim().isNotEmpty ?? false))
                .toList();

            final groupedByDay = <String, Map<String, List<Map<String, dynamic>>>>{};
            final momentsToUpdate = <String, Set<String>>{};
            final momentsDetected = <String, Set<String>>{};

            for (var item in originalIngredients) {
              if (item['moment'] != 'extra') {
                final dateKey = DateFormat('yyyy-MM-dd').format(item['date']);
                final moment = item['moment'];
                momentsDetected.putIfAbsent(dateKey, () => {}).add(moment);
              }
            }

            for (var item in ingredients) {
              if (item['moment'] != 'extra' && (item['name']?.toString().trim().isNotEmpty ?? false)) {
                final date = item['date'] as DateTime;
                final dateKey = DateFormat('yyyy-MM-dd').format(date);
                final moment = item['moment'];

                groupedByDay.putIfAbsent(dateKey, () => {'midi': [], 'soir': []});
                groupedByDay[dateKey]![moment]!.add(item);
                momentsToUpdate.putIfAbsent(dateKey, () => {}).add(moment);
              }
            }

            for (final entry in momentsDetected.entries) {
              final dateKey = entry.key;
              for (final moment in entry.value) {
                momentsToUpdate.putIfAbsent(dateKey, () => {}).add(moment);
              }
            }

            await mealProvider.updateExtrasForWeek(weekKey, extras);

            for (final entry in momentsToUpdate.entries) {
              final date = DateFormat('yyyy-MM-dd').parse(entry.key);
              for (final moment in entry.value) {
                final updatedItems = (groupedByDay[entry.key]?[moment] ?? [])
                    .where((e) => e['name']?.toString().trim().isNotEmpty ?? false)
                    .toList();
                final existingMeal = mealProvider.selectedMealsFor(date)[moment] ?? '';
                await mealProvider.saveMeal(
                  date: date,
                  moment: moment,
                  meal: existingMeal,
                  ingredients: updatedItems,
                );
              }
            }

            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryOrange,
          ),
          child: Text("Sauvegarder", style: TextStyle(fontSize: ResponsiveHelper.scalableFont(context, 12))),
        ),
      ],
    );
  }
}
