import 'package:flutter/material.dart';
import 'package:islami/core/model/sura.dart';
import 'package:islami/features/home/home_screen.dart';
import 'package:islami/features/home/tabs/quran_tab/widget/sura_details.dart';
import 'package:islami/features/onboarding/onboarding_screen.dart';
import 'package:islami/features/spalsh/splash_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        SplashScreen.routeName: (_) => SplashScreen(),
        HomeScreen.routeName: (_) => HomeScreen(),
        SuraDetails.routeName: (context) {
          var sura = ModalRoute.of(context)?.settings.arguments as Sura;
          return SuraDetails(sura: sura,);
        },
      },
      initialRoute: SplashScreen.routeName,
      home: OnboardingScreen(),
    );
  }
}
