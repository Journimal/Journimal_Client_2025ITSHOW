// register_place_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:journimal_client/screen/main_screen.dart';
import 'dart:convert';
import 'package:journimal_client/services/token_service.dart';

class RegisterPlaceScreen extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  const RegisterPlaceScreen({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<RegisterPlaceScreen> createState() => _RegisterPlaceScreenState();
}

class _RegisterPlaceScreenState extends State<RegisterPlaceScreen> {
  final TextEditingController departureController = TextEditingController();
  final TextEditingController arrivalController = TextEditingController();

  List<String> departureResults = [];
  List<String> arrivalResults = [];
  List<String> airports = [];

  String selectedDeparture = '';
  String selectedArrival = '';

  // 드롭다운 상태 관리
  bool isDepartureDropdownOpen = false;
  bool isArrivalDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _fetchAirports();
  }

  final TokenService _tokenService = TokenService();

  // 공항 api get
  Future<List<String>> _fetchAirports([String searchKeyword = '']) async {
    final apiUrl = dotenv.env['API_URL']!;
    final getAirportUrl = '$apiUrl/trip/airport?airportName=$searchKeyword';

    final token = await _tokenService.getToken();

    if (token == null) {
      debugPrint('토큰 없음');
    }

    final response = await http.get(
      Uri.parse(getAirportUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List airports = data['data'];

      return airports
          .map<String>((airport) => airport['airportName'] as String)
          .toList();
    } else {
      debugPrint('공항 목록 불러오기 실패: ${response.body}');
      return [];
    }
  }

  void _onNext() {
    if (selectedDeparture.isEmpty || selectedArrival.isEmpty) {
      _showSnackBar('출발지와 도착지를 모두 선택해주세요.');
      return;
    }
    debugPrint("출발지: $selectedDeparture, 도착지: $selectedArrival");
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void onSearchDeparture(String value) async {
    final results = await _fetchAirports(value);
    setState(() {
      departureResults = results;
      isDepartureDropdownOpen = results.isNotEmpty;
    });
  }

  void onSearchArrival(String value) async {
    final results = await _fetchAirports(value);
    setState(() {
      arrivalResults = results;
      isArrivalDropdownOpen = results.isNotEmpty;
    });
  }

  void onSubmit() async {
    final String formattedStartDate =
        DateFormat('yyyy-MM-dd').format(widget.startDate);
    final String formattedEndDate =
        DateFormat('yyyy-MM-dd').format(widget.endDate);

    if (selectedDeparture.isEmpty || selectedArrival.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both departure and arrival.')),
      );
      return;
    }

    final tokenService = TokenService();
    final token = await tokenService.getToken();

    final body = {
      "departure": selectedDeparture,
      "arrival": selectedArrival,
      "firstDay": DateFormat('yyyy-MM-dd').format(widget.startDate),
      "lastDay": DateFormat('yyyy-MM-dd').format(widget.endDate),
    };
    final apiUrl = dotenv.env['API_URL']!;
    final registerPlaceUrl = '$apiUrl/trip';

    final response = await http.post(
      Uri.parse(registerPlaceUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // API 호출 성공 시 홈 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trip creation failed: ${response.statusCode}')),
      );
    }
  }

  Widget buildDropdownField({
    required String label,
    required TextEditingController controller,
    required Function(String) onSearch,
    required List<String> results,
    required Function(String) onSelect,
    required bool isDropdownOpen,
    required Function(bool) setDropdownState,
    String? exampleText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 34),
        Text(
          label,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xff666666)),
        ),
        const SizedBox(height: 8),
        // 메인 검색 필드
        Stack(children: [
          Container(
            width: 310,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                // 검색 입력 필드
                Container(
                  height: 55,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 27,
                          child: TextField(
                            controller: controller,
                            onChanged: onSearch,
                            onTap: () {
                              if (controller.text.isNotEmpty) {
                                onSearch(controller.text);
                              }
                            },
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff333333),
                              overflow: TextOverflow.ellipsis,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                              hintText:
                                  'Search your ${label.toLowerCase()} here',
                              hintStyle: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Color(0xff929292),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 드롭다운 결과 리스트
                if (isDropdownOpen && results.isNotEmpty)
                  Container(
                    constraints: BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final airport = results[index];
                        return GestureDetector(
                          onTap: () {
                            controller.text = airport;
                            onSelect(airport);
                            setDropdownState(false);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.white, width: 1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    airport,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xff333333),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ]),

        // 예시 텍스트
        if (exampleText != null && !isDropdownOpen)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 8),
            child: Text(
              'ex. $exampleText',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 화면 다른 곳 터치 시 드롭다운 닫기
        setState(() {
          isDepartureDropdownOpen = false;
          isArrivalDropdownOpen = false;
        });
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar(),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 128),
                const Text(
                  'Select your Travel Route',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff022169),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Where are you traveling to?',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Pretendard',
                    color: Color(0xff666666),
                  ),
                ),
                SizedBox(height: 10),
                buildDropdownField(
                  label: 'Departing from',
                  controller: departureController,
                  onSearch: onSearchDeparture,
                  results: departureResults,
                  onSelect: (val) {
                    setState(() {
                      selectedDeparture = val;
                    });
                  },
                  isDropdownOpen: isDepartureDropdownOpen,
                  setDropdownState: (isOpen) {
                    setState(() {
                      isDepartureDropdownOpen = isOpen;
                      if (isOpen) isArrivalDropdownOpen = false; // 다른 드롭다운 닫기
                    });
                  },
                  exampleText: 'Incheon International Airport',
                ),
                buildDropdownField(
                  label: 'Arriving at',
                  controller: arrivalController,
                  onSearch: onSearchArrival,
                  results: arrivalResults,
                  onSelect: (val) {
                    setState(() {
                      selectedArrival = val;
                    });
                  },
                  isDropdownOpen: isArrivalDropdownOpen,
                  setDropdownState: (isOpen) {
                    setState(() {
                      isArrivalDropdownOpen = isOpen;
                      if (isOpen) isDepartureDropdownOpen = false; // 다른 드롭다운 닫기
                    });
                  },
                  exampleText: 'Melbourne Essendon Airport',
                ),
                SizedBox(height: 100),
                SizedBox(
                  width: 279,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff022169),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Text(
                      "Let's Journimal!",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
