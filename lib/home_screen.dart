import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'history_tab.dart';
import 'profile_page.dart';
import 'package:dart_openai/dart_openai.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'HomePage', home: MainPage());
  }
}

class Chatbot {
  final userMessage = OpenAIChatCompletionChoiceMessageModel(
    content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        "this is a test. tell me what you see in this image",
      ),

      //! image url contents are allowed only for models with image support such gpt-4.
      OpenAIChatCompletionChoiceMessageContentItemModel.imageUrl(
        "/recipeme/user_photos/image",
      ),
    ],
    role: OpenAIChatMessageRole.user,
  );

  // Add this method to call the OpenAI chat completion endpoint
  Future<OpenAIChatCompletionModel> createChatCompletion(
      ) async {
    final OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo-1106",
      responseFormat: {"type": "json_object"},
      seed: 6,
      messages: [userMessage],
      temperature: 0.2,
      maxTokens: 500,
    );
    return chatCompletion;
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 1; // Default to HomePage

  final _pages = [HistoryPage(), HomePage(), Center(child: Text('Profile Page'))];

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
            pageBuilder: (context, animation, secondaryAnimation) => HistoryTab(),
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
            pageBuilder: (context, animation, secondaryAnimation) => ProfilePage(),
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
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
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
      final url = "url";

      // Build message that contains the prompt and the base64 payload as text
      final requestMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            "Please describe the image linked below:",
          ),
          OpenAIChatCompletionChoiceMessageContentItemModel.imageUrl(
            url
            
          ),
        ],
        role: OpenAIChatMessageRole.user,
      );

      print('Sending request with image url size bytes: ${url}');

      // Call OpenAI and await result
      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo-1106",
        responseFormat: {"type": "json_object"},
        seed: 6,
        messages: [requestMessage],
        temperature: 0.2,
        maxTokens: 500,
      );

      print('OpenAI full response: $chatCompletion');

      try {
        final usage = chatCompletion.usage;
        print('Tokens - prompt: ${usage.promptTokens}, completion: ${usage.completionTokens}, total: ${usage.totalTokens}');
      } catch (e) {
        print('No usage info available: $e');
      }

      // Extract a readable string from the response (best-effort)
      String resultText = "";
      try {
        if (chatCompletion.choices.isNotEmpty) {
          final choice = chatCompletion.choices[0];
          final message = choice.message;
          final contents = message.content;
          if (contents != null && contents.isNotEmpty) {
            final textItem = contents.firstWhere(
              (c) => c.text != null && c.text!.isNotEmpty,
              orElse: () => contents.first,
            );
            resultText = textItem.text ?? choice.toString();
          } else {
            resultText = choice.toString();
          }
        } else {
          resultText = chatCompletion.toString();
        }
      } catch (_) {
        resultText = chatCompletion.toString();
      }

      // Clear preview and show result
      setState(() {
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OpenAI: ${resultText.length > 200 ? resultText.substring(0, 200) + "..." : resultText}'),
          backgroundColor: Colors.green,
        ),
      );
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
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Tips for Photos (i.e.\nmake sure area is well lit, all items visible)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
          // Camera and Choose Existing buttons positioned further down
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.10,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _pickImage,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, color: Colors.black87),
                          SizedBox(width: 8),
                          Text(
                            'Open Camera',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        try {
                          final XFile? image = await _picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 80,
                          );
                          if (image != null) {
                            setState(() {
                              _selectedImage = File(image.path);
                            });
                          }
                        } catch (e) {
                          print('Error picking existing image: $e');
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library, color: Colors.black87, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Choose Existing',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.contain,
                      ),
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

