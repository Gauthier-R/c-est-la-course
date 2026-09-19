import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recipe.dart';
import '../../providers/recipe_provider.dart';
import '../../utils/app_colors.dart';

class RecipePickerBottomSheet extends StatefulWidget {
  const RecipePickerBottomSheet({super.key});

  @override
  State<RecipePickerBottomSheet> createState() => _RecipePickerBottomSheetState();
}

class _RecipePickerBottomSheetState extends State<RecipePickerBottomSheet> {
  String _searchQuery = '';
  String _selectedSeason = 'Tous';
  String _selectedTime = 'Tous';
  String _selectedType = 'Tous';

  @override
  Widget build(BuildContext context) {
    final recipes = Provider.of<RecipeProvider>(context, listen: false).recipes;
    
    // Application des filtres
    final filteredRecipes = recipes.where((recipe) {
      final matchesSearch = recipe.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesSeason = _selectedSeason == 'Tous' || recipe.season == _selectedSeason;
      final matchesTime = _selectedTime == 'Tous' || recipe.time == _selectedTime;
      final matchesType = _selectedType == 'Tous' || recipe.type == _selectedType;
      return matchesSearch && matchesSeason && matchesTime && matchesType;
    }).toList();

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Choisir une recette',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryOrange),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher une recette...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildDropdown('Saison', ['Tous', 'Été', 'Hiver', 'Les deux'], _selectedSeason, (v) => setState(() => _selectedSeason = v!)),
                const SizedBox(width: 8),
                _buildDropdown('Temps', ['Tous', '- 15 min', '- 1h', '+ 1h'], _selectedTime, (v) => setState(() => _selectedTime = v!)),
                const SizedBox(width: 8),
                _buildDropdown('Type', ['Tous', 'Entrée', 'Plat', 'Dessert'], _selectedType, (v) => setState(() => _selectedType = v!)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: filteredRecipes.isEmpty
                ? const Center(child: Text('Aucune recette trouvée.'))
                : ListView.builder(
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = filteredRecipes[index];
                      return ListTile(
                        leading: recipe.imageBase64 != null && recipe.imageBase64!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(base64Decode(recipe.imageBase64!), width: 50, height: 50, fit: BoxFit.cover),
                              )
                            : const Icon(Icons.restaurant_menu, color: AppColors.primaryOrange),
                        title: Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${recipe.time} • ${recipe.type}'),
                        onTap: () {
                          Navigator.pop(context, recipe);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String selectedValue, void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              icon: const Icon(Icons.arrow_drop_down, size: 20),
              isDense: true,
              items: items.map((val) => DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
