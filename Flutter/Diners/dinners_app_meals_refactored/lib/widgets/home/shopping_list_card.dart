import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dinners_app/utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:dinners_app/providers/meal_provider.dart';
import 'package:dinners_app/utils/date_format.dart';
import 'package:dinners_app/utils/responsive_helper.dart';

class ShoppingListCard extends StatelessWidget {
  final VoidCallback onAddPressed;
  final VoidCallback onEditPressed;

  const ShoppingListCard({
    super.key,
    required this.onAddPressed,
    required this.onEditPressed,
  });

  String formatQuantity(Map<String, dynamic> item) {
    final quantity = item['quantity'] ?? 0;
    final unit = item['unit'] ?? 'QT';
    if (unit == 'QT') return 'x $quantity';
    return '$quantity $unit';
  }

  void _showAddIngredientDialog(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    final weekKey = getWeekKey(DateTime.now());

    final TextEditingController nameController = TextEditingController();
    final TextEditingController qtyController = TextEditingController(text: '1');
    final List<String> units = ['QT', 'g', 'kg', 'mL', 'L'];
    String selectedUnit = 'QT';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Ajouter un ingrédient",
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.scalableFont(context, 16),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 8,
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Ingrédient',
                          hintStyle: GoogleFonts.poppins(fontSize: 12),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.widthPercent(context, 0.01)),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: qtyController,
                        keyboardType: TextInputType.number,
                        onTap: () => qtyController.selection = TextSelection(baseOffset: 0, extentOffset: qtyController.text.length),
                        decoration: const InputDecoration(
                          prefixText: 'x',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.widthPercent(context, 0.01)),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedUnit,
                        items: units.map((u) => DropdownMenuItem(
                          value: u,
                          child: Text(u, style: TextStyle(fontSize: ResponsiveHelper.scalableFont(context, 12))),
                        )).toList(),
                        onChanged: (value) {
                          if (value != null) selectedUnit = value;
                        },
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        ),
                      ),
                    ),
                  ],
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final qty = int.tryParse(qtyController.text.trim()) ?? 1;
              if (name.isNotEmpty) {
                await mealProvider.addWeeklyExtra(weekKey, name, qty, selectedUnit);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryOrange),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.widthPercent(context, 0.05)),
      child: Card(
        color: AppColors.darkOrange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        shadowColor: Colors.black45,
        child: Padding(
          padding: EdgeInsets.all(ResponsiveHelper.widthPercent(context, 0.03)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Ma Liste",
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.scalableFont(context, 18),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.add, size: ResponsiveHelper.widthPercent(context, 0.08), color: Colors.white),
                        onPressed: () => _showAddIngredientDialog(context),
                      ),
                      IconButton(
                        icon: Icon(Icons.open_in_full, size: ResponsiveHelper.widthPercent(context, 0.06), color: Colors.white),
                        onPressed: () => Navigator.pushNamed(context, '/current_week'),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: ResponsiveHelper.heightPercent(context, 0.005)),
              Container(
                height: ResponsiveHelper.heightPercent(context, 0.315),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(ResponsiveHelper.widthPercent(context, 0.03)),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: mealProvider.getWeeklyIngredients(DateTime.now()),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final items = snapshot.data!;
                    if (items.isEmpty) {
                      return const Center(
                        child: Text(
                          "Aucun ingrédient pour cette semaine.",
                          style: TextStyle(fontSize: 10, color: Colors.black54),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final bool isChecked = item['checked'] ?? false;

                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.heightPercent(context, 0.002)),
                          child: Card(
                            color: isChecked ? AppColors.background : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isChecked ? AppColors.background : Colors.grey.shade300,
                                width: 0.5,
                              ),
                            ),
                            elevation: isChecked ? 0 : 6,
                            shadowColor: Colors.black45,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.widthPercent(context, 0.02)),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.widthPercent(context, 0.01)),
                                leading: GestureDetector(
                                  onTap: () async {
                                    await mealProvider.toggleIngredientChecked(item, !isChecked);
                                    item['checked'] = !isChecked;
                                    (context as Element).markNeedsBuild();
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: ResponsiveHelper.widthPercent(context, 0.07),
                                    height: ResponsiveHelper.widthPercent(context, 0.07),
                                    decoration: BoxDecoration(
                                      color: isChecked ? AppColors.primaryOrange : AppColors.background,
                                      shape: BoxShape.circle,
                                      boxShadow: isChecked
                                          ? [
                                              BoxShadow(
                                                color: AppColors.primaryOrange.withValues(alpha: 0.4),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Center(
                                      child: AnimatedOpacity(
                                        duration: const Duration(milliseconds: 200),
                                        opacity: isChecked ? 1.0 : 0.0,
                                        child: const Icon(Icons.check, size: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  item['name'],
                                  style: GoogleFonts.poppins(
                                    fontSize: ResponsiveHelper.scalableFont(context, 16),
                                    color: Colors.black,
                                    decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                                  ),
                                ),
                                trailing: Text(
                                  formatQuantity(item),
                                  style: GoogleFonts.poppins(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                    fontSize: ResponsiveHelper.scalableFont(context, 14),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}