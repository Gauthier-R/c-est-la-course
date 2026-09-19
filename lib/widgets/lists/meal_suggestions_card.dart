// 🍽️ Widget de suggestions de repas intelligentes — v3
// Design carte unifié pour Plats / Entrées / Desserts
// Plats : bouton Planifier (vert) + Voir recette (orange)
// Entrées/Desserts : bouton Voir recette (orange) uniquement
// Max 5 par section, bouton rafraîchissement, pagination circulaire
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recipe.dart';
import '../../providers/meal_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../screens/recipe_detail_screen.dart';
import 'package:intl/intl.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_theme.dart';
import '../../utils/recommendation_engine.dart';
import '../../utils/date_format.dart';

// ─── Constantes ────────────────────────────────────────────────────────────
const int _kPageSize   = 5;

class MealSuggestionsCard extends StatefulWidget {
  const MealSuggestionsCard({super.key});

  @override
  State<MealSuggestionsCard> createState() => _MealSuggestionsCardState();
}

class _MealSuggestionsCardState extends State<MealSuggestionsCard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;
  int _platOffset    = 0;
  int _entreeOffset  = 0;
  int _dessertOffset = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedTab = _tabController.index;
          _platOffset = _entreeOffset = _dessertOffset = 0;
        });
      }
    });
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  String get _season => MealRecommendationEngine.getCurrentSeason();
  Color get _seasonColor {
    switch (_season) {
      case 'Été': return const Color(0xFFF59E0B);
      case 'Hiver': return const Color(0xFF3B82F6);
      case 'Printemps': return const Color(0xFF10B981);
      default: return const Color(0xFFEF4444);
    }
  }
  IconData get _seasonIcon {
    switch (_season) {
      case 'Été': return Icons.wb_sunny_outlined;
      case 'Hiver': return Icons.ac_unit_outlined;
      case 'Printemps': return Icons.local_florist_outlined;
      default: return Icons.park_outlined;
    }
  }

  List<RecipeScore> _page(List<RecipeScore> all, int offset) {
    if (all.isEmpty) return [];
    final safeOffset = all.length <= _kPageSize ? 0 : (offset % all.length);
    final end = (safeOffset + _kPageSize).clamp(0, all.length);
    final slice = List<RecipeScore>.from(all.sublist(safeOffset, end));
    if (slice.length < _kPageSize && all.length > slice.length) {
      final missing = _kPageSize - slice.length;
      slice.addAll(all.sublist(0, missing.clamp(0, safeOffset)));
    }
    return slice;
  }

  void _refresh(String type) => setState(() {
    if (type == 'Plat')    _platOffset    = (_platOffset    + _kPageSize);
    if (type == 'Entrée')  _entreeOffset  = (_entreeOffset  + _kPageSize);
    if (type == 'Dessert') _dessertOffset = (_dessertOffset + _kPageSize);
  });

  @override
  Widget build(BuildContext context) {
    final recipes  = context.watch<RecipeProvider>().recipes;
    final meals    = context.watch<MealProvider>();
    final recipeHistory = MealRecommendationEngine.buildRecipeHistory(meals.cachedMeals);
    final isWE     = _selectedTab == 1;

    // Utilisation de la longueur totale de recettes par type pour permettre une rotation complète
    final platCount = recipes.where((r) => r.type == 'Plat').length;
    final entreeCount = recipes.where((r) => r.type == 'Entrée').length;
    final dessCount = recipes.where((r) => r.type == 'Dessert').length;

    final platAll   = MealRecommendationEngine.recommend(recipes: recipes, recipeHistory: recipeHistory, type: 'Plat',    isWeekend: isWE, topN: platCount > 0 ? platCount : 1);
    final entreeAll = MealRecommendationEngine.recommend(recipes: recipes, recipeHistory: recipeHistory, type: 'Entrée',  isWeekend: isWE, topN: entreeCount > 0 ? entreeCount : 1);
    final dessAll   = MealRecommendationEngine.recommend(recipes: recipes, recipeHistory: recipeHistory, type: 'Dessert', isWeekend: isWE, topN: dessCount > 0 ? dessCount : 1);

    final plats    = _page(platAll,   _platOffset);
    final entrees  = _page(entreeAll, _entreeOffset);
    final desserts = _page(dessAll,   _dessertOffset);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── HEADER ────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Icon(_seasonIcon, color: _seasonColor, size: 15),
              const SizedBox(width: 5),
              Text(_season, style: AppTheme.labelSmall.copyWith(color: _seasonColor, fontWeight: FontWeight.w700)),
              Text(' · basé sur vos recettes', style: AppTheme.labelSmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text('Suggestions pour vous', style: AppTheme.titleMedium.copyWith(fontSize: 18)),
        ),
        const SizedBox(height: 14),

        // ── ONGLETS ────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(10)),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: AppTheme.labelSmall.copyWith(fontWeight: FontWeight.w700, fontSize: 12),
              unselectedLabelStyle: AppTheme.labelSmall.copyWith(fontSize: 12),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: const [Tab(text: 'Cette semaine'), Tab(text: 'Ce week-end')],
            ),
          ),
        ),
        const SizedBox(height: 22),

        // ── PLATS ─────────────────────────────────────────────────────────
        if (recipes.any((r) => r.type == 'Plat')) ...[
          _SectionHeader(
            icon: Icons.restaurant_outlined,
            iconColor: AppColors.primaryOrange,
            title: 'Plats',
            badge: isWE ? 'Elaborés bienvenus' : 'Rapides favorisés',
            badgeColor: isWE ? AppColors.primaryOrange : AppColors.primaryGreen,
            canRefresh: platAll.length > _kPageSize,
            onRefresh: () => _refresh('Plat'),
          ),
          const SizedBox(height: 12),
          _CarouselSection(
            recs: plats,
            showPlanify: true,
            emptyMsg: 'Ajoutez des recettes "Plat" pour obtenir des suggestions',
          ),
          const SizedBox(height: 24),
        ],

        // ── ENTRÉES ────────────────────────────────────────────────────────
        if (recipes.any((r) => r.type == 'Entrée')) ...[
          _SectionHeader(
            icon: Icons.lunch_dining_outlined,
            iconColor: const Color(0xFF8B5CF6),
            title: 'Entrées',
            badge: 'Idées',
            badgeColor: const Color(0xFF8B5CF6),
            canRefresh: entreeAll.length > _kPageSize,
            onRefresh: () => _refresh('Entrée'),
          ),
          const SizedBox(height: 12),
          _CarouselSection(
            recs: entrees,
            showPlanify: false,
            emptyMsg: 'Aucune recette "Entrée" enregistrée',
          ),
          const SizedBox(height: 24),
        ],

        // ── DESSERTS ──────────────────────────────────────────────────────
        if (recipes.any((r) => r.type == 'Dessert')) ...[
          _SectionHeader(
            icon: Icons.cake_outlined,
            iconColor: const Color(0xFFEC4899),
            title: 'Desserts',
            badge: 'Idées',
            badgeColor: const Color(0xFFEC4899),
            canRefresh: dessAll.length > _kPageSize,
            onRefresh: () => _refresh('Dessert'),
          ),
          const SizedBox(height: 12),
          _CarouselSection(
            recs: desserts,
            showPlanify: false,
            emptyMsg: 'Aucune recette "Dessert" enregistrée',
          ),
          const SizedBox(height: 24),
        ],

        // ── Si aucune recette ──────────────────────────────────────────────
        if (recipes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
              ),
              child: Column(
                children: [
                  Icon(Icons.menu_book_outlined, size: 40, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('Aucune recette enregistrée',
                    style: AppTheme.bodyText.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
                  const SizedBox(height: 6),
                  Text('Ajoutez vos recettes dans l\'onglet "Mes Recettes" pour recevoir des suggestions personnalisées.',
                    style: AppTheme.labelSmall.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Carousel commun à toutes les sections ─────────────────────────────────
class _CarouselSection extends StatelessWidget {
  final List<RecipeScore> recs;
  final bool showPlanify;
  final String emptyMsg;

  const _CarouselSection({required this.recs, required this.showPlanify, required this.emptyMsg});

  @override
  Widget build(BuildContext context) {
    if (recs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Text(emptyMsg, style: AppTheme.labelSmall.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
        ),
      );
    }
    // Hauteur : image 88 + nom(42) + raison(18) + temps(18) + bouton(s) + padding
    // showPlanify = 2 boutons → hauteur 252 ; sinon 1 bouton → 220
    final height = showPlanify ? 252.0 : 220.0;
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: recs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) => _RecipeCard(scored: recs[i], showPlanify: showPlanify),
      ),
    );
  }
}

// ─── Carte de recette universelle ──────────────────────────────────────────
class _RecipeCard extends StatelessWidget {
  final RecipeScore scored;
  final bool showPlanify;

  const _RecipeCard({required this.scored, required this.showPlanify});

  Color _timeColor(String t) {
    final tl = t.toLowerCase();
    if (tl.contains('15')) return const Color(0xFF10B981);
    if (tl.contains('30')) return const Color(0xFF3B82F6);
    if (tl.startsWith('-')) return AppColors.primaryOrange;
    return const Color(0xFFEF4444);
  }

  IconData _timeIcon(String t) {
    final tl = t.toLowerCase();
    if (tl.contains('15')) return Icons.bolt_outlined;
    if (tl.contains('30')) return Icons.timer_outlined;
    return Icons.schedule_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final r = scored.recipe;
    final hasImg = r.imageBase64 != null && r.imageBase64!.isNotEmpty;
    final palettes = [
      [const Color(0xFFFEF3C7), const Color(0xFFD97706)],
      [const Color(0xFFD1FAE5), const Color(0xFF059669)],
      [const Color(0xFFDBEAFE), const Color(0xFF2563EB)],
      [const Color(0xFFFCE7F3), const Color(0xFFDB2777)],
      [const Color(0xFFEDE9FE), const Color(0xFF7C3AED)],
    ];
    final pal = palettes[r.name.length % palettes.length];

    return SizedBox(
      width: 152,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Image ───────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
                height: 88,
                child: hasImg
                    ? Image.memory(base64Decode(r.imageBase64!), fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(pal))
                    : _placeholder(pal),
              ),
            ),

            // ── Contenu texte ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.name,
                    style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w700, fontSize: 13, height: 1.1),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(scored.reason,
                    style: AppTheme.labelSmall.copyWith(color: AppColors.textSecondary, fontSize: 9, height: 1.1),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Row(children: [
                    Icon(_timeIcon(r.time), size: 11, color: _timeColor(r.time)),
                    const SizedBox(width: 3),
                    Text(r.time, style: AppTheme.labelSmall.copyWith(
                      color: _timeColor(r.time), fontWeight: FontWeight.w700, fontSize: 10)),
                  ]),
                ],
              ),
            ),

            const Spacer(),

            // ── Boutons ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
              child: Column(
                children: [
                  // Bouton Planifier (Plats uniquement)
                  if (showPlanify) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 28,
                      child: ElevatedButton.icon(
                        onPressed: () => _showPlanifyDialog(context, r),
                        icon: const Icon(Icons.calendar_today_outlined, size: 11),
                        label: const Text('Planifier'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.10),
                          foregroundColor: AppColors.primaryGreen,
                          elevation: 0, padding: EdgeInsets.zero,
                          textStyle: AppTheme.labelSmall.copyWith(fontWeight: FontWeight.w700, fontSize: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                  // Bouton Voir recette (toutes sections)
                  SizedBox(
                    width: double.infinity,
                    height: 28,
                    child: ElevatedButton.icon(
                      onPressed: () => _openRecipe(context, r),
                      icon: const Icon(Icons.open_in_new_rounded, size: 11),
                      label: const Text('Voir recette'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange.withValues(alpha: 0.10),
                        foregroundColor: AppColors.primaryOrange,
                        elevation: 0, padding: EdgeInsets.zero,
                        textStyle: AppTheme.labelSmall.copyWith(fontWeight: FontWeight.w700, fontSize: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(List<Color> pal) {
    return Container(
      color: pal[0],
      child: Center(child: Icon(Icons.restaurant_outlined, size: 30, color: pal[1].withValues(alpha: 0.4))),
    );
  }

  void _openRecipe(BuildContext context, Recipe recipe) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => RecipeDetailScreen(recipe: recipe),
    ));
  }

  Future<void> _showPlanifyDialog(BuildContext context, Recipe recipe) async {
    await showDialog(
      context: context,
      builder: (ctx) => _PlanifyDialog(recipe: recipe),
    );
  }
}

// ─── Header de section ─────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String badge;
  final Color badgeColor;
  final bool canRefresh;
  final VoidCallback onRefresh;

  const _SectionHeader({
    required this.icon, required this.iconColor,
    required this.title, required this.badge, required this.badgeColor,
    required this.canRefresh, required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 16),
      ),
      const SizedBox(width: 8),
      Text(title, style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(width: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: badgeColor.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(20)),
        child: Text(badge, style: AppTheme.labelSmall.copyWith(
          color: badgeColor, fontSize: 10, fontWeight: FontWeight.w600)),
      ),
      const Spacer(),
      if (canRefresh)
        IconButton(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded, size: 20),
          color: AppColors.textSecondary, tooltip: 'Autres suggestions',
          padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
    ]),
  );
}

