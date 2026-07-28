import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:islami/core/constans/app_Images.dart';
import 'package:islami/features/onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = "splash";
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // background
          Image.asset(
            AppImages.background,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // top Center image
          Positioned(
            top: mediaQuery.height * 0.06,
            right: 0,
            left: 0,
            child: ZoomIn(child: Image.asset(AppImages.mosqueSplash)),
          ),
          // right image
          Positioned(
            top: 0,
            right: 16,
            child: ZoomIn(child: Image.asset(AppImages.glow)),
          ),
          //  left top image
          Positioned(
            left: 0,
            top: mediaQuery.height * 0.25,
            child: Image.asset(AppImages.shape1),
          ),
          //  left bottom image
          Positioned(
            right: 0,
            bottom: mediaQuery.height * 0.25,
            child: ZoomIn(child: Image.asset(AppImages.shape2)),
          ),
          // center logo
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            left: 0,
            child: ZoomIn(child: Image.asset(AppImages.islamiLogo)),
          ),

          // route logo
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: ZoomIn(child: Image.asset(AppImages.routeLogo)),
          ),
        ],
      ),
    );
  }
}
