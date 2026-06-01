class Booking {
  final String id;
  final String status;
  final String callType;
  final DateTime scheduledAt;
  final String expertName;
  final String expertRole;
  final String? expertAvatarUrl;
  final String? consultationId;

  Booking.fromJson(Map<String, dynamic> json)
    : id = json['id'] ?? '',
      status = json['status'] ?? 'pending',
      callType = json['call_type'] ?? 'audio',
      scheduledAt =
          json['scheduled_at'] != null
              ? DateTime.parse(json['scheduled_at']).toLocal()
              : DateTime.now(),
      expertName =
          json['expert']?['user']?['fullname'] ??
          json['expert']?['user']?['username'] ??
          'Expert',
      expertRole = json['expert']?['expert_role']?['name'] ?? 'Advisor',
      expertAvatarUrl = json['expert']?['user']?['avatar_url'],
      consultationId =
          json['consultation'] != null ? json['consultation']['id'] : null;
}
