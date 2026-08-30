import 'package:equatable/equatable.dart';

class AuthTokens extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int userId;
  final String fullName;
  final String email;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'bearer',
    required this.userId,
    required this.fullName,
    required this.email,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'bearer',
      userId: json['user_id'] as int? ?? 0,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'token_type': tokenType,
        'user_id': userId,
        'full_name': fullName,
        'email': email,
      };

  @override
  List<Object?> get props => [accessToken, refreshToken, userId, email];
}
