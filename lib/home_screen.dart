import 'dart:convert';
import 'edit_ingredients.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'history_tab.dart';
import 'profile_page.dart';
import 'package:http/http.dart' as http;
// compression removed
// ...existing code... (removed unused import)

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'HomePage', home: MainPage());
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 1; // Default to HomePage

  final _pages = [
    HistoryPage(),
    HomePage(),
    Center(child: Text('Profile Page')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
    // Handle navigation based on index - direct switching without animation
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                HistoryTab(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 1:
        // Already on home page
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ProfilePage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      ),
      backgroundColor: const Color(0xFF50C878),
      resizeToAvoidBottomInset: false,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // image compression removed

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _confirmImage() async {
    if (_selectedImage == null) return;

    try {
      final supabase = Supabase.instance.client;
      final apiKey = dotenv.env['OPENAI_API_KEY'];

      // Ensure we have a selected image file
      if (_selectedImage == null) {
        throw 'No image selected';
      }

      final uploadedPhoto = _selectedImage!;

      // Create a unique filename to avoid collisions
      final fileName =
          'user_photos/image_${DateTime.now().millisecondsSinceEpoch}.png';

      // Prepare a variable that will hold the publicly accessible URL of the uploaded image
      String url = '';

      try {
        final uploadResponse = await supabase.storage
            .from('images')
            .upload(
              fileName,
              uploadedPhoto,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
              ),
            );
        print('Upload response: $uploadResponse');

        // Build the public URL using the SUPABASE_URL environment variable.
        // This avoids depending on SDK return shapes and works for public buckets.
        final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
        if (supabaseUrl.isEmpty) {
          throw 'SUPABASE_URL not found in environment';
        }

        url = "https://substackcdn.com/image/fetch/\$s_!5MZ6!,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F20cf3c47-bf52-4db6-9255-6a843711eb9b_2723x3631.jpeg"; // $supabaseUrl/storage/v1/object/public/images/$fileName';
        print('Public URL: $url');
      } catch (e) {
        print('Supabase upload error: $e');
        rethrow;
      }

      // Prepare a container for the OpenAI textual result we will show later.
      String resultText = '';

      // Use the Responses API which supports multimodal inputs (text + images).
      // We send the image URL in the `image_url` field as an object: {"url": "..."}
      // Choose a vision-capable model. Set OPENAI_VISION_MODEL in .env to override.
      final visionModel = 'gpt-4o-mini';
      if (apiKey == null || apiKey.isEmpty) {
        throw 'OPENAI_API_KEY not set in environment';
      }

      // Build request pieces for readability and send to Responses API
      final uri = Uri.parse('https://api.openai.com/v1/responses');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };

      final payload = {
        'model': visionModel,
        'input': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'input_text',
                'text':
                    'You are the AI for a recipe generation app. You are to classify each of the items in this image of fridge. Respond with a JSON structured {item1: quantity, item2: quantity}. If the image is not clear enough, respond with 0 (no json).',
              },
              {'type': 'input_image', 'image_url': url},
            ],
          },
        ],
        'temperature': 0.2,
      };

      final body = jsonEncode(payload);
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to generate response: ${response.statusCode} ${response.body}',
        );
      }

      final data = jsonDecode(response.body);
      print(data);

      // Responses API returns an 'output' array with mixed content. Extract
      // textual pieces (type: output_text) and concatenate them.
      String extracted = '';
      try {
        final output = data['output'];
        if (output is List && output.isNotEmpty) {
          for (final item in output) {
            if (item is Map && item['content'] is List) {
              for (final c in item['content']) {
                if (c is Map &&
                    c['type'] == 'output_text' &&
                    c['text'] != null) {
                  extracted += c['text'].toString();
                } else if (c is String) {
                  extracted += c;
                }
              }
            } else if (item is String) {
              extracted += item;
            }
          }
        }
      } catch (e) {
        print('Failed to parse Responses output: $e');
      }

      resultText = extracted.isNotEmpty ? extracted : data.toString();
      // Print only the extracted textual output from the model to reduce logs
      print('OpenAI output: $resultText');
      final _resultTrim = resultText.trim();
      if (_resultTrim == '0' || _resultTrim.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Image is not clear enough. Try taking a clearer photo.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        // Best-effort cleanup of the uploaded file
        try {
          await supabase.storage.from('images').remove([fileName]);
        } catch (e) {
          print('Failed to delete uploaded file after unclear image: $e');
        }

        // Clear preview and return early
        if (context.mounted) {
          setState(() {
            _selectedImage = null;
          });
        }
        return;
      }

      try {
        // Accept several possible shapes from the AI and normalize into
        // Map<String, dynamic> where each key is the ingredient name and
        // the value is the quantity (as a String). Example accepted shapes:
        // 1) { "apples": {"quantity": 3}, ... }
        // 2) { "apples": 3, ... }
        // 3) ["apples", "oranges"]
        // 4) [{"name":"apples","quantity":3}, ...]
        // Sanitize AI output: strip markdown fences and any surrounding text
        // so `jsonDecode` gets a clean JSON string. AI often returns:
        // ```json\n{...}\n```
        String sanitized = resultText.trim();

        // If the model returned a fenced block, remove the fences and language tag
        if (sanitized.startsWith('```')) {
          // remove leading ```... and trailing ``` if present
          // e.g. ```json\n{...}\n``` -> { ... }
          // Find first brace after the fence
          final firstBrace = sanitized.indexOf(RegExp(r'[\[{]'));
          final lastBrace = sanitized.lastIndexOf(RegExp(r'[\]}]'));
          if (firstBrace != -1 && lastBrace != -1 && lastBrace >= firstBrace) {
            sanitized = sanitized.substring(firstBrace, lastBrace + 1);
          } else {
            // fallback: strip backticks
            sanitized = sanitized.replaceAll('```', '');
          }
        } else {
          // Also attempt to extract the first JSON-looking substring if there is
          // surrounding explanatory text.
          final firstBrace = sanitized.indexOf(RegExp(r'[\[{]'));
          final lastBrace = sanitized.lastIndexOf(RegExp(r'[\]}]'));
          if (firstBrace != -1 && lastBrace != -1 && lastBrace >= firstBrace) {
            sanitized = sanitized.substring(firstBrace, lastBrace + 1);
          }
        }

        final parsed = jsonDecode(sanitized);
        final Map<String, dynamic> normalized = {};

        if (parsed is Map) {
          parsed.forEach((key, value) {
            if (value is Map && value.containsKey('quantity')) {
              normalized[key.toString()] = value['quantity'].toString();
            } else if (value is num || value is String) {
              normalized[key.toString()] = value.toString();
            } else {
              // Fallback to string representation
              normalized[key.toString()] = value?.toString() ?? '';
            }
          });
        } else if (parsed is List) {
          for (final item in parsed) {
            if (item is String) {
              normalized[item] = '1';
            } else if (item is Map) {
              final name = item['name'] ?? item['ingredient'] ?? item.keys.isNotEmpty ? item.keys.first : null;
              final qty = item['quantity'] ?? item['qty'] ?? '1';
              if (name != null) normalized[name.toString()] = qty.toString();
            }
          }
        } else {
          throw 'Unexpected ingredients JSON structure';
        }

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditIngredientsPage(
                initialIngredients: normalized,
                imageUrl: url,
              ),
            ),
          );
        }
      } catch (e) {
        print('Invalid JSON format from AI: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to parse ingredients from AI')),
        );
      }
    } catch (e, st) {
      print('Error sending image to OpenAI: $e');
      print(st);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to read/send image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _cancelImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tips for Photos (i.e.\nmake sure area is well lit, all items visible)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 1,
                        color: Colors.black45,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
          // Camera button positioned further down
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.camera_alt, size: 40, color: Colors.black),
                  onPressed: _pickImage,
                ),
              ),
            ),
          ),
          // Image preview overlay
          if (_selectedImage != null)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      margin: EdgeInsets.all(20),
                      child: Image.file(_selectedImage!, fit: BoxFit.contain),
                    ),
                  ),
                  // Confirm button at bottom
                  Positioned(
                    bottom: 100,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Cancel button
                        Container(
                          width: 120,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _cancelImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        // Confirm button
                        Container(
                          width: 120,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _confirmImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
                              'Confirm',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('History Page'));
  }
}
