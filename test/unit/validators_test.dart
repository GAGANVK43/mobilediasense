import 'package:flutter_test/flutter_test.dart';
import 'package:diasense_mobile/core/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    test('validateEmail returns null for valid email', () {
      expect(Validators.validateEmail('patient@example.com'), isNull);
      expect(Validators.validateEmail('dr.smith+care@hospital.org'), isNull);
    });

    test('validateEmail returns error message for invalid email', () {
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail('invalid-email'), isNotNull);
      expect(Validators.validateEmail('missing@domain'), isNotNull);
    });

    test('validatePassword validates minimum 6 characters', () {
      expect(Validators.validatePassword('123456'), isNull);
      expect(Validators.validatePassword('securePass1!'), isNull);
      expect(Validators.validatePassword('12345'), isNotNull);
      expect(Validators.validatePassword(''), isNotNull);
    });

    test('validateNumberRange enforces min and max clinical boundaries', () {
      expect(Validators.validateNumberRange('120', 'Glucose', min: 40, max: 500), isNull);
      expect(Validators.validateNumberRange('30', 'Glucose', min: 40, max: 500), isNotNull);
      expect(Validators.validateNumberRange('600', 'Glucose', min: 40, max: 500), isNotNull);
      expect(Validators.validateNumberRange('abc', 'Glucose', min: 40, max: 500), isNotNull);
    });
  });
}
