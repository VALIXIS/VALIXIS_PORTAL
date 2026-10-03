import 'package:flutter/foundation.dart';

@immutable
class PlayConsoleApp {
  final String name;
  final String packageName;
  final int installedAudience;
  final String status;
  final String lastUpdated;
  final String version;

  const PlayConsoleApp({
    required this.name,
    required this.packageName,
    required this.installedAudience,
    required this.status,
    required this.lastUpdated,
    required this.version,
  });

  bool get isProduction => status.toLowerCase().contains('production');
}

@immutable
class AdMobAccountInfo {
  final String publisherId;
  final String adsenseCustomerId;
  final String currency;
  final String status;
  final String timezone;

  const AdMobAccountInfo({
    required this.publisherId,
    required this.adsenseCustomerId,
    required this.currency,
    required this.status,
    required this.timezone,
  });
}

class RealDeveloperTelemetry {
  RealDeveloperTelemetry._();

  static const AdMobAccountInfo admobAccount = AdMobAccountInfo(
    publisherId: 'pub-6059224677913709',
    adsenseCustomerId: '498-494-8802',
    currency: 'USD (\$)',
    status: 'Open',
    timezone: 'Asia/Calcutta (GMT+05:30)',
  );

  /// Verified Live Google Play Console apps retrieved via Google Play Developer API
  static const List<PlayConsoleApp> realApps = [
    PlayConsoleApp(
      name: 'Planly – To-Do & Reminders',
      packageName: 'com.js.planly',
      installedAudience: 13,
      status: 'Production',
      lastUpdated: 'Oct 2, 2026',
      version: 'v1.0.2 (Build 5)',
    ),
    PlayConsoleApp(
      name: 'Password Vault',
      packageName: 'com.krishna.password_vault',
      installedAudience: 10,
      status: 'Production',
      lastUpdated: 'Aug 31, 2026',
      version: 'v1.0.0 (Build 5)',
    ),
    PlayConsoleApp(
      name: 'Fitora',
      packageName: 'com.subhash.fitora',
      installedAudience: 8,
      status: 'Production',
      lastUpdated: 'Oct 2, 2026',
      version: 'v1.2.2 (Build 11)',
    ),
    PlayConsoleApp(
      name: 'MedReminder',
      packageName: 'com.subhash.medreminder',
      installedAudience: 6,
      status: 'Closed testing',
      lastUpdated: 'Apr 24, 2026',
      version: 'Closed Test Track',
    ),
    PlayConsoleApp(
      name: 'AI PDF Toolkit',
      packageName: 'com.nagas.pdfaitoolkit',
      installedAudience: 5,
      status: 'Closed testing',
      lastUpdated: 'Oct 2, 2026',
      version: 'Closed Test Track',
    ),
    PlayConsoleApp(
      name: 'Resume Brain',
      packageName: 'com.valixis.resumebrain',
      installedAudience: 3,
      status: 'Closed testing',
      lastUpdated: 'Oct 2, 2026',
      version: 'Closed Test Track',
    ),
    PlayConsoleApp(
      name: 'PocketLedger',
      packageName: 'com.valixis.pocketledger',
      installedAudience: 0,
      status: 'Closed testing',
      lastUpdated: 'Aug 26, 2026',
      version: 'Closed Test Track',
    ),
  ];

  static int get totalInstalledAudience =>
      realApps.fold<int>(0, (sum, a) => sum + a.installedAudience);

  static int get productionAppsCount =>
      realApps.where((a) => a.isProduction).length;

  static int get closedTestingAppsCount =>
      realApps.where((a) => !a.isProduction).length;
}
