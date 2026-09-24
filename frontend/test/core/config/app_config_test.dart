import 'package:flutter_test/flutter_test.dart';
import 'package:khedmalink/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('app name should be KhedmaLink', () {
      expect(AppConfig.appName, 'KhedmaLink');
    });

    test('app version should be 0.1.0', () {
      expect(AppConfig.appVersion, '0.1.0');
    });

    test('build number should be 1', () {
      expect(AppConfig.buildNumber, '1');
    });

    test('environment should be development by default', () {
      expect(AppConfig.environment, 'development');
    });

    test('debug banner should be shown in development', () {
      expect(AppConfig.showDebugBanner, true);
    });

    test('debug logging should be enabled in development', () {
      expect(AppConfig.enableDebugLogging, true);
    });

    test('api base URL should use localhost in development', () {
      // Accept localhost and emulator IP for testing
      final validUrls = ['http://localhost:8000', 'http://10.0.2.2:8000'];
      expect(validUrls.contains(AppConfig.apiBaseUrl), true);
    });

    test('api version should be v1', () {
      expect(AppConfig.apiVersion, 'v1');
    });

    test('api endpoint should include version', () {
      // Accept localhost and emulator IP for testing
      final validEndpoints = ['http://localhost:8000/api/v1', 'http://10.0.2.2:8000/api/v1'];
      expect(validEndpoints.contains(AppConfig.apiEndpoint), true);
    });

    test('default language should be Arabic', () {
      expect(AppConfig.defaultLanguage, 'ar');
    });

    test('supported languages should include Arabic and French', () {
      expect(AppConfig.supportedLanguages, ['ar', 'fr']);
    });

    test('min password length should be 8', () {
      expect(AppConfig.minPasswordLength, 8);
    });

    test('max password length should be 128', () {
      expect(AppConfig.maxPasswordLength, 128);
    });

    test('default page size should be 20', () {
      expect(AppConfig.defaultPageSize, 20);
    });

    test('max page size should be 100', () {
      expect(AppConfig.maxPageSize, 100);
    });
  });
}
