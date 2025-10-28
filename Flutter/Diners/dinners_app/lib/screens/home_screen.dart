import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/home/header.dart';
import '../widgets/home/meal_carousel.dart';
import '../widgets/home/shopping_list_card.dart';
import '../providers/meal_provider.dart';
import '../providers/weekly_list_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final weeklyListProvider = Provider.of<WeeklyListProvider>(context, listen: false);
        await weeklyListProvider.loadFromFirebase();
      });
      _isLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final weeklyListProvider = Provider.of<WeeklyListProvider>(context);
    final currentWeekKey = weeklyListProvider.currentWeekKey;
    final currentWeekList = weeklyListProvider.getList(currentWeekKey);

    return Scaffold(
      body: Column(
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
                  const SizedBox(height: 200),
                ],
              ),
              Positioned(
                top: 180,
                left: 0,
                right: 0,
                child: MealCarousel(
                  baseDate: DateTime.now(),
                  getMealsForDate: Provider.of<MealProvider>(context, listen: false).selectedMealsFor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ShoppingListCard(
            items: currentWeekList,
            onAddPressed: () {
              debugPrint("Ajouter un élément !");
            },
            onEditPressed: () {
              debugPrint("Modifier la liste !");
            },
          ),
        ],
      ),
    );
  }
}

