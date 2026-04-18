class Challenge {
  final String id;
  final String name;
  final String? note;
  final String? imageUrl;
  final String difficulty;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final List<dynamic> activityRecords;
  final double? progressPercent;
  final bool isFinished;
  final bool canClaim;

  const Challenge({
    required this.id,
    required this.name,
    this.note,
    this.imageUrl,
    required this.difficulty,
    required this.createdAt,
    this.deletedAt,
    required this.activityRecords,
    this.progressPercent,
    this.isFinished = false,
    this.canClaim = false,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      name: json['name'] as String,
      note: json['note'] as String?,
      imageUrl: json['image_url'] as String?,
      difficulty: json['difficulty'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      deletedAt:
          json['deleted_at'] != null
              ? DateTime.parse(json['deleted_at'] as String)
              : null,
      activityRecords: json['activity_records'] as List<dynamic>? ?? [],
      progressPercent:
          json['progress_percent'] != null
              ? (json['progress_percent'] as num).toDouble()
              : null,
      isFinished: json['is_finished'] as bool? ?? false,
      canClaim: json['can_claim'] as bool? ?? false,
    );
  }
}
