import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/responsive_helper.dart';

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
          width: ResponsiveHelper.widthPercent(context, 0.1),
          height: ResponsiveHelper.widthPercent(context, 0.1),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(icon,
              color: Colors.white,
              size: ResponsiveHelper.widthPercent(context, 0.05)),
        ),
        SizedBox(width: ResponsiveHelper.widthPercent(context, 0.03)),
        Expanded(
          child: Container(
            height: ResponsiveHelper.heightPercent(context, 0.05),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12)),
            ),
            child: Text(
              mealText,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.scalableFont(context, 14),
              ),
            ),
          ),
        ),
        SizedBox(width: ResponsiveHelper.widthPercent(context, 0.03)),
        IconButton(
          onPressed: onEdit,
          icon: Icon(Icons.edit,
              size: ResponsiveHelper.widthPercent(context, 0.05)),
        ),
      ],
    );
  }
}