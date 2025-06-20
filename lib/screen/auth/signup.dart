import 'package:flutter/material.dart';
import 'package:journimal_client/screen/auth/login.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    // 메모리 누수 방지를 위해 컨트롤러들을 dispose
    nameController.dispose();
    idController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showSnackBar(BuildContext context, String message,
      {bool isError = true}) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor:
          isError ? const Color(0xffFA7A7A) : const Color(0xff4CAF50),
      duration: const Duration(seconds: 3), // 30초는 너무 길어서 3초로 변경
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> validateAndSignup(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final apiUrl = dotenv.env['API_URL']!;
    final signUpUrl = '$apiUrl/auth/signup';

    final Map<String, String> data = {
      "userId": idController.text.trim(),
      "userPassword": passwordController.text,
      "userNickname": nameController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse(signUpUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 201) {
        showSnackBar(context, 'Account created successfully!', isError: false);
        // 회원가입 성공 시 로그인 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else if (response.statusCode == 409) {
        showSnackBar(context, 'User already exists');
      } else {
        final responseBody = jsonDecode(response.body);
        showSnackBar(context,
            'Sign up failed: ${responseBody["message"] ?? "Unknown error"}');
      }
    } catch (e) {
      debugPrint('Signup error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showSnackBar(context, 'Network error. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff022169),
      appBar: AppBar(
        backgroundColor: const Color(0xff022169),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  const Text(
                    'Welcome to',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      fontSize: 25,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 23),
                  Image.asset(
                    'assets/images/journimal_logo.png',
                    width: 283.28,
                    height: 35.23,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 52),
                  buildTextFormField(
                    controller: nameController,
                    hintText: 'Enter your Name',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  buildTextFormField(
                    controller: idController,
                    hintText: 'Enter your ID',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your ID';
                      }
                      if (value.trim().length < 4) {
                        return 'ID must be at least 4 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  buildTextFormField(
                    controller: passwordController,
                    hintText: 'Enter your Password',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: 319,
                    height: 55,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading ? null : () => validateAndSignup(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffffffff),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xff022169)),
                              ),
                            )
                          : const Text(
                              'Sign up',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                                color: Color(0xff022169),
                                fontSize: 20,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 10,
                          ),
                          backgroundColor: const Color(0xffffffff),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Log in',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                            color: Color(0xff022169),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      width: 319,
      child: TextFormField(
        controller: controller,
        validator: validator,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 1.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
          ),
          hintText: hintText,
          hintStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
            color: Colors.white70,
          ),
          errorStyle: const TextStyle(
            color: Colors.red,
            fontSize: 12,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
      ),
    );
  }
}
