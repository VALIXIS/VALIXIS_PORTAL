import 'package:intl/intl.dart';

class AppUtils {
  AppUtils._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 0,
  );

  static final NumberFormat _compactCurrencyFormat =
      NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 1);

  static final NumberFormat _numberFormat = NumberFormat.decimalPattern();

  static String formatCurrency(num amount) {
    return _currencyFormat.format(amount);
  }

  static String formatCompactCurrency(num amount) {
    return _compactCurrencyFormat.format(amount);
  }

  static String formatNumber(num number) {
    return _numberFormat.format(number);
  }

  static String getInitials(String name) {
    if (name.trim().isEmpty) return 'VX';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length.clamp(1, 2)).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
