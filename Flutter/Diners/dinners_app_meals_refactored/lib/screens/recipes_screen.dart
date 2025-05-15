import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';
import '../utils/app_colors.dart';
import '../widgets/recipes/recipes_header.dart';
import '../widgets/recipes/recipes_filters.dart';
import '../widgets/recipes/recipes_card.dart';

class Recipe {
  final String name;
  final String season;
  final String time;
  final String type;

  Recipe({
    required this.name,
    required this.season,
    required this.time,
    required this.type,
  });
}

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  String selectedSeason = 'Tous';
  String selectedTime = 'Tous';
  String selectedType = 'Tous';

  final List<Recipe> allRecipes = [
    Recipe(name: 'Spaghettis', season: '☀️', time: '15min', type: '🥗'),
    Recipe(name: 'Tartiflette', season: '❄️', time: '+1h', type: '🍗'),
    Recipe(name: 'Salade César', season: '🌞❄️', time: '1h', type: '🥗'),
    Recipe(name: 'Gâteau au chocolat', season: '🌞❄️', time: '1h', type: '🍰'),
    Recipe(name: 'Soupe', season: '❄️', time: '15min', type: '🥗'),
  ];

  List<Recipe> filteredRecipes = [];

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      filteredRecipes = allRecipes.where((recipe) {
        final matchSeason = selectedSeason == 'Tous' || recipe.season == selectedSeason;
        final matchTime = selectedTime == 'Tous' || recipe.time == selectedTime;
        final matchType = selectedType == 'Tous' || recipe.type == selectedType;
        return matchSeason && matchTime && matchType;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxListHeight = MediaQuery.of(context).size.height * 0.45;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              RecipesHeader(
                onSettingsPressed: () {
                  debugPrint("Paramètres recettes");
                },
              ),
              SizedBox(height: ResponsiveHelper.heightPercent(context, 0.05)),
              Expanded(
                child: Column(
                  children: [
                    SizedBox(height: ResponsiveHelper.heightPercent(context, 0.06)),
                    Divider(
                      thickness: 1.2,
                      indent: ResponsiveHelper.heightPercent(context, 0.04),
                      endIndent: ResponsiveHelper.heightPercent(context, 0.04),
                      color: Colors.grey,
                    ),
                    SizedBox(height: ResponsiveHelper.heightPercent(context, 0.02)),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: maxListHeight,
                      ),
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.widthPercent(context, 0.04),
                        ),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20), // arrondi tous les coins
                        ),
                        child: filteredRecipes.isEmpty
                            ? Center(
                                child: Text(
                                  'Aucune recette ne correspond.',
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.scalableFont(context, 14),
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveHelper.widthPercent(context, 0.04),
                                  vertical: ResponsiveHelper.heightPercent(context, 0.02),
                                ),
                                itemCount: filteredRecipes.length,
                                itemBuilder: (context, index) {
                                  final recipe = filteredRecipes[index];
                                  return RecipeCard(
                                    name: recipe.name,
                                    indicators: [recipe.time, recipe.type, recipe.season],
                                  );
                                },
                              ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveHelper.heightPercent(context, 0.02),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.darkOrange, AppColors.primaryOrange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: ajout recette
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.widthPercent(context, 0.15),
                              vertical: ResponsiveHelper.heightPercent(context, 0.015),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Ajouter une recette',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.scalableFont(context, 16),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          RecipesFilters(
            selectedSeason: selectedSeason,
            selectedTime: selectedTime,
            selectedType: selectedType,
            onSeasonChanged: (val) {
              selectedSeason = val;
              _applyFilters();
            },
            onTimeChanged: (val) {
              selectedTime = val;
              _applyFilters();
            },
            onTypeChanged: (val) {
              selectedType = val;
              _applyFilters();
            },
          ),
        ],
      ),
    );
  }
}
