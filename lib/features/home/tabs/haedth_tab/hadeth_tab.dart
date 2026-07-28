import 'package:flutter/material.dart';
import 'package:islami/core/widget/base_tob_body.dart';
import 'package:islami/features/home/tabs/haedth_tab/hadeth_card.dart';

class HadethTab extends StatelessWidget {
  const HadethTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseTabBody(child: HadethCard());
  }
}
