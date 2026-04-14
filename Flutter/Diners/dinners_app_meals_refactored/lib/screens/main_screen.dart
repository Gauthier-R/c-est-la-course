import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/responsive_helper.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'shopping_list_screen.dart';
import 'recipes_screen.dart';
import '../widgets/home/bottom_nav_bar.dart';
import '../animations/animated_central_button.dart';
import 'design_sandbox_screen.dart';
import 'add_recipe_screen.dart';

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
    SizedBox(),
    ShoppingListScreen(),
    RecipesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index >= 2 ? index + 1 : index;
    });
  }

  void _onAddPressed() {
    debugPrint("Bouton + global pressé !");
    // TODO: ouvrir un menu de création rapide
  }

  void _onRecipePressed() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRecipeScreen()));
  }

  Color _getNavBarColor(int index) {
    switch (index) {
      case 0:
        return AppColors.background;
      case 1:
        return AppColors.primaryOrange;
      case 3:
        return AppColors.lightGreen;
      default:
        return AppColors.background;
    }
  }

  bool _shouldShowNotch(int index) {
    return true; // Toujours afficher l'encoche, même pour les recettes
  }

  @override
  Widget build(BuildContext context) {
    final double buttonHeight = 60;
    final double navBarHeight = ResponsiveHelper.heightPercent(context, 0.09);
    final Color navBarColor = _getNavBarColor(_selectedIndex);

    return Stack(
      children: [
        Scaffold(
          body: _pages[_selectedIndex],
          backgroundColor: navBarColor,
          bottomNavigationBar: _shouldShowNotch(_selectedIndex)
              ? ClipPath(
                  clipper: RoundedNotchClipper(),
                  child: Container(
                    height: navBarHeight,
                    decoration: BoxDecoration(
                      color: navBarColor,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: BottomNavBar(
                      currentIndex:
                          _selectedIndex >= 3 ? _selectedIndex - 1 : _selectedIndex,
                      onTabTapped: _onItemTapped,
                    ),
                  ),
                )
              : Container(
                  height: navBarHeight,
                  decoration: BoxDecoration(
                    color: navBarColor,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: BottomNavBar(
                    currentIndex:
                        _selectedIndex >= 3 ? _selectedIndex - 1 : _selectedIndex,
                    onTabTapped: _onItemTapped,
                  ),
                ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Transform.translate(
            offset: Offset(0, -buttonHeight * 0.35),
            child: AnimatedCentralButton(
              isRecipeTab: false, // Forcer le bouton central classique
              onAddPressed: _onAddPressed,
              onRecipePressed: _onRecipePressed,
            ),
          ),
        ),
      ],
    );
  }
}

class RoundedNotchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double radius = 38;
    final double centerX = size.width / 2;
    final double notchWidth = radius * 2 - 1;
    final double outerArcRadius = 10;

    final double leftArcStart = centerX - notchWidth / 2 - outerArcRadius;
    final double rightArcEnd = centerX + notchWidth / 2 + outerArcRadius;

    path.moveTo(0, 0);
    path.lineTo(leftArcStart, 0);

    path.arcToPoint(
      Offset(centerX - notchWidth / 2, outerArcRadius),
      radius: Radius.circular(outerArcRadius),
      clockwise: true,
    );

    path.arcToPoint(
      Offset(centerX + notchWidth / 2, outerArcRadius),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    path.arcToPoint(
      Offset(rightArcEnd, 0),
      radius: Radius.circular(outerArcRadius),
      clockwise: true,
    );

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}