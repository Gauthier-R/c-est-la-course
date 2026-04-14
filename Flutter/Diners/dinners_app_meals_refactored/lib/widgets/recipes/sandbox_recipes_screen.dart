import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_theme.dart';
import '../../providers/recipe_provider.dart';
import 'recipes_card_new.dart';
import '../../screens/add_recipe_screen.dart';
import '../../screens/recipe_detail_screen.dart';

class SandboxRecipesScreen extends StatefulWidget {
  final bool isNested;
  const SandboxRecipesScreen({super.key, this.isNested = false});

  @override
  State<SandboxRecipesScreen> createState() => _SandboxRecipesScreenState();
}

class _SandboxRecipesScreenState extends State<SandboxRecipesScreen> {
  String selectedSeason = 'Tous';
  String selectedTime = 'Tous';
  String selectedType = 'Tous';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final allRecipes = Provider.of<RecipeProvider>(context).recipes;

    final filteredRecipes = allRecipes.where((recipe) {
      final matchSearch = _searchQuery.isEmpty || recipe.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchSeason = selectedSeason == 'Tous' || recipe.season == selectedSeason;
      final matchTime = selectedTime == 'Tous' || recipe.time == selectedTime;
      final matchType = selectedType == 'Tous' || recipe.type == selectedType;
      return matchSearch && matchSeason && matchTime && matchType;
    }).toList();

    // ── Contenu (même pour imbriqué ou non) ─────────────────────────────
    final content = Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER ─────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 56, 8),
              child: Text('Mes Recettes', style: AppTheme.titleHuge),
            ),
          ),

          // ── BARRE DE RECHERCHE ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: AppTheme.bodyText.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Rechercher une recette...',
                  hintStyle: AppTheme.bodyText.copyWith(color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryOrange, size: 22),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () => setState(() => _searchQuery = ''),
                          child: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 18),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── FILTRES AVEC LABELS ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              children: [
                Expanded(child: _buildFilter(
                  icon: Icons.calendar_today_rounded,
                  iconColor: const Color(0xFFFF6B35),
                  label: 'Saison',
                  items: ['Tous', 'Été', 'Hiver', 'Les deux'],
                  selected: selectedSeason,
                  onChanged: (v) => setState(() => selectedSeason = v!),
                )),
                const SizedBox(width: 10),
                Expanded(child: _buildFilter(
                  icon: Icons.timer_outlined,
                  iconColor: AppColors.secondaryYellow,
                  label: 'Durée',
                  items: ['Tous', '- 15 min', '- 1h', '+ 1h'],
                  selected: selectedTime,
                  onChanged: (v) => setState(() => selectedTime = v!),
                )),
                const SizedBox(width: 10),
                Expanded(child: _buildFilter(
                  icon: Icons.restaurant,
                  iconColor: AppColors.primaryGreen,
                  label: 'Type',
                  items: ['Tous', 'Entrée', 'Plat', 'Dessert'],
                  selected: selectedType,
                  onChanged: (v) => setState(() => selectedType = v!),
                )),
              ],
            ),
          ),

          const SizedBox(height: 4),
          Divider(color: Colors.grey.shade200, indent: 16, endIndent: 16),

          // ── LISTE DES RECETTES ───────────────────────────────────
          Expanded(
            child: filteredRecipes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant_menu_outlined, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('Aucune recette trouvée.', style: AppTheme.bodyText.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = filteredRecipes[index];
                      return RecipeCardNew(
                        name: recipe.name,
                        imageBase64: recipe.imageBase64,
                        indicators: [recipe.time, recipe.type, recipe.season],
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)));
                        },
                      );
                    },
                  ),
          ),

          // ── BOUTON AJOUTER (padding pour ne PAS être masqué par la pilule) ──
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, widget.isNested ? 110 : 24),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRecipeScreen())),
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text('Ajouter une recette', style: AppTheme.titleMedium.copyWith(color: Colors.white, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // ── Pas de Scaffold quand imbriqué (pour éviter le conflit de fond avec la pilule) ──
    if (widget.isNested) {
      return content;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text('Mes Recettes', style: AppTheme.titleMedium),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.compare_arrows, color: AppColors.primaryOrange, size: 20),
              label: const Text('Ancien design', style: TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
      body: content,
    );
  }

  Widget _buildFilter({
    required IconData icon,
    required Color iconColor,
    required String label,
    required List<String> items,
    required String selected,
    required void Function(String?) onChanged,
  }) {
    final isActive = selected != 'Tous';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                size: 11,
                color: isActive ? AppColors.primaryOrange : iconColor,
              ),
              const SizedBox(width: 4),
              Text(label, style: AppTheme.labelSmall.copyWith(
                fontSize: 10,
                color: isActive ? AppColors.primaryOrange : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              )),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryOrange.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? AppColors.primaryOrange.withValues(alpha: 0.4) : Colors.grey.shade200,
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selected,
              isExpanded: true,
              isDense: true,
              icon: Icon(Icons.keyboard_arrow_down, size: 18,
                color: isActive ? AppColors.primaryOrange : Colors.grey.shade400),
              items: items.map((val) => DropdownMenuItem(
                value: val,
                child: Text(val, style: AppTheme.bodyText.copyWith(
                  color: isActive && val == selected ? AppColors.primaryOrange : AppColors.textPrimary,
                  fontWeight: val == selected ? FontWeight.w700 : FontWeight.normal,
                  fontSize: 13,
                )),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
