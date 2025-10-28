import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/responsive_helper.dart';

class ShoppingHeader extends StatelessWidget {
  const ShoppingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveHelper.heightPercent(context, 0.015),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "   Mes Listes",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: ResponsiveHelper.scalableFont(context, 20),
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
              size: ResponsiveHelper.widthPercent(context, 0.07),
            ),
            onPressed: () {
              debugPrint("Paramètres listes");
            },
          ),
        ],
      ),
    );
  }
}