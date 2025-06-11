class Review {
  final int? reviewId;
  final String userId;
  final int stayId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  Review({
    this.reviewId,
    required this.userId,
    required this.stayId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['review_id'],
      userId: json['user_id'],
      stayId: json['stay_id'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'review_id': reviewId,
      'user_id': userId,
      'stay_id': stayId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
