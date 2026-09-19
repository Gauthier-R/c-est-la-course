import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dinners_app/utils/app_colors.dart';
import 'package:dinners_app/utils/responsive_helper.dart';

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
      height: ResponsiveHelper.heightPercent(context, 0.20),
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.widthPercent(context, 0.05),
        vertical: ResponsiveHelper.heightPercent(context, 0.04), // réduit pour monter les éléments
      ),
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
          Padding(
            padding: EdgeInsets.only(top: ResponsiveHelper.heightPercent(context, 0.02)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: ResponsiveHelper.widthPercent(context, 0.1),
                      height: ResponsiveHelper.widthPercent(context, 0.1),
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
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveHelper.scalableFont(context, 16),
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.widthPercent(context, 0.04)),
                    Padding(
                      padding: EdgeInsets.only(top: ResponsiveHelper.heightPercent(context, 0.005)),
                      child: Text(
                        'Hey, $username 👋',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: ResponsiveHelper.scalableFont(context, 20),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: ResponsiveHelper.heightPercent(context, 0.005)),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.settings,
                            size: ResponsiveHelper.widthPercent(context, 0.07),
                            color: Colors.white),
                        onPressed: onSettingsPressed,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}