class Mission {
  final int id;
  final int missionId;
  int? userMissionId; // final 제거하고 nullable로 변경
  final String missionName;
  final String missionIcon;
  final String thumbnail;
  final String description;
  final String question1;
  final String question2;
  final String question3;
  bool isSelected;
  bool isCertified;
  Map<String, String>? answers;

  Mission({
    required this.id,
    required this.missionId,
    this.userMissionId, // required 제거
    required this.missionName,
    required this.missionIcon,
    required this.thumbnail,
    required this.description,
    required this.question1,
    required this.question2,
    required this.question3,
    this.isSelected = false,
    this.isCertified = false,
    this.answers,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'],
      missionId: json['missionId'] ?? json['id'], // API 구조에 따라 조정
      userMissionId: json['userMissionId'], // null 허용
      missionName: json['missionName'] ?? '',
      missionIcon: json['missionIcon'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      description: json['description'] ?? '',
      question1: json['question1'] ?? '',
      question2: json['question2'] ?? '',
      question3: json['question3'] ?? '',
      isSelected: json['isSelected'] ?? false,
      isCertified: json['isCertified'] ?? false,
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
    int? missionId, // ✅ 추가
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
      missionId: missionId ?? this.missionId, // ✅ 추가
      answers: answers ?? this.answers,
    );
  }
}
