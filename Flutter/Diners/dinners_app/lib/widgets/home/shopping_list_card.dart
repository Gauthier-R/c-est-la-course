import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dinners_app/utils/app_colors.dart';
import 'package:dinners_app/providers/weekly_list_provider.dart';

class ShoppingListCard extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final VoidCallback onAddPressed;
  final VoidCallback onEditPressed;

  const ShoppingListCard({
    super.key,
    required this.items,
    required this.onAddPressed,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final weeklyListProvider = Provider.of<WeeklyListProvider>(context);
    final String currentWeekKey = weeklyListProvider.currentWeekKey;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        color: AppColors.darkOrange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        shadowColor: Colors.black45,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Ma Liste",
                    style: GoogleFonts.poppins(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add, size: 34, color: Colors.white),
                        onPressed: onAddPressed,
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 30, color: Colors.white),
                        onPressed: onEditPressed,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 320,
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final bool isChecked = item['checked'] ?? false;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Card(
                        color: isChecked ? AppColors.background : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: isChecked ? 0 : 6,
                        shadowColor: Colors.black45,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                            leading: GestureDetector(
                              onTap: () {
                                weeklyListProvider.toggleCheck(currentWeekKey, index);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 28,
                                height: 28,
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
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                color: Colors.black,
                                decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                              ),
                            ),
                            trailing: Text(
                              'x${item['quantity']}',
                              style: GoogleFonts.poppins(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
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
