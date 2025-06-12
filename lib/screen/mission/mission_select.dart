import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:journimal_client/services/token_service.dart';

class MissionSelectScreen extends StatefulWidget {
  const MissionSelectScreen({super.key});

  @override
  State<MissionSelectScreen> createState() => _MissionSelectScreenState();
}

class Mission {
  final int id;
  final String missionName;
  final String missionIcon;

  Mission({
    required this.id,
    required this.missionName,
    required this.missionIcon,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'],
      missionName: json['missionName'],
      missionIcon: json['missionIcon'],
    );
  }
}

class _MissionSelectScreenState extends State<MissionSelectScreen> {
  late Future<List<Mission>> _missionsFuture;

  @override
  void initState() {
    super.initState();
    _missionsFuture = fetchMissions();
  }

  final TokenService _tokenService = TokenService();

  Future<List<Mission>> fetchMissions() async {
    final apiUrl = dotenv.env['API_URL']!;
    final getMissionUrl = '$apiUrl/mission';

    final token = await _tokenService.getToken();

    final response = await http.get(
      Uri.parse(getMissionUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      return data.map((json) => Mission.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load missions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildMissionSlot(),
                    const SizedBox(width: 18),
                    _buildMissionSlot(),
                    const SizedBox(width: 18),
                    _buildMissionSlot(),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: FutureBuilder<List<Mission>>(
                  future: _missionsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else {
                      final missions = snapshot.data!;
                      return ListView.separated(
                        itemCount: missions.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          color: Color(0xffDEDEDE),
                        ),
                        itemBuilder: (context, index) {
                          final mission = missions[index];
                          return ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 20),
                            leading: Image.network(
                              mission.missionIcon,
                            ),
                            title: Text(
                              mission.missionName,
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff424242),
                              ),
                            ),
                            trailing: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Color(0xFF022169),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                // TODO: Add mission to selection
                              },
                              child: const Text(
                                "Add",
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionSlot() {
    return DottedBorder(
        color: Color(0xffDEDEDE),
        dashPattern: [6, 3],
        borderType: BorderType.RRect,
        radius: Radius.circular(16),
        child: Container(
          height: 150,
          width: 150,
          alignment: Alignment.center,
          child: Icon(
            Icons.add,
            color: Color(0xffDEDEDE),
            size: 32,
          ),
        ));
  }
}
