import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';
import '../utils/responsive_helper.dart';
import '../widgets/lists/shopping_header.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  String formatWeekRange(DateTime startOfWeek) {
    final formatter = DateFormat('d MMMM', 'fr_FR');
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return 'Du ${formatter.format(startOfWeek)} au ${formatter.format(endOfWeek)}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final nextWeekStart = currentWeekStart.add(const Duration(days: 7));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryGreen, AppColors.lightGreen],
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
            const ShoppingHeader(),
            SizedBox(height: ResponsiveHelper.heightPercent(context, 0.02)),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(ResponsiveHelper.widthPercent(context, 0.05)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildListButton(
                      context,
                      label: "Historique",
                      color: Colors.grey.shade300,
                      textColor: Colors.black54,
                      onTap: () => Navigator.pushNamed(context, "/history"),
                    ),
                    SizedBox(height: ResponsiveHelper.heightPercent(context, 0.03)),
                    const Divider(thickness: 1.2, indent: 8, endIndent: 8, color: Colors.grey),
                    SizedBox(height: ResponsiveHelper.heightPercent(context, 0.03)),
                    _buildGradientButton(
                      context,
                      label: "Semaine Actuelle\n${formatWeekRange(currentWeekStart)}",
                      height: ResponsiveHelper.heightPercent(context, 0.24),
                      gradientColors: [AppColors.darkOrange, AppColors.primaryOrange],
                      textColor: Colors.white,
                      onTap: () => Navigator.pushNamed(context, "/current_week"),
                    ),
                    SizedBox(height: ResponsiveHelper.heightPercent(context, 0.05)),
                    _buildGradientButton(
                      context,
                      label: "Semaine Prochaine\n${formatWeekRange(nextWeekStart)}",
                      height: ResponsiveHelper.heightPercent(context, 0.18),
                      gradientColors: [AppColors.primaryGreen, AppColors.lightGreen],
                      textColor: Colors.white,
                      onTap: () => Navigator.pushNamed(context, "/next_week"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListButton(BuildContext context,
      {required String label,
      required Color color,
      required Color textColor,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.heightPercent(context, 0.025),
          horizontal: ResponsiveHelper.widthPercent(context, 0.04),
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsiveHelper.scalableFont(context, 16),
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton(
    BuildContext context, {
    required String label,
    required double height,
    required List<Color> gradientColors,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.widthPercent(context, 0.04)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveHelper.scalableFont(context, 18),
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}