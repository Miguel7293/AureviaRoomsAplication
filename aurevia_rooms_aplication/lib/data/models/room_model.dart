class Room {
  final int? roomId;
  final int stayId;
  final String availabilityStatus;
  final String? roomImageUrl;
  final Map<String, dynamic>? features;
  final DateTime createdAt;

  Room({
    this.roomId,
    required this.stayId,
    required this.availabilityStatus,
    this.roomImageUrl,
    this.features,
    required this.createdAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomId: json['room_id'],
      stayId: json['stay_id'],
      availabilityStatus: json['availability_status'],
      roomImageUrl: json['room_image_url'],
      features: json['features'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'stay_id': stayId,
      'availability_status': availabilityStatus,
      'room_image_url': roomImageUrl,
      'features': features,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
