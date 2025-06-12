import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mission_provider.dart';
import 'package:dotted_border/dotted_border.dart';

class HomeScreen extends StatefulWidget {
  final Function onMissionSelect;

  const HomeScreen({super.key, required this.onMissionSelect});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
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

  @override
  Widget build(BuildContext context) {
    final missionProvider = Provider.of<MissionProvider>(context);

    return Scaffold(
      backgroundColor: missionProvider.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 90),

            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Day counter
                  Text(
                    'Day ${missionProvider.dayCount}',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff424242),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Username greeting
                  Text(
                    'Hi, ${missionProvider.userName}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xff424242),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),

            // Animal image
            ClipRRect(
              child: Image.network(
                missionProvider.animalImageUrl ?? '',
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(60),
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 50),

            // Category and progress
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 40),
              child: Container(
                width: 42,
                height: 18,
                decoration: BoxDecoration(
                  color: missionProvider.pointColor,
                  borderRadius: BorderRadius.circular(2),
                ),
                alignment: Alignment.center,
                child: Text(
                  missionProvider.animalCategory,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 5),

            // Progress bar
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 274,
                  height: 13,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: missionProvider.progressPercentage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: missionProvider.pointColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Text(
                  '${missionProvider.completeMission} / ${missionProvider.totalMission}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff666666),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Current Mission section
            Container(
              width: 340,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF022169),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    width: 287,
                    height: 27,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(6)),
                    alignment: Alignment.center,
                    child: Text(
                      "Current Mission",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 13),

                  // Dashed border container
                  GestureDetector(
                    onTap: () {
                      widget.onMissionSelect();
                    },
                    child: DottedBorder(
                      color: Colors.white,
                      dashPattern: [6, 3], // 6픽셀 그리고 3픽셀 쉬기
                      borderType: BorderType.RRect,
                      radius: Radius.circular(8),
                      child: Container(
                        height: 62,
                        width: 287,
                        alignment: Alignment.center,
                        child: Text(
                          "You haven't chosen your mission yet :(\nClick here to choose missions!",
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
