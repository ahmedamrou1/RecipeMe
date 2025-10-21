import 'package:flutter/material.dart';
import 'nav_bar.dart';
import 'home_screen.dart';
import 'profile_page.dart';

class HistoryTab extends StatefulWidget
{
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab>
{
  int _selectedIndex = 0; // History tab is selected

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation based on index - direct switching without animation
    switch (index) {
      case 0:
        // Already on history page
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

  final List<Map<String, dynamic>> _recipes = const
  [
    { 
      'title': 'Avocado Toast', 
      'summary': 'Crispy toast with smashed avocado',
      'image': 'https://images.unsplash.com/photo-1541519227354-08fa5d50c44d?w=400&h=300&fit=crop',
    },
    { 
      'title': 'Pesto Pasta', 
      'summary': 'Basil pesto with al dente pasta',
      'image': 'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=400&h=300&fit=crop',
    },
    { 
      'title': 'Berry Smoothie', 
      'summary': 'Mixed berries and yogurt',
      'image': 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=400&h=300&fit=crop',
    },
    { 
      'title': 'Veggie Omelette', 
      'summary': 'Fluffy eggs with veggies',
      'image': 'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=400&h=300&fit=crop',
    },
  ];

  void _openRecipeModal(Map<String, dynamic> recipe)
  {
    showDialog
    (
      context: context,
      barrierDismissible: true,
      builder: (context)
      {
        return Dialog
        (
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Stack
          (
            children:
            [
              Padding
              (
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Column
                (
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                  [
                    Text
                    (
                      recipe['title'] ?? 'Recipe',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text
                    (
                      recipe['summary'] ?? '',
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    Container
                    (
                      height: 140,
                      decoration: BoxDecoration
                      (
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF50C878).withOpacity(0.35)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          recipe['image'] ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&h=300&fit=crop',
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
                    const Text('• Item 1\n• Item 2\n• Item 3'),
                    const SizedBox(height: 12),
                    const Text('Directions', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    const Text('1. Step one\n2. Step two\n3. Step three'),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              Positioned
              (
                right: 8,
                top: 8,
                child: IconButton
                (
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
      backgroundColor: const Color(0xFF50C878),
      appBar: AppBar
      (
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: ListView.separated
      (
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: _recipes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index)
        {
          final recipe = _recipes[index];
          return Material
          (
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell
            (
              borderRadius: BorderRadius.circular(12),
              onTap: () => _openRecipeModal(recipe),
              child: Container
              (
                padding: const EdgeInsets.all(14),
                child: Row
                (
                  children:
                  [
                    Container
                    (
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration
                      (
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          recipe['image'] ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100&h=100&fit=crop',
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
                    Expanded
                    (
                      child: Column
                      (
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                        [
                          Text
                          (
                            recipe['title'] ?? '',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text
                          (
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


