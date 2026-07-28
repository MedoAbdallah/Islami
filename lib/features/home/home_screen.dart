import 'package:flutter/material.dart';
import 'package:islami/core/constans/app_Images.dart';
import 'package:islami/core/theme/app_colors.dart';
import 'package:islami/features/home/tabs/haedth_tab/hadeth_tab.dart';
import 'package:islami/features/home/tabs/quran_tab/quran_tab.dart';
import 'package:islami/features/home/tabs/radio_tab/radio_tab.dart';
import 'package:islami/features/home/tabs/sebha_tab/sebha_tab.dart';
import 'package:islami/features/home/tabs/time_tab/time_tab.dart';
import 'package:islami/features/home/widget/custom_bottom_icon.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "home";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  List<Widget> tabs = [
    QuranTab(),
    HadethTab(),
    SebhaTab(),
    RadioTab(),
    TimeTab(),
  ];

  List<String> backgroundImages = [
    AppImages.quranBg,
    AppImages.hadithBg,
    AppImages.sebhaBg,
    AppImages.radioBg,
    AppImages.moreBg,
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundImages[selectedIndex]),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.black, AppColors.black.withAlpha(80)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: tabs[selectedIndex],
          bottomNavigationBar: SizedBox(
            height: 75,
            child: BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (newIndex) {
                selectedIndex = newIndex;
                setState(() {});
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.gold,
              unselectedItemColor: AppColors.black,
              selectedItemColor: AppColors.white,
              showSelectedLabels: true,
              showUnselectedLabels: false,
              items: [
                BottomNavigationBarItem(
                  icon: CustomBottomNavigationBarIcon(
                    imagePath: AppImages.icQuran,
                    isSelected: selectedIndex == 0,
                  ),
                  label: "Quran",
                ),
                BottomNavigationBarItem(
                  icon: CustomBottomNavigationBarIcon(
                    imagePath: AppImages.icHadeth,
                    isSelected: selectedIndex == 1,
                  ),
                  label: "Hadeth",
                ),
                BottomNavigationBarItem(
                  icon: CustomBottomNavigationBarIcon(
                    imagePath: AppImages.icSebha,
                    isSelected: selectedIndex == 2,
                  ),
                  label: "Sebha",
                ),
                BottomNavigationBarItem(
                  icon: CustomBottomNavigationBarIcon(
                    imagePath: AppImages.icRadio,
                    isSelected: selectedIndex == 3,
                  ),
                  label: "Radio",
                ),
                BottomNavigationBarItem(
                  icon: CustomBottomNavigationBarIcon(
                    imagePath: AppImages.icTime,
                    isSelected: selectedIndex == 4,
                  ),
                  label: "Time",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
