import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget
{
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
{

  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
      backgroundColor: const Color(0xFF50C878),
      body: Container
      (
        decoration: BoxDecoration
        (
          image: DecorationImage
          (
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: Container
        (
          decoration: BoxDecoration
          (
            color: Colors.black.withOpacity(0.4), // Darker tint overlay
          ),
          child: Stack
          (
            children:
            [
          // Content overlay
          SafeArea
          (
            child: SingleChildScrollView
            (
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column
              (
                crossAxisAlignment: CrossAxisAlignment.center,
                children:
                [
                  // Avatar + edit button
                  Row
                  (
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                    [
                      CircleAvatar
                      (
                        radius: 44,
                        backgroundColor: Colors.white,
                        child: const CircleAvatar
                        (
                          radius: 40,
                          backgroundImage: NetworkImage('https://picsum.photos/200'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox
                  (
                    height: 40,
                    child: OutlinedButton.icon
                    (
                      style: OutlinedButton.styleFrom
                      (
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.black, width: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FrostedSection
                  (
                    title: 'Email',
                    child: const Text('user@example.com', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  _FrostedSection
                  (
                    title: 'Chef level',
                    child: const Text('Sous Chef', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  _FrostedSection
                  (
                    title: 'Food allergies',
                    child: const Text('Peanuts, Shellfish', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  _FrostedSection
                  (
                    title: 'Favourite foods',
                    child: const Text('Pasta, Avocado, Berries', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FrostedSection extends StatelessWidget
{
  final String title;
  final Widget child;

  const _FrostedSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context)
  {
    return Container
    (
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration
      (
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Column
      (
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
        [
          Text
          (
            title,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}


