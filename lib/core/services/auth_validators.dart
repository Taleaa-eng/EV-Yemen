bool isValidYemenPhone(String value) {
  final compact = value.replaceAll(RegExp(r'[\s()-]'), '');
  return RegExp(r'^(?:(?:\+|00)?967)?0?7\d{8}$').hasMatch(compact);
}

String normalizeYemenPhone(String value) {
  var digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('00')) digits = digits.substring(2);
  if (digits.startsWith('967')) digits = digits.substring(3);
  if (digits.startsWith('0')) digits = digits.substring(1);
  return digits;
}

bool isValidEmail(String value) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());

bool isValidPassword(String value) => value.length >= 8;
