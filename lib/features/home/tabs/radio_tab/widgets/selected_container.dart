import 'package:flutter/material.dart';
import 'package:islami/core/theme/app_colors.dart';

class SelectedContainer extends StatefulWidget {
  const SelectedContainer({super.key});

  @override
  State<SelectedContainer> createState() => _SelectedContainerState();
}

class _SelectedContainerState extends State<SelectedContainer> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(150),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = 0;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: selectedIndex == 0
                      ? AppColors.gold
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "Radio",
                    style: TextStyle(
                      color: selectedIndex == 0 ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = 1;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: selectedIndex == 1
                      ? AppColors.gold
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "Reciters",
                    style: TextStyle(
                      color: selectedIndex == 1 ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
