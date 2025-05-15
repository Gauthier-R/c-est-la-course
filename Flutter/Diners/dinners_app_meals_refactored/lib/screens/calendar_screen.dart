import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/responsive_helper.dart';
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
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.widthPercent(context, 0.05),
          vertical: ResponsiveHelper.heightPercent(context, 0.05),
        ),
        
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CalendarHeader(),
            SizedBox( height: ResponsiveHelper.heightPercent(context, 0.03),), // Espace entre l'en-tête et le conteneur du calendrier 
            const Expanded(child: CalendarContainer()),
          ],
        ),
      ),
    );
  }
}