import '../../domain/entities/auth_user.dart';

class AuthUserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? accessToken;
  final String? refreshToken;

  const AuthUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.accessToken,
    this.refreshToken,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }

  AuthUser toEntity() =>
      AuthUser(id: id, name: name, email: email, avatarUrl: avatarUrl);
}
