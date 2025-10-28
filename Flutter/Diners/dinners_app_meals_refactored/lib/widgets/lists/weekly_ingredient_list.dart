import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinners_app/utils/date_format.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/meal_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive_helper.dart';

class WeeklyIngredientList extends StatelessWidget {
  final DateTime weekStart;

  const WeeklyIngredientList({super.key, required this.weekStart});

  String formatQuantity(Map<String, dynamic> item) {
    final quantity = item['quantity'] ?? 0;
    final unit = item['unit'] ?? 'QT';
    if (unit == 'QT') return 'x $quantity';
    return '$quantity $unit';
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context);
    final weekKey = getWeekKey(weekStart);
    final weekDates = List.generate(7, (i) => DateFormat('yyyy-MM-dd').format(weekStart.add(Duration(days: i))));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('meals')
          .where(FieldPath.documentId, whereIn: weekDates)
          .snapshots(),
      builder: (context, mealSnapshot) {
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('meals').doc(weekKey).snapshots(),
          builder: (context, extrasSnapshot) {
            final List<Map<String, dynamic>> allIngredients = [];

            if (mealSnapshot.hasData) {
              for (final doc in mealSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                for (final moment in ['midi', 'soir']) {
                  final entry = data[moment];
                  if (entry != null && entry['ingredients'] != null) {
                    final ingredients = List<Map<String, dynamic>>.from(
                      (entry['ingredients'] as List).map((e) => Map<String, dynamic>.from(e))
                    );
                    for (final ing in ingredients) {
                      ing['moment'] = moment;
                      ing['date'] = DateFormat('yyyy-MM-dd').parse(doc.id);
                    }
                    allIngredients.addAll(ingredients);
                  }
                }
              }
            }

            if (extrasSnapshot.hasData && extrasSnapshot.data!.exists) {
              final data = extrasSnapshot.data!.data() as Map<String, dynamic>?;
              if (data != null && data['extras'] != null) {
                final extras = List<Map<String, dynamic>>.from(
                  (data['extras'] as List).map((e) => Map<String, dynamic>.from(e))
                );
                allIngredients.addAll(extras);
              }
            }

            if (allIngredients.isEmpty) {
              return Center(
                child: Text(
                  'Aucun ingrédient pour cette semaine.',
                  style: TextStyle(fontSize: ResponsiveHelper.scalableFont(context, 10)),
                ),
              );
            }

            return ListView.builder(
              itemCount: allIngredients.length,
              itemBuilder: (context, index) {
                final item = allIngredients[index];
                final isChecked = item['checked'] ?? false;

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.heightPercent(context, 0.004)),
                  child: Card(
                    color: isChecked ? AppColors.background : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isChecked ? AppColors.background : Colors.grey.shade300,
                        width: 0.5,
                      ),
                    ),
                    elevation: isChecked ? 0 : 6,
                    shadowColor: Colors.black45,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.widthPercent(context, 0.02)),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.widthPercent(context, 0.01)),
                        leading: GestureDetector(
                          onTap: () {
                            mealProvider.toggleIngredientChecked(item, !isChecked);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: ResponsiveHelper.widthPercent(context, 0.07),
                            height: ResponsiveHelper.widthPercent(context, 0.07),
                            decoration: BoxDecoration(
                              color: isChecked ? AppColors.primaryOrange : AppColors.background,
                              shape: BoxShape.circle,
                              boxShadow: isChecked
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryOrange.withOpacity(0.4),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: isChecked ? 1.0 : 0.0,
                                child: const Icon(Icons.check, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          item['name'],
                          style: TextStyle(
                            fontSize: ResponsiveHelper.scalableFont(context, 16),
                            color: Colors.black,
                            decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                          ),
                        ),
                        trailing: Text(
                          formatQuantity(item),
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: ResponsiveHelper.scalableFont(context, 14),
                          ),
                        ),
                      ),
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
