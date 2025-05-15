import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShoppingHeader extends StatelessWidget {
  const ShoppingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Mes Listes",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 30),
            onPressed: () {
              debugPrint("Paramètres listes");
            },
          ),
        ],
      ),
    );
  }
}
