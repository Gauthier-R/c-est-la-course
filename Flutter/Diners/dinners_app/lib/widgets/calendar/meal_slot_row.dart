import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MealSlotRow extends StatelessWidget {
  final IconData icon;
  final List<Color> gradientColors;
  final String label;
  final String mealText;
  final VoidCallback onEdit;

  const MealSlotRow({
    super.key,
    required this.icon,
    required this.gradientColors,
    required this.label,
    required this.mealText,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 40,
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12)),
            ),
            child: Text(
              mealText,
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: onEdit,
          icon: const Icon(Icons.edit, size: 22),
        ),
      ],
    );
  }
}
