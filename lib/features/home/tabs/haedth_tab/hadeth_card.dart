 import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islami/core/constans/app_Images.dart';
import 'package:islami/core/model/hadeth.dart';
import 'package:islami/core/theme/app_colors.dart';
import 'package:islami/core/theme/textstyle.dart';
import 'package:islami/features/home/tabs/haedth_tab/hadeth_details.dart';

class HadethCard extends StatefulWidget {
  const HadethCard({super.key});

  @override
  State<HadethCard> createState() => _HadethCardState();
}

class _HadethCardState extends State<HadethCard> {
  final PageController _pageController = PageController(viewportFraction: 0.8);

  List<Hadeth> ahadeth = [];
  @override
  void initState() {
    super.initState();
    loadAhadeth();
  }

  Future<void> loadAhadeth() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    final hadethAssets = manifestMap.keys
        .where((String key) => key.startsWith('assets/hadeth/'))
        .toList();

    List<Hadeth> loadedAhadeth = [];
    int counter = 1;

    for (var file in hadethAssets) {
      String content = await rootBundle.loadString(file);
      List<String> lines = content.split('\n');
      if (lines.isNotEmpty && lines.first.trim().startsWith("الحد")) {
        lines.removeAt(0);
      }
      loadedAhadeth.add(Hadeth.fromFile(counter, lines.join('\n')));
      counter++;
    }

    setState(() {
      ahadeth = loadedAhadeth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ahadeth.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : PageView.builder(
            controller: _pageController,
            itemCount: ahadeth.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final hadeth = ahadeth[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.2)).clamp(0.9, 1.0);
                  }
                  return Transform.scale(scale: value, child: child);
                },
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            HadethDetailsScreen(hadeth: hadeth),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: AppColors.gold,
                      image: DecorationImage(
                        image: AssetImage(AppImages.hadethCardBackground),
                        fit: BoxFit.cover,
                      ),
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 4,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          child: Image.asset(AppImages.leftCorner),
                        ),
                        Positioned(
                          right: 0,
                          child: Image.asset(AppImages.rightCorner),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 30,
                              right: 10,
                              left: 10,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  hadeth.title,
                                  style: TextStylesHelper.largeTextStyle(
                                    textColor: AppColors.black,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Expanded(
                                  child: Text(
                                    hadeth.content,
                                    style: TextStylesHelper.mediumLabelTextStyle(
                                      textColor: AppColors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }
}
