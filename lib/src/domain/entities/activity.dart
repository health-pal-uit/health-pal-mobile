class Activity {
  final String id;
  final String name;
  final double metValue;
  final List<String> categories;
  final DateTime createdAt;
  final DateTime? deletedAt;

  Activity({
    required this.id,
    required this.name,
    required this.metValue,
    required this.categories,
    required this.createdAt,
    this.deletedAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      name: json['name'] as String,
      metValue: (json['met_value'] as num).toDouble(),
      categories:
          (json['categories'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
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
      'met_value': metValue,
      'categories': categories,
      'created_at': createdAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}
