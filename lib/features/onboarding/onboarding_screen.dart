import 'package:flutter/material.dart';
import 'package:islami/core/constans/app_Images.dart';
import 'package:islami/core/theme/app_colors.dart';
import 'package:islami/core/theme/textstyle.dart';
import 'package:islami/features/home/home_screen.dart';
import 'package:islami/features/onboarding/widget/custom_pageIntro.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController controller = PageController();

  bool onLastPage = false;
  bool onFirstPage = true;

  // go to next page

  void nextPage() {
    controller.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  // go to previous page

  void prevPage() {
    controller.previousPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }
  // list of pages

  final List<Map<String, String>> pages = [
    {
      "image": AppImages.welcome,
      "bottomText": "Welcome To Islmi App",
      "centerText": "",
    },
    {
      "image": AppImages.intro2,
      "bottomText": "We Are Very Excited To Have You In Our Community",
      "centerText": "Welcome To Islami",
    },
    {
      "image": AppImages.intro3,
      "bottomText": "Read, and your Lord is the Most Generous",
      "centerText": "Reading the Quran",
    },
    {
      "image": AppImages.intro4,
      "bottomText": "Praise the name of your Lord, the Most High",
      "centerText": "Bearish",
    },
    {
      "image": AppImages.mice,
      "bottomText":
          "You can listen to the Holy Quran Radio through the application ",
      "centerText": "Holy Quran Radio",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Image.asset(AppImages.imgHeader),
            ),
            // page view
            PageView.builder(
              controller: controller,
              itemCount: pages.length,
              onPageChanged: (index) {
                setState(() {
                  onLastPage = (index == pages.length - 1);
                  onFirstPage = (index == 0);
                });
              },
              itemBuilder: (context, index) {
                return CustomPageIntro(
                  centerImage: pages[index]["image"]!,
                  bottomText: pages[index]["bottomText"]!,
                  centerText: pages[index]["centerText"]!,
                );
              },
            ),

            /// Indicators + Buttons
            Container(
              alignment: const Alignment(0, 0.99),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  onFirstPage
                      ? const SizedBox.shrink()
                      : GestureDetector(
                          onTap: () => prevPage(),
                          child: Text(
                            "Back",
                            style: TextStylesHelper.smallLabelTextStyle(),
                          ),
                        ),
                  // dot indicators
                  SmoothPageIndicator(
                    controller: controller,
                    count: pages.length,
                    effect: WormEffect(
                      dotHeight: 8.0,
                      dotWidth: 8.0,
                      dotColor: AppColors.gray,
                      activeDotColor: AppColors.gold,
                    ),
                  ),

                  onLastPage
                      ? GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Done",
                            style: TextStylesHelper.smallLabelTextStyle(),
                          ),
                        )
                      : GestureDetector(
                          onTap: () => nextPage(),
                          child: Text(
                            "Next",
                            style: TextStylesHelper.smallLabelTextStyle(),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
