import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/home/header.dart';
import '../widgets/home/meal_carousel.dart';
import '../widgets/home/shopping_list_card.dart';
import '../providers/meal_provider.dart';
import '../utils/responsive_helper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Consumer<MealProvider>(
        builder: (context, mealProvider, _) {
          return Column(
            children: [
              Stack(
                children: [
                  Column(
                    children: [
                      Header(
                        username: "Gauthier",
                        initials: "GR",
                        onSettingsPressed: () {
                          debugPrint("Paramètres cliqués !");
                        },
                      ),
                      SizedBox(height: ResponsiveHelper.heightPercent(context, 0.22)),
                    ],
                  ),
                  Positioned(
                    top: ResponsiveHelper.heightPercent(context, 0.15),
                    left: 0,
                    right: 0,
                    child: MealCarousel(baseDate: DateTime.now()),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveHelper.heightPercent(context, 0.01)),
              ShoppingListCard(
                onAddPressed: () => debugPrint("Ajouter un élément !"),
                onEditPressed: () => debugPrint("Modifier la liste !"),
              ),
            ],
          );
        },
      ),
    );
  }
}
