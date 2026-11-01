import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:islami/core/model/sura.dart';
import 'package:islami/core/theme/app_theme.dart';
import 'package:islami/core/theme/theme_cubit.dart';
import 'package:islami/features/home/home_screen.dart';
import 'package:islami/features/prayer/data/repositories/prayer_repository_impl.dart';
import 'package:islami/features/prayer/presentation/cubit/prayer_cubit.dart';
import 'package:islami/features/quran/presentation/screens/sura_details.dart';
import 'package:islami/features/quran/presentation/cubit/quran_typography_cubit.dart';
import 'package:islami/features/spalsh/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  // Load the saved theme before the first frame so there is no flash.
  final themeCubit = ThemeCubit();
  await themeCubit.load();
  final quranTypographyCubit = QuranTypographyCubit();
  await quranTypographyCubit.load();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: themeCubit),
        BlocProvider.value(value: quranTypographyCubit),
        BlocProvider<PrayerCubit>(
          create: (_) => PrayerCubit(PrayerRepositoryImpl())..initialize(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeSettings>(
      builder: (context, settings) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightWithAccent(settings.accent),
          darkTheme: AppTheme.darkWithAccent(settings.accent),
          themeMode: settings.mode,
          themeAnimationDuration: const Duration(milliseconds: 350),
          themeAnimationCurve: Curves.easeInOutCubic,
          routes: {
            SplashScreen.routeName: (_) => SplashScreen(),
            HomeScreen.routeName: (_) => const HomeScreen(),
            SuraDetails.routeName: (context) {
              var sura = ModalRoute.of(context)?.settings.arguments as Sura;
              return SuraDetails(sura: sura);
            },
          },
          initialRoute: SplashScreen.routeName,
          // `home:` removed: it is ignored/conflicts when initialRoute is used.
        );
      },
    );
  }
}
