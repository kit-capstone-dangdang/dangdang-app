double parseDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value is int) return value.toDouble();
  if (value is double) return value;
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

double parseServingCount(
  dynamic value, {
  String? amountLabel,
  double defaultValue = 1.0,
}) {
  final parsed = parseDouble(value, defaultValue: defaultValue);
  if (parsed > 1.0) return parsed;

  final label = amountLabel?.trim() ?? '';
  if (label.isEmpty) {
    return parsed <= 0 ? defaultValue : parsed;
  }

  final match = RegExp(r'^(\d+(?:\.\d+)?)').firstMatch(label);
  if (match != null) {
    final labelCount = double.tryParse(match.group(1)!);
    if (labelCount != null && labelCount > 0) {
      return labelCount;
    }
  }

  return parsed <= 0 ? defaultValue : parsed;
}
