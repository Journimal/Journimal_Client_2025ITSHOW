class Mission {
  final int id;
  final String name;
  final String icon;
  bool isSelected;
  bool isCertified;

  Mission({
    required this.id,
    required this.name,
    required this.icon,
    this.isSelected = false,
    this.isCertified = false,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'],
      name: json['missionName'],
      icon: json['missionIcon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'missionName': name,
      'missionIcon': icon,
    };
  }
}
