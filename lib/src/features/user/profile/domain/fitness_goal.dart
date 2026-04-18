class FitnessGoal {
  final String id;
  final int targetKcal;
  final int targetProteinGr;
  final int targetFatGr;
  final int targetCarbsGr;
  final int targetFiberGr;
  final String goalType;
  final double waterDrankL;
  final DateTime createdAt;
  final DateTime? deletedAt;

  FitnessGoal({
    required this.id,
    required this.targetKcal,
    required this.targetProteinGr,
    required this.targetFatGr,
    required this.targetCarbsGr,
    required this.targetFiberGr,
    required this.goalType,
    required this.waterDrankL,
    required this.createdAt,
    this.deletedAt,
  });

  factory FitnessGoal.fromJson(Map<String, dynamic> json) {
    return FitnessGoal(
      id: json['id'] as String,
      targetKcal: (json['target_kcal'] as num).toInt(),
      targetProteinGr: (json['target_protein_gr'] as num).toInt(),
      targetFatGr: (json['target_fat_gr'] as num).toInt(),
      targetCarbsGr: (json['target_carbs_gr'] as num).toInt(),
      targetFiberGr: (json['target_fiber_gr'] as num).toInt(),
      goalType: json['goal_type'] as String,
      waterDrankL: (json['water_drank_l'] as num).toDouble(),
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
      'target_kcal': targetKcal,
      'target_protein_gr': targetProteinGr,
      'target_fat_gr': targetFatGr,
      'target_carbs_gr': targetCarbsGr,
      'target_fiber_gr': targetFiberGr,
      'goal_type': goalType,
      'water_drank_l': waterDrankL,
      'created_at': createdAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  String get goalTypeDisplay {
    switch (goalType) {
      case 'cut':
        return 'Cut';
      case 'bulk':
        return 'Bulk';
      case 'maintain':
        return 'Maintain';
      case 'recovery':
        return 'Recovery';
      case 'gain_muscles':
        return 'Gain Muscles';
      default:
        return goalType;
    }
  }
}
