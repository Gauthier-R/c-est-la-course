import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'sandbox_home_screen.dart';
import 'sandbox_calendar_screen.dart';
import 'sandbox_shopping_screen.dart';
import '../widgets/recipes/sandbox_recipes_screen.dart';

class SandboxMainScreen extends StatefulWidget {
  const SandboxMainScreen({super.key});

  @override
  State<SandboxMainScreen> createState() => _SandboxMainScreenState();
}

class _SandboxMainScreenState extends State<SandboxMainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = const [
    SandboxHomeScreen(),
    SandboxCalendarScreen(),
    SandboxShoppingScreen(),
    SandboxRecipesScreen(isNested: true), // Onglet Recettes
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Les Pages Naviguées
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),

          // PILULE FLOTTANTE EN BAS (APPLE STYLE)
          Positioned(
            left: 32,
            right: 32,
            bottom: 32, // Floating padding
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Fort effet de verre
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.65), // Glassmorphism
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5), // Effet refraction sur les bords
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
                    ]
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(Icons.home_outlined, Icons.home, 0),
                      _buildNavItem(Icons.calendar_month_outlined, Icons.calendar_month, 1),
                      _buildNavItem(Icons.format_list_bulleted, Icons.list_alt, 2),
                      _buildNavItem(Icons.restaurant_menu_outlined, Icons.restaurant, 3),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData unselectedIcon, IconData selectedIcon, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? selectedIcon : unselectedIcon,
                color: isSelected ? AppColors.primaryOrange : Colors.grey.shade500,
                size: isSelected ? 30 : 26,
              ),
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(color: AppColors.primaryOrange, shape: BoxShape.circle),
                )
            ],
          ),
        ),
      ),
    );
  }
}
