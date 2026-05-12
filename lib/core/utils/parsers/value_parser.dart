double parseDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value is int) return value.toDouble();
  if (value is double) return value;
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}
