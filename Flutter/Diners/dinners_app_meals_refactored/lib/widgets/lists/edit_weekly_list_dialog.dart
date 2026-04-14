import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:dinners_app/providers/meal_provider.dart';
import 'package:dinners_app/utils/date_format.dart';
import 'package:dinners_app/utils/app_colors.dart';
import 'package:dinners_app/utils/app_theme.dart';
import 'package:intl/intl.dart';

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
    Provider.of<MealProvider>(context, listen: false)
        .getWeeklyIngredients(widget.weekStart)
        .then((data) {
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
        'name': '', 'quantity': 1, 'unit': 'QT',
        'checked': false, 'moment': 'extra', 'date': DateTime.now()
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    final weekKey = getWeekKey(widget.weekStart);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 30, offset: const Offset(0, 10))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── HEADER ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit_note_rounded, color: AppColors.primaryGreen, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Liste de courses', style: AppTheme.labelSmall.copyWith(color: AppColors.primaryGreen, fontWeight: FontWeight.w700)),
                        Text('Modifier la liste', style: AppTheme.titleMedium.copyWith(fontSize: 16)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey.shade400),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // ── CONTENU ─────────────────────────────────────
            Flexible(
              child: isLoading
                  ? const SizedBox(
                      height: 150,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryOrange)),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Bouton ajouter
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                          child: Row(
                            children: [
                              Text('Ingrédients', style: AppTheme.titleMedium.copyWith(fontSize: 14)),
                              const Spacer(),
                              GestureDetector(
                                onTap: _addIngredient,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.add, color: AppColors.primaryGreen, size: 16),
                                      const SizedBox(width: 4),
                                      Text('Ajouter', style: AppTheme.labelSmall.copyWith(color: AppColors.primaryGreen, fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Liste scrollable
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 80, maxHeight: 320),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ingredients.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.shopping_basket_outlined, size: 32, color: Colors.grey.shade300),
                                          const SizedBox(height: 8),
                                          Text('Aucun ingrédient', style: AppTheme.bodyText.copyWith(color: AppColors.textSecondary)),
                                        ],
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                    itemCount: ingredients.length,
                                    separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
                                    itemBuilder: (context, index) {
                                      final item = ingredients[index];
                                      final nameCtrl = TextEditingController(text: item['name'])
                                        ..selection = TextSelection.collapsed(offset: (item['name'] as String).length);
                                      final qtyCtrl = TextEditingController(text: item['quantity'].toString());
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        child: Row(
                                          children: [
                                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle)),
                                            const SizedBox(width: 10),
                                            // Nom
                                            Expanded(
                                              flex: 7,
                                              child: TextField(
                                                controller: nameCtrl,
                                                style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600),
                                                decoration: InputDecoration(
                                                  hintText: 'Ingrédient',
                                                  hintStyle: AppTheme.bodyText.copyWith(color: Colors.grey.shade400),
                                                  border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero,
                                                ),
                                                onChanged: (v) => ingredients[index]['name'] = v,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Quantité
                                            Expanded(
                                              flex: 2,
                                              child: TextField(
                                                controller: qtyCtrl,
                                                keyboardType: TextInputType.number,
                                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                                textAlign: TextAlign.center,
                                                style: AppTheme.labelSmall.copyWith(fontWeight: FontWeight.w700),
                                                decoration: InputDecoration(
                                                  border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero,
                                                  hintText: '1', hintStyle: AppTheme.labelSmall.copyWith(color: Colors.grey.shade400),
                                                ),
                                                onTap: () => qtyCtrl.selection = TextSelection(baseOffset: 0, extentOffset: qtyCtrl.text.length),
                                                onTapOutside: (_) { if (qtyCtrl.text.isEmpty) qtyCtrl.text = '1'; },
                                                onChanged: (v) => ingredients[index]['quantity'] = int.tryParse(v) ?? 1,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            // Unité
                                            DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value: item['unit'] ?? 'QT',
                                                isDense: true,
                                                style: AppTheme.labelSmall.copyWith(color: AppColors.textSecondary),
                                                items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                                                onChanged: (v) => setState(() => ingredients[index]['unit'] = v),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            // Supprimer
                                            GestureDetector(
                                              onTap: () => setState(() => ingredients.removeAt(index)),
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                                                child: Icon(Icons.close, color: Colors.red.shade400, size: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
            ),

            // ── ACTIONS ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, -4))],
              ),
              child: Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Annuler', style: AppTheme.bodyText.copyWith(color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 8),
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
                          momentsDetected.putIfAbsent(dateKey, () => {}).add(item['moment']);
                        }
                      }

                      for (var item in ingredients) {
                        if (item['moment'] != 'extra' && (item['name']?.toString().trim().isNotEmpty ?? false)) {
                          final date = item['date'] as DateTime;
                          final dateKey = DateFormat('yyyy-MM-dd').format(date);
                          groupedByDay.putIfAbsent(dateKey, () => {'midi': [], 'soir': []});
                          groupedByDay[dateKey]![item['moment']]!.add(item);
                          momentsToUpdate.putIfAbsent(dateKey, () => {}).add(item['moment']);
                        }
                      }

                      for (final entry in momentsDetected.entries) {
                        for (final moment in entry.value) {
                          momentsToUpdate.putIfAbsent(entry.key, () => {}).add(moment);
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
                            date: date, moment: moment, meal: existingMeal, ingredients: updatedItems,
                          );
                        }
                      }

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('Sauvegarder', style: AppTheme.bodyText.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
