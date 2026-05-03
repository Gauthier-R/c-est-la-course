// Helper partagé : dialog "Ajouter un ingrédient" — style Apple Premium
// Détection de doublon + popup de confirmation si l'ingrédient est déjà dans la liste
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/meal_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_theme.dart';
import '../../utils/date_format.dart';

Future<void> showAddIngredientDialog(
  BuildContext context, {
  required String weekKey,
  VoidCallback? onAdded,
}) async {
  final mealProvider = Provider.of<MealProvider>(context, listen: false);
  final nameCtrl = TextEditingController();
  final qtyCtrl  = TextEditingController(text: '1');
  final units = ['QT', 'g', 'kg', 'cl', 'L', 'c.à.s.', 'c.à.c.', 'pincée', 'sachet', 'boîte', 'botte'];

  await showDialog(
    context: context,
    builder: (dialogCtx) {
      String selectedUnit = 'QT';
      bool nameError = false;
      bool isLoading = false;

      return StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 30, offset: const Offset(0, 10))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── HEADER ──────────────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.08),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_shopping_cart_rounded, color: AppColors.primaryGreen, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Liste de courses', style: AppTheme.labelSmall.copyWith(color: AppColors.primaryGreen, fontWeight: FontWeight.w700)),
                            Text('Ajouter un ingrédient', style: AppTheme.titleMedium.copyWith(fontSize: 16)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey.shade400),
                        onPressed: () => Navigator.pop(dialogCtx),
                        padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // ── CHAMPS ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom
                      Text('Nom', style: AppTheme.labelSmall.copyWith(
                        color: nameError ? Colors.red.shade400 : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      )),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: nameError ? Colors.red.shade50 : AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: nameError ? Border.all(color: Colors.red.shade300, width: 1.5) : null,
                        ),
                        child: TextField(
                          controller: nameCtrl,
                          autofocus: true,
                          style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          onChanged: (_) { if (nameError) setS(() => nameError = false); },
                          decoration: InputDecoration(
                            hintText: nameError ? 'Entrez un nom d\'ingrédient' : 'Ex: Carottes, Huile d\'olive…',
                            hintStyle: AppTheme.bodyText.copyWith(
                              color: nameError ? Colors.red.shade300 : Colors.grey.shade400,
                            ),
                            prefixIcon: Icon(Icons.shopping_basket_outlined,
                              color: nameError ? Colors.red.shade400 : AppColors.primaryGreen, size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Quantité + Unité
                      Text('Quantité', style: AppTheme.labelSmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: TextField(
                                controller: qtyCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d*'))],
                                textAlign: TextAlign.center,
                                style: AppTheme.titleMedium.copyWith(fontSize: 18),
                                onTap: () => qtyCtrl.selection = TextSelection(baseOffset: 0, extentOffset: qtyCtrl.text.length),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedUnit,
                                isDense: true,
                                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400, size: 20),
                                style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                                onChanged: (v) { if (v != null) setS(() => selectedUnit = v); },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── ACTIONS ─────────────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, -4))],
                  ),
                  child: Row(
                    children: [
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogCtx),
                        child: Text('Annuler', style: AppTheme.bodyText.copyWith(color: AppColors.textSecondary)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: isLoading ? null : () async {
                          // ── Validation ──────────────────────────────────
                          final name = nameCtrl.text.trim();
                          if (name.isEmpty) {
                            setS(() => nameError = true);
                            return;
                          }
                          final qty = double.tryParse(qtyCtrl.text.trim().replaceAll(',', '.')) ?? 1.0;

                          setS(() => isLoading = true);

                          try {
                            // ── Détection de doublon (avec fallback réseau) ──
                            bool isDuplicate = false;
                            try {
                              final weekStart = getStartOfWeekFromKey(weekKey);
                              final allIngredients = await mealProvider.getAllWeeklyIngredientNames(weekKey, weekStart);
                              final normalizedInput = name.toLowerCase();
                              isDuplicate = allIngredients.any(
                                (e) => (e['name'] as String? ?? '').toLowerCase() == normalizedInput,
                              );
                            } catch (_) {
                              isDuplicate = false; // erreur réseau → on bypass
                            }

                            if (isDuplicate) {
                              final confirmed = await _showDuplicateConfirmDialog(dialogCtx, name, qty);
                              if (!confirmed) {
                                setS(() => isLoading = false);
                                return;
                              }
                            }

                            // ── Ajout / fusion ───────────────────────────────
                            await mealProvider.addWeeklyExtra(weekKey, name, qty, selectedUnit);

                            Navigator.pop(dialogCtx);
                            onAdded?.call();
                          } catch (e) {
                            setS(() => isLoading = false);
                            debugPrint('❌ Erreur addIngredient: $e');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primaryGreen.withValues(alpha: 0.5),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: isLoading
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text('Ajouter', style: AppTheme.bodyText.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// ── Popup de confirmation doublon ──────────────────────────────────────────
Future<bool> _showDuplicateConfirmDialog(BuildContext context, String name, num qty) async {
  return await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondaryYellow.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: AppColors.secondaryYellow, size: 28),
            ),
            const SizedBox(height: 16),
            Text('Déjà dans la liste', style: AppTheme.titleMedium.copyWith(fontSize: 16), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTheme.bodyText.copyWith(color: AppColors.textSecondary, height: 1.5),
                children: [
                  const TextSpan(text: '"', style: TextStyle(fontStyle: FontStyle.italic)),
                  TextSpan(text: name, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontStyle: FontStyle.italic)),
                  TextSpan(text: '" est déjà présent dans votre liste.\n\nVoulez-vous ajouter '),
                  TextSpan(text: '+ $qty', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryGreen)),
                  const TextSpan(text: ' à la quantité existante ?'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      backgroundColor: Colors.grey.shade100,
                    ),
                    child: Text('Annuler', style: AppTheme.bodyText.copyWith(color: AppColors.textSecondary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Ajouter quand même', style: AppTheme.bodyText.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ) ?? false;
}
