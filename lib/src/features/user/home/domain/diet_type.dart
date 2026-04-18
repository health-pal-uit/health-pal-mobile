class DietType {
  final String id;
  final String name;
  final int proteinPercentages;
  final int fatPercentages;
  final int carbsPercentages;
  final DateTime createdAt;
  final DateTime? deletedAt;

  DietType({
    required this.id,
    required this.name,
    required this.proteinPercentages,
    required this.fatPercentages,
    required this.carbsPercentages,
    required this.createdAt,
    this.deletedAt,
  });

  factory DietType.fromJson(Map<String, dynamic> json) {
    return DietType(
      id: json['id'] as String,
      name: json['name'] as String,
      proteinPercentages: (json['protein_percentages'] as num).toInt(),
      fatPercentages: (json['fat_percentages'] as num).toInt(),
      carbsPercentages: (json['carbs_percentages'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      deletedAt:
          json['deleted_at'] != null
              ? DateTime.parse(json['deleted_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'protein_percentages': proteinPercentages,
      'fat_percentages': fatPercentages,
      'carbs_percentages': carbsPercentages,
      'created_at': createdAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  // Calculate macro grams based on total calories
  int getProteinGrams(int totalKcal) {
    return ((totalKcal * proteinPercentages / 100) / 4).round();
  }

  int getFatGrams(int totalKcal) {
    return ((totalKcal * fatPercentages / 100) / 9).round();
  }

  int getCarbsGrams(int totalKcal) {
    return ((totalKcal * carbsPercentages / 100) / 4).round();
  }
}
