/// Strongly typed supported payment methods matching database constraints:
/// LOWER(payment_method) IN ('cash', 'upi', 'bank_transfer', 'card', 'cheque', 'other')
enum PaymentMethod {
  bankTransfer('bank_transfer', 'Bank Transfer'),
  card('card', 'Credit / Debit Card'),
  upi('upi', 'UPI Payment'),
  cash('cash', 'Cash'),
  cheque('cheque', 'Cheque'),
  other('other', 'Other');

  final String value;
  final String displayName;

  const PaymentMethod(this.value, this.displayName);

  static PaymentMethod fromValue(String value) {
    return PaymentMethod.values.firstWhere(
      (m) => m.value.toLowerCase() == value.toLowerCase(),
      orElse: () => PaymentMethod.bankTransfer,
    );
  }
}
