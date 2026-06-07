import 'package:flutter_test/flutter_test.dart';
import 'package:momodown/core/utils/logger.dart';

void main() {
  group('AppLogger', () {
    test('does not throw when logging messages', () {
      expect(() => AppLogger.d('debug message'), returnsNormally);
      expect(() => AppLogger.i('info message'), returnsNormally);
      expect(() => AppLogger.w('warning message'), returnsNormally);
      expect(() => AppLogger.e('error message'), returnsNormally);
    });
  });
}
