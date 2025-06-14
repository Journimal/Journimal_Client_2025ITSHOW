class Animal {
  final int id;
  final String aniImage;
  final String aniName;
  final String aniLevel;

  Animal({
    required this.id,
    required this.aniImage,
    required this.aniName,
    required this.aniLevel,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'],
      aniImage: json['aniImage'],
      aniName: json['aniName'],
      aniLevel: json['aniLevel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'aniImage': aniImage,
      'aniName': aniName,
      'aniLevel': aniLevel,
    };
  }
}

class Trip {
  final int id;
  final String departure;
  final String arrival;
  final DateTime firstDay;
  final DateTime lastDay;
  final int completeMission;
  final int? lastAnimalId;
  final int userId;
  final int? animalId;
  final String level;
  final Animal? lastAnimal; // 추가된 필드
  final List<dynamic>? userMission; // 추가된 필드 (필요에 따라 구체적인 타입으로 변경 가능)

  Trip({
    required this.id,
    required this.departure,
    required this.arrival,
    required this.firstDay,
    required this.lastDay,
    required this.completeMission,
    required this.lastAnimalId,
    required this.userId,
    required this.animalId,
    required this.level,
    this.lastAnimal,
    this.userMission,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      departure: json['departure'],
      arrival: json['arrival'],
      firstDay: DateTime.parse(json['firstDay']),
      lastDay: DateTime.parse(json['lastDay']),
      completeMission: json['completeMission'],
      lastAnimalId: json['lastAnimalId'],
      userId: json['userId'],
      animalId: json['animalId'],
      level: json['level'],
      lastAnimal: json['lastAnimal'] != null
          ? Animal.fromJson(json['lastAnimal'])
          : null,
      userMission: json['UserMission'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'departure': departure,
      'arrival': arrival,
      'firstDay': firstDay.toIso8601String(),
      'lastDay': lastDay.toIso8601String(),
      'completeMission': completeMission,
      'lastAnimalId': lastAnimalId,
      'userId': userId,
      'animalId': animalId,
      'level': level,
      'lastAnimal': lastAnimal?.toJson(),
      'UserMission': userMission,
    };
  }
}
