import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

Widget buildCalendarDay(DateTime day, DateTime? selectedDay, Color? dotColor) {
  final isSelected = selectedDay != null && day.year == selectedDay.year && day.month == selectedDay.month && day.day == selectedDay.day;
  final isToday = DateTime.now().year == day.year && DateTime.now().month == day.month && DateTime.now().day == day.day;

  return Container(
    margin: const EdgeInsets.all(4),
    padding: const EdgeInsets.all(6),
    height: 60,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: isSelected
          ? AppColors.primaryOrange
          : isToday
              ? AppColors.background
              : Colors.transparent,
      border: isSelected || isToday ? null : Border.all(color: Colors.grey.shade200),
    ),
    child: Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (dotColor != null)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
              ),
            ),
          ),
      ],
    ),
  );
}
