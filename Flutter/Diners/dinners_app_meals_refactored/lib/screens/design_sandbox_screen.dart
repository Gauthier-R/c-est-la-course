import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';

class DesignSandboxScreen extends StatelessWidget {
  const DesignSandboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('🧪 Design Sandbox', style: AppTheme.titleMedium),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Composants Hybrides', style: AppTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Minimaliste + Chaleureux/Cartoon', style: AppTheme.bodyText),
            
            const SizedBox(height: 32),
            
            // --- TEST: CARTE RECETTE ---
            Text('Carte Recette (Exemple)', style: AppTheme.titleMedium),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecoration,
              child: Row(
                children: [
                  // Image factice avec bords ronds
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryYellow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.fastfood, color: Colors.white, size: 40),
                  ),
                  const SizedBox(width: 16),
                  
                  // Textes
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Burger Maison', style: AppTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text('Rapide & Gourmand', style: AppTheme.bodyText),
                        const SizedBox(height: 12),
                        
                        // Badges
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: AppTheme.badgeDecoration,
                              child: Text('20 min', style: AppTheme.labelSmall),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: AppTheme.badgeDecoration,
                              child: Text('Plat', style: AppTheme.labelSmall),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // --- TEST: BOUTON PRIMAIRE ---
            Text('Bouton d\'Action Principal', style: AppTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56, // Un bouton bien épais pour le côté "friendly"
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('Ajouter au Calendrier', style: AppTheme.titleMedium.copyWith(color: Colors.white)),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // --- TEST: COULEURS ---
            Text('Palette de Couleurs', style: AppTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildColorCircle(AppColors.primaryOrange, 'Orange Primary'),
                _buildColorCircle(AppColors.secondaryYellow, 'Yellow Accent'),
                _buildColorCircle(AppColors.lightGreen, 'Green Status'),
                _buildColorCircle(AppColors.background, 'Background (Bordered)', withBorder: true),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildColorCircle(Color color, String label, {bool withBorder = false}) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: withBorder ? Border.all(color: Colors.grey.shade300) : null,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 70,
          child: Text(
            label, 
            style: const TextStyle(fontSize: 10), 
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
