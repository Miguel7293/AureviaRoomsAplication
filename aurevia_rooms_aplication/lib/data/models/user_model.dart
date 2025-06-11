class UserModel {
  final String authUserId;
  final String username;
  final String userType;
  final String? preferredLanguage;
  final Map<String, dynamic>? preferredTheme;
  final String? profileImageUrl;
  final String email;
  final String? phoneNumber;
  final DateTime createdAt;

  UserModel({
    required this.authUserId,
    required this.username,
    required this.userType,
    this.preferredLanguage,
    this.preferredTheme,
    this.profileImageUrl,
    required this.email,
    this.phoneNumber,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      authUserId: json['auth_user_id'],
      username: json['username'],
      userType: json['user_type'],
      preferredLanguage: json['preferred_language'],
      preferredTheme: json['preferred_theme'],
      profileImageUrl: json['profile_image_url'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auth_user_id': authUserId,
      'username': username,
      'user_type': userType,
      'preferred_language': preferredLanguage,
      'preferred_theme': preferredTheme,
      'profile_image_url': profileImageUrl,
      'email': email,
      'phone_number': phoneNumber,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
