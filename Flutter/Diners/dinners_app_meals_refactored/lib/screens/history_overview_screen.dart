import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../utils/app_colors.dart';
import '../utils/responsive_helper.dart';
import '../utils/date_format.dart';
import 'history_list_screen.dart';

class HistoryOverviewScreen extends StatelessWidget {
  const HistoryOverviewScreen({super.key});

  String formatWeekRange(DateTime startOfWeek) {
    final formatter = DateFormat('d MMMM', 'fr_FR');
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return 'Du ${formatter.format(startOfWeek)} au ${formatter.format(endOfWeek)}';
  }

  DateTime getStartOfWeek(DateTime date, int weekStartDay) => getWeekStart(date, weekStartDay);

  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context);
    final now = DateTime.now();
    final currentWeekKey = DateFormat('yyyy-MM-dd').format(getStartOfWeek(now, mealProvider.weekStartDay));

    final uniqueWeeks = mealProvider
        .getAllUsedWeekStarts()
        .where((start) => DateFormat('yyyy-MM-dd').format(start) != currentWeekKey)
        .toList()
      ..sort((a, b) => a.compareTo(b));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.widthPercent(context, 0.05),
            vertical: ResponsiveHelper.heightPercent(context, 0.05),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.primaryGreen,
                      size: ResponsiveHelper.widthPercent(context, 0.05),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: ResponsiveHelper.widthPercent(context, 0.01)),
                  Text(
                    'Historique des semaines',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.scalableFont(context, 18),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveHelper.heightPercent(context, 0.02)),
              Expanded(
                child: uniqueWeeks.isEmpty
                    ? Center(
                        child: Text(
                          "Aucune liste disponible.",
                          style: TextStyle(fontSize: ResponsiveHelper.scalableFont(context, 14)),
                        ),
                      )
                    : ListView.builder(
                        itemCount: uniqueWeeks.length,
                        itemBuilder: (context, index) {
                          final weekStart = uniqueWeeks[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                              vertical: ResponsiveHelper.heightPercent(context, 0.007),
                            ),
                            child: ListTile(
                              title: Text(
                                formatWeekRange(weekStart),
                                style: TextStyle(fontSize: ResponsiveHelper.scalableFont(context, 14)),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: ResponsiveHelper.widthPercent(context, 0.04),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HistoryListScreen(weekStart: weekStart),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}