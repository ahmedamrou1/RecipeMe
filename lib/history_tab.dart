import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'nav_bar.dart';
import 'home_screen.dart';
import 'profile_page.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _recipes = [];

  @override
  void initState() {
    super.initState();
    getUserRecipes();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => MainPage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => ProfilePage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
    }
  }

  Future<void> getUserRecipes() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      print('User not logged in');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await supabase
          .from('recipes')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        _recipes = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching recipes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading recipes')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String formatIngredients(dynamic raw) {
    if (raw == null) return 'No ingredients listed';
    try {
      var ing = raw;
      if (ing is String) {
        // sometimes stored as JSON string
        try {
          ing = jsonDecode(ing);
        } catch (_) {}
      }

      if (ing is Map) {
        final parts = <String>[];
        ing.forEach((k, v) {
          String qty;
          if (v is Map && v.containsKey('quantity')) qty = v['quantity'].toString();
          else qty = v?.toString() ?? '';
          if (qty.isNotEmpty) parts.add('• $k (${qty})');
          else parts.add('• $k');
        });
        return parts.join('\n');
      } else if (ing is List) {
        final parts = <String>[];
        for (var e in ing) {
          if (e is String) parts.add('• $e');
          else if (e is Map) {
            final name = e['name'] ?? e['ingredient'] ?? (e.keys.isNotEmpty ? e.keys.first : null);
            final qty = e['quantity'] ?? e['qty'] ?? '';
            if (name != null) {
              if (qty != null && qty.toString().isNotEmpty) parts.add('• ${name} (${qty})');
              else parts.add('• ${name}');
            }
          } else {
            parts.add('• ${e.toString()}');
          }
        }
        return parts.join('\n');
      }

      return raw.toString();
    } catch (e) {
      return raw.toString();
    }
  }

  String recipeImageUrl(Map<String, dynamic> recipe) {
    final link = recipe['link'] ?? recipe['image_url'] ?? recipe['image'] ?? null;
    if (link == null) return '';
    if (link is String) return link;
    try {
      return link.toString();
    } catch (_) {
      return '';
    }
  }

  Widget buildIngredientsWidget(dynamic raw) {
    if (raw == null) return const Text('No ingredients listed');

    var ing = raw;
    if (ing is String) {
      try {
        ing = jsonDecode(ing);
      } catch (_) {
        // leave as-is
      }
    }

    if (ing is Map) {
      // Legacy shape: map name -> qty
      final rows = <Widget>[];
      ing.forEach((k, v) {
        String qty;
        if (v is Map && v.containsKey('quantity')) qty = v['quantity'].toString();
        else qty = v?.toString() ?? '';
        final display = qty.isNotEmpty ? '$k ($qty)' : k.toString();
        rows.add(Text(display, style: const TextStyle(fontSize: 14)));
        rows.add(const SizedBox(height: 6));
      });
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
    } else if (ing is List) {
      final rows = <Widget>[];
      for (var e in ing) {
        if (e is String) {
          rows.add(Text(e, style: const TextStyle(fontSize: 14)));
        } else if (e is Map) {
          // Preferred shape: { 'name': 'Apple', 'quantity': '2', 'display': 'Apple (2)'}
          final display = e['display'] ?? (e['name'] != null ? (e['quantity'] != null ? '${e['name']} (${e['quantity']})' : e['name'].toString()) : e.toString());
          rows.add(Text(display.toString(), style: const TextStyle(fontSize: 14)));
        } else {
          rows.add(Text(e.toString(), style: const TextStyle(fontSize: 14)));
        }
        rows.add(const SizedBox(height: 6));
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
    }

    return Text(ing.toString());
  }

  void _openRecipeModal(Map<String, dynamic> recipe) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
    try {
      final directionsRaw = recipe['directions'];
      Widget directionsWidget;
      if (directionsRaw == null) {
        directionsWidget = const Text('No directions provided');
      } else if (directionsRaw is String) {
        directionsWidget = Text(directionsRaw);
      } else if (directionsRaw is List) {
        // Render each step on its own line
        final steps = <Widget>[];
        for (var i = 0; i < directionsRaw.length; i++) {
          final stepRaw = directionsRaw[i];
          String stepText;
          if (stepRaw == null) stepText = '';
          else if (stepRaw is String) stepText = stepRaw;
          else if (stepRaw is List) stepText = (stepRaw).map((e) => e.toString()).join(' ');
          else if (stepRaw is Map) stepText = stepRaw.values.map((e) => e.toString()).join(' ');
          else stepText = stepRaw.toString();

          steps.add(Text('${i + 1}. $stepText', style: const TextStyle(fontSize: 14)));
          steps.add(const SizedBox(height: 6));
        }
        directionsWidget = Column(crossAxisAlignment: CrossAxisAlignment.start, children: steps);
      } else {
        directionsWidget = Text(directionsRaw.toString());
      }

      return Dialog(
        backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe['title'] ?? 'Recipe',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recipe['summary'] ?? '',
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF50C878).withOpacity(0.35)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            recipeImageUrl(recipe).isNotEmpty
                                ? recipeImageUrl(recipe)
                                : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&h=300&fit=crop',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFF50C878).withOpacity(0.15),
                                child: const Center(child: Text('Image not available')),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Ingredients', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      buildIngredientsWidget(recipe['ingredients']),
                      const SizedBox(height: 12),
                      const Text('Directions', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      directionsWidget,
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                ),
              ),
            ],
          ),
      );
    } catch (e) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Unable to display recipe', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(e.toString()),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
          ]),
        ),
      );
    }
    },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF50C878),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _recipes.isEmpty
              ? const Center(
                  child: Text(
                    'No recipes found.',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: _recipes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final recipe = _recipes[index];
                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _openRecipeModal(recipe),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    recipeImageUrl(recipe).isNotEmpty
                                        ? recipeImageUrl(recipe)
                                        : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100&h=100&fit=crop',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.black.withOpacity(0.08),
                                        child: const Icon(Icons.restaurant, color: Colors.black87),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipe['title'] ?? '',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      recipe['summary'] ?? '',
                                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.black87),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: NavBar(
        currentIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
