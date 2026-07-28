import 'package:flutter/material.dart';
import 'package:islami/core/constans/app_Images.dart';
import 'package:islami/core/model/sura.dart';
import 'package:islami/core/theme/app_colors.dart';
import 'package:islami/core/theme/textstyle.dart';
import 'package:islami/core/widget/base_tob_body.dart';
import 'package:islami/features/home/tabs/quran_tab/widget/most_recent_card.dart';
import 'package:islami/features/home/tabs/quran_tab/widget/sura_card.dart';
import 'package:islami/features/home/tabs/quran_tab/widget/sura_details.dart';
import 'package:shared_preferences/shared_preferences.dart';


class QuranTab extends StatefulWidget {
  const QuranTab({super.key});

  @override
  State<QuranTab> createState() => _QuranTabState();
}

class _QuranTabState extends State<QuranTab> {
  List<Sura> fullList = [];
  List<Sura> searchList = [];
  List<Sura> mostRecent = [];

  @override
  void initState() {
    super.initState();
    Sura.generateSurasList();
    for (var sura in Sura.suras) {
      fullList.add(sura);
    }
    for (var sura in Sura.suras) {
      searchList.add(sura);
    }
    readMostRecentSura();
  }

  @override
  Widget build(BuildContext context) {
    return BaseTabBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              onChanged: (value) {
                searchInList(value);
              },
              style: TextStylesHelper.smallLabelTextStyle(textColor: AppColors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.black.withAlpha(80),
                prefixIcon: ImageIcon(
                  AssetImage(AppImages.icQuran),
                  color: AppColors.gold,
                ),
                hintText: "Search By Sura Name",
                hintStyle: TextStylesHelper.smallLabelTextStyle(
                  textColor: AppColors.white,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.gold),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.gold),
                ),
              ),
            ),
          ),
          if (mostRecent.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                "Most Recent",
                style: TextStylesHelper.largeBodyTextStyle(),
              ),
            ),

          if (mostRecent.isNotEmpty)
            SizedBox(
              height: 160,
              child: ListView.separated(
                padding: EdgeInsets.all(16),
                scrollDirection: Axis.horizontal,
                separatorBuilder: (_, _) => SizedBox(width: 16),
                itemBuilder:
                    (_, index) => MostRecentCard(
                      sura: mostRecent[index],
                      onSuraClick: onSuraClick,
                    ),
                itemCount: mostRecent.length,
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text("Suras List", style: TextStylesHelper.largeBodyTextStyle()),
          ),
          Expanded(
            child: ListView.separated(
              itemBuilder:
                  (context, index) => SuraCard(
                    sura: searchList[index],
                    onSuraClick: onSuraClick,
                  ),
              separatorBuilder:
                  (_, _) => Divider(
                    indent: 40,
                    endIndent: 40,
                    color: AppColors.white,
                  ),
              itemCount: searchList.length,
            ),
          ),
        ],
      ),
    );
  }

  void searchInList(String value) {
    var searchResults =
        fullList
            .where(
              (element) =>
                  element.nameEn.toLowerCase().contains(value.toLowerCase()),
            )
            .toList();
    if (searchResults.isEmpty) {
      searchResults =
          fullList.where((element) => element.nameAr.contains(value)).toList();
    }
    searchList = searchResults;
    setState(() {});
  }

  Future<void> onSuraClick(Sura sura) async {
    Navigator.pushNamed(context, SuraDetails.routeName, arguments: sura);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> surasIds = preferences.getStringList("mostRecent") ?? [];
    if (surasIds.contains(sura.id.toString())) {
      surasIds.removeWhere((id) => id == sura.id.toString());
    }
    surasIds = [sura.id.toString(), ...surasIds];
    await preferences.setStringList("mostRecent", surasIds);
    readMostRecentSura();
  }

  Future<void> readMostRecentSura() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> surasIds = preferences.getStringList("mostRecent") ?? [];

    mostRecent = [];
    for (var value in surasIds) {
      mostRecent.add(
        fullList.firstWhere((element) => element.id.toString() == value),
      );
    }
    print(mostRecent);
    setState(() {});
  }
}