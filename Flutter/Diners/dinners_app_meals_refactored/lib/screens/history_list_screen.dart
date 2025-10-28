// ✅ Version responsive de HistoryListScreen avec affichage des unités de mesure

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../utils/app_colors.dart';
import '../utils/date_format.dart';
import '../utils/responsive_helper.dart';
import '../widgets/lists/edit_weekly_list_dialog.dart';

class HistoryListScreen extends StatefulWidget {
  final DateTime weekStart;

  const HistoryListScreen({super.key, required this.weekStart});

  @override
  State<HistoryListScreen> createState() => _HistoryListScreenState();
}

class _HistoryListScreenState extends State<HistoryListScreen> {
  late Future<List<Map<String, dynamic>>> _futureItems;

  @override
  void initState() {
    super.initState();
    _futureItems = _fetchItems();
  }

  String formatQuantity(Map<String, dynamic> item) {
    final quantity = item['quantity'] ?? 0;
    final unit = item['unit'] ?? 'QT';
    return unit == 'QT' ? 'x $quantity' : '$quantity $unit';
  }

  Future<List<Map<String, dynamic>>> _fetchItems() async {
    final List<Map<String, dynamic>> items = [];
    final weekStart = widget.weekStart;
    final weekDates = List.generate(7, (i) => DateFormat('yyyy-MM-dd').format(weekStart.add(Duration(days: i))));
    final weekKey = getWeekKey(weekStart);

    final dailyDocs = await FirebaseFirestore.instance
        .collection('meals')
        .where(FieldPath.documentId, whereIn: weekDates)
        .get();

    for (final doc in dailyDocs.docs) {
      final data = doc.data();
      for (final moment in ['midi', 'soir']) {
        final entry = data[moment];
        if (entry != null && entry['ingredients'] != null) {
          final ingredients = List<Map<String, dynamic>>.from(
            (entry['ingredients'] as List).map((e) => Map<String, dynamic>.from(e))
          );
          for (final ing in ingredients) {
            ing['moment'] = moment;
            ing['date'] = DateFormat('yyyy-MM-dd').parse(doc.id);
          }
          items.addAll(ingredients);
        }
      }
    }

    final weeklyDoc = await FirebaseFirestore.instance.collection('meals').doc(weekKey).get();
    if (weeklyDoc.exists) {
      final weeklyData = weeklyDoc.data();
      if (weeklyData != null && weeklyData['extras'] != null) {
        final extras = List<Map<String, dynamic>>.from(
          (weeklyData['extras'] as List).map((e) => Map<String, dynamic>.from(e))
        );
        items.addAll(extras);
      }
    }

    return items;
  }

  void _showAddIngredientDialog(BuildContext context) {
  final mealProvider = Provider.of<MealProvider>(context, listen: false);
  final weekKey = getWeekKey(widget.weekStart);

  final nameController = TextEditingController();
  final qtyController = TextEditingController(text: '1');
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
                  // Nom (50%)
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

                  // Quantité (20%)
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

                  // Unité (30%)
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: selectedUnit,
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
          child: Text('Annuler', style: TextStyle(fontSize: ResponsiveHelper.scalableFont(context, 14))),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = nameController.text.trim();
            final qty = int.tryParse(qtyController.text.trim()) ?? 1;
            if (name.isNotEmpty) {
              await mealProvider.addWeeklyExtra(
                weekKey,
                name,
                qty,
                selectedUnit,
              );
              Navigator.pop(context);
              setState(() {
                _futureItems = _fetchItems();
              });
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryOrange),
          child: Text('Ajouter', style: TextStyle(fontSize: ResponsiveHelper.scalableFont(context, 14))),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentStart = now.subtract(Duration(days: now.weekday - 1));
    final isCurrentWeek = widget.weekStart.year == currentStart.year &&
        widget.weekStart.month == currentStart.month &&
        widget.weekStart.day == currentStart.day;

    final gradientColors = isCurrentWeek
        ? [AppColors.darkOrange, AppColors.primaryOrange]
        : [AppColors.primaryGreen, AppColors.lightGreen];

    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureItems,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = List<Map<String, dynamic>>.from(snapshot.data!);

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.widthPercent(context, 0.05),
              vertical: ResponsiveHelper.heightPercent(context, 0.05),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: ResponsiveHelper.widthPercent(context, 0.05)),
                    ),
                    SizedBox(width: ResponsiveHelper.widthPercent(context, 0.015)),
                    Expanded(
                      child: Text(
                        'Du ${DateFormat('d MMMM', 'fr_FR').format(widget.weekStart)} au ${DateFormat('d MMMM', 'fr_FR').format(widget.weekStart.add(const Duration(days: 6)))}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveHelper.scalableFont(context, 16),
                            ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.white, size: ResponsiveHelper.widthPercent(context, 0.06)),
                      onPressed: () => _showAddIngredientDialog(context),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.white, size: ResponsiveHelper.widthPercent(context, 0.05)),
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (_) => EditWeeklyListDialog(weekStart: widget.weekStart),
                        );
                        setState(() {
                          _futureItems = _fetchItems();
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveHelper.heightPercent(context, 0.02)),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(ResponsiveHelper.widthPercent(context, 0.04)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: items.isEmpty
                        ? Center(
                            child: Text('Aucun ingrédient pour cette semaine.',
                                style: TextStyle(fontSize: ResponsiveHelper.scalableFont(context, 10))),
                          )
                        : ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final isChecked = item['checked'] ?? false;

                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.heightPercent(context, 0.004)),
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
                                          setState(() => item['checked'] = !isChecked);
                                          Provider.of<MealProvider>(context, listen: false)
                                              .toggleIngredientChecked(item, item['checked']);
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
                                                      color: AppColors.primaryOrange.withOpacity(0.4),
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
                                        style: TextStyle(
                                          fontSize: ResponsiveHelper.scalableFont(context, 16),
                                          color: Colors.black,
                                          decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                                        ),
                                      ),
                                      trailing: Text(
                                        formatQuantity(item),
                                        style: TextStyle(
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
                          ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}