import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:journimal_client/services/token_service.dart';
import 'dart:convert';
import 'package:journimal_client/models/mission.dart';
import 'package:journimal_client/models/trip.dart';

class MissionProvider extends ChangeNotifier {
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initializeIfNeeded() async {
    if (!_isInitialized) {
      await fetchCurrentTrip();
      await fetchMissionsWithUserData();
      _isInitialized = true;
    }
  }

  DateTime _startDate = DateTime.now();
  final TokenService _tokenService = TokenService();

  int get dayCount {
    final difference = DateTime.now().difference(_startDate).inDays;
    return difference + 1;
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
        return const Color(0xFFF7E7B9);
      case 'eu':
        return const Color(0xFFF3CFAE);
      case 'ce':
        return const Color(0xFFDFA4AB);
      default:
        return Colors.grey;
    }
  }

  Color get pointColor {
    switch (_animalLevel.toLowerCase()) {
      case 'vu':
        return const Color(0xFFFAD160);
      case 'eu':
        return const Color(0xFFF09543);
      case 'ce':
        return const Color(0xFFBD2B3D);
      default:
        return Colors.grey;
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

  Trip? _currentTrip;
  Trip? get currentTrip => _currentTrip;

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

  Future<void> toggleMissionSelection(Mission mission) async {
    if (_currentTrip == null) {
      debugPrint('현재 여행 정보가 없습니다.');
      return;
    }

    try {
      final apiUrl = dotenv.env['API_URL']!;
      final token = await _tokenService.getToken();

      final tripId = _currentTrip!.id;
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

      if (mission.isSelected) {
        // 🔴 미션 선택 취소
        if (mission.userMissionId == null) {
          debugPrint('userMissionId가 null입니다. 미션을 선택 취소할 수 없습니다.');
          return;
        }

        final deleteUrl = '$apiUrl/mission/${mission.userMissionId}';
        final response = await http.delete(
          Uri.parse(deleteUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          mission.isSelected = false;
          mission.userMissionId = null;
          debugPrint('미션 선택 취소 성공');
        } else {
          debugPrint('미션 선택 취소 실패: ${response.statusCode}');
          debugPrint('응답 내용: ${response.body}');
        }
      } else {
        // ✅ 선택 전에 현재 선택된 미션이 있는지 확인
        final currentMissionUrl = '$apiUrl/mission/current';
        final currentMissionResponse = await http.get(
          Uri.parse(currentMissionUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (currentMissionResponse.statusCode == 200) {
          final currentData = jsonDecode(currentMissionResponse.body);
          final userMissions = currentData['data']?['userMissions'] ?? [];

          final alreadySelected = userMissions
              .any((m) => m['round'] == round && m['missionId'] == mission.id);

          if (alreadySelected) {
            debugPrint('이미 이 라운드에 같은 미션이 선택되어 있습니다.');
            return;
          }
        } else {
          debugPrint('현재 미션 조회 실패: ${currentMissionResponse.statusCode}');
        }

        // 🟢 미션 선택 요청
        final createUrl = '$apiUrl/mission/choose';
        final response = await http.post(
          Uri.parse(createUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            "tripId": tripId,
            "missionId": mission.id,
            "round": round,
            "isCompleted": mission.isCertified,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = jsonDecode(response.body);
          debugPrint('미션 선택 응답 전체: $responseData');

          final userMissionId = responseData['data']?['id'];
          if (userMissionId != null) {
            mission.userMissionId = userMissionId;
            mission.isSelected = true;
            debugPrint('미션 선택 성공, userMissionId: ${mission.userMissionId}');
          } else {
            debugPrint('응답 데이터에서 ID를 찾을 수 없습니다: $responseData');
          }
        } else if (response.statusCode == 409) {
          debugPrint('해당 라운드에 이미 다른 미션이 선택되어 있습니다.');
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

  // 🔧 수정된 CertifedMission 메서드 - 올바른 API URL 사용
  Future<bool> CertifedMission({
    required Mission mission,
    required Map<String, String> answers,
    required bool isSuccessful,
  }) async {
    if (_currentTrip == null) {
      debugPrint('현재 여행 정보가 없습니다.');
      return false;
    }

    if (mission.userMissionId == null) {
      debugPrint('userMissionId가 null입니다. 미션을 완료할 수 없습니다.');
      return false;
    }

    try {
      final apiUrl = dotenv.env['API_URL']!;
      final url = '$apiUrl/mission/${mission.userMissionId}'; // 🔧 올바른 URL 구조
      debugPrint('요청 URL: $url');

      final token = await _tokenService.getToken();

      final requestBody = {
        'tripId': _currentTrip!.id,
      };

      debugPrint('미션 완료 요청 body: $requestBody');

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint('미션 완료 응답: $responseData');

        // 🔧 실제 API 응답에 따라 isCompleted 값 설정
        if (responseData['data'] != null) {
          final updatedData = responseData['data'];
          mission.isCertified = updatedData['isCompleted'] ?? isSuccessful;
          mission.answers = answers;

          // 🔧 completeMission 카운트 로직 수정
          if (mission.isCertified) {
            _completeMission++;
          }

          debugPrint('미션 완료 상태 업데이트: isCertified=${mission.isCertified}');
        }

        notifyListeners();
        return true;
      } else {
        debugPrint('미션 완료 실패: ${response.statusCode}');
        debugPrint('응답 내용: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('미션 완료 중 오류 발생: $e');
      return false;
    }
  }

  // 🔧 새로운 메서드: 현재 선택된 미션들을 가져오기
  Future<void> fetchCurrentChosenMissions() async {
    try {
      final apiUrl = dotenv.env['API_URL']!;
      final url = '$apiUrl/mission/current';

      final token = await _tokenService.getToken();

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> userMissions = responseData['data'];

        // 모든 미션을 먼저 선택 해제 상태로 초기화
        for (var mission in _allMissions) {
          mission.isSelected = false;
          mission.isCertified = false;
          mission.userMissionId = null;
          mission.answers = null;
        }

        // 각 미션에 userMissionId 매핑
        for (var userMission in userMissions) {
          final missionId = userMission['missionId'];
          final userMissionId = userMission['id'];
          final isCompleted = userMission['isCompleted'] ?? false;

          final missionIndex =
              _allMissions.indexWhere((m) => m.id == missionId);

          if (missionIndex != -1) {
            final mission = _allMissions[missionIndex];
            mission.isSelected = true;
            mission.isCertified = isCompleted;
            mission.userMissionId = userMissionId;

            // answers가 있다면 설정
            if (userMission['answers'] != null) {
              final answersMap = <String, String>{};
              final answers = userMission['answers'] as Map<String, dynamic>;
              answers.forEach((key, value) {
                answersMap[key] = value.toString();
              });
              mission.answers = answersMap;
            }

            debugPrint(
                '미션 ID: $missionId, userMissionId: $userMissionId 설정 완료');
          }
        }

        notifyListeners();
      } else {
        debugPrint('현재 선택된 미션 목록 가져오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('현재 선택된 미션 목록 가져오기 중 오류 발생: $e');
    }
  }

  // 🔧 기존 메서드 이름 변경 및 새로운 API 사용
  Future<void> fetchSelectedMissionsWithUserIds() async {
    await fetchCurrentChosenMissions();
  }

  Future<void> fetchMissionsWithUserData() async {
    await fetchAvailableMissions();
    await fetchCurrentChosenMissions(); // 🔧 새로운 API 사용
  }

  bool isMissionCompleted(int missionId) {
    final missionIndex = _allMissions.indexWhere((m) => m.id == missionId);
    return missionIndex != -1 ? _allMissions[missionIndex].isCertified : false;
  }

  List<Mission> get availableForCompletion =>
      _allMissions.where((m) => m.isSelected && !m.isCertified).toList();

  double get currentTripCompletionRate {
    final selectedMissions = _allMissions.where((m) => m.isSelected).toList();
    if (selectedMissions.isEmpty) return 0.0;

    final completedMissions =
        selectedMissions.where((m) => m.isCertified).toList();
    return completedMissions.length / selectedMissions.length;
  }
}