// ─── Dialog de planification ───────────────────────────────────────────────
class _PlanifyDialog extends StatefulWidget {
  final Recipe recipe;
  const _PlanifyDialog({required this.recipe});

  @override
  State<_PlanifyDialog> createState() => _PlanifyDialogState();
}

class _PlanifyDialogState extends State<_PlanifyDialog> {
  DateTime? _selectedDate;
  String _moment = 'midi';
  bool _saving = false;
  bool _isLeftover = false;

  List<DateTime> _buildDays(int weekStartDay) {
    final now = DateTime.now();
    final startOfThisWeek = getWeekStart(now, weekStartDay);
    return List.generate(14, (i) => startOfThisWeek.add(Duration(days: i)));
  }

  static const _wd = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  static const _mo = ['jan', 'fév', 'mar', 'avr', 'mai', 'jun',
                       'jul', 'aoû', 'sep', 'oct', 'nov', 'déc'];

  @override
  Widget build(BuildContext context) {
    final mp = Provider.of<MealProvider>(context, listen: false);
    final days = _buildDays(mp.weekStartDay);
    final today = DateTime.now();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 30, offset: const Offset(0, 10))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.primaryGreen.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.calendar_month_outlined, color: AppColors.primaryGreen, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Planifier un repas', style: AppTheme.labelSmall.copyWith(color: AppColors.primaryGreen, fontWeight: FontWeight.w700)),
                    Text(widget.recipe.name,
                      style: AppTheme.titleMedium.copyWith(fontSize: 15),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                )),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey.shade400),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                ),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Choisir un jour', style: AppTheme.labelSmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  _WeekRow(label: 'Cette semaine', days: days.sublist(0, 7), today: today, selected: _selectedDate, wd: _wd, mo: _mo,
                    mealProvider: Provider.of<MealProvider>(context, listen: false),
                    onSelect: (d) => setState(() => _selectedDate = d)),
                  const SizedBox(height: 10),
                  _WeekRow(label: 'Semaine prochaine', days: days.sublist(7), today: today, selected: _selectedDate, wd: _wd, mo: _mo,
                    mealProvider: Provider.of<MealProvider>(context, listen: false),
                    onSelect: (d) => setState(() => _selectedDate = d)),
                  
                  const SizedBox(height: 24),
                  
                  // Sélecteur Reste
                  GestureDetector(
                    onTap: () => setState(() => _isLeftover = !_isLeftover),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isLeftover ? AppColors.primaryOrange.withValues(alpha: 0.1) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _isLeftover ? AppColors.primaryOrange : Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(_isLeftover ? Icons.check_circle : Icons.circle_outlined, 
                            color: _isLeftover ? AppColors.primaryOrange : Colors.grey.shade400),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('C\'est un reste', style: AppTheme.bodyText.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _isLeftover ? AppColors.primaryOrange : AppColors.textPrimary)),
                                Text('Les ingrédients ne seront pas ajoutés à la liste de courses.', 
                                  style: AppTheme.labelSmall.copyWith(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text('Moment du repas', style: AppTheme.labelSmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Builder(builder: (ctx) {
                    final mp = Provider.of<MealProvider>(ctx, listen: false);
                    final meals = _selectedDate != null ? mp.selectedMealsFor(_selectedDate!) : <String, String>{};
                    final hasMidi = (meals['midi'] ?? '').isNotEmpty;
                    final hasSoir = (meals['soir'] ?? '').isNotEmpty;
                    return Row(children: [
                      Expanded(child: _MomentTile(
                        icon: Icons.wb_sunny_outlined, label: 'Midi',
                        selected: _moment == 'midi', color: AppColors.primaryOrange,
                        hasMeal: hasMidi,
                        onTap: () => setState(() => _moment = 'midi'))),
                      const SizedBox(width: 12),
                      Expanded(child: _MomentTile(
                        icon: Icons.nightlight_outlined, label: 'Soir',
                        selected: _moment == 'soir', color: const Color(0xFF6366F1),
                        hasMeal: hasSoir,
                        onTap: () => setState(() => _moment = 'soir'))),
                    ]);
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, -4))],
              ),
              child: Row(children: [
                Expanded(child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    backgroundColor: Colors.grey.shade100,
                  ),
                  child: Text('Annuler', style: AppTheme.bodyText.copyWith(color: AppColors.textSecondary)),
                )),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: ElevatedButton(
                  onPressed: (_selectedDate == null || _saving) ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    disabledBackgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.white, elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                        _selectedDate == null ? 'Choisir un jour' : 'Planifier ce repas',
                        style: AppTheme.bodyText.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                )),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_selectedDate == null) return;
    setState(() => _saving = true);
    try {
      final mp = Provider.of<MealProvider>(context, listen: false);
      await mp.saveMeal(
        date: _selectedDate!,
        moment: _moment,
        meal: widget.recipe.name,
        ingredients: List<Map<String, dynamic>>.from(widget.recipe.ingredients),
        isLeftover: _isLeftover,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(
              '"${widget.recipe.name}" planifié le ${DateFormat('EEEE d MMMM', 'fr_FR').format(_selectedDate!)}',
              style: const TextStyle(color: Colors.white),
            )),
          ]),
          backgroundColor: AppColors.primaryGreen, behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ));
      }
    } catch (e) {
      setState(() => _saving = false);
    }
  }
}

