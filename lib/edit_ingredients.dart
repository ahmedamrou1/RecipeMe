import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:recipeme/history_tab.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditIngredientsPage extends StatefulWidget {
  final Map<String, dynamic> initialIngredients;
  final String imageUrl;

  const EditIngredientsPage({
    required this.initialIngredients,
    required this.imageUrl,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing OpenAI API key')),
      );
      return;
    }

    // Collect updated ingredients
    final updatedIngredients = <String, String>{};
    for (final row in _items) {
      final name = row['name']?.text.trim() ?? '';
      final qty = row['quantity']?.text.trim() ?? '';
      if (name.isEmpty) continue;
      updatedIngredients[name] = qty.isEmpty ? '1' : qty;
    }

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse('https://api.openai.com/v1/responses');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };

      final prompt = '''
You are an expert chef AI. Using ONLY the following available ingredients and their quantities, generate a single recipe and respond with ONLY a JSON object (no prose) matching this exact structure:

{
  "title": "String",
  "summary": "Short summary of the dish",
  "ingredients": [{"name": "ingredient", "quantity": "amount"}],
  "directions": ["Step 1", "Step 2", "Step 3"],
}

Requirements:
- The "ingredients" array MUST contain only the ingredients that are actually used in the recipe (do NOT include other items present in the fridge).
- Quantities should be concise (e.g., "2", "1 cup", "2 slices").

Available ingredients (name -> quantity): $updatedIngredients

Return strictly valid JSON and nothing else (no markdown fences). If you cannot create a recipe, return a JSON object with an "error" field describing the reason.
''';

      final payload = {
        'model': 'gpt-4o-mini',
        'input': [
          {
            'role': 'user',
            'content': [
              {'type': 'input_text', 'text': prompt},
            ]
          }
        ],
        'temperature': 0.6,
        'max_output_tokens': 600,
      };

      final response = await http.post(uri, headers: headers, body: jsonEncode(payload));
      if (response.statusCode != 200) {
        throw Exception('Failed: ${response.body}');
      }

      final data = jsonDecode(response.body);

      // Extract text response
      String result = '';
      if (data['output'] is List) {
        for (final item in data['output']) {
          if (item['content'] is List) {
            for (final c in item['content']) {
              if (c['type'] == 'output_text') result += c['text'];
            }
          }
        }
      }

      // Sanitize AI output: strip markdown fences and surrounding text so
      // `jsonDecode` receives a clean JSON string. The model often returns
      // ```json\n{...}\n``` which causes jsonDecode to throw.
      String sanitized = result.trim();
      if (sanitized.startsWith('```')) {
        final firstBrace = sanitized.indexOf(RegExp(r'[\[{]'));
        final lastBrace = sanitized.lastIndexOf(RegExp(r'[\]}]'));
        if (firstBrace != -1 && lastBrace != -1 && lastBrace >= firstBrace) {
          sanitized = sanitized.substring(firstBrace, lastBrace + 1);
        } else {
          sanitized = sanitized.replaceAll('```', '');
        }
      } else {
        final firstBrace = sanitized.indexOf(RegExp(r'[\[{]'));
        final lastBrace = sanitized.lastIndexOf(RegExp(r'[\]}]'));
        if (firstBrace != -1 && lastBrace != -1 && lastBrace >= firstBrace) {
          sanitized = sanitized.substring(firstBrace, lastBrace + 1);
        }
      }

      final recipe = jsonDecode(sanitized);

      // Save recipe to Supabase
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw 'User not logged in';

      // Normalize returned ingredients into a List<Map{name,quantity}>
      final rawIngredients = recipe['ingredients'];
      final List<String> normalizedIngredients = [];
      if (rawIngredients is Map) {
        rawIngredients.forEach((k, v) {
          final qty = v is Map && v.containsKey('quantity') ? v['quantity'] : v;
          final qtyStr = qty?.toString() ?? '';
          normalizedIngredients.add("${k.toString()} ($qtyStr)");
        });
      } else if (rawIngredients is List) {
        for (final item in rawIngredients) {
          if (item is String) {
            final qty = updatedIngredients[item] ?? '1';
            normalizedIngredients.add("$item $qty");
          } else if (item is Map) {
            final name = item['name'] ?? item['ingredient'] ?? (item.keys.isNotEmpty ? item.keys.first : null);
            final qtyRaw = item['quantity'] ?? item['qty'] ?? (name != null ? updatedIngredients[name] ?? '1' : '1');
            final qty = qtyRaw?.toString() ?? '';
            normalizedIngredients.add("${name.toString()} ($qty)");
          } else {
            final s = item.toString();
            normalizedIngredients.add("$s (1)");
          }
        }
      }


      await supabase.from('recipes').insert({
        'user_id': user.id,
        'title': recipe['title'],
        'summary': recipe['summary'],
        'ingredients': normalizedIngredients,
        'directions': recipe['directions'],
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
      print('Error generating recipe: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating recipe: $e')),
      );
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
