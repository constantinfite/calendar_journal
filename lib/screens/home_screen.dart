import 'package:flutter/material.dart';
import 'package:calendar_journal/presentation/icons.dart';

import 'package:calendar_journal/screens/stats_screen.dart';
import 'package:calendar_journal/presentation/app_theme.dart';
import 'package:calendar_journal/screens/list_exercice_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> screens = [StatsScreen(), ListExerciceScreen()];

  String _title = "EXERCICES";

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        {
          _title = 'EXERCICES';
        }
        break;
      case 1:
        {
          _title = 'STATS';
        }
        break;
    }
  }

  String formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes;
    final seconds = totalSeconds % 60;

    final minutesString = '$minutes'.padLeft(1, '0');
    final secondsString = '$seconds'.padLeft(2, '0');
    return '$minutesString min $secondsString s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.redColor,
      appBar: AppBar(
        toolbarHeight: 100,
        elevation: 0,
        backgroundColor: AppTheme.colors.backgroundColor,
        title: Text(
          _title,
          style: TextStyle(
            color: AppTheme.colors.secondaryColor,
            fontSize: 35,
            fontFamily: 'BalooBhai',
          ),
        ),
        centerTitle: true,
        actions: [
          Icon(Icons.more_vert),
        ],
        actionsIconTheme: IconThemeData(
          color: AppTheme.colors.secondaryColor,
          size: 36,
        ),
      ),
      body: screens[_selectedIndex],
      //drawer: const DrawerNavigation(),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(MyFlutterApp.noun_list),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(MyFlutterApp.noun_stat),
            label: 'Stats',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.colors.redColor,
        onTap: (int index) {
          _onItemTapped(index);
        },
      ),
    );
  }
}
