import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dinners_app/utils/app_colors.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Card(
        elevation: 8, // Plus d'élévation = plus d'ombre
        shadowColor: Colors.black45,
        color: AppColors.darkOrange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: GoogleFonts.poppins(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Icon(Icons.wb_sunny, size: 30, color: Colors.white),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Midi",
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        lunch,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 25),
                      ),
                    ]
                  )  
                ],
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  const Icon(Icons.nightlight_round, size: 30, color: Colors.white),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Soir",
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        dinner,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 25),
                      ),
                    ],

                  )
                ]
                
              ),
            ],
          ),
        ),
      ),
    );
  }
}
