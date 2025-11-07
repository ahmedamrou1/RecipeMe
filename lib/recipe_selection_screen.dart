import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'history_tab.dart';

class RecipeSelectionScreen extends StatefulWidget {
  final List<Map<String, dynamic>> recipes;
  final Map<String, String> updatedIngredients;

  const RecipeSelectionScreen({
    required this.recipes,
    required this.updatedIngredients,
    Key? key,
  }) : super(key: key);

  @override
  State<RecipeSelectionScreen> createState() => _RecipeSelectionScreenState();
}

class _RecipeSelectionScreenState extends State<RecipeSelectionScreen> {
  final Set<int> _selectedIndices = {};
  bool _isSaving = false;

  String _normalizeIngredients(dynamic rawIngredients, Map<String, String> updatedIngredients) {
    final List<String> normalizedIngredients = <String>[];
    
    if (rawIngredients is Map) {
      rawIngredients.forEach((k, v) {
        final qty = (v is Map && v.containsKey('quantity')) ? v['quantity'] : v;
        final qtyStr = (qty?.toString().trim() ?? '').isEmpty ? '' : qty.toString().trim();
        if (qtyStr.isNotEmpty) {
          normalizedIngredients.add('${k.toString()} ($qtyStr)');
        } else {
          normalizedIngredients.add(k.toString());
        }
      });
    } else if (rawIngredients is List) {
      for (final item in rawIngredients) {
        if (item is Map) {
          final name = (item['name'] ?? item['ingredient'] ?? (item.keys.isNotEmpty ? item.keys.first : '')).toString();
          if (name.isEmpty) continue;
          final qRaw = item['quantity'] ?? item['qty'] ?? updatedIngredients[name] ?? '';
          final qtyStr = qRaw.toString().trim().isEmpty ? '' : qRaw.toString();
          if (qtyStr.isNotEmpty) {
            normalizedIngredients.add('$name ($qtyStr)');
          } else {
            normalizedIngredients.add(name);
          }
        } else if (item is String) {
          final qtyStr = updatedIngredients[item] ?? '';
          if (qtyStr.isNotEmpty) {
            normalizedIngredients.add('$item ($qtyStr)');
          } else {
            normalizedIngredients.add(item);
          }
        } else {
          normalizedIngredients.add(item.toString());
        }
      }
    }
    
    return normalizedIngredients.join(', ');
  }

  List<String> _normalizeIngredientsList(dynamic rawIngredients, Map<String, String> updatedIngredients) {
    final List<String> normalizedIngredients = <String>[];
    
    if (rawIngredients is Map) {
      rawIngredients.forEach((k, v) {
        final qty = (v is Map && v.containsKey('quantity')) ? v['quantity'] : v;
        final qtyStr = (qty?.toString().trim() ?? '').isEmpty ? '' : qty.toString().trim();
        if (qtyStr.isNotEmpty) {
          normalizedIngredients.add('${k.toString()} ($qtyStr)');
        } else {
          normalizedIngredients.add(k.toString());
        }
      });
    } else if (rawIngredients is List) {
      for (final item in rawIngredients) {
        if (item is Map) {
          final name = (item['name'] ?? item['ingredient'] ?? (item.keys.isNotEmpty ? item.keys.first : '')).toString();
          if (name.isEmpty) continue;
          final qRaw = item['quantity'] ?? item['qty'] ?? updatedIngredients[name] ?? '';
          final qtyStr = qRaw.toString().trim().isEmpty ? '' : qRaw.toString();
          if (qtyStr.isNotEmpty) {
            normalizedIngredients.add('$name ($qtyStr)');
          } else {
            normalizedIngredients.add(name);
          }
        } else if (item is String) {
          final qtyStr = updatedIngredients[item] ?? '';
          if (qtyStr.isNotEmpty) {
            normalizedIngredients.add('$item ($qtyStr)');
          } else {
            normalizedIngredients.add(item);
          }
        } else {
          normalizedIngredients.add(item.toString());
        }
      }
    }
    
    return normalizedIngredients;
  }

  List<String> _normalizeDirections(dynamic rawDirections) {
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
    return directions;
  }

  Future<void> _saveSelectedRecipes() async {
    if (_selectedIndices.isEmpty) {
      // User selected nothing, just navigate to history
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => HistoryTab(),
            transitionDuration: Duration.zero,
          ),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw 'User not logged in';

      final List<Map<String, dynamic>> recipesToSave = [];
      
      for (final index in _selectedIndices) {
        if (index >= 0 && index < widget.recipes.length) {
          final recipe = widget.recipes[index];
          final String title = (recipe['title'] ?? '').toString();
          final String summary = (recipe['summary'] ?? '').toString();
          final dynamic rawIngredients = recipe['ingredients'];
          final dynamic rawDirections = recipe['directions'];

          if (title.isEmpty || rawIngredients == null || rawDirections == null) continue;

          final normalizedIngredients = _normalizeIngredientsList(rawIngredients, widget.updatedIngredients);
          final directions = _normalizeDirections(rawDirections);

          recipesToSave.add({
            'user_id': user.id,
            'title': title,
            'summary': summary,
            'ingredients': normalizedIngredients,
            'directions': directions,
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      }

      if (recipesToSave.isNotEmpty) {
        await supabase.from('recipes').insert(recipesToSave);
      }

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
      debugPrint('Error saving recipes: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving recipes: $e')),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF50C878),
      appBar: AppBar(
        title: const Text(
          'Select Recipes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: widget.recipes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final recipe = widget.recipes[index];
                        final String title = (recipe['title'] ?? '').toString();
                        final String summary = (recipe['summary'] ?? '').toString();
                        final isSelected = _selectedIndices.contains(index);

                        return Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedIndices.remove(index);
                                } else {
                                  _selectedIndices.add(index);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          _selectedIndices.add(index);
                                        } else {
                                          _selectedIndices.remove(index);
                                        }
                                      });
                                    },
                                    activeColor: const Color(0xFF50C878),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          summary,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
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
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: SafeArea(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF50C878),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _saveSelectedRecipes,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF50C878),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _selectedIndices.isEmpty
                                ? 'Continue (Save None)'
                                : 'Save ${_selectedIndices.length} Recipe${_selectedIndices.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

