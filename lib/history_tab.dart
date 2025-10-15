import 'package:flutter/material.dart';
import 'widgets/bottom_nav_bar.dart';
import 'profile_page.dart';
import 'history_tab_empty.dart';

class HistoryTab extends StatefulWidget
{
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab>
{
  int _currentIndex = 0; // History selected

  final List<Map<String, String>> _recipes = const
  [
    { 'title': 'Avocado Toast', 'summary': 'Crispy toast with smashed avocado' },
    { 'title': 'Pesto Pasta', 'summary': 'Basil pesto with al dente pasta' },
    { 'title': 'Berry Smoothie', 'summary': 'Mixed berries and yogurt' },
    { 'title': 'Veggie Omelette', 'summary': 'Fluffy eggs with veggies' },
  ];

  void _openRecipeModal(Map<String, String> recipe)
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
                        color: const Color(0xFF50C878).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF50C878).withOpacity(0.35)),
                      ),
                      child: const Center(child: Text('Recipe Image Placeholder')),
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
                        color: Colors.black.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.restaurant, color: Colors.black87),
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
      bottomNavigationBar: RecipeMeBottomNavBar
      (
        currentIndex: _currentIndex,
        onTap: (i)
        {
          if (i == 2)
          {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
          }
          else if (i == 0)
          {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HistoryTabEmpty()));
          }
          // i == 1 is Home; leaving unimplemented for now
        },
      ),
    );
  }
}


