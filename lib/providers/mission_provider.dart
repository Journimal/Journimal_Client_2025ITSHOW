import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:journimal_client/services/token_service.dart';
import 'dart:convert';
import 'package:journimal_client/models/mission.dart';
import 'package:journimal_client/models/trip.dart';

class MissionProvider extends ChangeNotifier {
  DateTime _startDate = DateTime.now(); // 여행 시작 날짜 (API에서 불러올 예정)
  final TokenService _tokenService = TokenService();

  // 여행 시작일로부터 며칠이 지났는지 계산
  int get dayCount {
    final difference = DateTime.now().difference(_startDate).inDays;
    return difference + 1; // Day 1부터 시작
  }

  String _userName = '';
  String get userName => _userName;

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  Future<void> fetchUserName() async {
    final apiUrl = dotenv.env['API_URL']!;
    final getUserNameUrl = '$apiUrl/user/name';

    final token = await _tokenService.getToken();

    try {
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
        debugPrint('이름: $name');
      } else {
        debugPrint('이름 가져오기 실패');
      }
    } catch (e) {
      debugPrint('이름 가져오기 중 오류 발생: $e');
    }
  }

  int _completeMission = 0;
  int get completeMission => _completeMission;
  set completeMission(int completeMission) {
    _completeMission = completeMission;
    notifyListeners();
  }

  String _animalLevel = 'vu';
  String get animalLevel => _animalLevel;
  set animalLevel(String level) {
    _animalLevel = level;
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

  String? _animalImageUrl;
  String? get animalImageUrl => _animalImageUrl;

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

  // missionSelect화면에서 미션 리스트를 보여줌
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
        }
      }
    } catch (e) {
      debugPrint('Mission 가져오기 중 오류 발생: $e');
    }
  }

  // 홈화면에서 동물 레벨에 따라 테마가 바뀌는 함수
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
          }
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('animal level 가져오기 중 오류 발생: $e');
    }
  }

  // 홈화면에서 동물 이미지 불러오는 함수
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
          }
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('동물 이미지 가져오기 중 오류 발생: $e');
    }
  }

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

  // 현재 여행 정보를 저장할 변수 추가
  Trip? _currentTrip;
  Trip? get currentTrip => _currentTrip;

// 현재 여행 정보를 가져오는 함수
  Future<void> fetchCurrentTrip() async {
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
          _currentTrip = Trip.fromJson(latestTrip);

          // 기존 로직들도 여기서 함께 처리
          _completeMission = latestTrip['completeMission'] ?? 0;

          if (latestTrip['lastAnimal'] != null) {
            final aniLevel = latestTrip['lastAnimal']['aniLevel'];
            _animalLevel = aniLevel;
            final imageUrl = latestTrip['lastAnimal']['aniImage'];
            _animalImageUrl = imageUrl;
          }

          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Current Trip 가져오기 중 오류 발생: $e');
    }
  }

  // 방법 1: missionId로 삭제하는 경우
  Future<void> toggleMissionSelection(Mission mission) async {
    if (_currentTrip == null) {
      debugPrint('현재 여행 정보가 없습니다.');
      return;
    }

    try {
      final apiUrl = dotenv.env['API_URL']!;
      final token = await _tokenService.getToken();

      if (mission.isSelected) {
        // 미션이 이미 선택되어 있다면 DELETE 요청
        // URL에 missionId를 포함
        final deleteUrl = '$apiUrl/mission/${mission.id}';

        final response = await http.delete(
          Uri.parse(deleteUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          mission.isSelected = false;
          debugPrint('미션 선택 취소 성공');
        } else {
          debugPrint('미션 선택 취소 실패: ${response.statusCode}');
          debugPrint('응답 내용: ${response.body}');
        }
      } else {
        // 미션이 선택되어 있지 않다면 POST 요청
        final createUrl = '$apiUrl/mission/choose';

        // aniLevel 값을 기반으로 round 설정
        final aniLevel = _currentTrip!.lastAnimal?.aniLevel?.toUpperCase();
        int round;

        switch (aniLevel) {
          case 'VU':
            round = 1;
            break;
          case 'EU':
            round = 2;
            break;
          case 'CE':
            round = 3;
            break;
          default:
            debugPrint('알 수 없는 aniLevel: $aniLevel');
            return;
        }

        final response = await http.post(
          Uri.parse(createUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            "tripId": _currentTrip!.id,
            "missionId": mission.id,
            "round": round,
            "isCompleted": mission.isCertified,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          mission.isSelected = true;
          debugPrint('미션 선택 성공');
        } else {
          debugPrint('미션 선택 실패: ${response.statusCode}');
          debugPrint('응답 내용: ${response.body}');
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('미션 선택/취소 오류: $e');
    }
  }

  void toggleMissionCertified(Mission mission) {
    mission.isCertified = !mission.isCertified;
    if (mission.isCertified) {
      _completeMission++;
    } else {
      _completeMission--;
    }
    notifyListeners();
  }

  Future<bool> certifyMission(
      Mission mission, Map<String, String> answers) async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final certifyUrl = '$apiUrl/mission/certify';

      final token = await _tokenService.getToken();
      final response = await http.post(
        Uri.parse(certifyUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'missionId': mission.id,
          'answers': answers,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        toggleMissionCertified(mission);
        return true;
      } else {
        debugPrint('미션 인증 실패: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('미션 인증 중 오류 발생: $e');
      return false;
    }
  }
}
