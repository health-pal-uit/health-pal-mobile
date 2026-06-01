class BookingClient {
  final String id;
  final String? fullname;
  final String? username;
  final String? avatarUrl;

  BookingClient({
    required this.id,
    this.fullname,
    this.username,
    this.avatarUrl,
  });

  factory BookingClient.fromJson(Map<String, dynamic> json) {
    return BookingClient(
      id: json['id'] ?? '',
      fullname: json['fullname'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
    );
  }
}

class BookingModel {
  final String id;
  final String status;
  final String confirmedBy;
  final String callType;
  final DateTime scheduledAt;
  final String? clientNote;
  final BookingClient client;
  final String? consultationId;

  BookingModel({
    required this.id,
    required this.status,
    required this.confirmedBy,
    required this.callType,
    required this.scheduledAt,
    this.clientNote,
    required this.client,
    this.consultationId,
  });

  String get clientName =>
      client.fullname ?? client.username ?? 'Unknown Client';
  String get clientAvatar => client.avatarUrl ?? '';

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      confirmedBy: json['confirmed_by'] ?? '',
      callType: json['call_type'] ?? '',
      scheduledAt: DateTime.parse(json['scheduled_at']),
      clientNote: json['client_note'],
      client: BookingClient.fromJson(json['client'] ?? {}),
      consultationId:
          json['consultation'] != null ? json['consultation']['id'] : null,
    );
  }
}
