import 'package:flutter/material.dart';
import 'package:recipeme/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables first so keys are available
  await dotenv.load(fileName: ".env");

  // Diagnostics: ensure keys are present
  final supabaseKey = dotenv.env['SUPABASE_API_KEY'];
  final openaiApiKey = dotenv.env['OPENAI_API_KEY'];
  final supabaseURL = dotenv.env['SUPABASE_URL'];

  if (supabaseKey == null || supabaseKey.isEmpty) {
    // Helpful message during development — avoid crashing silently
    print('ERROR: SUPABASE_API_KEY not found in .env. Supabase will not initialize.');
  } else {
    try {
      await Supabase.initialize(
        url: supabaseURL!,
        anonKey: supabaseKey,
      );
      print('Supabase (not firebase !) initialized');
    } catch (e, st) {
      print('Supabase.initialize failed: $e');
      print(st);
    }
  }

  if (openaiApiKey == null || openaiApiKey.isEmpty) {
    print('WARNING: OPENAI_API_KEY not found in .env. OpenAI features will be disabled.');
  } else {
    OpenAI.apiKey = openaiApiKey;
  }
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
