import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../../../auth/domain/entities/organization.dart';
import '../entities/invoice_line_item.dart';

/// Deterministic financial calculator for VALIXIS BUSINESS OS.
/// All monetary values are maintained and rounded to 2 decimal places (cents).
class FinancialCalculator {
  FinancialCalculator._();

  /// Allowed standard tax percentage rates.
  static const List<double> allowedTaxRates = [0.0, 5.0, 12.0, 18.0, 28.0];

  /// Rounds a double value to 2 decimal places using half-up arithmetic.
  static double roundMoney(double value) {
    if (value.isNaN || value.isInfinite) return 0.0;
    // Multiply by 100 with epsilon to avoid precision issues like 1.005 * 100 = 100.49999999999999
    final factor = math.pow(10, 2);
    final sign = value < 0 ? -1.0 : 1.0;
    final absVal = value.abs();
    final shifted = (absVal * factor) + 1e-10;
    final rounded = shifted.roundToDouble();
    return sign * (rounded / factor);
  }

  /// Calculates individual line item total: Quantity × Unit Price.
  static double calculateLineTotal(double quantity, double unitPrice) {
    if (quantity <= 0 || unitPrice < 0) return 0.0;
    return roundMoney(quantity * unitPrice);
  }

  /// Calculates the sum of all valid line totals.
  static double calculateSubtotal(List<InvoiceLineItem> items) {
    double sum = 0.0;
    for (final item in items) {
      sum += calculateLineTotal(item.quantity, item.unitPrice);
    }
    return roundMoney(sum);
  }

  /// Calculates tax amount: Subtotal × (Tax Rate / 100).
  /// Enforces non-negative tax and allowed rates.
  static double calculateTaxAmount(double subtotal, double taxRate) {
    if (subtotal <= 0 || taxRate <= 0) return 0.0;
    final rate = taxRate.clamp(0.0, 100.0);
    return roundMoney(subtotal * (rate / 100.0));
  }

  /// Calculates Grand Total: Subtotal + Tax Amount.
  static double calculateGrandTotal(double subtotal, double taxAmount) {
    return roundMoney(math.max(0.0, subtotal) + math.max(0.0, taxAmount));
  }

  /// Formats any monetary amount with 2 decimal places and the appropriate currency symbol.
  /// Example: formatCurrency(1800.0, 'INR') -> "₹1,800.00"
  /// Example: formatCurrency(1234.56, 'USD') -> "$1,234.56"
  static String formatCurrency(double amount, String currencyCode) {
    final currency = AppCurrency.fromCode(currencyCode);
    final symbol = currency.symbol;
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(roundMoney(amount));
  }
}
