import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(const RecipeMeApp());
}

class RecipeMeApp extends StatelessWidget {
  const RecipeMeApp({super.key});

  static const Color appGreen = Color(0xFF50C878);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RecipeMe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: appGreen,
          primary: appGreen,
          background: appGreen,
        ),
        scaffoldBackgroundColor: appGreen,
        appBarTheme: const AppBarTheme(backgroundColor: appGreen, elevation: 0),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
