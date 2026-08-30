import 'package:flutter_test/flutter_test.dart';
import 'package:diasense_mobile/features/authentication/data/models/auth_tokens.dart';
import 'package:diasense_mobile/features/authentication/data/models/user_model.dart';

void main() {
  group('Auth Models Unit Tests', () {
    test('AuthTokens JSON parsing and serialization', () {
      final json = {
        'access_token': 'jwt.token.sample',
        'refresh_token': 'jwt.refresh.sample',
        'token_type': 'bearer',
        'user_id': 42,
        'full_name': 'John Doe',
        'email': 'john@example.com',
      };

      final tokens = AuthTokens.fromJson(json);
      expect(tokens.accessToken, 'jwt.token.sample');
      expect(tokens.userId, 42);
      expect(tokens.email, 'john@example.com');
      expect(tokens.toJson()['user_id'], 42);
    });

    test('UserModel JSON parsing and copyWith', () {
      final user = UserModel(
        id: 1,
        fullName: 'Jane Smith',
        email: 'jane@example.com',
        age: 28,
        gender: 'Female',
      );

      final updated = user.copyWith(fullName: 'Dr. Jane Smith');
      expect(updated.fullName, 'Dr. Jane Smith');
      expect(updated.age, 28);
      expect(updated.id, 1);
    });
  });
}
