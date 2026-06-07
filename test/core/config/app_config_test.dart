import 'package:flutter_test/flutter_test.dart';
import 'package:momodown/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('baseUrl returns default localhost when not overridden', () {
      expect(AppConfig.baseUrl, 'http://localhost:3000/api');
    });

    test('isDebug returns true by default', () {
      expect(AppConfig.isDebug, isTrue);
    });
  });
}
