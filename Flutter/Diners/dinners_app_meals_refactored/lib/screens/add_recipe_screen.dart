import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../utils/app_colors.dart';
import '../utils/responsive_helper.dart';
import 'recipe_detail_screen.dart';

class AddRecipeScreen extends StatefulWidget {
  final Recipe? recipeToEdit; // Optionnel : si on modifie une recette existante
  const AddRecipeScreen({super.key, this.recipeToEdit});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _name = '';
  String _type = 'Plat';
  String _season = 'Les deux';
  String _time = '- 1h';
  String _description = '';
  String? _imageBase64;

  final List<Map<String, dynamic>> _ingredients = [];

  final List<String> _types = ['Entrée', 'Plat', 'Dessert'];
  final List<String> _seasons = ['Été', 'Hiver', 'Les deux'];
  final List<String> _times = ['- 15 min', '- 1h', '+ 1h'];
  final List<String> _units = ['QT', 'g', 'kg', 'ml', 'cl', 'L', 'c.à.s', 'c.à.c', 'pincée'];

  final _ingredientNameController = TextEditingController();
  final _ingredientQtyController = TextEditingController();
  String _selectedIngredientUnit = 'QT';

  @override
  void initState() {
    super.initState();
    if (widget.recipeToEdit != null) {
      _name = widget.recipeToEdit!.name;
      _type = widget.recipeToEdit!.type;
      _season = widget.recipeToEdit!.season;
      _time = widget.recipeToEdit!.time;
      _description = widget.recipeToEdit!.description;
      _imageBase64 = widget.recipeToEdit!.imageBase64;
      _ingredients.addAll(List.from(widget.recipeToEdit!.ingredients));
    }
  }

  @override
  void dispose() {
    _ingredientNameController.dispose();
    _ingredientQtyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 50, // Compression agressive pour Firestore
        maxWidth: 400,
        maxHeight: 400,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la capture de l\'image: \$e')),
      );
    }
  }

  void _addIngredient() {
    if (_ingredientNameController.text.trim().isEmpty) return;
    final qty = int.tryParse(_ingredientQtyController.text.trim()) ?? 1;

    setState(() {
      _ingredients.add({
        'name': _ingredientNameController.text.trim(),
        'quantity': qty,
        'unit': _selectedIngredientUnit,
      });
    });

    _ingredientNameController.clear();
    _ingredientQtyController.clear();
    FocusScope.of(context).unfocus();
  }

  void _saveRecipe() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final newId = widget.recipeToEdit?.id ?? FirebaseFirestore.instance.collection('recipes').doc().id;

    final recipe = Recipe(
      id: newId,
      name: _name,
      type: _type,
      season: _season,
      time: _time,
      description: _description,
      imageBase64: _imageBase64,
      ingredients: _ingredients,
    );

    final provider = Provider.of<RecipeProvider>(context, listen: false);
    if (widget.recipeToEdit != null) {
      provider.updateRecipe(recipe);
      Navigator.of(context).pop();
    } else {
      provider.addRecipe(recipe);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.recipeToEdit == null ? "Nouvelle Recette" : "Modifier la Recette", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryOrange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveHelper.widthPercent(context, 0.05)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Zone Photo
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Galerie'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.gallery);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('Caméra'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.camera);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                      image: _imageBase64 != null
                          ? DecorationImage(
                              image: MemoryImage(base64Decode(_imageBase64!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _imageBase64 == null
                        ? const Center(child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey))
                        : null,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.heightPercent(context, 0.03)),
                
                // Nom de la recette
                TextFormField(
                  initialValue: _name,
                  decoration: InputDecoration(
                    labelText: 'Nom du plat',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Requis' : null,
                  onSaved: (value) => _name = value!.trim(),
                ),
                SizedBox(height: ResponsiveHelper.heightPercent(context, 0.02)),

                // Type et Saison
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Type', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                        initialValue: _type,
                        items: _types.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) => setState(() => _type = val!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Saison', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                        initialValue: _season,
                        items: _seasons.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) => setState(() => _season = val!),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveHelper.heightPercent(context, 0.02)),

                // Temps
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Temps de préparation', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  initialValue: _time,
                  items: _times.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => _time = val!),
                ),
                SizedBox(height: ResponsiveHelper.heightPercent(context, 0.02)),

                // Description
                TextFormField(
                  initialValue: _description,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Étapes de préparation',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onSaved: (value) => _description = value?.trim() ?? '',
                ),
                SizedBox(height: ResponsiveHelper.heightPercent(context, 0.03)),

                // Ingrédients
                const Text('Ingrédients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _ingredientNameController,
                        decoration: const InputDecoration(hintText: 'Ingrédient'),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: _ingredientQtyController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Qt', contentPadding: EdgeInsets.symmetric(horizontal: 5)),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 2,
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedIngredientUnit,
                        items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (val) => setState(() => _selectedIngredientUnit = val!),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: AppColors.primaryOrange, size: 30),
                      onPressed: _addIngredient,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                
                // Liste des ingrédients ajoutés
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _ingredients.length,
                  itemBuilder: (context, index) {
                    final ing = _ingredients[index];
                    return ListTile(
                      dense: true,
                      title: Text(ing['name']),
                      subtitle: Text('${ing["quantity"]} ${ing["unit"]}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _ingredients.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
                
                SizedBox(height: ResponsiveHelper.heightPercent(context, 0.04)),
                
                // Bouton Save
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _saveRecipe,
                  child: const Text('Enregistrer la recette', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
