import 'package:flutter/material.dart';
import 'profile_page.dart';

void main() 
{
  // Entry point of app
  runApp(const MyApp());
}

// Root widget of app
class MyApp extends StatelessWidget 
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp
    (
      title: 'Auth Page', // Title of app, not visible to users
      theme: ThemeData
      (
        primaryColor: const Color(0xFF50C878), // Custom app color
        scaffoldBackgroundColor: const Color(0xFF50C878) // Page background
      ),
      home: const LoginPage(), // First screen shown
    );
  }
}
// -------- Login Page --------
class LoginPage extends StatefulWidget 
{
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> 
{
  final _emailController = TextEditingController(); // To read email input
  final _formKey = GlobalKey<FormState>(); // For validating form fields

  @override
  void dispose() 
  {
    _emailController.dispose(); // Free memory when widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      // Top AppBar
      appBar: AppBar
      (
        title: const Text
        (
          'RecipeMe', // App title
          style: TextStyle
          (
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 54,
            color: Colors.white,
            shadows: 
            [
              Shadow // Shadow behind title
              (
                offset: Offset(2,2), // x, y offset
                blurRadius: 6.0, // Softness of shadow
                color: Colors.black54, // Color of shadow
              )
            ]
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Transparent background
        elevation: 0, // Remove drop shadow from AppBar
      ),
      
      backgroundColor: const Color(0xFF50C878), // Page background
      
      body: Center
      (
        child: Padding
        (
          padding: const EdgeInsets.all(30.0), // Space around the form
          child: Form
          (
            key: _formKey, // Connect validators to form
            child: Column
            (
              mainAxisAlignment: MainAxisAlignment.center,
              children: 
              [
                const Text
                (
                  'Create an account',
                  style: TextStyle
                  (
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                const Text
                (
                  'Enter your email to sign up for this app',
                  style: TextStyle
                  (
                    fontFamily: 'Inter',
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 26),

                // Email field
                TextFormField
                (
                  controller: _emailController,
                  decoration: InputDecoration
                  (
                    labelText: 'email@domain.com',
                    border: OutlineInputBorder
                    (
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white, // White box background
                  ),
                  validator: (value) 
                  {
                    // Validation logic for email
                    if (value == null || value.isEmpty) 
                    {
                      return 'Email is required';
                    }
                    final emailRegex =
                        RegExp(r'^[a-zA-Z0-9.%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                    if (!emailRegex.hasMatch(value)) 
                    {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 26),

                // Sign Up button
                SizedBox
                (
                  width: double.infinity,
                  height: 49,
                  child: ElevatedButton
                  (
                    onPressed:() 
                    {
                      if (_formKey.currentState!.validate()) 
                      {
                        // Navigate to Password Page
                        Navigator.push
                        (
                          context,
                          MaterialPageRoute
                          (
                            builder: (context) =>
                                PasswordPage(email: _emailController.text),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom
                    (
                      backgroundColor: Colors.black, // Button color
                      shape: RoundedRectangleBorder
                      (
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text
                    (
                      'Sign up with email',
                      style: TextStyle
                      (
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// -------- Password Page --------
class PasswordPage extends StatefulWidget 
{
  final String email; // Passed from LoginPage
  const PasswordPage({super.key, required this.email});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> 
{
  final _passwordController = TextEditingController(); // Read password input
  final _formKey = GlobalKey<FormState>(); // Valdatiing password form

  @override
  void dispose() 
  {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      // Top AppBar
  appBar: AppBar
  (
        title: const Text
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
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF50C878), // Background color
      body: Center
      (
        child: Padding
        (
          padding: const EdgeInsets.all(30.0),
          child: Form
          (
            key: _formKey,
            child: Column
            (
              mainAxisAlignment: MainAxisAlignment.center,
              children: 
              [
                const Text
                (
                  // Heading
                  'Finish Signing Up',
                  style: TextStyle
                  (
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.black,
                  ),
                ),
                // Subheading
                const Text
                (
                  'Create a password for your account',
                  style: TextStyle
                  (
                    fontFamily: 'Inter',
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 26),

                // Display email (read-only)
                TextFormField
                (
                  initialValue: widget.email,
                  readOnly: true,
                  decoration: InputDecoration
                  (
                    labelText: 'email@domain.com',
                    border: OutlineInputBorder
                    (
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 26),

                // Password input field
                TextFormField
                (
                  controller: _passwordController,
                  obscureText: true, // Hides password input
                  decoration: InputDecoration
                  (
                    labelText: 'password',
                    border: OutlineInputBorder
                    (
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) 
                  {
                    if (value == null || value.isEmpty) 
                    {
                      return 'Password is required';
                    }
                    if (value.length < 6) 
                    {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 26),

                // Create account button
                SizedBox
                (
                  width: double.infinity,
                  height: 49,
                  child: ElevatedButton
                  (
                    onPressed: () 
                    {
                      if (_formKey.currentState!.validate()) 
                      {
                        // TEMP: Navigate to ProfilePage after signup until backend hookup (remember to change once implemented on GitHub)
                        Navigator.pushReplacement
                        (
                          context,
                          MaterialPageRoute(builder: (_) => const ProfilePage()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom
                    (
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder
                      (
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text
                    (
                      'Create Account',
                      style: TextStyle
                      (
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}