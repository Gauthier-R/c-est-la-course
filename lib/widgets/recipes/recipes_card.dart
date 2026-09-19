import 'dart:convert';
import 'package:flutter/material.dart';
import '../../utils/responsive_helper.dart';
import '../../utils/app_colors.dart';

Color getTimeColor(String time) {
  switch (time) {
    case '- 15 min':
      return Colors.green;
    case '- 1h':
      return Colors.orange;
    case '+ 1h':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

class RecipeCard extends StatelessWidget {
  final String name;
  final String? imageBase64;
  final List<String> indicators;
  final VoidCallback? onTap;

  const RecipeCard({
    super.key,
    required this.name,
    this.imageBase64,
    required this.indicators,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String time = indicators.firstWhere(
      (i) => i == '- 15 min' || i == '- 1h' || i == '+ 1h',
      orElse: () => '',
    );

    return Card(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.heightPercent(context, 0.02)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: imageBase64 != null && imageBase64!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    base64Decode(imageBase64!),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.restaurant_menu, color: AppColors.primaryOrange, size: ResponsiveHelper.heightPercent(context, 0.04)),
                ),
          title: Text(
            name,
            style: TextStyle(
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.scalableFont(context, 16),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: indicators
                  .where((item) => item.isNotEmpty)
                  .map(
                    (item) => Chip(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      label: Text(item, style: TextStyle(fontSize: 12)),
                      backgroundColor: item == time ? getTimeColor(item).withValues(alpha: 0.2) : Colors.grey[200],
                      labelStyle: item == time ? TextStyle(color: getTimeColor(item)) : const TextStyle(color: Colors.black87),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
