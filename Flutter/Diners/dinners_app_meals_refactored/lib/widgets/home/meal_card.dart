import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dinners_app/utils/app_colors.dart';
import 'package:dinners_app/utils/responsive_helper.dart';

class MealCard extends StatelessWidget {
  final String date;
  final String lunch;
  final String dinner;

  const MealCard({
    super.key,
    required this.date,
    required this.lunch,
    required this.dinner,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.widthPercent(context, 0.015),
        vertical: ResponsiveHelper.heightPercent(context, 0.009),
      ),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black45,
        color: AppColors.darkOrange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveHelper.heightPercent(context, 0.004),
            horizontal: ResponsiveHelper.widthPercent(context, 0.035),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: ResponsiveHelper.heightPercent(context, 0.015)),
              Text(
                date,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.scalableFont(context, 18),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: ResponsiveHelper.heightPercent(context, 0.01)),
              Row(
                children: [
                  Icon(Icons.wb_sunny,
                      size: ResponsiveHelper.widthPercent(context, 0.06),
                      color: Colors.white),
                  SizedBox(width: ResponsiveHelper.widthPercent(context, 0.04)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Déjeuner",
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveHelper.scalableFont(context, 10),
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          lunch,
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveHelper.scalableFont(context, 16),
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveHelper.heightPercent(context, 0.02)),
              Row(
                children: [
                  Icon(Icons.nightlight_round,
                      size: ResponsiveHelper.widthPercent(context, 0.06),
                      color: Colors.white),
                  SizedBox(width: ResponsiveHelper.widthPercent(context, 0.04)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Dîner",
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveHelper.scalableFont(context, 10),
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          dinner,
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveHelper.scalableFont(context, 16),
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}