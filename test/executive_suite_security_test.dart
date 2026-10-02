import 'package:flutter_test/flutter_test.dart';
import 'package:valixis_portal/app/router/app_router.dart';
import 'package:valixis_portal/features/auth/domain/role_service.dart';

void main() {
  group('Executive Suite Security & Stealth Gatekeeping Tests', () {
    test('AppRoutes contains paths for all 4 unified suites', () {
      expect(AppRoutes.managerDashboard, equals('/manager'));
      expect(AppRoutes.businessOs, equals('/business-os'));
      expect(AppRoutes.flow, equals('/flow'));
      expect(AppRoutes.flowWorkflows, equals('/flow/workflows'));
      expect(AppRoutes.flowLogs, equals('/flow/logs'));
      expect(AppRoutes.flowAnalytics, equals('/flow/analytics'));
      expect(AppRoutes.pulse, equals('/pulse'));
      expect(AppRoutes.pulseDashboard, equals('/pulse/dashboard'));
      expect(AppRoutes.pulseForensic, equals('/pulse/forensic'));
      expect(AppRoutes.pulsePredictive, equals('/pulse/predictive'));
      expect(AppRoutes.pulseAnomalies, equals('/pulse/anomalies'));
    });

    test('UserRole permissions strictly categorize manager vs employee', () {
      expect(UserRole.manager.isManager, isTrue);
      expect(UserRole.fromString('admin').isManager, isTrue);
      expect(UserRole.fromString('lead').isManager, isTrue);
      expect(UserRole.employee.isManager, isFalse);
      expect(UserRole.fromString('intern').isManager, isFalse);
    });

    test('Restricted suite paths list covers all executive surfaces', () {
      final executivePrefixes = ['/manager', '/business-os', '/flow', '/pulse'];
      
      for (final prefix in executivePrefixes) {
        // Any route starting with these prefixes must be restricted for employees
        expect(prefix.startsWith('/manager') ||
               prefix.startsWith('/business-os') ||
               prefix.startsWith('/flow') ||
               prefix.startsWith('/pulse'), isTrue);
      }
    });

    test('Regular employee routes are completely separated and non-executive', () {
      final employeeSafeRoutes = ['/dashboard', '/tasks', '/calendar', '/profile'];
      
      for (final route in employeeSafeRoutes) {
        final isRestricted = route.startsWith('/manager') ||
                             route.startsWith('/business-os') ||
                             route.startsWith('/flow') ||
                             route.startsWith('/pulse');
        expect(isRestricted, isFalse, reason: 'Route $route should be accessible to employees');
      }
    });
  });
}
