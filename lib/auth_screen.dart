import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:recipeme/home_screen.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId:
      '679604839287-fsgkp1q3seji5k9gltju2vn7hdo8tpcd.apps.googleusercontent.com', // iOS client ID from Google Cloud Console
);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // allow scaffold to resize when keyboard appears
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'RecipeMe',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 54,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(2, 2),
                blurRadius: 6.0,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF50C878),
      // <-- REPLACED BODY START
      body: SafeArea(
        child: SingleChildScrollView(
          // ensure content lifts above the keyboard
          padding: EdgeInsets.fromLTRB(
            30,
            20,
            30,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // lets column shrink
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sign in or create an account',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Enter your email and password to sign in or create an account',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'email@domain.com',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        final emailRegex = RegExp(
                          r'^[a-zA-Z0-9.%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        );
                        if (!emailRegex.hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 26),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 26),

                    // Sign In button
                    SizedBox(
                      width: double.infinity,
                      height: 49,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              final credential = await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Signed in successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomePage(),
                                  ),
                                );
                              }
                            } on FirebaseAuthException catch (e) {
                              print(e.code);
                              String errorMessage = 'An error occurred';
                              if (e.code == 'invalid-credential') {
                                errorMessage =
                                    'Email or password invalid. Please try again.';
                              }
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMessage),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Sign in',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Add padding between buttons
                    const SizedBox(height: 16),

                    // Second button
                    SizedBox(
                      width: double.infinity,
                      height: 49,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              final credential = await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Account created successfully!',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomePage(),
                                  ),
                                );
                              }
                            } on FirebaseAuthException catch (e) {
                              String errorMessage = 'An error occurred';
                              if (e.code == 'weak-password') {
                                errorMessage =
                                    'The password provided is too weak.';
                              } else if (e.code == 'email-already-in-use') {
                                errorMessage =
                                    'An account already exists for that email. Try signing in.';
                              }
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMessage),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Horizontal divider with "or" text
                    Row(
                      children: const [
                        Expanded(
                          child: Divider(thickness: 1, color: Colors.black54),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(thickness: 1, color: Colors.black54),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Google Sign In button
                    SizedBox(
                      width: double.infinity,
                      height: 49,
                      child: SignInButton(
                        Buttons.Google,
                        text: "Sign in with Google",
                        onPressed: () async {
                          try {
                            final GoogleSignInAccount? googleUser =
                                await _googleSignIn.signIn();
                            if (googleUser == null) return;

                            final GoogleSignInAuthentication googleAuth =
                                await googleUser.authentication;
                            final credential = GoogleAuthProvider.credential(
                              accessToken: googleAuth.accessToken,
                              idToken: googleAuth.idToken,
                            );

                            await FirebaseAuth.instance.signInWithCredential(
                              credential,
                            );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Signed in with Google successfully!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomePage(),
                                ),
                              );
                            }
                          } catch (e) {
                            print(e);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Failed to sign in with Google',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      // <-- REPLACED BODY END
    );
  }
}
