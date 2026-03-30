import 'package:flutter/material.dart';
import 'package:dinners_app/utils/app_colors.dart';
import 'package:dinners_app/utils/responsive_helper.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabTapped;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildIcon(context, icon: Icons.home, index: 0),
          _buildIcon(context, icon: Icons.calendar_today, index: 1),
          SizedBox(width: ResponsiveHelper.widthPercent(context, 0.1)), // espace pour la bulle centrale
          _buildIcon(context, icon: Icons.list, index: 2),
          _buildIcon(context, icon: Icons.menu_book, index: 3),
        ],
      ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, {required IconData icon, required int index}) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTabTapped(index),
      child: AnimatedScale(
        scale: isActive ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(ResponsiveHelper.widthPercent(context, 0.03)),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primaryOrange : Colors.transparent,
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : Colors.grey[700],
            size: ResponsiveHelper.widthPercent(context, 0.06),
          ),
        ),
      ),
    );
  }
}
