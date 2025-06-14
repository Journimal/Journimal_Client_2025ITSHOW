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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'missionName': missionName,
      'missionIcon': missionIcon,
    };
  }
}
