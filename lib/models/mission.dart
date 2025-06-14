class Mission {
  final int id;
  final String missionName;
  final String missionIcon;
  final String thumbnail;
  final String description;
  final String question1;
  final String question2;
  final String question3;
  bool isSelected;
  bool isCertified;

  // 새로 추가되는 필드들
  int? userMissionId; // API 응답에서 받아올 userMission의 id
  Map<String, String>? answers; // 설문 답변 저장용

  Mission({
    required this.id,
    required this.missionName,
    required this.missionIcon,
    required this.thumbnail,
    required this.description,
    required this.question1,
    required this.question2,
    required this.question3,
    this.isSelected = false,
    this.isCertified = false,
    this.userMissionId,
    this.answers,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'],
      missionName: json['missionName'],
      missionIcon: json['missionIcon'],
      thumbnail: json['thumbnail'],
      description: json['description'],
      question1: json['question1'],
      question2: json['question2'],
      question3: json['question3'],
      // API에서 userMission 정보도 함께 오는 경우
      userMissionId: json['userMissionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'missionName': missionName,
      'missionIcon': missionIcon,
      'thumbnail': thumbnail,
      'description': description,
      'question1': question1,
      'question2': question2,
      'question3': question3,
      'isSelected': isSelected,
      'isCertified': isCertified,
      'userMissionId': userMissionId,
      'answers': answers,
    };
  }

  // copyWith 메서드 추가
  Mission copyWith({
    int? id,
    String? missionName,
    String? missionIcon,
    String? thumbnail,
    String? description,
    String? question1,
    String? question2,
    String? question3,
    bool? isSelected,
    bool? isCertified,
    int? userMissionId,
    Map<String, String>? answers,
  }) {
    return Mission(
      id: id ?? this.id,
      missionName: missionName ?? this.missionName,
      missionIcon: missionIcon ?? this.missionIcon,
      thumbnail: thumbnail ?? this.thumbnail,
      description: description ?? this.description,
      question1: question1 ?? this.question1,
      question2: question2 ?? this.question2,
      question3: question3 ?? this.question3,
      isSelected: isSelected ?? this.isSelected,
      isCertified: isCertified ?? this.isCertified,
      userMissionId: userMissionId ?? this.userMissionId,
      answers: answers ?? this.answers,
    );
  }
}
