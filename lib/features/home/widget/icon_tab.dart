import 'package:flutter/material.dart';

class CustomBottomNavigatorBarIcon extends StatelessWidget {
  final String imagePath;
  final bool isSelected;
  const CustomBottomNavigatorBarIcon({
    super.key,
    required this.imagePath,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => ScaleTransition(scale: animation,child: child),
      child: isSelected
          ? Container(
             padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(50),
                borderRadius: BorderRadius.circular(100),
              ),
              child: ImageIcon(AssetImage(imagePath)),
            )
          : ImageIcon(AssetImage(imagePath)),
    );
  }
}