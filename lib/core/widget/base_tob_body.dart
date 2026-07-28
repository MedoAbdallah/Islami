import 'package:flutter/material.dart';
import 'package:islami/core/constans/app_Images.dart';

class BaseTabBody extends StatelessWidget {
  final Widget child;
  const BaseTabBody({required this.child , super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Image.asset(AppImages.imgHeader)],
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}