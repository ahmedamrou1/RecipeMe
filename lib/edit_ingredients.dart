import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:recipeme/history_tab.dart';
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
        'quantity': TextEditingController(text: '1'),
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
      updatedIngredients[name] = qty.isEmpty ? '1' : qty;
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
You are an AI for a recipe app. Generate a single recipe using ONLY the ingredients provided in the user's inventory below.

User Profile:
- Skill Level: $skillLevel/10
- Favorite Cuisines: ${favoriteCuisines.isNotEmpty ? favoriteCuisines.join(', ') : 'None'}
- Allergies/Restrictions: ${allergies.isNotEmpty ? allergies.join(', ') : 'None'}
- Available Cooking Equipment: ${cookingEquipment.isNotEmpty ? cookingEquipment.join(', ') : 'Basic tools assumed'}

Inventory (JSON object of name -> quantity):
$inventoryJson

If the provided inventory does not contain enough ingredients to create a reasonable recipe, respond with the single token:
INSUFFICIENT_INGREDIENTS
Do not include any other text or formatting in that case.

Otherwise, strictly respond with JSON only (no markdown fences) in this schema:
{
  "title": "Recipe Title",
  "summary": "Short summary of the dish",
  "ingredients": [{"name": "ingredient", "quantity": "amount"}],
  "directions": ["Step 1", "Step 2", "Step 3"]
}

Rules:
- Only include ingredients that are actually used in the recipe (subset of the provided inventory).
- Tailor complexity to skill level; prefer favorite cuisines; avoid allergens; respect available equipment.
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
        'temperature': 0.6,
        'max_output_tokens': 600,
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

      final String title = (decoded['title'] ?? '').toString();
      final String summary = (decoded['summary'] ?? '').toString();
      final dynamic rawIngredients = decoded['ingredients'];
      final dynamic rawDirections = decoded['directions'];

      // Empty or missing fields -> show snackbar
      if (title.isEmpty || rawIngredients == null || rawDirections == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incomplete recipe from AI.')));
        return;
      }
      final bool noIngredients =
          (rawIngredients is List && rawIngredients.isEmpty) ||
          (rawIngredients is Map && rawIngredients.isEmpty);
      if (noIngredients) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not enough ingredients to generate a recipe. Add more items and try again.')),
        );
        return;
      }

      // Normalize ingredients to UI-friendly display strings: "Name (Qty)"
      final List<String> normalizedIngredients = <String>[];
      if (rawIngredients is Map) {
        rawIngredients.forEach((k, v) {
          final qty = (v is Map && v.containsKey('quantity')) ? v['quantity'] : v;
          final qtyStr = qty?.toString().trim().isEmpty == true ? '1' : qty.toString();
          normalizedIngredients.add('${k.toString()} ($qtyStr)');
        });
      } else if (rawIngredients is List) {
        for (final item in rawIngredients) {
          if (item is Map) {
            final name = (item['name'] ?? item['ingredient'] ?? (item.keys.isNotEmpty ? item.keys.first : '')).toString();
            if (name.isEmpty) continue;
            final qRaw = item['quantity'] ?? item['qty'] ?? updatedIngredients[name] ?? '1';
            final qtyStr = qRaw.toString().trim().isEmpty ? '1' : qRaw.toString();
            normalizedIngredients.add('$name ($qtyStr)');
          } else if (item is String) {
            final qtyStr = (updatedIngredients[item] ?? '1').toString();
            normalizedIngredients.add('$item ($qtyStr)');
          } else {
            normalizedIngredients.add('${item.toString()} (1)');
          }
        }
      }

      // Normalize directions to List<String>
      final List<String> directions = <String>[];
      if (rawDirections is String) {
        directions.add(rawDirections);
      } else if (rawDirections is List) {
        for (final d in rawDirections) {
          directions.add(d.toString());
        }
      } else {
        directions.add(rawDirections.toString());
      }

      // Insert recipe. Save only display strings for ingredients. Use user_id.
      await supabase.from('recipes').insert({
        'user_id': user.id,
        'title': title,
        'summary': summary,
        'ingredients': normalizedIngredients,
        'directions': directions,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => HistoryTab(),
            transitionDuration: Duration.zero,
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
      appBar: AppBar(
        title: const Text('Edit Ingredients'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final row = _items[index];
                        return Row(
                          children: [
                            Expanded(
                              flex: 6,
                              child: TextField(
                                controller: row['name'],
                                decoration: const InputDecoration(
                                  labelText: 'Ingredient',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: row['quantity'],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Qty',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () {
                                    setState(() {
                                      if (_items.length > 1) {
                                        final removed = _items.removeAt(index);
                                        removed['name']?.dispose();
                                        removed['quantity']?.dispose();
                                      } else {
                                        // clear the single remaining row
                                        _items[0]['name']?.text = '';
                                        _items[0]['quantity']?.text = '1';
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _items.add({
                                'name': TextEditingController(text: ''),
                                'quantity': TextEditingController(text: '1'),
                              });
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add ingredient'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _generateRecipe,
                          icon: const Icon(Icons.local_dining),
                          label: const Text('Generate Recipe'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
