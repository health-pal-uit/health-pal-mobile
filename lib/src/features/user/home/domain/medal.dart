class Medal {
  final String id;
  final String name;
  final String? imageUrl;
  final String tier;
  final String? note;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final List<dynamic> challengesMedals;
  final bool isFinished;
  final bool allChallengesFinished;
  final bool canClaim;

  const Medal({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.tier,
    this.note,
    required this.createdAt,
    this.deletedAt,
    required this.challengesMedals,
    required this.isFinished,
    required this.allChallengesFinished,
    required this.canClaim,
  });

  factory Medal.fromJson(Map<String, dynamic> json) {
    return Medal(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String?,
      tier: json['tier'] as String,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      deletedAt:
          json['deleted_at'] != null
              ? DateTime.parse(json['deleted_at'] as String)
              : null,
      challengesMedals: json['challenges_medals'] as List<dynamic>? ?? [],
      isFinished: json['is_finished'] as bool? ?? false,
      allChallengesFinished: json['all_challenges_finished'] as bool? ?? false,
      canClaim: json['can_claim'] as bool? ?? false,
    );
  }
}
