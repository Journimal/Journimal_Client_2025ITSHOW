import 'package:flutter/material.dart';
import 'package:journimal_client/screen/home/home_screen.dart';
import 'package:journimal_client/screen/info/infomation.dart';
import 'package:journimal_client/screen/mission/mission_select.dart';
import 'package:journimal_client/screen/trip/trip.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _goToMissionScreen() {
    setState(() {
      _selectedIndex = 1; // MissionSelectScreen으로 전환
    });
  }

  // 각 탭에 해당하는 화면 리스트 - IndexedStack에서 사용
  late final List<Widget> _screens = [
    HomeScreen(onMissionSelect: _goToMissionScreen),
    MissionSelectScreen(),
    TripScreen(),
    InfromationScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory, // 물결 효과 제거
      ),
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: SizedBox(
          height: 100,
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            backgroundColor: Colors.white,
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
