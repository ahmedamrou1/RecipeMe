import 'package:flutter/material.dart';
import 'widgets/bottom_nav_bar.dart';
import 'history_tab.dart';
import 'profile_page.dart';

class HistoryTabEmpty extends StatefulWidget
{
  const HistoryTabEmpty({super.key});

  @override
  State<HistoryTabEmpty> createState() => _HistoryTabEmptyState();
}

class _HistoryTabEmptyState extends State<HistoryTabEmpty>
{
  int _currentIndex = 0; // History selected

  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
      backgroundColor: const Color(0xFF50C878),
      body: SafeArea
      (
        child: Column
        (
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children:
          [
            Padding
            (
              padding: const EdgeInsets.only(top: 16),
              child: Center
              (
                child: Text
                (
                  'RecipeMe',
                  style: TextStyle
                  (
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 54,
                    color: Colors.white,
                    shadows: 
                    [
                      Shadow
                      (
                        offset: Offset(2,2),
                        blurRadius: 6.0,
                        color: Colors.black54,
                      )
                    ]
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded
            (
              child: Container
              (
                decoration: BoxDecoration
                (
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column
                (
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:
                  [
                    const Text
                    (
                      'No Saved',
                      textAlign: TextAlign.center,
                      style: TextStyle
                      (
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text
                    (
                      'Recipes...Yet?',
                      textAlign: TextAlign.center,
                      style: TextStyle
                      (
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text
                    (
                      "Let's Get Cooking!",
                      textAlign: TextAlign.center,
                      style: TextStyle
                      (
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container
                    (
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration
                      (
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.35)),
                      ),
                      child: const Center
                      (
                        child: Text
                        (
                          'Image Placeholder',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Small button to navigate to history list
                    SizedBox(
                      height: 28,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          side: const BorderSide(color: Colors.white, width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const HistoryTab()),
                          );
                        },
                        child: const Text(
                          'View Recipes',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
            // Already on history empty
            setState(() { _currentIndex = 0; });
          }
          // i == 1 is Home; leaving unimplemented for now
        },
      ),
    );
  }
}


