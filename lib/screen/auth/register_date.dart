import 'package:flutter/material.dart';
import 'package:journimal_client/screen/auth/register_place.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:journimal_client/services/token_service.dart'; // TokenService 임포트

class RegisterDateScreen extends StatefulWidget {
  const RegisterDateScreen({super.key});

  @override
  State<RegisterDateScreen> createState() => _TravelDateScreenState();
}

class _TravelDateScreenState extends State<RegisterDateScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _startDate;
  DateTime? _endDate;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;

  final dateFormat = DateFormat('yyyy-MM-dd');
  final TokenService _tokenService = TokenService(); // TokenService 인스턴스

  Future<void> _sendDatesToApi(String start, String end) async {
    final apiUrl = dotenv.env['API_URL']!;
    final registerDateUrl = '$apiUrl/trip';

    final token = await _tokenService.getToken(); // secure_storage에서 토큰 읽기

    if (token == null) {
      showSnackBar(context, const Text('로그인이 필요합니다.'));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(registerDateUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // 토큰 포함
        },
        body: jsonEncode({'start_date': start, 'end_date': end}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 성공적으로 전송됨
        debugPrint("✅ 전송 성공: ${response.body}");
      } else {
        showSnackBar(context, Text('전송 실패: ${response.body}'));
        debugPrint("🔥 전송 실패: ${response.body}");
      }
    } catch (e) {
      debugPrint('🚨 예외 발생: $e');
    }
  }

  void _onContinue() {
    if (_startDate != null && _endDate != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterPlaceScreen(
            startDate: _startDate!,
            endDate: _endDate!,
          ),
        ),
      );
    } else {
      showSnackBar(context, Text('출발일과 도착일을 선택해주세요.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(),
      ),
      body: Center(
        child: Column(children: [
          const SizedBox(height: 128),
          const Text(
            'Select your Travel Date',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
              color: Color(0xff022169),
            ),
          ),
          const SizedBox(height: 60),
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            calendarFormat: CalendarFormat.month,
            rangeSelectionMode: _rangeSelectionMode,
            rangeStartDay: _startDate,
            rangeEndDay: _endDate,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            onRangeSelected: (start, end, focusedDay) {
              setState(() {
                _startDate = start;
                _endDate = end;
                _focusedDay = focusedDay;
                _rangeSelectionMode = RangeSelectionMode.toggledOn;
              });
            },
            calendarStyle: const CalendarStyle(
              rangeHighlightColor: Color(0xff7B8AAE),
              rangeStartDecoration: BoxDecoration(
                color: Color(0xff022169),
                shape: BoxShape.circle,
              ),
              rangeEndDecoration: BoxDecoration(
                color: Color(0xff022169),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                fontFamily: 'Pretendard',
                color: Color(0xff022169),
              ),
              leftChevronIcon:
                  Icon(Icons.chevron_left, color: Color(0xff022169)),
              rightChevronIcon:
                  Icon(Icons.chevron_right, color: Color(0xff022169)),
            ),
          ),
          const SizedBox(height: 60),
          SizedBox(
            width: 150,
            height: 40,
            child: ElevatedButton(
              onPressed: _onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff022169),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Continue',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: 15),
                  Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }

  void showSnackBar(BuildContext context, Text text) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 8),
          text,
        ],
      ),
      backgroundColor: const Color(0xffFA7A7A),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
