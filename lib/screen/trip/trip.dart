import 'package:flutter/material.dart';
import 'package:journimal_client/screen/auth/signup.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({Key? key}) : super(key: key);

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  // 필요한 상태 변수는 여기 선언 (예: int counter = 0;)

  @override
  Widget build(BuildContext context) {
    const navyColor = Color(0xFF001A72);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Trip Archive',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  color: Color(0xff022169),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Here are your trip accomplishments\nwith Eco-Buddies!!',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  color: Color(0xff666666),
                ),
              ),
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    const Text(
                      "Let’s make more your ticket!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff022169),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 77,
                      height: 77,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(0xff022169), width: 3),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.add,
                          size: 36,
                          color: Color(0xff022169),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
