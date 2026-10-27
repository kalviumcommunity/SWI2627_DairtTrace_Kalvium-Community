class QualityCheckResult {
  const QualityCheckResult({required this.isAccepted, required this.reasons});

  final bool isAccepted;
  final List<String> reasons;

  String get status => isAccepted ? 'ACCEPTED' : 'ALERT';

  String get message {
    if (isAccepted) {
      return 'Milk quality is within the accepted range.';
    }

    return reasons.join(' ');
  }
}

class QualityChecker {
  QualityChecker._();

  // MVP / demo thresholds.
  // Change these later if your project receives official quality standards.
  static const double minimumFat = 3.0;
  static const double minimumSnf = 8.0;
  static const double maximumTemperature = 10.0;

  static QualityCheckResult check({
    required double fat,
    required double snf,
    required double temperature,
  }) {
    for (final entry in {
      'Fat': fat,
      'SNF': snf,
      'Temperature': temperature,
    }.entries) {
      if (!entry.value.isFinite ||
          entry.value < 0 ||
          (entry.key != 'Temperature' && entry.value > 100)) {
        throw ArgumentError('Invalid ${entry.key} reading.');
      }
    }
    final reasons = <String>[];

    if (fat < minimumFat) {
      reasons.add('Fat is below the minimum requirement of $minimumFat%.');
    }

    if (snf < minimumSnf) {
      reasons.add('SNF is below the minimum requirement of $minimumSnf%.');
    }

    if (temperature > maximumTemperature) {
      reasons.add(
        'Temperature is above the maximum allowed '
        '${maximumTemperature.toStringAsFixed(1)}°C.',
      );
    }

    return QualityCheckResult(isAccepted: reasons.isEmpty, reasons: reasons);
  }
}
