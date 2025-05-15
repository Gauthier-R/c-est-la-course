import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/calendar/calendar_header.dart';
import '../widgets/calendar/calendar_container.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.darkOrange, AppColors.primaryOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CalendarHeader(),
            Expanded(child: CalendarContainer()),
          ],
        ),
      ),
    );
  }
}
