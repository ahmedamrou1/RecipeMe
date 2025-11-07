import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:recipeme/history_tab.dart';
import 'package:recipeme/recipe_selection_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditIngredientsPage extends StatefulWidget {
  final Map<String, dynamic> initialIngredients;

  const EditIngredientsPage({
    required this.initialIngredients,
    Key? key,
  }) : super(key: key);

  @override
  State<EditIngredientsPage> createState() => _EditIngredientsPageState();
}

class _EditIngredientsPageState extends State<EditIngredientsPage> {
  // Each row has a 'name' and 'quantity' controller
  late List<Map<String, TextEditingController>> _items;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _items = [];
    if (widget.initialIngredients.isNotEmpty) {
      for (var e in widget.initialIngredients.entries) {
        _items.add({
          'name': TextEditingController(text: e.key),
          'quantity': TextEditingController(text: e.value.toString()),
        });
      }
    } else {
      _items.add({
        'name': TextEditingController(text: ''),
        'quantity': TextEditingController(text: ''),
      });
    }
  }

  @override
  void dispose() {
    for (final row in _items) {
      row['name']?.dispose();
      row['quantity']?.dispose();
    }
    super.dispose();
  }

  Future<void> _generateRecipe() async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Missing OpenAI API key')));
      return;
    }

    // Collect updated ingredients: name -> qty
    final updatedIngredients = <String, String>{};
    for (final row in _items) {
      final name = row['name']?.text.trim() ?? '';
      final qty = row['quantity']?.text.trim() ?? '';
      if (name.isEmpty) continue;
      updatedIngredients[name] = qty.isEmpty ? '' : qty;
    }

    // Quick UX guard: require at least 2 items to generate a reasonable recipe
    if (updatedIngredients.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough ingredients to generate a recipe. Add more items and try again.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse('https://api.openai.com/v1/responses');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };

      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw 'User not logged in';

      // Fetch user profile data (for personalization)
      final profileResponse = await supabase
          .from('profiles')
          .select('skill_level, favorite_cuisines, allergies, cooking_equipment')
          .eq('id', user.id)
          .single();

      final int skillLevel = profileResponse['skill_level'] ?? 1;
      final List<String> favoriteCuisines =
          (profileResponse['favorite_cuisines'] is List) ? List<String>.from(profileResponse['favorite_cuisines']) : <String>[];
      final List<String> allergies =
          (profileResponse['allergies'] is List) ? List<String>.from(profileResponse['allergies']) : <String>[];
      final List<String> cookingEquipment =
          (profileResponse['cooking_equipment'] is List) ? List<String>.from(profileResponse['cooking_equipment']) : <String>[];

      // Build inventory JSON (name -> quantity) for the prompt
      final inventoryJson = jsonEncode(updatedIngredients);

      // Prompt: no image vision here. Only use provided inventory.
      // New rule: if not enough for a reasonable recipe, respond EXACTLY "INSUFFICIENT_INGREDIENTS" (no JSON).
      final prompt = '''
You are an AI for a recipe app. Generate 3-5 different recipe options using ONLY the ingredients provided in the user's inventory below.

User Profile:
- Skill Level: $skillLevel/10
- Favorite Cuisines: ${favoriteCuisines.isNotEmpty ? favoriteCuisines.join(', ') : 'None'}
- Allergies/Restrictions: ${allergies.isNotEmpty ? allergies.join(', ') : 'None'}
- Available Cooking Equipment: ${cookingEquipment.isNotEmpty ? cookingEquipment.join(', ') : 'Basic tools assumed'}

Inventory (JSON object of name -> quantity):
$inventoryJson

If the provided inventory does not contain enough ingredients to create reasonable recipes, respond with the single token:
INSUFFICIENT_INGREDIENTS
Do not include any other text or formatting in that case.

Otherwise, strictly respond with JSON only (no markdown fences) in this schema:
{
  "recipes": [
    {
      "title": "Recipe Title 1",
      "summary": "Short summary of the dish",
      "ingredients": [{"name": "ingredient", "quantity": "amount"}],
      "directions": ["Step 1", "Step 2", "Step 3"]
    },
    {
      "title": "Recipe Title 2",
      "summary": "Short summary of the dish",
      "ingredients": [{"name": "ingredient", "quantity": "amount"}],
      "directions": ["Step 1", "Step 2", "Step 3"]
    }
  ]
}

Rules:
- Generate 3-5 different recipe options that vary in style, cuisine, or cooking method.
- Only include ingredients that are actually used in each recipe (subset of the provided inventory).
- Tailor complexity to skill level; prefer favorite cuisines; avoid allergens; respect available equipment.
- Each recipe should be unique and offer variety.
''';

      final payload = {
        'model': 'gpt-4o-mini',
        'input': [
          {
            'role': 'user',
            'content': [
              {'type': 'input_text', 'text': prompt},
            ],
          },
        ],
        'temperature': 0.7,
        'max_output_tokens': 2000,
      };

      final response = await http.post(uri, headers: headers, body: jsonEncode(payload));
      if (response.statusCode != 200) {
        throw Exception('Failed: ${response.body}');
      }

      final data = jsonDecode(response.body);

      // Extract only output_text
      String result = '';
      final output = data['output'];
      if (output is List) {
        for (final item in output) {
          final content = item is Map ? item['content'] : null;
          if (content is List) {
            for (final c in content) {
              if (c is Map && c['type'] == 'output_text' && c['text'] is String) {
                result += c['text'] as String;
              }
            }
          }
        }
      }

      // Handle explicit insufficient-ingredients signal from the model
      final trimmed = result.trim();
      if (trimmed == 'INSUFFICIENT_INGREDIENTS') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Not enough ingredients to generate a recipe. Add more items and try again.')),
          );
        }
        return;
      }

      // Sanitize fences if present
      String sanitized = trimmed;
      if (sanitized.startsWith('```')) {
        final firstBrace = sanitized.indexOf(RegExp(r'[\[{]'));
        final lastBrace = sanitized.lastIndexOf(RegExp(r'[\]}]'));
        if (firstBrace != -1 && lastBrace != -1 && lastBrace >= firstBrace) {
          sanitized = sanitized.substring(firstBrace, lastBrace + 1);
        } else {
          sanitized = sanitized.replaceAll('```', '').trim();
        }
      } else {
        final firstBrace = sanitized.indexOf(RegExp(r'[\[{]'));
        final lastBrace = sanitized.lastIndexOf(RegExp(r'[\]}]'));
        if (firstBrace != -1 && lastBrace != -1 && lastBrace >= firstBrace) {
          sanitized = sanitized.substring(firstBrace, lastBrace + 1);
        }
      }

      final decoded = jsonDecode(sanitized);
      if (decoded is! Map<String, dynamic>) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unexpected AI response. Please try again.')));
        return;
      }

      // Check if response has a "recipes" array (multiple recipes) or single recipe format
      List<Map<String, dynamic>> recipesList = [];
      
      if (decoded.containsKey('recipes') && decoded['recipes'] is List) {
        // Multiple recipes format
        final rawRecipes = decoded['recipes'] as List;
        for (final recipe in rawRecipes) {
          if (recipe is Map<String, dynamic>) {
            final String title = (recipe['title'] ?? '').toString();
            final dynamic rawIngredients = recipe['ingredients'];
            final dynamic rawDirections = recipe['directions'];

            // Validate recipe has required fields
            if (title.isEmpty || rawIngredients == null || rawDirections == null) continue;
            
            final bool noIngredients =
                (rawIngredients is List && rawIngredients.isEmpty) ||
                (rawIngredients is Map && rawIngredients.isEmpty);
            if (noIngredients) continue;

            recipesList.add(recipe);
          }
        }
      } else {
        // Single recipe format (backward compatibility)
        final String title = (decoded['title'] ?? '').toString();
        final dynamic rawIngredients = decoded['ingredients'];
        final dynamic rawDirections = decoded['directions'];

        if (title.isNotEmpty && rawIngredients != null && rawDirections != null) {
          final bool noIngredients =
              (rawIngredients is List && rawIngredients.isEmpty) ||
              (rawIngredients is Map && rawIngredients.isEmpty);
          if (!noIngredients) {
            recipesList.add(decoded);
          }
        }
      }

      if (recipesList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No valid recipes generated. Please try again.')),
        );
        return;
      }

      // Navigate to recipe selection screen
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeSelectionScreen(
              recipes: recipesList,
              updatedIngredients: updatedIngredients,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error generating recipe: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating recipe: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF50C878),
      appBar: AppBar(
        title: const Text(
          'Edit Ingredients',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          itemCount: _items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final row = _items[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: TextField(
                                        controller: row['name'],
                                        decoration: InputDecoration(
                                          labelText: 'Ingredient',
                                          labelStyle: TextStyle(color: Colors.black87),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[50],
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: TextField(
                                        controller: row['quantity'],
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                          labelText: 'Quantity',
                                          hintText: 'e.g., 1 bushel',
                                          labelStyle: TextStyle(color: Colors.black87),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[50],
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 24),
                                      onPressed: () {
                                        setState(() {
                                          if (_items.length > 1) {
                                            final removed = _items.removeAt(index);
                                            removed['name']?.dispose();
                                            removed['quantity']?.dispose();
                                          } else {
                                            // clear the single remaining row
                                            _items[0]['name']?.text = '';
                                            _items[0]['quantity']?.text = '';
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _items.add({
                                      'name': TextEditingController(text: ''),
                                      'quantity': TextEditingController(text: ''),
                                    });
                                  });
                                },
                                icon: const Icon(Icons.add, color: Colors.black87),
                                label: const Text(
                                  'Add ingredient',
                                  style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _generateRecipe,
                                icon: const Icon(Icons.local_dining, color: Colors.white),
                                label: const Text(
                                  'Generate Recipe',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF50C878),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
