// Mise à jour du layout dans EditMealDialog — Style Apple Premium

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/recipe.dart';
import '../../providers/recipe_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_theme.dart';
import '../../providers/meal_provider.dart';
import 'recipe_picker.dart';

class EditMealDialog extends StatefulWidget {
  final String moment;
  final String initialMeal;
  final List<Map<String, dynamic>> initialIngredients;
  final Function(String, List<Map<String, dynamic>>) onValidate;
  final DateTime date;

  const EditMealDialog({
    super.key,
    required this.moment,
    required this.initialMeal,
    required this.initialIngredients,
    required this.onValidate,
    required this.date,
  });

  static Future<void> show(
    BuildContext context, {
    required String moment,
    required String initialMeal,
    required List<Map<String, dynamic>> initialIngredients,
    required Function(String, List<Map<String, dynamic>>) onValidate,
    required DateTime date,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => EditMealDialog(
        moment: moment,
        initialMeal: initialMeal,
        initialIngredients: initialIngredients,
        onValidate: onValidate,
        date: date,
      ),
    );
  }

  @override
  State<EditMealDialog> createState() => _EditMealDialogState();
}

class _EditMealDialogState extends State<EditMealDialog> {
  late TextEditingController _mealController;
  late List<Map<String, dynamic>> _ingredients;
  final List<TextEditingController> _qtyControllers = [];
  final List<String> _units = ['QT', 'g', 'kg', 'mL', 'L'];
  final List<String> _selectedUnits = [];

  // Pour afficher l'aperçu de la recette sélectionnée
  String? _selectedRecipeImage;

