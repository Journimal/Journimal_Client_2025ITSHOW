import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:journimal_client/services/token_service.dart';
import 'dart:convert';

class MissionProvider with ChangeNotifier {
  int _completedMissions = 0;
  DateTime _startDate = DateTime.now(); // 여행 시작 날짜 (API에서 불러올 예정)

  int get completedMissions => _completedMissions;

  // 여행 시작일로부터 며칠이 지났는지 계산
  int get dayCount {
    final difference = DateTime.now().difference(_startDate).inDays;
    return difference + 1; // Day 1부터 시작
  }

  // 진행률 계산 (0.0 ~ 1.0)
  double get progressPercentage {
    return _completedMissions / 2; // 총 2개 미션 기준
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

  void completeMission() {
    if (_completedMissions < 2) {
      _completedMissions++;
      notifyListeners();
    }
  }

  // API에서 미션 완료 상태 로드
  void loadMissionProgress(int completedCount) {
    _completedMissions = completedCount;
    notifyListeners();
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
        // data['data']로 접근해야 함 (data['id']가 아닌)
        final trips = data['data'] as List;

        if (trips.isNotEmpty) {
          // trip id 기준으로 내림차순 정렬 (가장 최근 항목이 먼저 오도록)
          trips.sort((a, b) => b['id'].compareTo(a['id']));

          // 가장 최근 trip 선택
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

        // data['data']로 접근해야 함 (data['id']가 아닌)
        final trips = data['data'] as List;

        if (trips.isNotEmpty) {
          // trip id 기준으로 내림차순 정렬 (가장 최근 항목이 먼저 오도록)
          trips.sort((a, b) => b['id'].compareTo(a['id']));

          // 가장 최근 trip 선택
          final latestTrip = trips.first;

          // lastAnimal이 존재하는지 확인하고 aniImage 가져오기
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
}
