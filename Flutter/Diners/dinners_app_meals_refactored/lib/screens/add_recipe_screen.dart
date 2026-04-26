import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../services/recipe_ocr_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';
import 'recipe_detail_screen.dart';

class AddRecipeScreen extends StatefulWidget {
  final Recipe? recipeToEdit;
  const AddRecipeScreen({super.key, this.recipeToEdit});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  String _type = 'Plat';
  String _season = 'Les deux';
  String _time = '- 1h';
  String? _imageBase64;
  final List<Map<String, dynamic>> _ingredients = [];
  bool _isScanning = false;

  final List<String> _types = ['Entrée', 'Plat', 'Dessert'];
  final List<String> _seasons = ['Été', 'Hiver', 'Les deux'];
  final List<String> _times = ['- 15 min', '- 1h', '+ 1h'];
  final List<String> _units = ['QT', 'g', 'kg', 'ml', 'cl', 'L', 'c.à.s', 'c.à.c', 'pincée'];

  final _nameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _ingredientNameCtrl = TextEditingController();
  final _ingredientQtyCtrl = TextEditingController();
  String _selectedUnit = 'QT';

  @override
  void initState() {
    super.initState();
    if (widget.recipeToEdit != null) {
      _nameCtrl.text = widget.recipeToEdit!.name;
      _type = widget.recipeToEdit!.type;
      _season = widget.recipeToEdit!.season;
      _time = widget.recipeToEdit!.time;
      _descriptionCtrl.text = widget.recipeToEdit!.description;
      _imageBase64 = widget.recipeToEdit!.imageBase64;
      _ingredients.addAll(List.from(widget.recipeToEdit!.ingredients));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _ingredientNameCtrl.dispose();
    _ingredientQtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 50, maxWidth: 600, maxHeight: 600);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => _imageBase64 = base64Encode(bytes));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur image : $e')));
    }
  }

  void _addIngredient() {
    if (_ingredientNameCtrl.text.trim().isEmpty) return;
    final qty = int.tryParse(_ingredientQtyCtrl.text.trim()) ?? 1;
    setState(() {
      _ingredients.add({'name': _ingredientNameCtrl.text.trim(), 'quantity': qty, 'unit': _selectedUnit});
    });
    _ingredientNameCtrl.clear();
    _ingredientQtyCtrl.clear();
    FocusScope.of(context).unfocus();
  }

  void _saveRecipe() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final newId = widget.recipeToEdit?.id ?? FirebaseFirestore.instance.collection('recipes').doc().id;
    final recipe = Recipe(
      id: newId,
      name: _nameCtrl.text.trim(),
      type: _type,
      season: _season,
      time: _time,
      description: _descriptionCtrl.text.trim(),
      imageBase64: _imageBase64,
      ingredients: _ingredients,
    );
    final provider = Provider.of<RecipeProvider>(context, listen: false);
    if (widget.recipeToEdit != null) {
      provider.updateRecipe(recipe);
      Navigator.of(context).pop();
    } else {
      provider.addRecipe(recipe);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)));
    }
  }

  Future<void> _deleteRecipe() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Supprimer la recette ?',
            style: AppTheme.titleMedium),
        content: Text(
          'Cette action est irréversible. La recette sera définitivement supprimée.',
          style: AppTheme.bodyText.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Annuler',
                style: AppTheme.bodyText.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: Text('Supprimer', style: AppTheme.bodyText.copyWith(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      Provider.of<RecipeProvider>(context, listen: false)
          .deleteRecipe(widget.recipeToEdit!.id);
      // Remonter à la liste des recettes (2 pages : detail écran + edit écran)
      Navigator.of(context).pop(); // ferme l'écran d'édition
      Navigator.of(context).pop(); // ferme l'écran de détail si présent
    }
  }

  /// Lance l'analyse Gemini : photos → IA → JSON → pré-remplissage des champs
  Future<void> _scanRecipeFromPhoto() async {
    // Affiche le choix : appareil photo ou galerie (multi-sélection)
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  'Scanner une recette papier',
                  style: AppTheme.titleMedium.copyWith(fontSize: 16),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_outlined,
                      color: AppColors.primaryGreen, size: 22),
                ),
                title: Text('Prendre une photo', style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text('Utiliser l\'appareil photo', style: AppTheme.bodyText.copyWith(color: AppColors.textSecondary, fontSize: 12)),
                onTap: () => Navigator.pop(ctx, 'camera'),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_outlined,
                      color: AppColors.primaryOrange, size: 22),
                ),
                title: Text('Choisir depuis la galerie', style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text('Sélectionner une ou plusieurs photos', style: AppTheme.bodyText.copyWith(color: AppColors.textSecondary, fontSize: 12)),
                onTap: () => Navigator.pop(ctx, 'gallery'),
              ),
            ],
          ),
        ),
      ),
    );

    if (choice == null || !mounted) return;

    List<File> imageFiles = [];

    try {
      if (choice == 'camera') {
        final pickedFile = await ImagePicker().pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
          maxWidth: 1600,
          maxHeight: 2000,
        );
        if (pickedFile == null || !mounted) return;
        imageFiles = [File(pickedFile.path)];
      } else {
        final pickedFiles = await ImagePicker().pickMultiImage(
          imageQuality: 85,
          maxWidth: 1600,
          maxHeight: 2000,
        );
        if (pickedFiles.isEmpty || !mounted) return;
        imageFiles = pickedFiles.map((f) => File(f.path)).toList();
      }

      setState(() => _isScanning = true);

      final result = await RecipeOcrService.analyze(imageFiles);

      if (!mounted) return;

      // Construire le résumé des champs détectés pour le feedback
      final detectedInfo = <String>[];

      setState(() {
        _isScanning = false;
        if (result.name != null && _nameCtrl.text.isEmpty) {
          _nameCtrl.text = result.name!;
          detectedInfo.add('nom');
        }
        if (result.description != null && _descriptionCtrl.text.isEmpty) {
          _descriptionCtrl.text = result.description!;
          detectedInfo.add('étapes');
        }
        if (result.time != null && _times.contains(result.time)) {
          _time = result.time!;
          detectedInfo.add('temps');
        }
        if (result.type != null && _types.contains(result.type)) {
          _type = result.type!;
          detectedInfo.add('type');
        }
        if (result.ingredients.isNotEmpty) {
          _ingredients.addAll(result.ingredients);
          detectedInfo.add('${result.ingredients.length} ingrédient(s)');
        }
      });

      debugPrint('📋 OCR: Champs remplis: ${detectedInfo.join(", ")}');

      final good = result.detectedFields >= 2;
      final photoCount = imageFiles.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            good
                ? '✅ ${photoCount > 1 ? "$photoCount photos analysées" : "Recette scannée"} ! Détecté : ${detectedInfo.join(", ")}.'
                : detectedInfo.isNotEmpty
                    ? '⚠️ Partiellement détecté (${detectedInfo.join(", ")}). Complétez le reste.'
                    : '⚠️ L\'IA n\'a rien pu lire. Essayez avec une photo mieux cadrée ou plus nette.',
          ),
          backgroundColor: good
              ? AppColors.primaryGreen
              : detectedInfo.isNotEmpty
                  ? Colors.orange.shade700
                  : Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isScanning = false);
      debugPrint('❌ Scan: Erreur complète: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'analyse : $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }


  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: AppTheme.labelSmall.copyWith(color: AppColors.textSecondary),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primaryOrange, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recipeToEdit != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(isEditing ? 'Modifier la recette' : 'Nouvelle recette', style: AppTheme.titleMedium),
        actions: [
          if (isEditing)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Tooltip(
                message: 'Supprimer la recette',
                child: InkWell(
                  onTap: _deleteRecipe,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red.shade500,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          if (!isEditing)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _isScanning
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryOrange),
                      ),
                    )
                  : Tooltip(
                      message: 'Scanner une recette papier',
                      child: InkWell(
                        onTap: _scanRecipeFromPhoto,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.document_scanner_outlined,
                            color: AppColors.primaryOrange,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── ZONE PHOTO ──────────────────────────────────────
              GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (_) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                        ListTile(
                          leading: const Icon(Icons.photo_library_outlined, color: AppColors.primaryOrange),
                          title: Text('Choisir dans la galerie', style: AppTheme.bodyText),
                          onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
                        ),
                        ListTile(
                          leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primaryGreen),
                          title: Text('Prendre une photo', style: AppTheme.bodyText),
                          onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                      image: _imageBase64 != null
                          ? DecorationImage(image: MemoryImage(base64Decode(_imageBase64!)), fit: BoxFit.cover)
                          : null,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
                    ),
                    child: _imageBase64 == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              Text('Ajouter une photo', style: AppTheme.bodyText.copyWith(color: AppColors.textSecondary)),
                            ],
                          )
                        : Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryOrange),
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionHeader('Informations'),
              const SizedBox(height: 12),

              // ── NOM ─────────────────────────────────────────────
              TextFormField(
                controller: _nameCtrl,
                style: AppTheme.bodyText,
                decoration: _inputDecoration('Nom du plat'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Ce champ est requis' : null,
              ),
              const SizedBox(height: 12),

              // ── TYPE & SAISON ────────────────────────────────────
              Row(
                children: [
                  Expanded(child: _buildDropdown('Type', _types, _type, (v) => setState(() => _type = v!))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDropdown('Saison', _seasons, _season, (v) => setState(() => _season = v!))),
                ],
              ),
              const SizedBox(height: 12),

              // ── TEMPS ────────────────────────────────────────────
              _buildDropdown('Temps de préparation', _times, _time, (v) => setState(() => _time = v!)),
              const SizedBox(height: 12),

              // ── DESCRIPTION ──────────────────────────────────────
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 5,
                style: AppTheme.bodyText,
                decoration: _inputDecoration('Étapes de préparation', hint: 'Décrivez comment préparer ce plat...'),
              ),

              const SizedBox(height: 28),
              _buildSectionHeader('Ingrédients'),
              const SizedBox(height: 12),

              // ── AJOUT INGRÉDIENT ─────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: _ingredientNameCtrl,
                        style: AppTheme.bodyText,
                        decoration: InputDecoration(
                          hintText: 'Ingrédient',
                          hintStyle: AppTheme.bodyText.copyWith(color: Colors.grey.shade400),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    Container(width: 1, height: 20, color: Colors.grey.shade200),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: _ingredientQtyCtrl,
                        keyboardType: TextInputType.number,
                        style: AppTheme.bodyText,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(hintText: '0', border: InputBorder.none, isDense: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedUnit,
                        isDense: true,
                        style: AppTheme.bodyText,
                        items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                        onChanged: (v) => setState(() => _selectedUnit = v!),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: _addIngredient,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: AppColors.primaryOrange, shape: BoxShape.circle),
                        child: const Icon(Icons.add, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── LISTE INGRÉDIENTS ────────────────────────────────
              if (_ingredients.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _ingredients.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100, indent: 20),
                    itemBuilder: (context, index) {
                      final ing = _ingredients[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        leading: Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle),
                        ),
                        title: Text(ing['name'], style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600)),
                        subtitle: Text('${ing["quantity"]} ${ing["unit"]}', style: AppTheme.labelSmall.copyWith(color: AppColors.textSecondary)),
                        trailing: GestureDetector(
                          onTap: () => setState(() => _ingredients.removeAt(index)),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                            child: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 18),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 32),

              // ── BOUTON ENREGISTRER ───────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: _saveRecipe,
                  child: Text(isEditing ? 'Enregistrer les modifications' : 'Créer la recette',
                    style: AppTheme.titleMedium.copyWith(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 20, decoration: BoxDecoration(color: AppColors.primaryOrange, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(title, style: AppTheme.titleMedium),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> options, String value, void Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: AppTheme.labelSmall.copyWith(color: AppColors.textSecondary),
            border: InputBorder.none,
            isDense: true,
          ),
          style: AppTheme.bodyText,
          items: options.map((e) => DropdownMenuItem(value: e, child: Text(e, style: AppTheme.bodyText))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
