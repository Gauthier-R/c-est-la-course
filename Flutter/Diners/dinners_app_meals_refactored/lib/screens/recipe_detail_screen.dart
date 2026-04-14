import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';
import 'add_recipe_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final currentRecipe = Provider.of<RecipeProvider>(context)
        .recipes
        .firstWhere((r) => r.id == recipe.id, orElse: () => recipe);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── APP BAR avec image en arrière-plan ──────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.background,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
            surfaceTintColor: Colors.transparent,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primaryOrange),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => AddRecipeScreen(recipeToEdit: currentRecipe)));
                  },
                ),
              ),
            ],
            leading: Container(
              margin: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: currentRecipe.imageBase64 != null && currentRecipe.imageBase64!.isNotEmpty
                  ? Image.memory(
                      base64Decode(currentRecipe.imageBase64!),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppColors.secondaryYellow.withValues(alpha: 0.1),
                      child: const Center(
                        child: Icon(Icons.restaurant_menu, size: 80, color: AppColors.primaryOrange),
                      ),
                    ),
            ),
          ),

          // ── CONTENU ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom de la recette
                  Text(currentRecipe.name, style: AppTheme.titleHuge.copyWith(fontSize: 28)),
                  const SizedBox(height: 16),

                  // Badges info
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      if (currentRecipe.time.isNotEmpty) _buildBadge(Icons.access_time, currentRecipe.time, AppColors.primaryOrange),
                      if (currentRecipe.type.isNotEmpty) _buildBadge(Icons.restaurant, currentRecipe.type, AppColors.primaryGreen),
                      if (currentRecipe.season.isNotEmpty) _buildBadge(Icons.wb_sunny_outlined, currentRecipe.season, AppColors.secondaryYellow),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Section Ingrédients
                  _buildSectionTitle('Ingrédients'),
                  const SizedBox(height: 12),
                  if (currentRecipe.ingredients.isEmpty)
                    _buildEmptyHint('Aucun ingrédient renseigné.')
                  else
                    ...currentRecipe.ingredients.asMap().entries.map((entry) {
                      final ing = entry.value;
                      final isLast = entry.key == currentRecipe.ingredients.length - 1;
                      return _buildIngredientRow(ing, showDivider: !isLast);
                    }),

                  const SizedBox(height: 32),

                  // Section Préparation
                  _buildSectionTitle('Préparation'),
                  const SizedBox(height: 12),
                  currentRecipe.description.isEmpty
                      ? _buildEmptyHint('Aucune étape de préparation renseignée.')
                      : SizedBox(
                          width: double.infinity,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
                            ),
                            child: Text(
                              currentRecipe.description,
                              style: AppTheme.bodyText.copyWith(height: 1.7),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: AppTheme.labelSmall.copyWith(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 20, decoration: BoxDecoration(color: AppColors.primaryOrange, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(title, style: AppTheme.titleMedium),
      ],
    );
  }

  Widget _buildIngredientRow(Map<String, dynamic> ing, {bool showDivider = true}) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(ing['name'] ?? '', style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600))),
              Text(
                '${ing["quantity"]} ${ing["unit"]}',
                style: AppTheme.labelSmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1, color: Colors.grey.shade100, indent: 38),
      ],
    );
  }

  Widget _buildEmptyHint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(text, style: AppTheme.bodyText.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
    );
  }
}
