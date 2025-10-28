import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CalendarHeader extends StatelessWidget {
  const CalendarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final rawDay = DateFormat.EEEE('fr_FR').format(DateTime.now());
    final String today = rawDay[0].toUpperCase() + rawDay.substring(1);

    final String date = DateFormat("d MMMM", 'fr_FR').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$today $date",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 30),
            onPressed: () {
              debugPrint("Paramètres calendrier");
            },
          ),
        ],
      ),
    );
  }
}
