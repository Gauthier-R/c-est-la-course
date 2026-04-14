import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';
import '../providers/meal_provider.dart';
import '../providers/recipe_provider.dart';
import '../utils/date_format.dart';
import '../widgets/lists/add_ingredient_dialog.dart';
import '../providers/auth_provider.dart';
import 'settings_profile_screen.dart';

// ─── Carte de repas STYLE APPLE PREMIUM ────────────────────────────────────
class _PremiumMealCard extends StatelessWidget {
  final DateTime date;
  final String lunch;
  final String dinner;

  const _PremiumMealCard({
    required this.date,
    required this.lunch,
    required this.dinner,
  });

  bool get _isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final formattedDay = DateFormat('EEEE d MMMM', 'fr_FR').format(date);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: _isToday
              ? Border.all(color: AppColors.primaryOrange, width: 2)
              : Border.all(color: Colors.grey.shade100, width: 1),
          boxShadow: [
            BoxShadow(
              color: _isToday
                  ? AppColors.primaryOrange.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (_isToday)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text("Aujourd'hui", style: AppTheme.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  Expanded(
                    child: Text(
                      formattedDay,
                      style: AppTheme.titleMedium.copyWith(
                        fontSize: 15,
                        color: _isToday ? AppColors.primaryOrange : AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Midi
              _buildMealRow(context, Icons.wb_sunny, AppColors.secondaryYellow, 'Déjeuner', lunch),
              const SizedBox(height: 12),
              // Soir
              _buildMealRow(context, Icons.nightlight_round, AppColors.primaryGreen, 'Dîner', dinner),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealRow(BuildContext context, IconData icon, Color color, String label, String meal) {
    // Chercher une image de recette si le repas correspond à une recette connue
    final recipes = Provider.of<RecipeProvider>(context, listen: false).recipes;
    final matchingRecipe = recipes.where(
      (r) => r.name.toLowerCase() == meal.toLowerCase() && (r.imageBase64?.isNotEmpty ?? false)
    ).firstOrNull;

    return Row(
      children: [
        // Icône ou photo de la recette
        (matchingRecipe != null && matchingRecipe.imageBytes != null)
            ? ClipOval(
                child: Image.memory(
                  matchingRecipe.imageBytes!,
                  width: 36, height: 36,
                  fit: BoxFit.cover,
                  gaplessPlayback: true, // Évite le scintillement si rebuild
                ),
              )
            : Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTheme.labelSmall.copyWith(color: AppColors.textSecondary, fontSize: 10)),
              Text(
                meal.isNotEmpty ? meal : '—',
                style: AppTheme.bodyText.copyWith(
                  color: meal.isNotEmpty ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: meal.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── CARROUSEL DE REPAS PREMIUM ────────────────────────────────────────────
class _PremiumMealCarousel extends StatefulWidget {
  final DateTime baseDate;
  const _PremiumMealCarousel({required this.baseDate});

  @override
  State<_PremiumMealCarousel> createState() => _PremiumMealCarouselState();
}

class _PremiumMealCarouselState extends State<_PremiumMealCarousel> {
  late final PageController _pageController;
  double _currentPage = 7.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88, initialPage: 7);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? _currentPage;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _dateFromIndex(int index) => widget.baseDate.add(Duration(days: index - 7));

  @override
  Widget build(BuildContext context) {
    return Consumer<MealProvider>(
      builder: (context, provider, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _pageController,
                itemCount: 15,
                allowImplicitScrolling: true, // Précharge les pages adjacentes
                itemBuilder: (context, index) {
                  final date = _dateFromIndex(index);
                  final meals = provider.selectedMealsFor(date);
                  return _PremiumMealCard(
                    date: date,
                    lunch: meals['midi'] ?? '',
                    dinner: meals['soir'] ?? '',
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Indicateurs de page (petits dots animés)
            AnimatedBuilder(
              animation: _pageController,
              builder: (context, _) {
                int total = 15;
                int center = _currentPage.round();
                int start = (center - 3).clamp(0, total - 1);
                int end = (center + 3).clamp(0, total - 1);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(end - start + 1, (i) {
                    int idx = start + i;
                    double distance = (_currentPage - idx).abs();
                    double size = (1.0 - (distance * 0.3).clamp(0.0, 0.7)) * 8;
                    double opacity = (1.0 - (distance * 0.4).clamp(0.0, 0.8));
                    bool isSelected = idx == center;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isSelected ? 20 : size,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryOrange : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ).animate(opacity.clamp(0.2, 1.0));
                  }),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// ─── LISTE DE COURSES PREMIUM ───────────────────────────────────────────────
class _PremiumShoppingCard extends StatelessWidget {
  const _PremiumShoppingCard();

  String _formatQty(Map<String, dynamic> item) {
    var qty = item['quantity'] ?? 0;
    var unit = item['unit'] ?? 'QT';
    if (qty is num && qty == qty.toInt()) qty = qty.toInt();
    if (unit == 'QT') return 'x $qty';
    return '$qty $unit';
  }

  /// Fusionne les ingrédients de même nom en cumulant les quantités
  List<Map<String, dynamic>> _deduplicateIngredients(List<Map<String, dynamic>> items) {
    final Map<String, Map<String, dynamic>> merged = {};
    for (final item in items) {
      final name = (item['name'] as String? ?? '').trim();
      if (name.isEmpty) continue;
      final key = name.toLowerCase();
      if (merged.containsKey(key)) {
        final existingQty = ((merged[key]!['quantity'] as num?) ?? 0).toInt();
        final newQty = ((item['quantity'] as num?) ?? 0).toInt();
        merged[key]!['quantity'] = existingQty + newQty;
      } else {
        merged[key] = Map<String, dynamic>.from(item);
      }
    }
    return merged.values.toList();
  }

  void _showAddDialog(BuildContext context) {
    showAddIngredientDialog(context, weekKey: getWeekKey(DateTime.now()));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MealProvider>(
      builder: (context, mealProvider, _) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
            children: [
              // Header de la carte
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.primaryGreen.withValues(alpha: 0.12), shape: BoxShape.circle),
                      child: const Icon(Icons.shopping_basket_outlined, color: AppColors.primaryGreen, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Ma liste de la semaine', style: AppTheme.titleMedium.copyWith(fontSize: 16))),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: AppColors.primaryOrange, size: 28),
                      onPressed: () => _showAddDialog(context),
                      tooltip: 'Ajouter un ingrédient',
                    ),
                    IconButton(
                      icon: Icon(Icons.open_in_full, color: Colors.grey.shade400, size: 20),
                      onPressed: () => Navigator.pushNamed(context, '/current_week'),
                      tooltip: 'Voir toute la liste',
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.grey.shade100, height: 1),
              // Liste des ingrédients
              FutureBuilder<List<Map<String, dynamic>>>(
                future: mealProvider.getWeeklyIngredients(DateTime.now()),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryOrange)),
                    );
                  }
                  final rawItems = snapshot.data!;
                  final items = _deduplicateIngredients(rawItems);
                  if (items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 40, color: Colors.grey.shade300),
                          const SizedBox(height: 8),
                          Text('Aucun ingrédient pour cette semaine', style: AppTheme.bodyText.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  }
                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: ListView.separated(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => Divider(color: Colors.grey.shade50, height: 1, indent: 64),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isChecked = item['checked'] ?? false;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                        leading: GestureDetector(
                          onTap: () async {
                            await mealProvider.toggleIngredientChecked(item, !isChecked);
                            item['checked'] = !isChecked;
                            (context as Element).markNeedsBuild();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: isChecked ? AppColors.primaryGreen : Colors.transparent,
                              shape: BoxShape.circle,
                              border: isChecked ? null : Border.all(color: Colors.grey.shade300, width: 2),
                            ),
                            child: isChecked
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : null,
                          ),
                        ),
                        title: Text(
                          item['name'],
                          style: AppTheme.bodyText.copyWith(
                            color: isChecked ? AppColors.textSecondary : AppColors.textPrimary,
                            decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(_formatQty(item),
                            style: AppTheme.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            )),
                        ),
                      );
                    },
                  ),
                  );

                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

// ─── EXTENSION ANIMATE OPACITY ─────────────────────────────────────────────
extension on Widget {
  Widget animate(double opacity) => Opacity(opacity: opacity, child: this);
}

// ─── ÉCRAN PRINCIPAL ACCUEIL SANDBOX ───────────────────────────────────────
class SandboxHomeScreen extends StatelessWidget {
  const SandboxHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER ───────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    final user = auth.userProfile;
                    final firstName = user?.name.split(' ').first ?? 'Utilisateur';
                    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U';
                    
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bonjour,', style: AppTheme.bodyText.copyWith(color: AppColors.textSecondary)),
                              Text(firstName, style: AppTheme.titleHuge),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SettingsProfileScreen()),
                            );
                          },
                          child: Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange.withAlpha(50),
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: AppColors.primaryOrange.withValues(alpha: 0.3), blurRadius: 8)],
                              image: user?.photoBase64 != null 
                                ? DecorationImage(
                                    image: MemoryImage(base64Decode(user!.photoBase64!)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            ),
                            child: user?.photoBase64 == null 
                              ? Center(
                                  child: Text(initial, style: GoogleFonts.poppins(color: AppColors.primaryOrange, fontWeight: FontWeight.bold, fontSize: 18)),
                                )
                              : null,
                          ),
                        ),
                      ],
                    );
                  }
                ),
              ),
              const SizedBox(height: 32),
              
              // ── TITRE SECTION ────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('Mes repas', style: AppTheme.titleMedium.copyWith(color: AppColors.textSecondary, fontSize: 14)),
              ),
              const SizedBox(height: 12),

              // ── CARROUSEL DE REPAS (Fonctionnel, défiler gauche/droite) ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _PremiumMealCarousel(baseDate: DateTime.now()),
              ),
              const SizedBox(height: 32),

              // ── TITRE SECTION ────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('Ma liste de courses', style: AppTheme.titleMedium.copyWith(color: AppColors.textSecondary, fontSize: 14)),
              ),
              const SizedBox(height: 12),

              // ── LISTE DE COURSES COMPLÈTE ────────────
              const _PremiumShoppingCard(),
              const SizedBox(height: 16),

              // ── ACCÈS RAPIDE AUTRES SEMAINES ─────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickAccessTile(
                        icon: Icons.history,
                        color: AppColors.textSecondary,
                        label: 'Historique',
                        onTap: () => Navigator.pushNamed(context, '/history'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickAccessTile(
                        icon: Icons.next_plan_outlined,
                        color: AppColors.primaryGreen,
                        label: 'Semaine\nprochaine',
                        onTap: () => Navigator.pushNamed(context, '/next_week'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAccessTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _QuickAccessTile({required this.icon, required this.color, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 2,
                  softWrap: true,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
          ],
        ),
      ),
    );
  }
}
