import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/form_validators.dart';

void main() {
  group('validateEmail', () {
    test('requires a value', () {
      expect(validateEmail(null), 'Email is required.');
      expect(validateEmail('  '), 'Email is required.');
    });

    test('rejects malformed addresses and accepts a trimmed address', () {
      expect(validateEmail('not-an-email'), 'Enter a valid email address.');
      expect(validateEmail(' user@example.com '), isNull);
    });
  });

  group('validatePassword', () {
    test('requires a value for sign-in and registration', () {
      expect(
        validatePassword('', isRegistering: false),
        'Password is required.',
      );
      expect(
        validatePassword(null, isRegistering: true),
        'Password is required.',
      );
    });

    test('enforces minimum length only during registration', () {
      expect(
        validatePassword('abc', isRegistering: true),
        'Password must be at least 6 characters.',
      );
      expect(validatePassword('abc', isRegistering: false), isNull);
      expect(validatePassword('abcdef', isRegistering: true), isNull);
    });
  });

  group('validateFarmerName', () {
    test('requires at least two letters', () {
      expect(validateFarmerName(null), 'Farmer name is required.');
      expect(validateFarmerName(' '), 'Farmer name is required.');
      expect(validateFarmerName('A'), 'Enter at least 2 characters.');
      expect(validateFarmerName('Ada 2'), 'Use letters and spaces only.');
    });

    test('accepts a trimmed name containing letters and spaces', () {
      expect(validateFarmerName('  Ada Lovelace  '), isNull);
    });
  });

  group('validateMilkQuantity', () {
    test('requires a positive finite number', () {
      expect(validateMilkQuantity(null), 'Milk quantity is required.');
      expect(validateMilkQuantity(' '), 'Milk quantity is required.');
      expect(
        validateMilkQuantity('not a number'),
        'Enter a valid quantity greater than 0.',
      );
      expect(
        validateMilkQuantity('0'),
        'Enter a valid quantity greater than 0.',
      );
      expect(
        validateMilkQuantity('-1'),
        'Enter a valid quantity greater than 0.',
      );
      expect(
        validateMilkQuantity('NaN'),
        'Enter a valid quantity greater than 0.',
      );
    });

    test('accepts a positive decimal value', () {
      expect(validateMilkQuantity(' 1.25 '), isNull);
    });
  });
}
