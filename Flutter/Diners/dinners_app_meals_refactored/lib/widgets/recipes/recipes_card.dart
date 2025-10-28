import 'package:flutter/material.dart';
import '../../utils/responsive_helper.dart';
import '../../utils/app_colors.dart';

Color getTimeColor(String time) {
  switch (time) {
    case '15min':
      return Colors.green;
    case '1h':
      return Colors.orange;
    case '+1h':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

class RecipeCard extends StatelessWidget {
  final String name;
  final List<String> indicators;

  const RecipeCard({
    super.key,
    required this.name,
    required this.indicators,
  });

  @override
  Widget build(BuildContext context) {
    final String time = indicators.firstWhere(
      (i) => i == '15min' || i == '1h' || i == '+1h',
      orElse: () => '',
    );

    return Card(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.heightPercent(context, 0.02)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: Colors.white,
      child: ListTile(
        leading: Icon(Icons.restaurant_menu, size: ResponsiveHelper.heightPercent(context, 0.05)),
        title: Text(
          name,
          style: TextStyle(
            color: AppColors.primaryOrange,
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveHelper.scalableFont(context, 16),
          ),
        ),
        subtitle: Row(
          children: indicators
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Chip(
                    label: Text(item),
                    backgroundColor: item == time ? getTimeColor(item).withOpacity(0.2) : null,
                    labelStyle: item == time ? TextStyle(color: getTimeColor(item)) : null,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
