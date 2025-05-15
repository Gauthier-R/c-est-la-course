import 'package:flutter/material.dart';
import 'package:dinners_app/utils/app_colors.dart';

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
    return BottomAppBar(
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildIcon(icon: Icons.home, index: 0),
          _buildIcon(icon: Icons.calendar_today, index: 1),
          const SizedBox(width: 40), // espace pour la bulle centrale
          _buildIcon(icon: Icons.list, index: 2),
          _buildIcon(icon: Icons.menu_book, index: 3), // 📚 Recette
        ],
      ),
    );
  }

  Widget _buildIcon({required IconData icon, required int index}) {
  final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTabTapped(index),
      child: AnimatedScale(
        scale: isActive ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primaryOrange.withOpacity(0.1) : Colors.transparent,
          ),
          child: Icon(
            icon,
            size: 35,
            color: isActive ? AppColors.primaryOrange : Colors.grey,
          ),
        ),
      ),
    );
  }
}
