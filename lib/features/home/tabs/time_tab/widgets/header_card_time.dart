import 'package:flutter/material.dart';
import 'package:islami/core/theme/app_colors.dart';
import 'package:islami/core/theme/textstyle.dart';

class HeaderCardTime extends StatelessWidget {
  const HeaderCardTime({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            "16 Jul,\n2024",
            style: TextStylesHelper.largeBoldTextStyle(
              textColor: AppColors.white,
            ),
          ),
          Column(
            children: [
              Text(
                'Pray Time',
                style: TextStylesHelper.largeLabelBoldTextStyle(
                  textColor: AppColors.gray,
                ),
              ),
              Text(
                "Tuesday",
                style: TextStylesHelper.largeLabelBoldTextStyle(
                  textColor: AppColors.black,
                ),
              ),
            ],
          ),
          Text(
            "09 Muh,\n1446",
            style: TextStylesHelper.largeBoldTextStyle(
              textColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
