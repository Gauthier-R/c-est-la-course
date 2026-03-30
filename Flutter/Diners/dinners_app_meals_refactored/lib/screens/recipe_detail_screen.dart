import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../utils/app_colors.dart';
import '../utils/responsive_helper.dart';
import 'add_recipe_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    // Écoute les changements dynamiques de la recette via Firestore
    final currentRecipe = Provider.of<RecipeProvider>(context)
        .recipes
        .firstWhere((r) => r.id == recipe.id, orElse: () => recipe);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(currentRecipe.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryOrange,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddRecipeScreen(recipeToEdit: currentRecipe))
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (currentRecipe.imageBase64 != null && currentRecipe.imageBase64!.isNotEmpty)
              Image.memory(
                base64Decode(currentRecipe.imageBase64!),
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 200,
                color: AppColors.primaryOrange.withValues(alpha: 0.2),
                child: const Center(
                  child: Icon(Icons.restaurant_menu, size: 80, color: AppColors.primaryOrange),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(ResponsiveHelper.widthPercent(context, 0.05)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoChip(Icons.access_time, currentRecipe.time),
                      _buildInfoChip(Icons.category, currentRecipe.type),
                      _buildInfoChip(Icons.wb_sunny, currentRecipe.season),
                    ],
                  ),
                  SizedBox(height: ResponsiveHelper.heightPercent(context, 0.04)),
                  const Text('Ingrédients', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryOrange)),
                  const SizedBox(height: 10),
                  if (currentRecipe.ingredients.isEmpty)
                    const Text('Aucun ingrédient renseigné.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                  ...currentRecipe.ingredients.map((ing) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.fiber_manual_record, size: 12, color: AppColors.darkOrange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ing['name'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          Text(
                            '${ing["quantity"]} ${ing["unit"]}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                          ),
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: ResponsiveHelper.heightPercent(context, 0.04)),
                  const Text('Préparation', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryOrange)),
                  const SizedBox(height: 10),
                  Text(
                    currentRecipe.description.isNotEmpty ? currentRecipe.description : 'Aucune étape de préparation renseignée.',
                    style: TextStyle(fontSize: 16, color: currentRecipe.description.isNotEmpty ? Colors.black87 : Colors.grey, height: 1.5),
                  ),
                  SizedBox(height: ResponsiveHelper.heightPercent(context, 0.05)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    if (label.isEmpty) return const SizedBox();
    return Chip(
      avatar: Icon(icon, size: 18, color: AppColors.darkOrange),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey.shade300)),
    );
  }
}
