import 'package:flutter/material.dart';
import 'package:islami/core/theme/app_colors.dart';

class CustomBottomNavigationBarIcon extends StatelessWidget {
  final String imagePath;
  final bool isSelected;

  const CustomBottomNavigationBarIcon({
    required this.imagePath,
    required this.isSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      transitionBuilder:
          (child, animation) => ScaleTransition(scale: animation , child: child,),
      child:
          isSelected
              ? Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.black.withAlpha(50),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: ImageIcon(AssetImage(imagePath)),
              )
              : ImageIcon(AssetImage(imagePath)),
    );
  }
}
