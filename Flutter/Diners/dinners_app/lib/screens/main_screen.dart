import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'shopping_list_screen.dart';
import 'recipes_screen.dart';
import '../widgets/home/bottom_nav_bar.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    CalendarScreen(),
    SizedBox(), // Placeholder for the Add button
    ShoppingListScreen(),
    RecipesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index >= 2 ? index + 1 : index;
    });
  }

  void _onAddPressed() {
    debugPrint("Bouton + pressé !");
    // TODO: ouvrir une page ou afficher un menu
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex >= 3 ? _selectedIndex - 1 : _selectedIndex,
        onTabTapped: _onItemTapped,
      ),
      floatingActionButton: AnimatedAddButton(onPressed: _onAddPressed),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class AnimatedAddButton extends StatefulWidget {
  final VoidCallback onPressed;

  const AnimatedAddButton({super.key, required this.onPressed});

  @override
  State<AnimatedAddButton> createState() => _AnimatedAddButtonState();
}

class _AnimatedAddButtonState extends State<AnimatedAddButton>
    with SingleTickerProviderStateMixin {
  bool _rotated = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.0,
      upperBound: 0.1,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() async {
    setState(() {
      _rotated = !_rotated;
    });

    // Animation rebond
    await _controller.forward();
    await _controller.reverse();

    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(
        scale: Tween(begin: 1.0, end: 1.1).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
        ),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.darkOrange, AppColors.primaryOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryOrange.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: AnimatedRotation(
            turns: _rotated ? 0.25 : 0.0, // 90° rotation
            duration: const Duration(milliseconds: 300),
            child: Icon(
              _rotated ? Icons.close : Icons.add,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}