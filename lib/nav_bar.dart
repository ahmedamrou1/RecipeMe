import 'package:flutter/material.dart';

class NavBar extends StatelessWidget 
{
  final int currentIndex;
  final Function(int) onItemTapped;

  NavBar({required this.currentIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) 
  {
    return BottomNavigationBar
    (
      currentIndex: currentIndex,
      onTap: onItemTapped,
      items: 
      [
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
    );
  }
}