import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';
import '../utils/date_format.dart';
import '../widgets/lists/meal_suggestions_card.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  String _formatWeekRange(DateTime start) {
    final fmt = DateFormat('d MMMM', 'fr_FR');
    final end = start.add(const Duration(days: 6));
    return 'Du ${fmt.format(start)} au ${fmt.format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context);
    final now = DateTime.now();
    final currentWeekStart = getWeekStart(now, mealProvider.weekStartDay);
    final nextWeekStart = currentWeekStart.add(const Duration(days: 7));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Text('Mes Listes', style: AppTheme.titleHuge),
              ),
              const SizedBox(height: 28),

              // ── NAVIGATION SEMAINES (style Réglages iOS) ─────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Column(
                  children: [
                    _buildNavRow(context, Icons.history, AppColors.textSecondary, 'Historique', '/history', showDivider: true),
                    _buildNavRow(context, Icons.calendar_today, AppColors.primaryOrange, 'Semaine Actuelle\n${_formatWeekRange(currentWeekStart)}', '/current_week', showDivider: true),
                    _buildNavRow(context, Icons.next_plan_outlined, AppColors.primaryGreen, 'Semaine Prochaine\n${_formatWeekRange(nextWeekStart)}', '/next_week', showDivider: false),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── SUGGESTIONS DE REPAS INTELLIGENTES ───────────
              const MealSuggestionsCard(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavRow(BuildContext context, IconData icon, Color iconColor, String title, String route, {bool showDivider = false}) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(title, style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600))),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
          if (showDivider) Divider(height: 1, indent: 60, thickness: 1, color: Colors.grey.shade100),
        ],
      ),
    );
  }
}
