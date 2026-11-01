import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:islami/core/constans/app_images.dart';
import 'package:islami/features/home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = "splash";

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToOnboarding();
  }

  Future<void> _navigateToOnboarding() async {
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            AppImages.background,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // Top Mosque
          Positioned(
            top: size.height * 0.05,
            left: 0,
            right: 0,
            child: FadeInDown(
              duration: const Duration(milliseconds: 900),
              child: Image.asset(
                AppImages.mosqueSplash,
                height: size.height * 0.22,
              ),
            ),
          ),

          // Glow (top right)
          Positioned(
            top: 0,
            right: 12,
            child: FadeIn(
              duration: const Duration(milliseconds: 1200),
              child: Image.asset(
                AppImages.glow,
                width: size.width * 0.45,
              ),
            ),
          ),

          // Left Shape
          Positioned(
            left: 0,
            top: size.height * 0.28,
            child: FadeInLeft(
              duration: const Duration(milliseconds: 1000),
              delay: const Duration(milliseconds: 200),
              child: Image.asset(
                AppImages.shape1,
                width: size.width * 0.28,
              ),
            ),
          ),

          // Right Bottom Shape
          Positioned(
            right: 0,
            bottom: size.height * 0.22,
            child: FadeInRight(
              duration: const Duration(milliseconds: 1000),
              delay: const Duration(milliseconds: 300),
              child: Image.asset(
                AppImages.shape2,
                width: size.width * 0.28,
              ),
            ),
          ),

          // Center Logo
          Center(
            child: ZoomIn(
              duration: const Duration(milliseconds: 1100),
              delay: const Duration(milliseconds: 150),
              child: Image.asset(
                AppImages.islamiLogo,
                width: size.width * 0.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
