class Promotion {
  final String promotionId;
  final int stayId;
  final String description;
  final double discountPercentage;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final String state;

  Promotion({
    required this.promotionId,
    required this.stayId,
    required this.description,
    required this.discountPercentage,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.state,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      promotionId: json['promotion_id'],
      stayId: json['stay_id'],
      description: json['description'],
      discountPercentage: (json['discount_percentage'] as num).toDouble(),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      createdAt: DateTime.parse(json['created_at']),
      state: json['state'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'promotion_id': promotionId,
      'stay_id': stayId,
      'description': description,
      'discount_percentage': discountPercentage,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'state': state,
    };
  }
}