// ─── Ligne de jours ─────────────────────────────────────────────────────────
class _WeekRow extends StatelessWidget {
  final String label;
  final List<DateTime> days;
  final DateTime today;
  final DateTime? selected;
  final List<String> wd;
  final List<String> mo;
  final MealProvider mealProvider;
  final ValueChanged<DateTime> onSelect;

  const _WeekRow({required this.label, required this.days, required this.today,
    required this.selected, required this.wd, required this.mo,
    required this.mealProvider, required this.onSelect});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTheme.labelSmall.copyWith(color: AppColors.textSecondary, fontSize: 10)),
      const SizedBox(height: 6),
      Row(children: days.map((d) {
        final isSel  = selected != null && d.year == selected!.year && d.month == selected!.month && d.day == selected!.day;
        final isToday= d.year == today.year && d.month == today.month && d.day == today.day;
        final isPast = d.isBefore(DateTime(today.year, today.month, today.day));
        final isDifferentMonth = d.month != today.month;
        final dotColor = mealProvider.getDotColor(d);
        
        return Expanded(child: GestureDetector(
          onTap: () => onSelect(d),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isSel ? AppColors.primaryGreen : isToday ? AppColors.primaryGreen.withValues(alpha: 0.08) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: isToday && !isSel ? Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.4), width: 1.5) : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(wd[d.weekday - 1], style: AppTheme.labelSmall.copyWith(
                  fontSize: 9, color: isSel ? Colors.white : (isPast ? Colors.grey.shade400 : AppColors.textSecondary))),
                const SizedBox(height: 2),
                Text('${d.day}${d.day == 1 || isDifferentMonth ? ' ${mo[d.month - 1]}' : ''}', 
                  style: AppTheme.bodyText.copyWith(
                    fontSize: d.day == 1 || isDifferentMonth ? 10 : 13, 
                    fontWeight: FontWeight.w700,
                    color: isSel ? Colors.white : (isPast ? Colors.grey.shade400 : AppColors.textPrimary))),
                const SizedBox(height: 3),
                // Pastille : visible seulement si non sélectionné pour ne pas confondre
                if (dotColor != null && !isSel)
                  Container(width: 5, height: 5,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor))
                else
                  const SizedBox(height: 5),
              ],
            ),
          ),
        ));
      }).toList()),
    ],
  );
}

// ─── Bouton Midi / Soir ────────────────────────────────────────────────────
class _MomentTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color color;
  final bool hasMeal;
  final VoidCallback onTap;

  const _MomentTile({required this.icon, required this.label,
    required this.selected, required this.color, required this.onTap,
    this.hasMeal = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: selected ? color : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: selected ? null : Border.all(color: Colors.grey.shade200),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 18, color: selected ? Colors.white : color),
            const SizedBox(width: 6),
            Text(label, style: AppTheme.bodyText.copyWith(
              color: selected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w700, fontSize: 14)),
          ]),
        ),
        // Badge "repas déjà planifié"
        if (hasMeal)
          Positioned(
            top: -5, right: -5,
            child: Container(
              width: 16, height: 16,
              decoration: BoxDecoration(
                color: selected ? Colors.white : color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4)],
              ),
              child: Center(child: Icon(Icons.check, size: 9,
                color: selected ? color : Colors.white)),
            ),
          ),
      ],
    ),
  );
}
