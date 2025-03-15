class UserModel {
  final String name;
  final String? jwt;
  final String email;
  final bool twoFAEnabled;
  final bool emailVerified;
  final String id;
  final String? emailVerificationToken;

  UserModel({
    required this.name,
    this.jwt,
    required this.email,
    required this.twoFAEnabled,
    required this.emailVerified,
    required this.id,
    this.emailVerificationToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] as String,
      jwt: json['jwt'] as String?,
      email: json['email'] as String,
      twoFAEnabled: json['twoFAEnabled'] as bool,
      emailVerified: json['emailVerified'] as bool,
      id: json['id'] as String,
      emailVerificationToken: json['emailVerificationToken'] as String?,
    );
  }
} 