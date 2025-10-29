import 'package:flutter/material.dart';
import 'nav_bar.dart';
import 'home_screen.dart';
import 'history_tab.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_setup.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 2; // Profile tab is selected

  // Add state variables for fetched data
  String? _displayName;
  int? _cookingExperienceInt;
  String? _cookingExperience;
  String? _allergies;
  String? _favorites;
  String? _cookingEquipment;
  bool _isLoading = true; // For loading state
  String? _errorMessage; // For error handling

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => MainPage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 2:
        // Already on profile page
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Fetch data when the page loads
  }

  // Add this method to query Supabase
  Future<void> _fetchUserProfile() async {
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

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        setState(() {
          _errorMessage =
              'User not logged in. Please log in to view your profile.';
          _isLoading = false;
        });
        return;
      }

      // Query the profiles table for the current user
      final response = await supabase
          .from('profiles')
          .select(
            'display_name, skill_level, allergies, favorite_cuisines, cooking_equipment',
          )
          .eq(
            'id',
            user.id,
          ) // Assuming 'id' is the primary key matching auth.users.id
          .single(); // Fetch a single row

      // Update state with fetched data
      setState(() {
        _displayName = response['display_name'] ?? 'Not set';
        _cookingExperienceInt = response['skill_level'] ?? 0;
        _cookingExperience = _experienceLabel(_cookingExperienceInt!);

        // Helper function to format lists
        String _formatList(dynamic value) {
          if (value is List) {
            if (value.isEmpty) return 'None';
            if (value.length == 1) return value[0].toString();
            return value.join(', ');
          }
          return value?.toString() ?? 'None';
        }

        _allergies = _formatList(response['allergies']);
        _favorites = _formatList(response['favorite_cuisines']);
        _cookingEquipment = _formatList(response['cooking_equipment']);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF50C878),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark overlay
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4), // Darker tint overlay
            ),
          ),
          // Content overlay
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar + edit button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white,
                        child: const CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(
                            'https://picsum.photos/200',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.black, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileSetupPage1(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FrostedSection(
                    title: 'Display Name',
                    child: _isLoading
                        ? const CircularProgressIndicator() // Show loading spinner
                        : _errorMessage != null
                        ? Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          )
                        : Text(
                            _displayName ?? 'Not set',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  _FrostedSection(
                    title: 'Cooking Experience',
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : _errorMessage != null
                        ? Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          )
                        : Text(
                            _cookingExperience ?? 'Not set',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  _FrostedSection(
                    title: 'Allergies and Restrictions',
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : _errorMessage != null
                        ? Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          )
                        : Text(
                            _allergies ?? 'None',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  _FrostedSection(
                    title: 'Favorites',
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : _errorMessage != null
                        ? Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          )
                        : Text(
                            _favorites ?? 'None',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  _FrostedSection(
                    title: 'Cooking Equipment',
                    child: _isLoading
                        ? const CircularProgressIndicator() // Show loading spinner
                        : _errorMessage != null
                        ? Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          )
                        : Text(
                            _cookingEquipment ?? 'Not set',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavBar(
        currentIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class _FrostedSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _FrostedSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
