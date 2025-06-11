class RoomRate {
  final int? id;
  final int roomId;
  final String rateType;
  final double price;
  final DateTime createdAt;
  final String? promotionId;

  RoomRate({
    this.id,
    required this.roomId,
    required this.rateType,
    required this.price,
    required this.createdAt,
    this.promotionId,
  });

  factory RoomRate.fromJson(Map<String, dynamic> json) {
    return RoomRate(
      id: json['id'],
      roomId: json['room_id'],
      rateType: json['rate_type'],
      price: (json['price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      promotionId: json['promotion_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'rate_type': rateType,
      'price': price,
      'created_at': createdAt.toIso8601String(),
      'promotion_id': promotionId,
    };
  }
}
