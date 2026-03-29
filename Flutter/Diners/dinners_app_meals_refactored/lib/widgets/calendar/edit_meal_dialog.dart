// Mise à jour du layout dans EditMealDialog pour une ligne optimisée avec champ responsive pour nom, quantité, unité et suppression

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive_helper.dart';
import '../../providers/meal_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _mealController = TextEditingController(text: widget.initialMeal);
    _ingredients = List<Map<String, dynamic>>.from(widget.initialIngredients);
    _qtyControllers.addAll(_ingredients.map((e) => TextEditingController(text: e['quantity'].toString())));
    _selectedUnits.addAll(_ingredients.map((e) => e['unit']?.toString() ?? 'QT'));
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add({
        'name': '',
        'quantity': 1,
        'unit': 'QT',
        'checked': false,
        'moment': widget.moment,
        'date': widget.date
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

  void _updateIngredientName(int index, String name) {
    _ingredients[index]['name'] = name;
  }

  void _updateQuantity(int index, String value) {
    final quantity = int.tryParse(value);
    _ingredients[index]['quantity'] = (quantity != null && quantity > 0) ? quantity : 1;
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
              'name': e['name'],
              'quantity': e['quantity'],
              'unit': e['unit'] ?? 'QT',
              'checked': e['checked'] ?? false,
              'moment': widget.moment,
              'date': widget.date,
            })
        .toList();

    if (mealName.isNotEmpty) {
      widget.onValidate(mealName, cleanIngredients);

      final mealProvider = Provider.of<MealProvider>(context, listen: false);
      mealProvider.updateMealAndIngredients(
        widget.date,
        widget.moment,
        mealName,
        cleanIngredients,
      );

      Navigator.pop(context);
    }
  }

  void _delete() {
    widget.onValidate('', []);
    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    mealProvider.deleteMeal(widget.date, widget.moment);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Enregistrez le repas du ${widget.moment}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: ResponsiveHelper.scalableFont(context, 16),
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _mealController,
                decoration: InputDecoration(
                  labelText: 'Votre Plat',
                  hintText: 'Ex: Poulet au curry',
                  hintStyle: TextStyle(fontSize: ResponsiveHelper.scalableFont(context, 10)),
                  suffixIcon: const Icon(Icons.menu_book_outlined),
                ),
              ),
              SizedBox(height: ResponsiveHelper.heightPercent(context, 0.02)),
              Container(
                padding: EdgeInsets.all(ResponsiveHelper.widthPercent(context, 0.02)),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(ResponsiveHelper.widthPercent(context, 0.03)),
                ),
                constraints: BoxConstraints(maxHeight: ResponsiveHelper.heightPercent(context, 0.4)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Liste',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveHelper.scalableFont(context, 14),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveHelper.heightPercent(context, 0.01)),
                    GestureDetector(
                      onTap: _addIngredient,
                      child: Row(
                        children: [
                          const Icon(Icons.add_circle_outline, color: Colors.green, size: 15),
                          SizedBox(width: ResponsiveHelper.widthPercent(context, 0.015)),
                          Text(
                            'Ajouter Ingrédient',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: ResponsiveHelper.scalableFont(context, 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.heightPercent(context, 0.03)),
                    if (_ingredients.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.heightPercent(context, 0.1048)),
                        child: Text(
                          "Aucun ingrédient ajouté.",
                          style: TextStyle(fontSize: ResponsiveHelper.scalableFont(context, 10)),
                        ),
                      )
                    else
                      SizedBox(
                        height: ResponsiveHelper.heightPercent(context, 0.27),
                        child: ListView.builder(
                          itemCount: _ingredients.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.heightPercent(context, 0.005)),
                              child: Row(
                                children: [
                                  // Nom ingrédient (50%)
                                  Expanded(
                                    flex: 7,
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Ingrédient',
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                      ),
                                      style: TextStyle(fontSize: ResponsiveHelper.scalableFont(context, 12)),
                                      controller: TextEditingController(text: _ingredients[index]['name'])
                                        ..selection = TextSelection.collapsed(offset: _ingredients[index]['name'].length),
                                      onChanged: (value) => _updateIngredientName(index, value),
                                    ),
                                  ),
                                  SizedBox(width: ResponsiveHelper.widthPercent(context, 0.01)),

                                  // Quantité (15%)
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: _qtyControllers[index],
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      decoration: const InputDecoration(
                                        prefixText: 'x',
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                                      ),
                                      onTap: () => _qtyControllers[index].selection = TextSelection(baseOffset: 0, extentOffset: _qtyControllers[index].text.length),
                                      onTapOutside: (_) {
                                        if (_qtyControllers[index].text.isEmpty) {
                                          _qtyControllers[index].text = '1';
                                          _updateQuantity(index, '1');
                                        }
                                      },
                                      onChanged: (value) => _updateQuantity(index, value),
                                      style: TextStyle(fontSize: ResponsiveHelper.scalableFont(context, 12)),
                                    ),
                                  ),
                                  SizedBox(width: ResponsiveHelper.widthPercent(context, 0.01)),

                                  // Unité (20%)
                                  Expanded(
                                    flex: 3,
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _selectedUnits[index],
                                      items: _units.map((unit) => DropdownMenuItem(
                                        value: unit,
                                        child: Text(unit, style: TextStyle(fontSize: ResponsiveHelper.scalableFont(context, 10), color: Colors.black)),
                                      )).toList(),
                                      onChanged: (value) => _updateUnit(index, value),
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      style: TextStyle(fontSize: ResponsiveHelper.scalableFont(context, 10)),
                                      isExpanded: true,
                                    ),
                                  ),
                                  SizedBox(width: ResponsiveHelper.widthPercent(context, 0.01)),

                                  // Supprimer (15%)
                                  Expanded(
                                    flex: 1,
                                    child: IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red, size: ResponsiveHelper.scalableFont(context, 18)),
                                      onPressed: () => _removeIngredient(index),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: EdgeInsets.only(
        left: ResponsiveHelper.widthPercent(context, 0.04),
        right: ResponsiveHelper.widthPercent(context, 0.04),
        bottom: ResponsiveHelper.heightPercent(context, 0.015),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _delete,
              child: Text(
                'Supprimer',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: ResponsiveHelper.scalableFont(context, 10),
                ),
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Annuler',
                    style: TextStyle(fontSize: ResponsiveHelper.scalableFont(context, 10)),
                  ),
                ),
                SizedBox(width: ResponsiveHelper.widthPercent(context, 0.01)),
                ElevatedButton(
                  onPressed: _validate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                  ),
                  child: Text(
                    'Valider',
                    style: TextStyle(fontSize: ResponsiveHelper.scalableFont(context, 10)),
                  ),
                ),
              ],
            )
          ],
        )
      ],
    );
  }
}
