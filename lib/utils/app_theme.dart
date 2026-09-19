import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  /// Décoration standard pour les Cartes (Minimaliste avec touche ludique et ombres douces)
  static BoxDecoration get cardDecoration {
    return BoxDecoration(
      color: AppColors.surfaceWhite,
      borderRadius: BorderRadius.circular(24), // Bords très ronds (Cartoon/Ludique)
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryOrange.withOpacity(0.08), // Ombre légèrement orangée/chaude
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
      border: Border.all(color: Colors.grey.shade100, width: 2), // Bordure subtile pour détacher du fond
    );
  }

  /// Décoration pour les badges (Type de plat, Temps) - Très arrondis
  static BoxDecoration get badgeDecoration {
    return BoxDecoration(
      color: AppColors.secondaryYellow.withOpacity(0.2),
      borderRadius: BorderRadius.circular(30),
    );
  }

  // ===== SYSTÈME DE TYPOGRAPHIE (Google Fonts Poppins) ===== //
  
  static TextStyle get titleHuge => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -1, // Plus de prestance façon iOS
  );

  static TextStyle get titleLarge => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleMedium => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyText => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  
  static TextStyle get labelSmall => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.textSecondary,
  );
}
