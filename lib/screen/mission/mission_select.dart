import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:journimal_client/providers/mission_provider.dart'; // 경로 확인

class MissionSelectScreen extends StatefulWidget {
  const MissionSelectScreen({super.key});

  @override
  State<MissionSelectScreen> createState() => _MissionSelectScreenState();
}

class _MissionSelectScreenState extends State<MissionSelectScreen> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MissionProvider>(context, listen: false);
    provider.fetchAvailableMissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Consumer<MissionProvider>(
            builder: (context, provider, child) {
              final selectedMissions = provider.selectedMissions;
              final allMissions = provider.allMissions;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today’s Mission",
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff424242),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Let’s make your Eco-trip by choosing the mission you want.",
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xffB3B3B3),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 선택된 미션
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(provider.totalMission, (index) {
                        if (index < selectedMissions.length) {
                          final mission = selectedMissions[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 18),
                            child: Container(
                              width: 154,
                              height: 154,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0x1A000000),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border:
                                    Border.all(color: const Color(0xffF0F0F0)),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 12),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.network(
                                    mission.icon,
                                    width: 36,
                                    height: 36,
                                  ),
                                  Text(
                                    mission.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF424242),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 28,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        // 인증하기 로직 (아직 구현 안됨)
                                      },
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: mission.isCertified
                                            ? const Color(0xFFCCCCCC)
                                            : const Color(0xFF022169),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                        side: BorderSide.none,
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        mission.isCertified
                                            ? "Done"
                                            : "Certifying",
                                        style: const TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.only(right: 18),
                            child: _buildMissionSlot(),
                          );
                        }
                      }),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 전체 미션 목록
                  Expanded(
                    child: ListView.separated(
                      itemCount: allMissions.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        color: Color(0xffDEDEDE),
                      ),
                      itemBuilder: (context, index) {
                        final mission = allMissions[index];
                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 15),
                          leading: Image.network(mission.icon,
                              width: 40, height: 40),
                          title: Text(
                            mission.name,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff424242),
                            ),
                          ),
                          trailing: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: mission.isSelected
                                  ? const Color(0xFFCCCCCC)
                                  : const Color(0xFF022169),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              provider.toggleMissionSelection(mission);
                            },
                            child: Text(
                              mission.isSelected ? "Cancel" : "Add",
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMissionSlot() {
    return DottedBorder(
      color: const Color(0xffDEDEDE),
      dashPattern: [6, 3],
      borderType: BorderType.RRect,
      radius: const Radius.circular(16),
      child: Container(
        height: 150,
        width: 150,
        alignment: Alignment.center,
        child: const Icon(
          Icons.add,
          color: Color(0xffDEDEDE),
          size: 32,
        ),
      ),
    );
  }
}
