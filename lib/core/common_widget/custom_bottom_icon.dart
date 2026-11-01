import 'package:flutter/material.dart';
import 'package:islami/core/theme/app_palette.dart';

class CustomBottomNavigationBarIcon extends StatelessWidget {
  final String imagePath;
  final bool isSelected;
  final double size;

  const CustomBottomNavigationBarIcon({
    required this.imagePath,
    required this.isSelected,
    this.size = 24,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: EdgeInsets.symmetric(
        horizontal: isSelected ? 16 : 0,
        vertical: isSelected ? 8 : 0,
      ),
      decoration: BoxDecoration(
        // Dark translucent pill works on both the gold (dark mode)
        // and the brown (light mode) bar.
        color: isSelected
            ? Colors.black.withValues(alpha: 0.35)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: ImageIcon(
        AssetImage(imagePath),
        size: size,
        // Selected: white on the dark pill.
        // Unselected: whatever contrasts with the bar (black on gold,
        // white on brown).
        color: isSelected ? Colors.white : p.onPrimary,
      ),
    );
  }
}