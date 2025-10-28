import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../utils/app_colors.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../providers/meal_provider.dart';
import '../../providers/weekly_list_provider.dart';
import 'meal_slot_row.dart';
import 'calendar_day_builder.dart';
import 'edit_meal_dialog.dart';
import 'package:provider/provider.dart';

class CalendarContainer extends StatefulWidget {
  const CalendarContainer({super.key});

  @override
  State<CalendarContainer> createState() => _CalendarContainerState();
}

class _CalendarContainerState extends State<CalendarContainer> {
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
  }

  void _editMeal(BuildContext context, String moment, String currentText) {
    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    final weeklyListProvider = Provider.of<WeeklyListProvider>(context, listen: false);
    final selectedDay = mealProvider.selectedDay;

    EditMealDialog.show(
      context,
      moment: moment,
      initialMeal: currentText,
      initialIngredients: mealProvider.getIngredientsForDate(selectedDay, moment),
      onValidate: (meal, ingredients) {
        mealProvider.updateMealAndIngredients(
          selectedDay,
          moment,
          meal,
          ingredients,
          weeklyListProvider,
        );
      },
      date: selectedDay,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context);
    final selectedMeals = mealProvider.selectedMeals;

    return SizedBox.expand(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            TableCalendar(
              locale: 'fr_FR',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(mealProvider.selectedDay, day),
              startingDayOfWeek: StartingDayOfWeek.monday,
              onDaySelected: (selectedDay, focusedDay) {
                mealProvider.selectDay(selectedDay);
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: const CalendarStyle(
                cellMargin: EdgeInsets.all(2),
                defaultTextStyle: TextStyle(fontSize: 16),
                weekendTextStyle: TextStyle(color: Colors.black87),
                todayTextStyle: TextStyle(color: Colors.black),
                selectedTextStyle: TextStyle(color: Colors.white),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
                weekendStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, _) =>
                    buildCalendarDay(day, mealProvider.selectedDay, mealProvider.getDotColor(day)),
                selectedBuilder: (context, day, _) =>
                    buildCalendarDay(day, mealProvider.selectedDay, mealProvider.getDotColor(day)),
                todayBuilder: (context, day, _) =>
                    buildCalendarDay(day, mealProvider.selectedDay, mealProvider.getDotColor(day)),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 50),
            MealSlotRow(
              icon: Icons.wb_sunny,
              gradientColors: [AppColors.primaryOrange, AppColors.darkOrange],
              label: "Midi",
              mealText: selectedMeals['midi'] ?? '',
              onEdit: () => _editMeal(context, 'midi', selectedMeals['midi'] ?? ''),
            ),
            const SizedBox(height: 50),
            MealSlotRow(
              icon: Icons.nightlight_round,
              gradientColors: [AppColors.primaryOrange.withOpacity(0.8), AppColors.darkOrange.withOpacity(0.8)],
              label: "Soir",
              mealText: selectedMeals['soir'] ?? '',
              onEdit: () => _editMeal(context, 'soir', selectedMeals['soir'] ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}
