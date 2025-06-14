import 'package:flutter/material.dart';
import 'package:journimal_client/models/mission.dart'; // Mission 모델이 분리되어 있다면 import
import 'package:provider/provider.dart';
import 'package:journimal_client/providers/mission_provider.dart'; // 이 줄 추가

// 설문 조사 화면
class SurveyScreen extends StatefulWidget {
  final Mission mission;

  SurveyScreen({required this.mission});

  @override
  _SurveyScreenState createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  String? answer1;
  String? answer2;
  String? answer3;
  bool isSubmitting = false;

  bool get isFormComplete =>
      answer1 != null && answer2 != null && answer3 != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF8F9FA),
      appBar: AppBar(
        title: Text(
          widget.mission.missionName,
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Pretendard',
            color: Color(0xff022169),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 미션 썸네일
            Container(
              height: 214,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.green[400]!, Colors.green[600]!],
                ),
              ),
              child: Image.network(
                widget.mission.thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    child: Icon(
                      Icons.eco,
                      size: 80,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  );
                },
              ),
            ),

            // 미션 정보
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.mission.missionName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Pretendard',
                      color: Color(0xff424242),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.mission.description,
                    style: TextStyle(
                      color: Color(0xff666666),
                      fontSize: 16,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  SizedBox(height: 20),
                  Divider()
                ],
              ),
            ),

            // 설문 질문들
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildQuestion(
                    widget.mission.question1,
                    answer1,
                    (value) => setState(() => answer1 = value),
                  ),
                  Divider(),
                  SizedBox(height: 24),
                  _buildQuestion(
                    widget.mission.question2,
                    answer2,
                    (value) => setState(() => answer2 = value),
                  ),
                  Divider(),
                  SizedBox(height: 24),
                  _buildQuestion(
                    widget.mission.question3,
                    answer3,
                    (value) => setState(() => answer3 = value),
                  ),
                  SizedBox(height: 32),

                  // 제출 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (isFormComplete && !isSubmitting)
                          ? _submitSurvey
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff022169),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        disabledBackgroundColor: Color(0xffCCCCCC),
                      ),
                      child: isSubmitting
                          ? CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(
      String question, String? selectedAnswer, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xff424242),
          ),
        ),
        SizedBox(height: 12),
        RadioListTile<String>(
          title: Text(
            'Yes, I did',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontFamily: 'Pretendard',
              fontSize: 16,
              color: Color(0xff666666),
            ),
          ),
          value: 'yes',
          groupValue: selectedAnswer,
          onChanged: (value) => onChanged(value!),
          contentPadding: EdgeInsets.zero,
          activeColor: Color(0xff022169),
        ),
        RadioListTile<String>(
          title: Text(
            'No, I didn\'t',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontFamily: 'Pretendard',
              fontSize: 16,
              color: Color(0xff666666),
            ),
          ),
          value: 'no',
          groupValue: selectedAnswer,
          onChanged: (value) => onChanged(value!),
          contentPadding: EdgeInsets.zero,
          activeColor: Color(0xff022169),
        ),
      ],
    );
  }

  void _submitSurvey() async {
    setState(() {
      isSubmitting = true;
    });

    final answers = {
      'question1': answer1!,
      'question2': answer2!,
      'question3': answer3!,
    };

    final provider = Provider.of<MissionProvider>(context, listen: false);
    final success = await provider.certifyMission(widget.mission, answers);

    setState(() {
      isSubmitting = false;
    });

    if (success) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Mission Completed!'),
            content: Text('Your eco-mission has been successfully completed.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  Navigator.of(context).pop(); // 설문 화면 닫기
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit mission. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
