// ✅ Version redesignée style Apple Premium — HistoryListScreen

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';
import '../utils/date_format.dart';
import '../widgets/lists/edit_weekly_list_dialog.dart';
import '../widgets/lists/weekly_ingredient_list.dart';
import '../widgets/lists/add_ingredient_dialog.dart';

class HistoryListScreen extends StatefulWidget {
  final DateTime weekStart;
  const HistoryListScreen({super.key, required this.weekStart});

  @override
  State<HistoryListScreen> createState() => _HistoryListScreenState();
}

class _HistoryListScreenState extends State<HistoryListScreen> {
  String _formatWeekRange(DateTime start) {
    final fmt = DateFormat('d MMMM', 'fr_FR');
    return 'Du ${fmt.format(start)} au ${fmt.format(start.add(const Duration(days: 6)))}';
  }

  void _showAddDialog(BuildContext context) {
    final weekKey = getWeekKey(widget.weekStart);
    showAddIngredientDialog(
      context,
      weekKey: weekKey,
      onAdded: () => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ─────────────────────────────────────────
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
                        Text('Historique', style: AppTheme.titleMedium),
                        Text(_formatWeekRange(widget.weekStart),
                          style: AppTheme.labelSmall.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: AppColors.primaryOrange, size: 28),
                    onPressed: () => _showAddDialog(context),
                    tooltip: 'Ajouter',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_note, color: AppColors.primaryGreen, size: 26),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => EditWeeklyListDialog(weekStart: widget.weekStart),
                    ),
                    tooltip: 'Modifier la liste',
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey.shade100, height: 1),

            // ── LISTE ──────────────────────────────────────────
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16, offset: const Offset(0, 6),
                  )],
                ),
                padding: const EdgeInsets.all(8),
                child: WeeklyIngredientList(weekStart: widget.weekStart),
              ),
            ),
          ],
        ),
      ),
    );
  }
}