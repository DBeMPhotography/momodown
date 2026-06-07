import 'package:flutter_test/flutter_test.dart';
import 'package:momodown/core/config/app_config.dart';
import 'package:momodown/core/network/api_endpoints.dart';

void main() {
  group('ApiEndpoints', () {
    test('baseUrl matches AppConfig', () {
      expect(ApiEndpoints.baseUrl, AppConfig.baseUrl);
    });

    test('auth paths are correct', () {
      expect(ApiEndpoints.login, '/auth/login');
      expect(ApiEndpoints.register, '/auth/register');
      expect(ApiEndpoints.refreshToken, '/auth/refresh');
    });

    test('memo path is correct', () {
      expect(ApiEndpoints.memos, '/memos');
    });

    test('accounting path is correct', () {
      expect(ApiEndpoints.transactions, '/transactions');
    });

    test('voice path is correct', () {
      expect(ApiEndpoints.parseVoice, '/voice/parse');
    });

    test('sync path is correct', () {
      expect(ApiEndpoints.sync, '/sync');
    });
  });
}
