import 'package:flutter/material.dart';
import 'package:calendar_journal/presentation/icons.dart';
import 'package:calendar_journal/helpers/drawer_navigation.dart';
import 'package:calendar_journal/screens/calendar_screen.dart';
import 'package:calendar_journal/presentation/app_theme.dart';
import 'package:calendar_journal/screens/list_event_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> screens = [CalendarScreen(), ListEventScreen()];

  String _title = "";

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
          _title = 'Calendar';
        }
        break;
      case 1:
        {
          _title = 'To do';
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.greenColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 39, 39, 39),
        centerTitle: true,
        title: Text(
          "Calendar",
          style: TextStyle(
            color: AppTheme.colors.backgroundColor,
            fontSize: 30,
            fontFamily: 'BalooBhai',
          ),
        ),
      ),
      body: screens[_selectedIndex],
      //drawer: const DrawerNavigation(),
      drawer: DrawerNavigaton(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              MyFlutterApp.noun_calendar,
              size: 30,
            ),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              MyFlutterApp.noun_list,
            ),
            label: 'Todo',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.colors.greenColor,
        onTap: (int index) {
          _onItemTapped(index);
        },
      ),
    );
  }
}