  @override
  void initState() {
    super.initState();
    _mealController = TextEditingController(text: widget.initialMeal);
    _ingredients = List<Map<String, dynamic>>.from(widget.initialIngredients);
    _qtyControllers.addAll(_ingredients.map((e) => TextEditingController(text: e['quantity'].toString())));
    _selectedUnits.addAll(_ingredients.map((e) => e['unit']?.toString() ?? 'QT'));

    // Chercher une image pour le repas initial si c'est une recette connue
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryFindRecipeImage());
  }

  void _tryFindRecipeImage() {
    if (!mounted) return;
    final name = _mealController.text.trim();
    if (name.isEmpty) return;
    final recipes = Provider.of<RecipeProvider>(context, listen: false).recipes;
    final match = recipes.where((r) => r.name.toLowerCase() == name.toLowerCase()).firstOrNull;
    if (match != null && match.imageBase64 != null && match.imageBase64!.isNotEmpty) {
      setState(() => _selectedRecipeImage = match.imageBase64);
    }
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add({
        'name': '', 'quantity': 1, 'unit': 'QT',
        'checked': false, 'moment': widget.moment, 'date': widget.date
      });
      _qtyControllers.add(TextEditingController(text: '1'));
      _selectedUnits.add('QT');
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
      _qtyControllers.removeAt(index);
      _selectedUnits.removeAt(index);
    });
  }

  void _updateIngredientName(int index, String name) => _ingredients[index]['name'] = name;

  void _updateQuantity(int index, String value) {
    final qty = int.tryParse(value);
    _ingredients[index]['quantity'] = (qty != null && qty > 0) ? qty : 1;
    _qtyControllers[index].text = _ingredients[index]['quantity'].toString();
  }

  void _updateUnit(int index, String? value) {
    if (value != null) {
      setState(() {
        _selectedUnits[index] = value;
        _ingredients[index]['unit'] = value;
      });
    }
  }

  void _validate() {
    final mealName = _mealController.text.trim();
    final cleanIngredients = _ingredients
        .where((ing) => ing['name'].toString().trim().isNotEmpty)
        .map((e) => {
              'name': e['name'], 'quantity': e['quantity'],
              'unit': e['unit'] ?? 'QT', 'checked': e['checked'] ?? false,
              'moment': widget.moment, 'date': widget.date,
            })
        .toList();

    if (mealName.isNotEmpty) {
      widget.onValidate(mealName, cleanIngredients);
      Provider.of<MealProvider>(context, listen: false)
          .updateMealAndIngredients(widget.date, widget.moment, mealName, cleanIngredients);
      Navigator.pop(context);
    }
  }

  void _delete() {
    widget.onValidate('', []);
    Provider.of<MealProvider>(context, listen: false).deleteMeal(widget.date, widget.moment);
    Navigator.pop(context);
  }

  void _openRecipePicker() {
    final recipes = Provider.of<RecipeProvider>(context, listen: false).recipes;
    if (recipes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucune recette disponible.')));
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.85,
        child: const RecipePickerBottomSheet(),
      ),
    ).then((selectedRecipe) {
      if (selectedRecipe != null && selectedRecipe is Recipe) {
        setState(() {
          _mealController.text = selectedRecipe.name;
          _selectedRecipeImage = (selectedRecipe.imageBase64?.isNotEmpty ?? false) ? selectedRecipe.imageBase64 : null;
          _ingredients.clear();
          _qtyControllers.clear();
          _selectedUnits.clear();
          for (var ing in selectedRecipe.ingredients) {
            _ingredients.add({
              'name': ing['name'], 'quantity': ing['quantity'],
              'unit': ing['unit'], 'checked': false,
              'moment': widget.moment, 'date': widget.date,
            });
            _qtyControllers.add(TextEditingController(text: ing['quantity'].toString()));
            _selectedUnits.add(ing['unit'].toString());
          }
        });
      }
    });
  }

  String get _momentLabel => widget.moment == 'midi' ? 'Déjeuner' : 'Dîner';
  Color get _momentColor => widget.moment == 'midi' ? AppColors.secondaryYellow : AppColors.primaryGreen;
  IconData get _momentIcon => widget.moment == 'midi' ? Icons.wb_sunny : Icons.nightlight_round;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 30, offset: const Offset(0, 10))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── HEADER ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                color: _momentColor.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: _momentColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: Icon(_momentIcon, color: _momentColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_momentLabel, style: AppTheme.labelSmall.copyWith(color: _momentColor, fontWeight: FontWeight.w700)),
                        Text('Planifier un repas', style: AppTheme.titleMedium.copyWith(fontSize: 16)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey.shade400),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── APERÇU IMAGE RECETTE ───────────────────
                    if (_selectedRecipeImage != null)
                      Container(
                        height: 120,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: MemoryImage(base64Decode(_selectedRecipeImage!)),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.3)],
                            ),
                          ),
                        ),
                      ),

                    // ── CHAMP NOM DU REPAS ─────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _mealController,
                              style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                hintText: 'Nom du plat (ex: Poulet rôti)',
                                hintStyle: AppTheme.bodyText.copyWith(color: Colors.grey.shade400),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                            ),
                          ),
                          // Bouton Recette
                          GestureDetector(
                            onTap: _openRecipePicker,
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryOrange.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.menu_book_outlined, color: AppColors.primaryOrange, size: 16),
                                  const SizedBox(width: 4),
                                  Text('Recettes', style: AppTheme.labelSmall.copyWith(color: AppColors.primaryOrange, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── SECTION INGRÉDIENTS ────────────────────
                    Row(
                      children: [
                        Text('Ingrédients', style: AppTheme.titleMedium.copyWith(fontSize: 14)),
                        const Spacer(),
                        GestureDetector(
                          onTap: _addIngredient,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add, color: AppColors.primaryGreen, size: 16),
                                const SizedBox(width: 4),
                                Text('Ajouter', style: AppTheme.labelSmall.copyWith(color: AppColors.primaryGreen, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // ── ZONE INGRÉDIENTS (min = taille état vide, scrollable au-delà) ──
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 100, maxHeight: 200),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _ingredients.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.shopping_basket_outlined, size: 32, color: Colors.grey.shade300),
                                    const SizedBox(height: 8),
                                    Text('Aucun ingrédient ajouté',
                                      style: AppTheme.bodyText.copyWith(color: AppColors.textSecondary)),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                itemCount: _ingredients.length,
                                separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    children: [
                                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle)),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        flex: 7,
                                        child: TextField(
                                          decoration: InputDecoration(
                                            hintText: 'Ingrédient',
                                            hintStyle: AppTheme.bodyText.copyWith(color: Colors.grey.shade400),
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600),
                                          controller: TextEditingController(text: _ingredients[index]['name'])
                                            ..selection = TextSelection.collapsed(offset: _ingredients[index]['name'].length),
                                          onChanged: (v) => _updateIngredientName(index, v),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 2,
                                        child: TextField(
                                          controller: _qtyControllers[index],
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            border: InputBorder.none, isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                            hintText: '1',
                                            hintStyle: AppTheme.labelSmall.copyWith(color: Colors.grey.shade400),
                                          ),
                                          style: AppTheme.labelSmall.copyWith(fontWeight: FontWeight.w700),
                                          onTap: () => _qtyControllers[index].selection = TextSelection(baseOffset: 0, extentOffset: _qtyControllers[index].text.length),
                                          onChanged: (v) => _updateQuantity(index, v),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _selectedUnits[index],
                                          isDense: true,
                                          style: AppTheme.labelSmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                          items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                                          onChanged: (v) => _updateUnit(index, v),
                                        ),
                                      ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () => _removeIngredient(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                                      child: Icon(Icons.close, color: Colors.red.shade400, size: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── ACTIONS ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, -4))],
              ),
              child: Row(
                children: [
                  // Supprimer
                  TextButton.icon(
                    onPressed: _delete,
                    icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 16),
                    label: Text('Supprimer', style: AppTheme.labelSmall.copyWith(color: Colors.red.shade400)),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                  ),
                  const Spacer(),
                  // Annuler
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Annuler', style: AppTheme.bodyText.copyWith(color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 8),
                  // Valider
                  ElevatedButton(
                    onPressed: _validate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('Valider', style: AppTheme.bodyText.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
