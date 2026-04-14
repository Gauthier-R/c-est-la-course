import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dinners_app/utils/app_colors.dart';
import 'package:dinners_app/utils/app_theme.dart';
import 'package:dinners_app/widgets/lists/weekly_ingredient_list.dart';
import 'package:dinners_app/utils/date_format.dart';
import 'package:dinners_app/widgets/lists/edit_weekly_list_dialog.dart';
import 'package:dinners_app/widgets/lists/add_ingredient_dialog.dart';

class NextWeekListScreen extends StatelessWidget {
  const NextWeekListScreen({super.key});

  String _formatWeekRange(DateTime start) {
    final fmt = DateFormat('d MMMM', 'fr_FR');
    return 'Du ${fmt.format(start)} au ${fmt.format(start.add(const Duration(days: 6)))}';
  }

  void _showAddDialog(BuildContext context, DateTime weekStart) {
    showAddIngredientDialog(context, weekKey: getWeekKey(weekStart));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final nextWeekStart = now.subtract(Duration(days: now.weekday - 1)).add(const Duration(days: 7));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Semaine Prochaine', style: AppTheme.titleMedium),
                        Text(_formatWeekRange(nextWeekStart), style: AppTheme.labelSmall.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: AppColors.primaryOrange, size: 28),
                    onPressed: () => _showAddDialog(context, nextWeekStart),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_note, color: AppColors.primaryGreen, size: 26),
                    onPressed: () => showDialog(context: context, builder: (_) => EditWeeklyListDialog(weekStart: nextWeekStart)),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey.shade100, height: 1),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                padding: const EdgeInsets.all(8),
                child: WeeklyIngredientList(weekStart: nextWeekStart),
              ),
            ),
          ],
        ),
      ),
    );
  }
}