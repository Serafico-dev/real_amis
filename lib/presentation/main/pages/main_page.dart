import 'package:flutter/material.dart';
import 'package:real_amis/core/configs/theme/app_colors.dart';
import 'package:real_amis/presentation/history/pages/history_page.dart';
import 'package:real_amis/presentation/match/pages/matches_page.dart';
import 'package:real_amis/presentation/player/pages/players_page.dart';
import 'package:real_amis/presentation/settings/pages/settings_page.dart';
import 'package:real_amis/presentation/team/pages/teams_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => MainPage());

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  List<Widget> pages = [
    MatchesPage(),
    PlayersPage(),
    TeamsPage(),
    HistoryPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 35,
        backgroundColor: AppColors.primary,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: AppColors.tertiary,
        unselectedItemColor: AppColors.quaternary,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Partite'),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Giocatori',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_circle_outlined),
            label: 'Squadre',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fmd_good_sharp),
            label: 'Storia',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Impostazioni',
          ),
        ],
      ),
    );
  }
}
