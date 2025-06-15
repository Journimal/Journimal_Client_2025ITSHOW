import 'package:flutter/material.dart';
import 'package:journimal_client/models/mission.dart';
import 'package:journimal_client/screen/mission/mission_result.dart';
import 'package:provider/provider.dart';
import 'package:journimal_client/providers/mission_provider.dart';

// 설문 조사 화면
class SurveyScreen extends StatefulWidget {
  final Mission mission;
  SurveyScreen({
    required this.mission,
  });

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

  // 미션 성공 여부 판단 (2개 이상 yes)
  bool get isMissionSuccessful {
    if (!isFormComplete) return false;

    int yesCount = 0;
    if (answer1 == 'yes') yesCount++;
    if (answer2 == 'yes') yesCount++;
    if (answer3 == 'yes') yesCount++;

    return yesCount >= 2;
  }

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
                  SizedBox(height: 12),
                  // 미션 성공 조건 안내
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xffE3F2FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xff1976D2),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Mission succeeds when you answer "Yes" to at least 2 questions',
                            style: TextStyle(
                              color: Color(0xff1976D2),
                              fontSize: 14,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ),
                      ],
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
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              setState(() {
                                isSubmitting = true;
                              });

                              // 1. 성공 여부 판단
                              int yesCount = _getYesCount();
                              bool isMissionSuccessful = yesCount >= 2; // 예시 기준

                              // 2. 결과 화면에 전달할 수 있도록 변수 설정
                              final answers = {
                                'question1': answer1!,
                                'question2': answer2!,
                                'question3': answer3!,
                              };

                              final provider = Provider.of<MissionProvider>(
                                  context,
                                  listen: false);

                              // 3. 서버에 제출 (이때 isMissionSuccessful도 함께 전달)
                              final success = await provider.CertifedMission(
                                mission: widget.mission,
                                answers: answers,
                                isSuccessful: isMissionSuccessful,
                              );

                              setState(() {
                                isSubmitting = false;
                              });

                              // 4. 제출 성공 여부와 관계없이 결과 화면으로 이동
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => MissionResultPage(
                                    isSuccess: isMissionSuccessful,
                                  ),
                                ),
                              );
                            },
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

  int _getYesCount() {
    int count = 0;
    if (answer1 == 'yes') count++;
    if (answer2 == 'yes') count++;
    if (answer3 == 'yes') count++;
    return count;
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

    // 미션 성공 여부에 따라 API 호출
    final success = await provider.CertifedMission(
      mission: widget.mission,
      answers: answers,
      isSuccessful: isMissionSuccessful,
    );

    setState(() {
      isSubmitting = false;
    });
  }
}
