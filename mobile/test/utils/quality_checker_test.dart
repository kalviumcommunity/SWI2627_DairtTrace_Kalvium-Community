import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/quality_checker.dart';

void main() {
  group('QualityChecker', () {
    test('accepts milk when all readings are within limits', () {
      final result = QualityChecker.check(fat: 4.0, snf: 8.5, temperature: 6.0);

      expect(result.isAccepted, isTrue);
      expect(result.status, 'ACCEPTED');
      expect(result.reasons, isEmpty);
    });

    test('returns alert when fat is too low', () {
      final result = QualityChecker.check(fat: 2.5, snf: 8.5, temperature: 6.0);

      expect(result.isAccepted, isFalse);
      expect(result.status, 'ALERT');
      expect(result.message, contains('Fat is below'));
    });

    test('returns alert when SNF is too low', () {
      final result = QualityChecker.check(fat: 4.0, snf: 7.5, temperature: 6.0);

      expect(result.isAccepted, isFalse);
      expect(result.status, 'ALERT');
      expect(result.message, contains('SNF is below'));
    });

    test('returns alert when temperature is too high', () {
      final result = QualityChecker.check(
        fat: 4.0,
        snf: 8.5,
        temperature: 15.0,
      );

      expect(result.isAccepted, isFalse);
      expect(result.status, 'ALERT');
      expect(result.message, contains('Temperature is above'));
    });

    test('reports multiple quality problems together', () {
      final result = QualityChecker.check(
        fat: 2.0,
        snf: 7.0,
        temperature: 15.0,
      );

      expect(result.isAccepted, isFalse);
      expect(result.reasons.length, 3);
    });
  });
}
