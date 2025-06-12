import 'package:flutter/material.dart';
import 'package:journimal_client/screen/home/home_screen.dart';
import 'package:journimal_client/screen/info/infomation.dart';
import 'package:journimal_client/screen/mission/mission_select.dart';
import 'package:journimal_client/screen/trip/trip.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // 각 탭에 해당하는 화면 리스트
  final List<Widget> _screens = [
    HomeScreen(),
    MissionSelectScreen(),
    TripScreen(),
    InfromationScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory, // 물결 효과 제거
      ),
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: SizedBox(
          height: 100,
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Color(0xff022169),
            unselectedItemColor: Color(0xffD9D9D9),
            selectedLabelStyle: TextStyle(fontSize: 12),
            unselectedLabelStyle: TextStyle(fontSize: 12),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.track_changes_outlined),
                label: 'Mission',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.mode_of_travel_rounded),
                label: 'My trip',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_2_outlined),
                label: 'Info',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
