import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dinners_app/utils/app_colors.dart';


class Header extends StatelessWidget {
  final String username;
  final String initials;
  final VoidCallback onSettingsPressed;

  const Header({
    super.key,
    required this.username,
    required this.initials,
    required this.onSettingsPressed,
  });

  @override
Widget build(BuildContext context) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.25,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.lightGreen, AppColors.primaryGreen],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.darkOrange, AppColors.primaryOrange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Text(
                    initials,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Hello, $username !',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white, size: 30),
              onPressed: onSettingsPressed,
            )
          ],
        ),
        const Spacer(), // cela pousse le contenu vers le haut
      ],
    ),
  );
}
}