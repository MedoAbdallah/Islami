import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islami/core/constans/app_Images.dart';
import 'package:islami/core/model/sura.dart';
import 'package:islami/core/theme/app_colors.dart';
import 'package:islami/core/theme/textstyle.dart';


class SuraDetails extends StatefulWidget {
  static const String routeName = "sura_details";
  final Sura sura;

  SuraDetails({required this.sura, super.key});

  @override
  State<SuraDetails> createState() => _SuraDetailsState();
}

class _SuraDetailsState extends State<SuraDetails> {
  String? suraContent;

  @override
  Widget build(BuildContext context) {
    if (suraContent == null) {
      loadSuraDetails();
    }

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.gold,
        title: Text(widget.sura.nameEn),
        surfaceTintColor: Colors.transparent,
      ),
      body:
          suraContent == null
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:5),
                    child: Row(
                      children: [
                        Image.asset(AppImages.imgLeftCorner),
                        Expanded(
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(
                              widget.sura.nameAr,
                              style: TextStylesHelper.largeLabelTextStyle(
                                textColor: AppColors.gold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Image.asset(AppImages.imgRightCorner),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(10),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          suraContent!,
                          style: TextStylesHelper.largeBodyTextStyle(
                            textColor: AppColors.gold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Image.asset(AppImages.imgBottomDecoration),
                ],
              ),
    );
  }

  Future<void> loadSuraDetails() async {
    var sura = await rootBundle.loadString(
      "assets/quran/${widget.sura.id}.txt",
    );
    var ayas = sura.trim().split("\n");
    String formatedSura = " ";

    for (int i = 0; i < ayas.length; i++) {
      formatedSura = " $formatedSura[${i + 1}] ${ayas[i].trim()} ";
    }
    suraContent = formatedSura;
    setState(() {});
  }
}
