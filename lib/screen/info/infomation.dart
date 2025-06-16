import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mission_provider.dart';
import 'package:journimal_client/models/mission.dart';

class InfromationScreen extends StatefulWidget {
  const InfromationScreen({Key? key}) : super(key: key);

  @override
  State<InfromationScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfromationScreen> {
  @override
  void initState() {
    super.initState();
    // context 안전하게 접근
    final provider = Provider.of<MissionProvider>(context, listen: false);
    provider.fetchUserName();
    provider.fetchAnimalImage();
    provider.fetchAnimalLevel();
    provider.fetchMission();
  }

  final int tripCount = 1;
  final int completedMissionCount = 2;

  @override
  Widget build(BuildContext context) {
    final missionProvider = Provider.of<MissionProvider>(context);

    const navyColor = Color(0xFF022169);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 유저 프로필 영역
              Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xffCCCCCC),
                    child: Icon(Icons.person, size: 38, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${missionProvider.userName}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff666666),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 통계 카드 3개
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoCard(
                      icon: Icons.flight_takeoff_rounded,
                      label: 'TRIP',
                      value: '$tripCount'),
                  _animalCard(),
                  _infoCard(
                      icon: Icons.language,
                      label: 'Completed\nMission',
                      value: '$completedMissionCount'),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'Current Mission',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: navyColor,
                ),
              ),
              const Divider(thickness: 2, color: navyColor, endIndent: 200),
              const SizedBox(height: 26),
              missionProvider.selectedMissions.isEmpty
                  ? const Center(
                      child: Text(
                        'Nothing...\nPlease Add the mission...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff022169),
                        ),
                      ),
                    )
                  : Column(
                      children: missionProvider.selectedMissions
                          .map((mission) => _missionCard(mission))
                          .toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(
      {required IconData icon, required String label, required String value}) {
    return Container(
      width: 100,
      height: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // 수직 정렬
        crossAxisAlignment: CrossAxisAlignment.center, // 수평 정렬
        children: [
          Icon(icon, color: Color(0xff022169), size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xff022169),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              color: Color(0xff022169),
            ),
          ),
        ],
      ),
    );
  }

  Widget _animalCard() {
    final missionProvider = context.watch<MissionProvider>();

    return Container(
      width: 100,
      height: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // 수직 정렬
        crossAxisAlignment: CrossAxisAlignment.center, // 수평 정렬
        children: [
          Image.network(
            missionProvider.animalImageUrl ?? '',
            height: 50,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.pets, size: 28),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 3),
            decoration: BoxDecoration(
              color: missionProvider.pointColor,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              missionProvider.animalCategory,
              style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _missionCard(Mission mission) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFF0F0F0),
            backgroundImage: NetworkImage(mission.missionIcon),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              mission.missionName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Pretendard',
                color: Color(0xff424242),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
