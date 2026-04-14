import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';
import '../providers/meal_provider.dart';
import '../widgets/calendar/edit_meal_dialog.dart';

class SandboxCalendarScreen extends StatefulWidget {
  const SandboxCalendarScreen({super.key});

  @override
  State<SandboxCalendarScreen> createState() => _SandboxCalendarScreenState();
}

class _SandboxCalendarScreenState extends State<SandboxCalendarScreen> {
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
  }

  void _editMeal(BuildContext context, String moment, String currentText) {
    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    final selectedDay = mealProvider.selectedDay;
    EditMealDialog.show(
      context,
      moment: moment,
      initialMeal: currentText,
      initialIngredients: mealProvider.getIngredientsForDate(selectedDay, moment),
      onValidate: (meal, ingredients) {
        mealProvider.updateMealAndIngredients(selectedDay, moment, meal, ingredients);
      },
      date: selectedDay,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Consumer<MealProvider>(
          builder: (context, mealProvider, _) {
            final selectedMeals = mealProvider.selectedMeals;
            final selectedDay = mealProvider.selectedDay;
            final formattedDay = DateFormat('EEEE d MMMM', 'fr_FR').format(selectedDay);
            final capitalizedDay = formattedDay[0].toUpperCase() + formattedDay.substring(1);

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── HEADER ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Text('Planning', style: AppTheme.titleHuge),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(capitalizedDay, style: AppTheme.bodyText.copyWith(color: AppColors.primaryOrange, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 24),

                  // ── CALENDRIER PREMIUM BLANC ──────────────────────
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: TableCalendar(
                      locale: 'fr_FR',
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(mealProvider.selectedDay, day),
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      onDaySelected: (selected, focused) {
                        mealProvider.selectDay(selected);
                        setState(() => _focusedDay = focused);
                      },
                      calendarStyle: CalendarStyle(
                        cellPadding: const EdgeInsets.all(4),
                        defaultTextStyle: AppTheme.bodyText,
                        weekendTextStyle: AppTheme.bodyText.copyWith(color: AppColors.textSecondary),
                        outsideTextStyle: AppTheme.bodyText.copyWith(color: Colors.grey.shade300),
                        todayTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        todayDecoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle),
                        selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        selectedDecoration: const BoxDecoration(color: AppColors.primaryOrange, shape: BoxShape.circle),
                        markerDecoration: const BoxDecoration(color: Colors.transparent),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: AppTheme.labelSmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                        weekendStyle: AppTheme.labelSmall.copyWith(color: AppColors.textSecondary),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.grey.shade400),
                        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                        titleTextStyle: AppTheme.titleMedium,
                        headerPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      // Pastilles Firebase (vert = tous deux remplis, orange = partiel)
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, _) {
                          final dotColor = mealProvider.getDotColor(date);
                          if (dotColor == null || dotColor == Colors.transparent) return const SizedBox();
                          return Positioned(
                            bottom: 1,
                            child: Container(
                              width: 5, height: 5,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── SECTION REPAS DU JOUR ─────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text('Repas du jour', style: AppTheme.titleMedium.copyWith(color: AppColors.textSecondary, fontSize: 14)),
                  ),
                  const SizedBox(height: 12),

                  // Repas MIDI
                  _buildMealSlot(
                    context,
                    icon: Icons.wb_sunny,
                    iconColor: AppColors.secondaryYellow,
                    label: 'Déjeuner (Midi)',
                    meal: selectedMeals['midi'] ?? '',
                    onTap: () => _editMeal(context, 'midi', selectedMeals['midi'] ?? ''),
                  ),
                  const SizedBox(height: 8),

                  // Repas SOIR
                  _buildMealSlot(
                    context,
                    icon: Icons.nightlight_round,
                    iconColor: AppColors.primaryGreen,
                    label: 'Dîner (Soir)',
                    meal: selectedMeals['soir'] ?? '',
                    onTap: () => _editMeal(context, 'soir', selectedMeals['soir'] ?? ''),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMealSlot(BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String meal,
    required VoidCallback onTap,
  }) {
    final hasContent = meal.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTheme.labelSmall.copyWith(color: AppColors.textSecondary, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(
                    hasContent ? meal : 'Appuyer pour ajouter un repas...',
                    style: AppTheme.bodyText.copyWith(
                      color: hasContent ? AppColors.textPrimary : Colors.grey.shade400,
                      fontWeight: hasContent ? FontWeight.w600 : FontWeight.normal,
                      fontStyle: hasContent ? FontStyle.normal : FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            Icon(
              hasContent ? Icons.edit_note : Icons.add_circle_outline,
              color: hasContent ? Colors.grey.shade400 : AppColors.primaryOrange,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
