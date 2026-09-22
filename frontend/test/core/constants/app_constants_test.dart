import 'package:flutter_test/flutter_test.dart';
import 'package:khedmalink/core/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    test('email pattern should be valid regex', () {
      expect(AppConstants.emailPattern, isNotEmpty);
      expect(AppConstants.emailPattern, contains('@'));
    });

    test('phone pattern should be valid regex', () {
      expect(AppConstants.phonePattern, isNotEmpty);
    });

    test('password pattern should be valid regex', () {
      expect(AppConstants.passwordPattern, isNotEmpty);
    });

    test('spacing constants should be positive', () {
      expect(AppConstants.spacingXxs, greaterThan(0));
      expect(AppConstants.spacingXs, greaterThan(0));
      expect(AppConstants.spacingSm, greaterThan(0));
      expect(AppConstants.spacingMd, greaterThan(0));
      expect(AppConstants.spacingLg, greaterThan(0));
      expect(AppConstants.spacingXl, greaterThan(0));
      expect(AppConstants.spacingXxl, greaterThan(0));
    });

    test('border radius constants should be positive', () {
      expect(AppConstants.radiusSm, greaterThan(0));
      expect(AppConstants.radiusMd, greaterThan(0));
      expect(AppConstants.radiusLg, greaterThan(0));
      expect(AppConstants.radiusXl, greaterThan(0));
      expect(AppConstants.radiusXxl, greaterThan(0));
      expect(AppConstants.radiusFull, greaterThan(0));
    });

    test('font size constants should be positive', () {
      expect(AppConstants.fontSizeXs, greaterThan(0));
      expect(AppConstants.fontSizeSm, greaterThan(0));
      expect(AppConstants.fontSizeMd, greaterThan(0));
      expect(AppConstants.fontSizeLg, greaterThan(0));
      expect(AppConstants.fontSizeXl, greaterThan(0));
      expect(AppConstants.fontSizeXxl, greaterThan(0));
    });

    test('icon size constants should be positive', () {
      expect(AppConstants.iconSizeXs, greaterThan(0));
      expect(AppConstants.iconSizeSm, greaterThan(0));
      expect(AppConstants.iconSizeMd, greaterThan(0));
      expect(AppConstants.iconSizeLg, greaterThan(0));
      expect(AppConstants.iconSizeXl, greaterThan(0));
    });

    test('screen breakpoints should be positive', () {
      expect(AppConstants.breakpointMobile, greaterThan(0));
      expect(AppConstants.breakpointTablet, greaterThan(AppConstants.breakpointMobile));
      expect(AppConstants.breakpointDesktop, greaterThan(AppConstants.breakpointTablet));
    });

    test('avatar size constants should be positive', () {
      expect(AppConstants.avatarSizeSm, greaterThan(0));
      expect(AppConstants.avatarSizeMd, greaterThan(0));
      expect(AppConstants.avatarSizeLg, greaterThan(0));
      expect(AppConstants.avatarSizeXl, greaterThan(0));
    });

    test('file size limits should be positive', () {
      expect(AppConstants.maxFileSizeBytes, greaterThan(0));
      expect(AppConstants.maxImageSizeBytes, greaterThan(0));
    });

    test('supported image formats should not be empty', () {
      expect(AppConstants.supportedImageFormats, isNotEmpty);
    });

    test('supported document formats should not be empty', () {
      expect(AppConstants.supportedDocumentFormats, isNotEmpty);
    });

    test('error messages should not be empty', () {
      expect(AppConstants.errorGeneric, isNotEmpty);
      expect(AppConstants.errorNetwork, isNotEmpty);
      expect(AppConstants.errorTimeout, isNotEmpty);
      expect(AppConstants.errorUnauthorized, isNotEmpty);
      expect(AppConstants.errorNotFound, isNotEmpty);
      expect(AppConstants.errorValidation, isNotEmpty);
      expect(AppConstants.errorServer, isNotEmpty);
    });
  });
}
