import 'dart:math';

String generateRandomId() {
  final random = Random();
  final codeUnits = List.generate(16, (index) {
    return random.nextInt(33) + 89;
  });
  return String.fromCharCodes(codeUnits);
}
