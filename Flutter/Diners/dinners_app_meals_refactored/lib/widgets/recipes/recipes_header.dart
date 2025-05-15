import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/responsive_helper.dart';
import '../../utils/app_colors.dart';

class RecipesHeader extends StatelessWidget {
  final VoidCallback onSettingsPressed;

  const RecipesHeader({super.key, required this.onSettingsPressed});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      height: ResponsiveHelper.heightPercent(context, 0.16) + topPadding,
      padding: EdgeInsets.only(
        top: ResponsiveHelper.heightPercent(context, 0.01),
        left: ResponsiveHelper.widthPercent(context, 0.05),
        right: ResponsiveHelper.widthPercent(context, 0.05),
        bottom: ResponsiveHelper.heightPercent(context, 0.02),
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.lightGreen, AppColors.primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '   Mes recettes',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveHelper.scalableFont(context, 20),
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
              size: ResponsiveHelper.widthPercent(context, 0.07),
            ),
            onPressed: onSettingsPressed,
          ),
        ],
      ),
    );
  }
}
