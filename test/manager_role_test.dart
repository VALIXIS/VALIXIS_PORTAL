import 'package:flutter_test/flutter_test.dart';
import 'package:valixis_portal/features/auth/domain/role_service.dart';

void main() {
  group('UserRole Authorization', () {
    test('UserRole.fromString identifies manager roles correctly', () {
      expect(UserRole.fromString('manager'), equals(UserRole.manager));
      expect(UserRole.fromString('MANAGER'), equals(UserRole.manager));
      expect(UserRole.fromString('admin'), equals(UserRole.manager));
      expect(UserRole.fromString('Engineering Lead'), equals(UserRole.manager));
      expect(UserRole.fromString('lead'), equals(UserRole.manager));
      expect(UserRole.fromString('Co-founder / Manager'), equals(UserRole.manager));
    });

    test('UserRole.fromString defaults to employee for non-manager roles', () {
      expect(UserRole.fromString('employee'), equals(UserRole.employee));
      expect(UserRole.fromString('developer'), equals(UserRole.employee));
      expect(UserRole.fromString('intern'), equals(UserRole.employee));
      expect(UserRole.fromString(null), equals(UserRole.employee));
      expect(UserRole.fromString(''), equals(UserRole.employee));
    });

    test('isManager getter behaves accurately', () {
      expect(UserRole.manager.isManager, isTrue);
      expect(UserRole.employee.isManager, isFalse);
    });
  });
}
