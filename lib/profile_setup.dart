import 'package:flutter/material.dart';
import 'package:recipeme/home_screen.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Class to hold all profile data
class UserProfile {
  String? name;
  int experienceLevel = 1;
  List<String>? kitchenEquipment;
  List<String>? foodRestrictions;
  List<String>? foodPreferences;

  UserProfile({
    this.name,
    this.kitchenEquipment,
    this.foodRestrictions,
    this.foodPreferences,
  });
}

// -------------------- First Page --------------------
class ProfileSetupPage1 extends StatefulWidget {
  @override
  _ProfileSetupPage1State createState() => _ProfileSetupPage1State();
}

class _ProfileSetupPage1State extends State<ProfileSetupPage1> {
  final TextEditingController _nameController = TextEditingController();

  void _nextPage() {
    String name = _nameController.text.trim();

    if (name.isNotEmpty) {
      UserProfile profile = UserProfile(name: name);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileSetupPage2(userProfile: profile),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your name!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF50C878),
      appBar: AppBar(
        backgroundColor: const Color(0xFF50C878),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'RecipeMe',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 28,
            fontWeight: FontWeight.bold,
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
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
            child: Column(
              children: [
                const Text(
                  'Welcome to RecipeMe.\nLet\'s get started with your profile!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
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
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF3DAA61),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'What should I call you?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
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
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name:',
                          filled: true,
                          fillColor: const Color(0xFF2E8B57),
                          labelStyle: const TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3DAA61),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _nextPage,
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------- Second Page --------------------
class ProfileSetupPage2 extends StatefulWidget {
  final UserProfile userProfile;
  ProfileSetupPage2({required this.userProfile});

  @override
  _ProfileSetupPage2State createState() => _ProfileSetupPage2State();
}

class _ProfileSetupPage2State extends State<ProfileSetupPage2> {
  double _experienceLevel = 1; // default slider value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF50C878),
      appBar: AppBar(
        backgroundColor: const Color(0xFF50C878),
        elevation: 0,
        title: const Text(
          'RecipeMe',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 28,
            fontWeight: FontWeight.bold,
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
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Let\'s get your profile up to date',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
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
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF3DAA61),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'How much cooking experience do you have?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
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
                      const SizedBox(height: 20),

                      // --- Slider Widget ---
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white54,
                          thumbColor: Colors.white,
                          overlayColor: Colors.white24,
                          valueIndicatorColor: const Color(0xFF2E8B57),
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 10.0,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 20.0,
                          ),
                        ),
                        child: Slider(
                          value: _experienceLevel,
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: _experienceLabel(_experienceLevel.toInt()),
                          onChanged: (value) {
                            setState(() {
                              _experienceLevel = value;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 10),
                      Text(
                        _experienceLabel(_experienceLevel.toInt()),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 4.0,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3DAA61),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    widget.userProfile.experienceLevel = _experienceLevel
                        .toInt();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfileSetupPage3(userProfile: widget.userProfile),
                      ),
                    );
                  },
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Converts numeric value to readable label
  String _experienceLabel(int value) {
    switch (value) {
      case 1:
      case 2:
        return 'Never cooked';
      case 3:
      case 4:
        return 'Beginner';
      case 5:
      case 6:
        return 'Intermediate';
      case 7:
      case 8:
        return 'Experienced';
      case 9:
      case 10:
        return 'Professional Chef';
      default:
        return 'Unknown';
    }
  }
}

// -------------------- Third Page --------------------
class ProfileSetupPage3 extends StatefulWidget {
  final UserProfile userProfile;
  ProfileSetupPage3({required this.userProfile});

  @override
  _ProfileSetupPage3State createState() => _ProfileSetupPage3State();
}

class _ProfileSetupPage3State extends State<ProfileSetupPage3> {
  List<String> _selectedEquipment = [];

  void _toggleEquipment(String item) {
    setState(() {
      if (_selectedEquipment.contains(item)) {
        _selectedEquipment.remove(item);
      } else {
        _selectedEquipment.add(item);
      }
    });
  }

  void _goToNextPage() {
    // Save selected equipment into userProfile
    widget.userProfile.kitchenEquipment = _selectedEquipment;

    // Navigate to the 4th page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProfileSetupPage4(userProfile: widget.userProfile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> equipmentOptions = [
      'Knife',
      'Cutting board',
      'Measuring cups & spoons',
      'Mixing bowls',
      'Spatula',
      'Tongs',
      'Whisk',
      'Peeler',
      'Grater',
      'Can opener',
      'Colander',
      'Fine-mesh sieve',
      'Frying pan / Skillet',
      'Saucepan',
      'Large pot',
      'Baking sheet',
      'Casserole dish',
      'Oven mitts / Pot holders',
      'Blender',
      'Toaster / Toaster oven',
      'Microwave',
      'Electric kettle',
      'Food storage containers',
      'Parchment paper',
      'Aluminum foil',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF50C878),
      appBar: AppBar(
        backgroundColor: const Color(0xFF50C878),
        elevation: 0,
        title: const Text(
          'RecipeMe',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 28,
            fontWeight: FontWeight.bold,
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
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'One step closer to cooking!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
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
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF3DAA61),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'What kitchen equipment is available to you?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
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
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: equipmentOptions.map((item) {
                          bool selected = _selectedEquipment.contains(item);
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selected
                                  ? const Color(0xFF1E6B47)
                                  : const Color(0xFF2E8B57),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _toggleEquipment(item),
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3DAA61),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _goToNextPage,
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------- Fourth Page --------------------
class ProfileSetupPage4 extends StatefulWidget {
  final UserProfile userProfile;
  const ProfileSetupPage4({required this.userProfile, Key? key})
    : super(key: key);

  @override
  _ProfileSetupPage4State createState() => _ProfileSetupPage4State();
}

class _ProfileSetupPage4State extends State<ProfileSetupPage4> {
  List<String> _selectedRestrictions = [];

  void _toggleRestriction(String item) {
    setState(() {
      if (_selectedRestrictions.contains(item)) {
        _selectedRestrictions.remove(item);
      } else {
        _selectedRestrictions.add(item);
      }
    });
  }

  void _goToNextPage() {
    widget.userProfile.foodRestrictions = _selectedRestrictions;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProfileSetupPage5(userProfile: widget.userProfile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> restrictionOptions = [
      'Milk',
      'Eggs',
      'Peanuts',
      'Tree Nuts',
      'Wheat',
      'Soy',
      'Fish',
      'Shellfish',
      'Sesame',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF50C878),
      appBar: AppBar(
        backgroundColor: const Color(0xFF50C878),
        elevation: 0,
        title: const Text(
          'RecipeMe',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 28,
            fontWeight: FontWeight.bold,
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Health is concerning!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 24,
                fontWeight: FontWeight.bold,
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
            const SizedBox(height: 40),
            // Food restrictions container with scroll
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF3DAA61),
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Do you have any food restrictions? (Select all that apply)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
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
                  const SizedBox(height: 16),

                  // Scrollbar *inside* container only
                  SizedBox(
                    height: 230,
                    child: Scrollbar(
                      thumbVisibility: true,
                      radius: const Radius.circular(12),
                      thickness: 6,
                      child: SingleChildScrollView(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 10,
                          children: restrictionOptions.map((item) {
                            bool selected = _selectedRestrictions.contains(
                              item,
                            );
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selected
                                    ? const Color(0xFF1E6B47)
                                    : const Color(0xFF2E8B57),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => _toggleRestriction(item),
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3DAA61),
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _goToNextPage,
              child: const Text(
                'Next',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
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
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- Fifth Page --------------------
class ProfileSetupPage5 extends StatefulWidget {
  final UserProfile userProfile;
  const ProfileSetupPage5({required this.userProfile, Key? key})
    : super(key: key);

  @override
  _ProfileSetupPage5State createState() => _ProfileSetupPage5State();
}

class _ProfileSetupPage5State extends State<ProfileSetupPage5> {
  List<String> _selectedFood = [];

  void _toggleFood(String item) {
    setState(() {
      if (_selectedFood.contains(item)) {
        _selectedFood.remove(item);
      } else {
        _selectedFood.add(item);
      }
    });
  }

  void _finishProfileSetup() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw 'User not logged in';

      // Update userProfile object with selected values
      widget.userProfile.foodPreferences = _selectedFood;

      print(widget.userProfile.experienceLevel);
      print(widget.userProfile.foodRestrictions);
      print(widget.userProfile.kitchenEquipment);
      print(widget.userProfile.name);

      // 🧩 Use upsert — creates or updates based on 'id'
      await supabase.from('profiles').upsert({
        'id': user.id,
        'allergies': widget.userProfile.foodRestrictions,
        'skill_level': widget.userProfile.experienceLevel,
        'cooking_equipment': widget.userProfile.kitchenEquipment,
        'display_name': widget.userProfile.name,
        'favorite_cuisines': widget.userProfile.foodPreferences,
        'updated_at': DateTime.now().toIso8601String(), // optional
      });

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      }
    } catch (e) {
      print('Error saving profile details: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile details: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> foodOptions = [
      'Italian',
      'Mexican',
      'Indian',
      'Japanese',
      'Chinese',
      'Thai',
      'Greek',
      'American',
      'French',
      'Mediterranean',
      'Korean',
      'Caribbean',
      'Vegan Dishes',
      'BBQ',
      'Seafood',
      'Burgers',
      'Pasta',
      'Pizza',
      'Desserts',
      'Soups',
      'Salads',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF50C878),
      appBar: AppBar(
        backgroundColor: const Color(0xFF50C878),
        elevation: 0,
        title: const Text(
          'RecipeMe',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 28,
            fontWeight: FontWeight.bold,
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Last Step!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 24,
                fontWeight: FontWeight.bold,
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
            const SizedBox(height: 40),

            // Scrollable Container
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF3DAA61),
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Tell me about your favorite cuisines and food! (Select all that apply)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
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
                  const SizedBox(height: 16),

                  // Inner scroll only inside this box
                  SizedBox(
                    height: 230,
                    child: Scrollbar(
                      thumbVisibility: true,
                      radius: const Radius.circular(12),
                      thickness: 6,
                      child: SingleChildScrollView(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 10,
                          children: foodOptions.map((item) {
                            bool selected = _selectedFood.contains(item);
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selected
                                    ? const Color(0xFF1E6B47)
                                    : const Color(0xFF2E8B57),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => _toggleFood(item),
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3DAA61),
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _finishProfileSetup,
              child: const Text(
                'Finish profile setup',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
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
            ),
          ],
        ),
      ),
    );
  }
}
