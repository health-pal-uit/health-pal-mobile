class ExpertRating {
  final String id;
  final int score;
  final String? comment;
  final DateTime createdAt;

  final String clientId;
  final String clientName;
  final String? clientAvatarUrl;

  ExpertRating({
    required this.id,
    required this.score,
    this.comment,
    required this.createdAt,
    required this.clientId,
    required this.clientName,
    this.clientAvatarUrl,
  });

  factory ExpertRating.fromJson(Map<String, dynamic> json) {
    final client = json['client'] ?? {};

    return ExpertRating(
      id: json['id'] ?? '',
      score: json['score'] ?? 0,
      comment: json['comment'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at']).toLocal()
              : DateTime.now(),
      clientId: client['id'] ?? '',
      clientName: client['fullname'] ?? client['username'] ?? 'Anonymous',
      clientAvatarUrl: client['avatar_url'],
    );
  }
}
