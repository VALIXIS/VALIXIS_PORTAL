/// Domain model representing a multi-tenant business organization in VALIXIS.
class Organization {
  final String id;
  final String name;
  final String slug;
  final String currency;
  final String timezone;
  final String? logoUrl;
  final DateTime? createdAt;

  const Organization({
    required this.id,
    required this.name,
    required this.slug,
    this.currency = 'USD',
    this.timezone = 'UTC',
    this.logoUrl,
    this.createdAt,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      currency: json['currency'] as String? ?? 'USD',
      timezone: json['timezone'] as String? ?? 'UTC',
      logoUrl: json['logo_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'currency': currency,
      'timezone': timezone,
      'logo_url': logoUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Organization copyWith({
    String? id,
    String? name,
    String? slug,
    String? currency,
    String? timezone,
    String? logoUrl,
    DateTime? createdAt,
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      currency: currency ?? this.currency,
      timezone: timezone ?? this.timezone,
      logoUrl: logoUrl ?? this.logoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Organization &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

/// Strongly typed supported currencies
class AppCurrency {
  final String code;
  final String name;
  final String symbol;

  const AppCurrency({
    required this.code,
    required this.name,
    required this.symbol,
  });

  static const List<AppCurrency> supportedCurrencies = [
    AppCurrency(code: 'USD', name: 'US Dollar', symbol: '\$'),
    AppCurrency(code: 'EUR', name: 'Euro', symbol: '€'),
    AppCurrency(code: 'GBP', name: 'British Pound', symbol: '£'),
    AppCurrency(code: 'INR', name: 'Indian Rupee', symbol: '₹'),
    AppCurrency(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$'),
    AppCurrency(code: 'CAD', name: 'Canadian Dollar', symbol: 'C\$'),
    AppCurrency(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
    AppCurrency(code: 'SGD', name: 'Singapore Dollar', symbol: 'S\$'),
    AppCurrency(code: 'AED', name: 'UAE Dirham', symbol: 'AED'),
  ];

  static AppCurrency fromCode(String code) {
    return supportedCurrencies.firstWhere(
      (c) => c.code.toUpperCase() == code.toUpperCase(),
      orElse: () => supportedCurrencies.first,
    );
  }
}

/// Standardized timezones for enterprise workspaces
class AppTimezones {
  AppTimezones._();

  static const List<String> commonTimezones = [
    'UTC',
    'America/New_York',
    'America/Chicago',
    'America/Denver',
    'America/Los_Angeles',
    'Europe/London',
    'Europe/Berlin',
    'Europe/Paris',
    'Asia/Dubai',
    'Asia/Kolkata',
    'Asia/Singapore',
    'Asia/Tokyo',
    'Asia/Hong_Kong',
    'Australia/Sydney',
  ];

  /// Guess or default the local timezone name
  static String get initialTimezone {
    final now = DateTime.now();
    final offset = now.timeZoneOffset;
    if (offset.inHours == 5 && offset.inMinutes % 60 == 30) {
      return 'Asia/Kolkata';
    } else if (offset.inHours == 8 && offset.inMinutes % 60 == 0) {
      return 'Asia/Singapore';
    } else if (offset.inHours == 0 && offset.inMinutes == 0) {
      return 'UTC';
    } else if (offset.inHours == 1 || offset.inHours == 2) {
      return 'Europe/Berlin';
    } else if (offset.inHours == -5 || offset.inHours == -4) {
      return 'America/New_York';
    } else if (offset.inHours == -8 || offset.inHours == -7) {
      return 'America/Los_Angeles';
    }
    return 'UTC';
  }
}
