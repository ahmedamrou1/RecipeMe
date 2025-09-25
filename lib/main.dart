import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:recipeme/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Firebase initialized');
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
