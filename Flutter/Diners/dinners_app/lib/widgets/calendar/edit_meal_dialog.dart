import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../providers/meal_provider.dart';
import '../../providers/weekly_list_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _mealController = TextEditingController(text: widget.initialMeal);
    _ingredients = List<Map<String, dynamic>>.from(widget.initialIngredients);
    _qtyControllers.addAll(_ingredients.map((e) => TextEditingController(text: e['quantity'].toString())));
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add({'name': '', 'quantity': 1});
      _qtyControllers.add(TextEditingController(text: '1'));
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
      _qtyControllers.removeAt(index);
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

  void _validate() {
    final mealName = _mealController.text.trim();
    final cleanIngredients = _ingredients
        .where((ing) => ing['name'].toString().trim().isNotEmpty)
        .toList();

    if (mealName.isNotEmpty) {
      widget.onValidate(mealName, cleanIngredients);

      final mealProvider = Provider.of<MealProvider>(context, listen: false);
      final weeklyListProvider = Provider.of<WeeklyListProvider>(context, listen: false);
      mealProvider.updateMealAndIngredients(
        widget.date,
        widget.moment,
        mealName,
        cleanIngredients,
        weeklyListProvider,
      );

      Navigator.pop(context);
    }
  }

  void _delete() {
    print("🟥 Bouton Supprimer activé !");
    widget.onValidate('', []);
    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    final weeklyListProvider = Provider.of<WeeklyListProvider>(context, listen: false);
    mealProvider.deleteMeal(widget.date, widget.moment, weeklyListProvider); // ✅ avec weeklyListProvider
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Enregistrez le repas du ${widget.moment}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _mealController,
                decoration: const InputDecoration(
                  labelText: 'Votre Plat',
                  hintText: 'Ex: Poulet au curry',
                  suffixIcon: Icon(Icons.menu_book_outlined),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                constraints: const BoxConstraints(maxHeight: 300),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Text('Liste', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (_ingredients.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text("Aucun ingrédient ajouté."),
                      )
                    else
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          itemCount: _ingredients.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      decoration: const InputDecoration(hintText: 'Ingrédient'),
                                      controller: TextEditingController(text: _ingredients[index]['name'])
                                        ..selection = TextSelection.collapsed(offset: _ingredients[index]['name'].length),
                                      onChanged: (value) => _updateIngredientName(index, value),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 50,
                                    child: TextField(
                                      controller: _qtyControllers[index],
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      decoration: const InputDecoration(prefixText: 'x'),
                                      onTap: () => _qtyControllers[index].selection = TextSelection(baseOffset: 0, extentOffset: _qtyControllers[index].text.length),
                                      onTapOutside: (_) {
                                        if (_qtyControllers[index].text.isEmpty) {
                                          _qtyControllers[index].text = '1';
                                          _updateQuantity(index, '1');
                                        }
                                      },
                                      onChanged: (value) => _updateQuantity(index, value),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                    onPressed: () => _removeIngredient(index),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _addIngredient,
                      child: const Row(
                        children: [
                          Icon(Icons.add_circle_outline, color: Colors.green),
                          SizedBox(width: 6),
                          Text('Ajouter Ingrédient', style: TextStyle(color: Colors.green)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _delete,
              child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _validate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                  ),
                  child: const Text('Valider'),
                ),
              ],
            )
          ],
        )
      ],
    );
  }
}
