import 'dart:convert';
import 'package:flutter/material.dart';
import '../../utils/responsive_helper.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_theme.dart';

class RecipeCardNew extends StatelessWidget {
  final String name;
  final String? imageBase64;
  final List<String> indicators;
  final VoidCallback? onTap;

  const RecipeCardNew({
    super.key,
    required this.name,
    this.imageBase64,
    required this.indicators,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.heightPercent(context, 0.02)),
      decoration: AppTheme.cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Image ludique
                imageBase64 != null && imageBase64!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          base64Decode(imageBase64!),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryYellow.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.restaurant_menu, color: AppColors.primaryOrange, size: 40),
                      ),
                const SizedBox(width: 16),
                
                // Textes et Badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: indicators
                            .where((item) => item.isNotEmpty)
                            .map((item) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: AppTheme.badgeDecoration,
                                  child: Text(item, style: AppTheme.labelSmall),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
