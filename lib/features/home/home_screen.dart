import 'package:flutter/material.dart';
import 'package:islami/core/constans/app_images.dart';
import 'package:islami/core/theme/app_palette.dart';
import 'package:islami/features/assistant/presentation/screens/ai_chat_screen.dart';
import 'package:islami/features/hadith/presentation/screens/hadeth_tab.dart';
import 'package:islami/features/quran/presentation/screens/quran_tab.dart';
import 'package:islami/features/sebha/presentation/screens/sebha_tab.dart';
import 'package:islami/features/prayer/presentation/screens/time_tab.dart';
import 'package:islami/features/prayer/presentation/screens/prayer_settings_screen.dart';
import 'package:islami/features/prayer/presentation/screens/prayer_notification_settings_screen.dart';
import 'package:islami/features/prayer/presentation/screens/prayer_time_adjustment_screen.dart';
import 'package:islami/features/azkar/presentation/widgets/azkar_card.dart';
import 'package:islami/features/dua/presentation/widgets/dua_card_widget.dart';
import 'package:islami/features/fasting/presentation/screens/fasting_screen.dart';
import 'package:islami/features/home/home_dashboard.dart';

import 'package:islami/core/common_widget/animated_nav_bar.dart';
import 'package:islami/core/common_widget/home_menu.dart';
import 'package:islami/features/quran/presentation/screens/bookmarks_screen.dart';
import 'package:islami/features/quran/presentation/screens/quran_typography_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "home";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedIndex = 0;

  late final List<Widget> tabs = [
    HomeDashboard(
      onOpenQuran: () => setState(() => selectedIndex = 1),
      onOpenHadith: () => setState(() => selectedIndex = 2),
      onOpenSebha: () => setState(() => selectedIndex = 3),
      onOpenAssistant: () => setState(() => selectedIndex = 4),
      onOpenPrayer: () => setState(() => selectedIndex = 5),
      onOpenAzkar: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HomeMenuSectionScreen(title: 'الأذكار', child: AzkarCardWidget()))),
      onOpenDua: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HomeMenuSectionScreen(title: 'الأدعية', child: DuaCardWidget()))),
      onOpenFasting: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const FastingScreen())),
    ),
    QuranTab(),
    HadethTab(),
    SebhaTab(),
    AiChatScreen(onMenuTap: _openMenu),
    TimeTab(),
  ];

  late final List<HomeMenuGroup> _menuGroups = [
    HomeMenuGroup(
      title: 'القرآن الكريم',
      entries: [
        const HomeMenuEntry(
          title: 'فهرس السور',
          icon: Icons.format_list_numbered_rounded,
          tabIndex: 1,
        ),
        HomeMenuEntry(
          title: 'العلامات المرجعية',
          icon: Icons.bookmark_rounded,
          pageBuilder: (_) => const BookmarksScreen(),
        ),
        HomeMenuEntry(
          title: 'تغيير خط وحجم القرآن',
          icon: Icons.text_fields_rounded,
          pageBuilder: (_) => const QuranTypographySettingsScreen(),
        ),
      ],
    ),
    HomeMenuGroup(
      title: 'الأذكار والأدعية',
      entries: [
        HomeMenuEntry(
          title: 'إشعارات الصلاة',
          icon: Icons.notifications_active_outlined,
          pageBuilder: (_) => const PrayerNotificationSettingsScreen(),
        ),
        HomeMenuEntry(
          title: 'تعديل مواقيت الصلاة',
          icon: Icons.schedule_rounded,
          pageBuilder: (_) => const PrayerTimeAdjustmentScreen(),
        ),
        HomeMenuEntry(
          title: 'الأذكار',
          icon: Icons.bookmark_border_rounded,
          pageBuilder: (_) => const HomeMenuSectionScreen(
            title: 'الأذكار',
            child: AzkarCardWidget(),
          ),
        ),
        HomeMenuEntry(
          title: 'الأدعية',
          icon: Icons.volunteer_activism_outlined,
          pageBuilder: (_) => const HomeMenuSectionScreen(
            title: 'الأدعية',
            child: DuaCardWidget(),
          ),
        ),
      ],
    ),
    HomeMenuGroup(
      title: 'الصيام',
      entries: [
        HomeMenuEntry(
          title: 'الصيام',
          icon: Icons.nightlight_round,
          pageBuilder: (_) => const FastingScreen(),
        ),
      ],
    ),
    HomeMenuGroup(
      title: 'الصلاة',
      entries: [
        HomeMenuEntry(
          title: 'إعدادات الصلاة والأذان',
          icon: Icons.settings_outlined,
          pageBuilder: (_) => const PrayerSettingsScreen(),
        ),
      ],
    ),
  ];
  final List<String> backgroundImages = [
    AppImages.moreBg,
    AppImages.quranBg,
    AppImages.hadithBg,
    AppImages.sebhaBg,
    AppImages.aiIcon,
    AppImages.moreBg,
  ];

  static const List<NavBarItem> _navItems = [
    NavBarItem(label: 'الرئيسية', icon: AppImages.islamiLogo),
    NavBarItem(label: 'القرآن', icon: AppImages.icQuran),
    NavBarItem(label: 'الحديث', icon: AppImages.icHadeth),
    NavBarItem(label: 'السبحة', icon: AppImages.icSebha),
    NavBarItem(label: 'المساعد', icon: AppImages.aiIcon, iconSize: 23),
    NavBarItem(label: 'الصلاة', icon: AppImages.icTime),
  ];

  void _openMenu() => _scaffoldKey.currentState?.openDrawer();

  void _onMenuEntrySelected(HomeMenuEntry entry) {
    final tabIndex = entry.tabIndex;
    if (tabIndex != null) {
      setState(() => selectedIndex = tabIndex);
      return;
    }

    final pageBuilder = entry.pageBuilder;
    if (pageBuilder != null) {
      Navigator.of(context).push(MaterialPageRoute<void>(builder: pageBuilder));
    }
  }

  Widget _buildBackground() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = context.palette.background;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Cross-fade between backgrounds
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: SizedBox.expand(
            key: ValueKey<int>(selectedIndex),
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(backgroundImages[selectedIndex]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        // Dark: black overlay. Light: cream overlay (stronger so the
        // dark artwork doesn't show through and hurt text contrast).
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                bg,
                bg.withValues(alpha: isDark ? 0.75 : 0.9),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<int>(selectedIndex),
        child: tabs[selectedIndex],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildBackground(),
        Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          drawer: HomeMenuDrawer(
            groups: _menuGroups,
            selectedTabIndex: selectedIndex,
            onSelected: _onMenuEntrySelected,
          ),
          body: _buildBody(),
          bottomNavigationBar: AnimatedNavBar(
            items: _navItems,
            selectedIndex: selectedIndex,
            onTap: (index) => setState(() => selectedIndex = index),
          ),
        ),
      ],
    );
  }
}
