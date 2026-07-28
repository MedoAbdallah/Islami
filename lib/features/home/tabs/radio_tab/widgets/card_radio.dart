import 'package:flutter/material.dart';
import 'package:islami/core/constans/app_Images.dart';
import 'package:islami/core/theme/app_colors.dart';
import 'package:islami/core/theme/textstyle.dart';

class CardRadio extends StatefulWidget {
  final String title;

  const CardRadio({super.key, required this.title});

  @override
  State<CardRadio> createState() => _CardRadioState();
}

class _CardRadioState extends State<CardRadio> {
  bool isAuto = false;
  bool isAutoSound = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0,left: 8.0),
      child: Container(
        margin: EdgeInsets.all(5.0),
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: AppColors.gold,
        ),
        child: Stack(
          children: [
            Align(
              alignment: AlignmentGeometry.bottomCenter,
              child: Image.asset(
                isAuto ? AppImages.soundWave : AppImages.imgBottomDecoration,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  widget.title,
                  style: TextStylesHelper.smallLabelTextStyle(textColor: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 50),
                    // autoplay bottom
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isAuto = !isAuto;
                        });
                      },
                      child: isAuto
                          ? Icon(Icons.pause_rounded, size: 45)
                          : Image.asset(AppImages.polygon),
                    ),
                    const SizedBox(width: 20),
                    // Sound Bottom
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isAutoSound = !isAutoSound;
                        });
                      },
                      child: Image.asset(
                        isAutoSound ? AppImages.volumeCross : AppImages.volume,
                      ),
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
