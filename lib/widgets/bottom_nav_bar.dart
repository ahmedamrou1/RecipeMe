import 'package:flutter/material.dart';

class RecipeMeBottomNavBar extends StatelessWidget
{
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const RecipeMeBottomNavBar({super.key, required this.currentIndex, this.onTap});

  static const Color appGreen = Color(0xFF50C878);

  @override
  Widget build(BuildContext context)
  {
    return SafeArea
    (
      top: false,
      child: Padding
      (
        padding: const EdgeInsets.all(12.0),
        child: Container
        (
          decoration: BoxDecoration
          (
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow:
            [
              BoxShadow
              (
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row
          (
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
            [
              _NavButton(
                icon: Icons.history,
                label: 'History',
                index: 0,
                selected: currentIndex == 0,
                onTap: onTap,
              ),
              _NavButton(
                icon: Icons.home_filled,
                label: 'Home',
                index: 1,
                selected: currentIndex == 1,
                onTap: onTap,
              ),
              _NavButton(
                icon: Icons.person,
                label: 'Profile',
                index: 2,
                selected: currentIndex == 2,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget
{
  final IconData icon;
  final String label;
  final int index;
  final bool selected;
  final ValueChanged<int>? onTap;

  const _NavButton({required this.icon, required this.label, required this.index, required this.selected, this.onTap});

  @override
  Widget build(BuildContext context)
  {
    final Color baseBg = Colors.white;
    final Color baseFg = Colors.black;

    final Color bgColor = selected ? baseFg : baseBg;
    final Color fgColor = selected ? baseBg : baseFg;

    return Expanded
    (
      child: GestureDetector
      (
        onTap: () => onTap?.call(index),
        child: Container
        (
          height: 48,
          decoration: BoxDecoration
          (
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row
          (
            mainAxisAlignment: MainAxisAlignment.center,
            children:
            [
              Icon(icon, color: fgColor),
              const SizedBox(width: 6),
              Text
              (
                label,
                style: TextStyle
                (
                  color: fgColor,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


