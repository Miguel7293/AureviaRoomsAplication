class Stay {
  final int? stayId;
  final String name;
  final String category;
  final String? description;
  final String status;
  final String? mainImageUrl;
  final String? ownerId;
  final DateTime createdAt;
  final String? location; // Representa WKT: 'POINT(lon lat)' por simplicidad

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
      stayId: json['stay_id'],
      name: json['name'],
      category: json['category'],
      description: json['description'],
      status: json['status'],
      mainImageUrl: json['main_image_url'],
      ownerId: json['owner_id'],
      createdAt: DateTime.parse(json['created_at']),
      location: json['location'],
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
