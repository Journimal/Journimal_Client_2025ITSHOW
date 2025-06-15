import 'package:flutter/material.dart';

class MissionResultPage extends StatelessWidget {
  final bool isSuccess;

  const MissionResultPage({Key? key, required this.isSuccess})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child:
            isSuccess ? _buildSuccessView(context) : _buildFailureView(context),
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Well done!',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w500,
            fontFamily: 'Pretendard',
            color: Color(0xff424242),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Nailed it,\nyour mission has been certified.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Color(0xff666666),
          ),
        ),
        const SizedBox(height: 100),
        _buildBottomButton(context, 'Done'),
      ],
    );
  }

  Widget _buildFailureView(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 배경 눈물방울 (간단한 데코용 예시)
        Positioned(top: 100, left: 40, child: _drop()),
        Positioned(top: 140, right: 30, child: _drop(size: 40, opacity: 0.5)),
        Positioned(top: 220, left: 80, child: _drop(size: 50)),
        Positioned(
            bottom: 180, right: 60, child: _drop(size: 30, opacity: 0.4)),
        Positioned(bottom: 120, left: 40, child: _drop(size: 45)),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Oh no..',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w500,
                fontFamily: 'Pretendard',
                color: Color(0xff424242),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Don’t worry..\nYou can try this mission again!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Color(0xff666666),
              ),
            ),
            const SizedBox(height: 100),
            _buildBottomButton(context, 'Try Next Time'),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // 이전 화면으로 돌아감
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF022169), // 진한 파랑
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                fontFamily: 'Pretendard'),
          ),
        ),
      ),
    );
  }

  Widget _drop({double size = 50, double opacity = 1.0}) {
    return Opacity(
      opacity: opacity,
      child: Icon(
        Icons.water_drop,
        size: size,
        color: Color(0xff3FA9F5),
      ),
    );
  }
}
