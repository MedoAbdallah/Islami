import 'package:flutter/material.dart';
import 'package:islami/core/constans/app_Images.dart';
import 'package:islami/core/model/hadeth.dart';
import 'package:islami/core/theme/app_colors.dart';
import 'package:islami/core/theme/textstyle.dart';



class HadethDetailsScreen extends StatelessWidget {
  static const String routeName = "/hadeth-details";
  final Hadeth hadeth;

  const HadethDetailsScreen({required this.hadeth, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.gold,
        title: Text("Hadith ${hadeth.id}"),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Image.asset(AppImages.imgLeftCorner),
                Expanded(
                  child: Text(
                    hadeth.title,
                    style: TextStylesHelper.largeLabelTextStyle(
                      textColor: AppColors.gold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Image.asset(AppImages.imgRightCorner),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(8),
              child: Text(
                hadeth.content,
                style: TextStylesHelper.smallTextStyle(textColor: AppColors.gold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Image.asset(AppImages.imgBottomDecoration),
        ],
      ),
    );
  }
}