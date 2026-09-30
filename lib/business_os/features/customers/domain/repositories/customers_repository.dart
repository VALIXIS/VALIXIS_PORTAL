import '../entities/customer.dart';
import '../entities/customer_360.dart';

/// Clean domain repository contract for Customer operations in VALIXIS BUSINESS OS.
abstract interface class CustomersRepository {
  /// Fetches all accessible customers for the active organization, optionally filtered by [searchQuery].
  Future<List<Customer>> getCustomers({String? searchQuery});

  /// Fetches complete 360 profile aggregate for a specific customer.
  Future<Customer360> getCustomer360(String customerId);

  /// Creates a new customer account.
  Future<Customer> createCustomer({
    required String name,
    required String companyName,
    required String email,
    String? phone,
    String? billingAddress,
    String? taxId,
  });

  /// Transactionally converts a 'won' lead into a customer.
  Future<Customer> convertLeadToCustomer(String leadId);

  /// Checks if a lead has already been converted into a customer.
  Future<bool> isLeadConverted(String leadId);
}
