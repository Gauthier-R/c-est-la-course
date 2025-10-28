import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:dinners_app/utils/responsive_helper.dart';


class CalendarHeader extends StatelessWidget {
  const CalendarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final rawDay = DateFormat.EEEE('fr_FR').format(DateTime.now());
    final String today = rawDay[0].toUpperCase() + rawDay.substring(1);

    final String date = DateFormat("d MMMM", 'fr_FR').format(DateTime.now());

    return Container(
      padding: EdgeInsets.only(top: ResponsiveHelper.heightPercent(context, 0.015)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "   $today $date",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: Icon(Icons.settings,
                size: ResponsiveHelper.widthPercent(context, 0.07),
                color: Colors.white),
            onPressed: () => debugPrint("Paramètres cliqués !"),
          ),
        ],
      ),
    );
  }
}
