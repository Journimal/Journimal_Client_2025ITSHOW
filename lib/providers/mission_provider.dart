import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:journimal_client/services/token_service.dart';
import 'dart:convert';
import 'package:journimal_client/models/mission.dart'; // Mission 모델이 분리되어 있다면 import

class MissionProvider with ChangeNotifier {
  DateTime _startDate = DateTime.now(); // 여행 시작 날짜 (API에서 불러올 예정)

  // 여행 시작일로부터 며칠이 지났는지 계산
  int get dayCount {
    final difference = DateTime.now().difference(_startDate).inDays;
    return difference + 1; // Day 1부터 시작
  }

  String _userName = '';
  String get userName => _userName;

  void setUserName(String name) {
    _userName = name;
  }

  final TokenService _tokenService = TokenService();
  Future<void> fetchUserName() async {
    final apiUrl = dotenv.env['API_URL']!;
    final getUserNameUrl = '$apiUrl/user/name';

    final token = await _tokenService.getToken();

    final response = await http.get(
      Uri.parse(getUserNameUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final name = data['data']['userNickname'];
      setUserName(name);
      notifyListeners();
      debugPrint('이름: $name');
    } else {
      debugPrint('이름 가져오기 실패');
    }
  }

  int _completeMission = 0;
  int get completeMission => _completeMission;
  set completeMission(int completeMission) {
    _completeMission = completeMission;
    notifyListeners();
  }

  int get totalMission {
    switch (_animalLevel.toLowerCase()) {
      case 'vu':
        return 2;
      case 'eu':
        return 4;
      case 'ce':
        return 6;
      default:
        return 2;
    }
  }

  double get progressPercentage {
    return _completeMission / totalMission;
  }

  Future<void> fetchMission() async {
    try {
      final apiUrl = dotenv.env['API_URL']!;
      final tripUrl = '$apiUrl/trip';

      final token = await _tokenService.getToken();

      final response = await http.get(
        Uri.parse(tripUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final trips = data['data'] as List;

        if (trips.isNotEmpty) {
          trips.sort((a, b) => b['id'].compareTo(a['id']));
          final latestTrip = trips.first;

          _completeMission = latestTrip['completeMission'] ?? 0;
          notifyListeners();
        } else {
          debugPrint('여행 데이터가 없습니다.');
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Mission 가져오기 중 오류 발생: $e');
      notifyListeners();
    }
  }

  String _animalLevel = 'vu';
  String get animalLevel => _animalLevel;
  set animalLevel(String level) {
    _animalLevel = level;
    notifyListeners();
  }

  Color get backgroundColor {
    switch (_animalLevel.toLowerCase()) {
      case 'vu':
        return const Color(0xFFF7E7B9); // Gold
      case 'eu':
        return const Color(0xFFF3CFAE); // Orange
      case 'ce':
        return const Color(0xFFDFA4AB); // Red
      default:
        return Colors.grey; // 기본값
    }
  }

  Color get pointColor {
    switch (_animalLevel.toLowerCase()) {
      case 'vu':
        return const Color(0xFFFAD160); // Gold
      case 'eu':
        return const Color(0xFFF09543); // Orange
      case 'ce':
        return const Color(0xFFBD2B3D); // Red
      default:
        return Colors.grey; // 기본값
    }
  }

  String get animalCategory {
    switch (_animalLevel.toLowerCase()) {
      case 'vu':
        return 'VU';
      case 'eu':
        return 'EU';
      case 'ce':
        return 'CE';
      default:
        return 'Unknown';
    }
  }

  Future<void> fetchAnimalLevel() async {
    try {
      final apiUrl = dotenv.env['API_URL']!;
      final tripUrl = '$apiUrl/trip';

      final token = await _tokenService.getToken();

      final response = await http.get(
        Uri.parse(tripUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final trips = data['data'] as List;
        if (trips.isNotEmpty) {
          trips.sort((a, b) => b['id'].compareTo(a['id']));
          final latestTrip = trips.first;

          if (latestTrip['lastAnimal'] != null) {
            final aniLevel = latestTrip['lastAnimal']['aniLevel'];
            _animalLevel = aniLevel;
            debugPrint('현재 level: $_animalLevel');
          } else {
            debugPrint('lastAnimal 데이터가 없습니다.');
            _animalImageUrl = null;
          }
          notifyListeners();
        } else {
          debugPrint('여행 데이터가 없습니다.');
          notifyListeners();
        }
      } else {
        debugPrint('animal level 가져오기 실패: ${response.statusCode}');
        debugPrint('응답 내용: ${response.body}');
      }
    } catch (e) {
      debugPrint('animal level 가져오기 중 오류 발생: $e');
      notifyListeners();
    }
  }

  String? _animalImageUrl;
  String? get animalImageUrl => _animalImageUrl;

  Future<void> fetchAnimalImage() async {
    try {
      final apiUrl = dotenv.env['API_URL']!;
      final tripUrl = '$apiUrl/trip';

      final token = await _tokenService.getToken();

      final response = await http.get(
        Uri.parse(tripUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final trips = data['data'] as List;

        if (trips.isNotEmpty) {
          trips.sort((a, b) => b['id'].compareTo(a['id']));
          final latestTrip = trips.first;
          if (latestTrip['lastAnimal'] != null) {
            final imageUrl = latestTrip['lastAnimal']['aniImage'];
            _animalImageUrl = imageUrl;
            debugPrint('동물 이미지 URL: $_animalImageUrl');
          } else {
            debugPrint('lastAnimal 데이터가 없습니다.');
            _animalImageUrl = null;
          }
          notifyListeners();
        } else {
          debugPrint('여행 데이터가 없습니다.');
          _animalImageUrl = null;
          notifyListeners();
        }
      } else {
        debugPrint('동물 이미지 가져오기 실패: ${response.statusCode}');
        debugPrint('응답 내용: ${response.body}');
      }
    } catch (e) {
      debugPrint('동물 이미지 가져오기 중 오류 발생: $e');
      _animalImageUrl = null;
      notifyListeners();
    }
  }

  List<Mission> _allMissions = [];
  List<Mission> get allMissions => _allMissions;

  List<Mission> get selectedMissions =>
      _allMissions.where((m) => m.isSelected).toList();
  List<Mission> get unselectedMissions =>
      _allMissions.where((m) => !m.isSelected).toList();

  List<Mission> get certifiedMissions =>
      _allMissions.where((m) => m.isCertified).toList();
  List<Mission> get uncertifiedMissions =>
      _allMissions.where((m) => !m.isCertified).toList();
  Future<void> fetchAvailableMissions() async {
    try {
      final apiUrl = dotenv.env['API_URL']!;
      final missionsUrl = '$apiUrl/mission';

      final token = await _tokenService.getToken();

      final response = await http.get(
        Uri.parse(missionsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        _allMissions = data.map((e) => Mission.fromJson(e)).toList();
        notifyListeners();
      } else {
        debugPrint('미션 목록 가져오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('미션 목록 오류: $e');
    }
  }

  void toggleMissionSelection(Mission mission) {
    if (mission.isSelected) {
      mission.isSelected = false;
    } else {
      if (selectedMissions.length < totalMission) {
        mission.isSelected = true;
      } else {
        debugPrint('최대 선택 미션 수 초과');
      }
    }
    notifyListeners();
  }

  void toggleMissionCertified(Mission mission) {
    if (mission.isCertified) {
      mission.isCertified = false;
    } else {
      if (selectedMissions.length < totalMission) {
        mission.isCertified = true;
      } else {
        debugPrint('최대 선택 미션 수 초과');
      }
    }
    notifyListeners();
  }
}
