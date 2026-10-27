import 'package:flutter_test/flutter_test.dart';
import 'package:valixis_portal/core/storage/auth_storage.dart';

void main() {
  group('AuthStorageService & Credential Memory Tests', () {
    setUp(() {
      AuthStorageService.clearRememberedEmail();
      AuthStorageService.setRememberMe(true);
    });

    test('getRememberedEmail returns null initially when cleared', () {
      expect(AuthStorageService.getRememberedEmail(), isNull);
    });

    test('persists and retrieves remembered employee email correctly', () {
      const email = 'hasitha@valixis.com';
      AuthStorageService.setRememberedEmail(email);

      expect(AuthStorageService.getRememberedEmail(), equals(email));
    });

    test('clears remembered email when instructed', () {
      AuthStorageService.setRememberedEmail('krishna@valixis.com');
      expect(AuthStorageService.getRememberedEmail(), equals('krishna@valixis.com'));

      AuthStorageService.clearRememberedEmail();
      expect(AuthStorageService.getRememberedEmail(), isNull);
    });

    test('remembers and toggles rememberMe preference', () {
      expect(AuthStorageService.getRememberMe(), isTrue);

      AuthStorageService.setRememberMe(false);
      expect(AuthStorageService.getRememberMe(), isFalse);

      AuthStorageService.setRememberMe(true);
      expect(AuthStorageService.getRememberMe(), isTrue);
    });
  });
}
