import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:journimal_client/screen/auth/register_date.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:journimal_client/services/token_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController id = TextEditingController();
  final TextEditingController pw = TextEditingController();
  final TokenService tokenservice = TokenService();

  // Secure storage instance
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff022169),
      appBar: AppBar(
        backgroundColor: Color(0xff022169),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image(
            image: AssetImage('assets/images/journimal_logo.png'),
            width: 260.83,
            height: 35.23,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 50),
          SizedBox(
            width: 319,
            height: 62,
            child: TextField(
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.white,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.white,
                    width: 1.0,
                  ),
                ),
                hintText: 'Enter your ID',
                hintStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              controller: id,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 319,
            height: 62,
            child: TextField(
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.white,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.white,
                    width: 1.0,
                  ),
                ),
                hintText: 'Enter your Password',
                hintStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              controller: pw,
              keyboardType: TextInputType.text,
              obscureText: true,
            ),
          ),
          const SizedBox(height: 60),
          SizedBox(
            width: 319,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                debugPrint('🔘 Login button pressed');
                _login(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              child: const Text(
                'Log In',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  color: Color(0xff022169),
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _login(BuildContext context) async {
    debugPrint('🔐 _login 함수 시작');
    final userId = id.text.trim();
    final userPassword = pw.text.trim();

    // 유효성 검사 (서버에서 요구하는 조건에 맞게 확인)
    if (userId.length < 4 || userId.length > 20) {
      showSnackBar(context, const Text('Username must be 4-20 characters.'));
      return;
    }

    if (userPassword.length < 4 || userPassword.length > 20) {
      showSnackBar(context, const Text('Password must be 4-20 characters.'));
      return;
    }

    final apiUrl = dotenv.env['API_URL']!;
    final logInUrl = '$apiUrl/auth/login';

    try {
      debugPrint('🌐 로그인 요청 보내는 중...');
      final response = await http.post(
        Uri.parse(logInUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'userPassword': userPassword}),
      );
      debugPrint('📨 서버 응답 상태: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final accessToken = responseData['data']['accessToken'];

        await tokenservice.saveToken(accessToken);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RegisterDateScreen()),
        );
      } else {
        final Map<String, dynamic> errorResponse = jsonDecode(response.body);
        final errorMessage = errorResponse['message'];

        if (errorMessage is String) {
          debugPrint('⚠️ 서버 에러 메시지: $errorMessage');
          showSnackBar(context, Text(errorMessage));
        } else {
          debugPrint('⚠️ 알 수 없는 에러 발생');
          showSnackBar(context, const Text('Unknown Error'));
        }
      }
    } catch (e) {
      debugPrint('🚨 예외 발생: $e');
      log('Exception: $e');
    }
  }

  void showSnackBar(BuildContext context, Text text) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.white,
          ),
          const SizedBox(
            width: 8,
          ),
          text,
        ],
      ),
      backgroundColor: const Color(0xffFA7A7A),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
