import 'package:flutter/material.dart';
import 'package:real_amis/common/helpers/is_dark_mode.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/presentation/history/pages/history_page.dart';
import 'package:real_amis/presentation/match/pages/matches_page.dart';
import 'package:real_amis/presentation/player/pages/players_page.dart';
import 'package:real_amis/presentation/settings/pages/settings_page.dart';
import 'package:real_amis/presentation/team/pages/teams_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (_) => const MainPage());

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final PageStorageBucket _bucket = PageStorageBucket();

  List<Widget> get _pages => const [
    MatchesPage(),
    PlayersPage(),
    TeamsPage(),
    HistoryPage(),
    SettingsPage(),
  ];

  List<BottomNavigationBarItem> get _navItems => const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Partite'),
    BottomNavigationBarItem(
      icon: Icon(Icons.sports_soccer),
      label: 'Giocatori',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.flag_circle_outlined),
      label: 'Squadre',
    ),
    BottomNavigationBarItem(icon: Icon(Icons.fmd_good_sharp), label: 'Storia'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Impostazioni'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;

    final bgColor = isDarkMode ? AppColors.bgDark : AppColors.primary;
    final selectedColor = isDarkMode ? AppColors.tertiary : AppColors.tertiary;
    final unselectedColor = isDarkMode ? AppColors.accent : AppColors.accent;

    return Scaffold(
      body: PageStorage(
        bucket: _bucket,
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages
              .map(
                (page) => PageStorage(
                  bucket: _bucket,
                  key: PageStorageKey(page.runtimeType),
                  child: page,
                ),
              )
              .toList(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        iconSize: 28,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        selectedItemColor: selectedColor,
        unselectedItemColor: unselectedColor,
        backgroundColor: bgColor,
        items: _navItems
            .map(
              (item) => BottomNavigationBarItem(
                icon: Tooltip(message: item.label ?? '', child: item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
