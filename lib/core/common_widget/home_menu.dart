import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islami/core/theme/app_palette.dart';
import 'package:islami/core/theme/theme_cubit.dart';

import '../theme/text_style_helper.dart';

class HomeMenuEntry {
  const HomeMenuEntry({
    required this.title,
    required this.icon,
    this.tabIndex,
    this.pageBuilder,
  }) : assert(tabIndex != null || pageBuilder != null);

  final String title;
  final IconData icon;
  final int? tabIndex;
  final WidgetBuilder? pageBuilder;
}

class HomeMenuGroup {
  const HomeMenuGroup({required this.title, required this.entries});

  final String title;
  final List<HomeMenuEntry> entries;
}

class HomeMenuDrawer extends StatelessWidget {
  const HomeMenuDrawer({
    super.key,
    required this.groups,
    required this.selectedTabIndex,
    required this.onSelected,
  });

  final List<HomeMenuGroup> groups;
  final int selectedTabIndex;
  final ValueChanged<HomeMenuEntry> onSelected;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Drawer(
      backgroundColor: p.background,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                decoration: BoxDecoration(
                  color: p.primary.withValues(alpha: 0.12),
                  border: Border(
                    bottom: BorderSide(
                      color: p.primary.withValues(alpha: 0.25),
                    ),
                  ),
                ),
                child: Text(
                  'القائمة الرئيسية',
                  textAlign: TextAlign.right,
                  style: TextStylesHelper.largeBodyTextStyle(
                    context,
                    textColor: p.primary,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  children: [
                    for (final group in groups) ...[
                      _GroupTitle(title: group.title),
                      for (final entry in group.entries)
                        _MenuTile(
                          entry: entry,
                          selected: entry.tabIndex == selectedTabIndex,
                          onTap: () {
                            Navigator.of(context).pop();
                            onSelected(entry);
                          },
                        ),
                    ],
                    const _GroupTitle(title: 'المظهر'),
                    const _ThemeModeSelector(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 14, 20, 6),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          title,
          style: TextStylesHelper.smallLabelTextStyle(
            context,
            textColor: context.palette.primary.withValues(alpha: 0.75),
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.entry,
    required this.selected,
    required this.onTap,
  });

  final HomeMenuEntry entry;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return ListTile(
      selected: selected,
      selectedTileColor: p.primary.withValues(alpha: 0.1),
      leading: Icon(
        entry.icon,
        color: selected
            ? p.primary
            : p.onBackground.withValues(alpha: 0.8),
      ),
      title: Text(
        entry.title,
        textAlign: TextAlign.right,
        style: TextStylesHelper.mediumBodyTextStyle(
          context,
          textColor: selected ? p.primary : p.onBackground,
        ),
      ),
      onTap: onTap,
    );
  }
}

/// Single animated light / dark control shown at the bottom of the drawer.
class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDark = context.watch<ThemeCubit>().state.isDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsetsDirectional.fromSTEB(14, 6, 8, 6),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.primary.withValues(alpha: .22)),
        ),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) => RotationTransition(
                turns: Tween<double>(begin: .8, end: 1).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                key: ValueKey(isDark),
                color: p.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  isDark ? 'الوضع الداكن' : 'الوضع الفاتح',
                  key: ValueKey(isDark),
                  style: TextStylesHelper.mediumBodyTextStyle(
                    context,
                    textColor: p.onBackground,
                  ),
                ),
              ),
            ),
            Switch.adaptive(
              value: isDark,
              activeColor: p.primary,
              onChanged: (_) => context.read<ThemeCubit>().toggle(),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeMenuSectionScreen extends StatelessWidget {
  const HomeMenuSectionScreen({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: p.background,
        appBar: AppBar(
          title: Text(title),
          centerTitle: true,
          backgroundColor: p.background,
          foregroundColor: p.primary,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            child: child,
          ),
        ),
      ),
    );
  }
}





