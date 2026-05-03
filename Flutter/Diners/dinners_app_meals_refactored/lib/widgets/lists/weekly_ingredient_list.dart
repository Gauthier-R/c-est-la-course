// ✅ Version corrigée — WeeklyIngredientList
// Utilise le chemin correct groups/{groupId}/meals via MealProvider

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinners_app/utils/date_format.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/meal_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_theme.dart';

class WeeklyIngredientList extends StatelessWidget {
  final DateTime weekStart;

  const WeeklyIngredientList({super.key, required this.weekStart});

  String _formatQuantity(Map<String, dynamic> item) {
    final quantity = item['quantity'] ?? 0;
    final unit = item['unit'] ?? 'QT';
    // Formatage pour enlever le .0 si c'est un entier
    final formattedQty = quantity is double && quantity == quantity.roundToDouble() 
        ? quantity.toInt().toString() 
        : quantity.toString();
        
    if (unit == 'QT') return 'x $formattedQty';
    return '$formattedQty $unit';
  }

  /// Fusionne les ingrédients de même nom en cumulant les quantités
  List<Map<String, dynamic>> _deduplicateIngredients(
      List<Map<String, dynamic>> items) {
    final Map<String, Map<String, dynamic>> merged = {};
    for (final item in items) {
      final name = (item['name'] as String? ?? '').trim();
      if (name.isEmpty) continue;
      final key = name.toLowerCase();
      if (merged.containsKey(key)) {
        final existing = merged[key]!;
        final num existingQty = (existing['quantity'] as num?) ?? 0;
        final num newQty = (item['quantity'] as num?) ?? 0;
        existing['quantity'] = existingQty + newQty;
      } else {
        merged[key] = Map<String, dynamic>.from(item);
      }
    }
    return merged.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context);
    final groupId =
        Provider.of<AuthProvider>(context, listen: false).currentGroupId;

    // 🔴 Guard : si pas de groupe, afficher un message clair
    if (groupId == null || groupId.isEmpty) {
      return Center(
        child: Text(
          'Aucun groupe actif.',
          style: AppTheme.bodyText.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    final weekKey = getWeekKey(weekStart);
    final weekDates = List.generate(
      7,
      (i) => DateFormat('yyyy-MM-dd').format(weekStart.add(Duration(days: i))),
    );

    // ✅ Chemin correct : groups/{groupId}/meals
    final mealsCollection = FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('meals');

    return StreamBuilder<QuerySnapshot>(
      stream: mealsCollection
          .where(FieldPath.documentId, whereIn: weekDates)
          .snapshots(),
      builder: (context, mealSnapshot) {
        return StreamBuilder<DocumentSnapshot>(
          stream: mealsCollection.doc(weekKey).snapshots(),
          builder: (context, extrasSnapshot) {
            final List<Map<String, dynamic>> allIngredients = [];

            if (mealSnapshot.hasData) {
              for (final doc in mealSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                for (final moment in ['midi', 'soir']) {
                  final entry = data[moment];
                  if (entry != null && entry['ingredients'] != null) {
                    final ingredients = List<Map<String, dynamic>>.from(
                        (entry['ingredients'] as List)
                            .map((e) => Map<String, dynamic>.from(e)));
                    for (final ing in ingredients) {
                      ing['moment'] = moment;
                      ing['date'] =
                          DateFormat('yyyy-MM-dd').parse(doc.id);
                    }
                    allIngredients.addAll(ingredients);
                  }
                }
              }
            }

            if (extrasSnapshot.hasData && extrasSnapshot.data!.exists) {
              final data =
                  extrasSnapshot.data!.data() as Map<String, dynamic>?;
              if (data != null && data['extras'] != null) {
                allIngredients.addAll(List<Map<String, dynamic>>.from(
                    (data['extras'] as List)
                        .map((e) => Map<String, dynamic>.from(e))));
              }
            }

            final displayItems = _deduplicateIngredients(allIngredients);

            if (displayItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_basket_outlined,
                        size: 48, color: Colors.grey.shade200),
                    const SizedBox(height: 12),
                    Text(
                      'Aucun ingrédient pour cette semaine.',
                      style: AppTheme.bodyText
                          .copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding:
                  const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              itemCount: displayItems.length,
              separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: Colors.grey.shade100,
                  indent: 56),
              itemBuilder: (context, index) {
                final item = displayItems[index];
                final isChecked = item['checked'] ?? false;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 2),
                  leading: GestureDetector(
                    onTap: () =>
                        mealProvider.toggleIngredientChecked(item, !isChecked),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isChecked
                            ? AppColors.primaryGreen
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: isChecked
                            ? null
                            : Border.all(
                                color: Colors.grey.shade300, width: 2),
                        boxShadow: isChecked
                            ? [
                                BoxShadow(
                                    color: AppColors.primaryGreen
                                        .withValues(alpha: 0.3),
                                    blurRadius: 6)
                              ]
                            : [],
                      ),
                      child: isChecked
                          ? const Icon(Icons.check,
                              size: 16, color: Colors.white)
                          : null,
                    ),
                  ),
                  title: Text(
                    item['name'],
                    style: AppTheme.bodyText.copyWith(
                      color: isChecked
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      decoration: isChecked
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      _formatQuantity(item),
                      style: AppTheme.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
