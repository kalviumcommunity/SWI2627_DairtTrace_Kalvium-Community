String? validateEmail(String? value) {
  final email = value?.trim() ?? '';

  if (email.isEmpty) {
    return 'Email is required.';
  }

  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return 'Enter a valid email address.';
  }

  return null;
}

String? validatePassword(String? value, {required bool isRegistering}) {
  final password = value ?? '';

  if (password.isEmpty) {
    return 'Password is required.';
  }

  if (isRegistering && password.length < 6) {
    return 'Password must be at least 6 characters.';
  }

  return null;
}

String? validateFarmerName(String? value) {
  final name = value?.trim() ?? '';

  if (name.isEmpty) {
    return 'Farmer name is required.';
  }

  if (name.length < 2) {
    return 'Enter at least 2 characters.';
  }

  if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(name)) {
    return 'Use letters and spaces only.';
  }

  return null;
}

String? validateMilkQuantity(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Milk quantity is required.';
  }

  final quantity = double.tryParse(value.trim());

  if (quantity == null || !quantity.isFinite || quantity <= 0) {
    return 'Enter a valid quantity greater than 0.';
  }

  return null;
}

String? validateQualityReading(
  String? value, {
  required String label,
  bool percentage = false,
}) {
  if (value == null || value.trim().isEmpty) return '$label is required.';
  final reading = double.tryParse(value.trim());
  if (reading == null ||
      !reading.isFinite ||
      reading < 0 ||
      (percentage && reading > 100)) {
    return percentage
        ? 'Enter $label between 0 and 100.'
        : 'Enter a valid non-negative $label.';
  }
  return null;
}
