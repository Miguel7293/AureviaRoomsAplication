class Stay {
  final int? stayId;
  final String name;
  final String category;
  final String? description;
  final String status;
  final String? mainImageUrl;
  final String? ownerId;
  final DateTime createdAt;
  final Map<String, dynamic>? location; // Changed to Map<String, dynamic>? for GeoJSON

  Stay({
    this.stayId,
    required this.name,
    required this.category,
    this.description,
    required this.status,
    this.mainImageUrl,
    this.ownerId,
    required this.createdAt,
    this.location,
  });

  factory Stay.fromJson(Map<String, dynamic> json) {
    return Stay(
      stayId: json['stay_id'] as int?,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      mainImageUrl: json['main_image_url'] as String?,
      ownerId: json['owner_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      location: json['location'] as Map<String, dynamic>?, // Handle GeoJSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stay_id': stayId,
      'name': name,
      'category': category,
      'description': description,
      'status': status,
      'main_image_url': mainImageUrl,
      'owner_id': ownerId,
      'created_at': createdAt.toIso8601String(),
      'location': location,
    };
  }
}
