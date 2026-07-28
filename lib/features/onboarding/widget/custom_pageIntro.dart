import 'package:flutter/material.dart';
import 'package:islami/core/theme/textstyle.dart';

class CustomPageIntro extends StatelessWidget {
  final String centerImage;
  final String centerText;
  final String bottomText;

  const CustomPageIntro({
    super.key,
    required this.centerImage,
    required this.bottomText,
    required this.centerText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(20),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: SizedBox()),
            Center(child: Image.asset(centerImage, fit: BoxFit.contain)),
              SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Text(
                centerText,
                style: TextStylesHelper.smallLabelTextStyle(),
                textAlign: TextAlign.center,
              ),
            ),

              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Text(
                  bottomText,
                  style: TextStylesHelper.smallLabelTextStyle(),
                  textAlign: TextAlign.center,
                ),
              ),

          ],
        ),
      ),
    );
  }
}
