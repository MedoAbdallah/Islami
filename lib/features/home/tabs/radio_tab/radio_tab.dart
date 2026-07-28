import 'package:flutter/material.dart';

import 'package:islami/core/widget/base_tob_body.dart';
import 'package:islami/features/home/tabs/radio_tab/widgets/card_radio.dart';
import 'package:islami/features/home/tabs/radio_tab/widgets/selected_container.dart';

class RadioTab extends StatelessWidget {
  const RadioTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseTabBody(
      child: Column(
        children: [
          // selected container
          SelectedContainer(),
          // card radio
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CardRadio(title: 'Radio Ibrahim Al-Akdar'),
                  CardRadio(title: 'Radio Al-Qaria Yassen'),
                  CardRadio(title: 'Radio Ahmed Al-trabulsi'),
                  CardRadio(title: 'Radio Addokali Mohammad Alalim'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
