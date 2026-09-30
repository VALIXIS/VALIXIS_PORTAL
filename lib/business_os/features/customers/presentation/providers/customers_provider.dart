import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../../auth/presentation/providers/auth_state_notifier.dart';
import '../../data/repositories/customers_repository_impl.dart';
import '../../data/repositories/dev_customers_repository.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/customer_360.dart';
import '../../domain/repositories/customers_repository.dart';

export '../../domain/entities/customer.dart';
export '../../domain/entities/customer_360.dart';
export '../../domain/repositories/customers_repository.dart';

/// Provider for the Customers Repository.
final customersRepositoryProvider = Provider<CustomersRepository>((ref) {
  try {
    final client = sp.Supabase.instance.client;
    if (kDebugMode && client.auth.currentSession == null) {
      return DevCustomersRepository();
    }
    return SupabaseCustomersRepository(client);
  } catch (e) {
    debugPrint('Supabase unavailable for Customers, using Dev fallback: $e');
    return DevCustomersRepository();
  }
});

/// State of the customers directory collection and search query.
@immutable
class CustomersState {
  final List<Customer> customers;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  const CustomersState({
    required this.customers,
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  const CustomersState.initial()
    : customers = const [],
      searchQuery = '',
      isLoading = true,
      error = null;

  int get totalCount => customers.length;

  /// Derived list filtered by search query across company, contact, email, and phone.
  List<Customer> get filteredCustomers {
    if (searchQuery.trim().isEmpty) return customers;
    final q = searchQuery.toLowerCase().trim();
    return customers.where((c) {
      return c.companyName.toLowerCase().contains(q) ||
          c.name.toLowerCase().contains(q) ||
          c.email.toLowerCase().contains(q) ||
          (c.phone != null && c.phone!.toLowerCase().contains(q));
    }).toList();
  }

  CustomersState copyWith({
    List<Customer>? customers,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    return CustomersState(
      customers: customers ?? this.customers,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomersState &&
          runtimeType == other.runtimeType &&
          listEquals(customers, other.customers) &&
          searchQuery == other.searchQuery &&
          isLoading == other.isLoading &&
          error == other.error;

  @override
  int get hashCode =>
      customers.hashCode ^
      searchQuery.hashCode ^
      isLoading.hashCode ^
      error.hashCode;
}

/// StateNotifier managing customer collection fetching, filtering, and additions.
class CustomersNotifier extends StateNotifier<CustomersState> {
  final CustomersRepository _repository;

  CustomersNotifier(this._repository) : super(const CustomersState.initial()) {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repository.getCustomers();
      if (!mounted) return;
      state = state.copyWith(customers: list, isLoading: false, error: null);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<Customer> createCustomer({
    required String name,
    required String companyName,
    required String email,
    String? phone,
    String? billingAddress,
    String? taxId,
  }) async {
    final newCustomer = await _repository.createCustomer(
      name: name,
      companyName: companyName,
      email: email,
      phone: phone,
      billingAddress: billingAddress,
      taxId: taxId,
    );

    if (mounted) {
      // Immediately prepend to canonical collection
      final updatedList = [newCustomer, ...state.customers];
      state = state.copyWith(customers: updatedList);
    }
    return newCustomer;
  }

  void addCustomer(Customer customer) {
    if (!state.customers.any((c) => c.id == customer.id)) {
      state = state.copyWith(customers: [customer, ...state.customers]);
    }
  }

  Future<void> refresh() async => loadCustomers();
}

/// Provider for Customers collection and query state.
final customersProvider =
    StateNotifierProvider<CustomersNotifier, CustomersState>((ref) {
      final repository = ref.watch(customersRepositoryProvider);
      // Re-fetch when organization context changes
      ref.watch(currentOrganizationProvider);
      return CustomersNotifier(repository);
    });

/// Tracks currently selected customer ID for the 360 profile slide-over drawer.
final selectedCustomerIdProvider = StateProvider<String?>((ref) => null);

/// Family FutureProvider fetching Customer360 profile data on demand.
final customer360Provider = FutureProvider.family<Customer360, String>((
  ref,
  customerId,
) async {
  final repo = ref.watch(customersRepositoryProvider);
  return repo.getCustomer360(customerId);
});

/// Sealed state hierarchy for Won Lead -> Customer conversion.
@immutable
sealed class LeadConversionState {
  const LeadConversionState();
}

class LeadConversionIdle extends LeadConversionState {
  const LeadConversionIdle();
}

class LeadConversionLoading extends LeadConversionState {
  const LeadConversionLoading();
}

class LeadConversionSuccess extends LeadConversionState {
  final Customer customer;
  const LeadConversionSuccess(this.customer);
}

class LeadConversionError extends LeadConversionState {
  final String message;
  const LeadConversionError(this.message);
}

/// Notifier managing isolated per-lead conversion lifecycle and idempotency.
class LeadConversionNotifier extends StateNotifier<LeadConversionState> {
  final CustomersRepository _repository;
  final Ref _ref;

  LeadConversionNotifier(this._repository, this._ref)
    : super(const LeadConversionIdle());

  Future<void> convert({
    required String leadId,
    required String leadName,
    required String companyName,
    required String? email,
    String? phone,
  }) async {
    // Duplicate conversion guard
    if (state is LeadConversionLoading || state is LeadConversionSuccess) {
      return;
    }

    state = const LeadConversionLoading();
    try {
      final Customer customer;
      final repo = _repository;
      if (repo is DevCustomersRepository) {
        customer = await repo.convertLeadWithDetails(
          leadId: leadId,
          name: leadName,
          companyName: companyName,
          email: email ?? '',
          phone: phone,
        );
      } else {
        customer = await _repository.convertLeadToCustomer(leadId);
      }

      if (!mounted) return;
      state = LeadConversionSuccess(customer);

      // Invalidate/update customersProvider so the customer immediately appears in CustomersScreen
      _ref.read(customersProvider.notifier).addCustomer(customer);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = LeadConversionError(msg);
    }
  }

  void reset() {
    state = const LeadConversionIdle();
  }
}

/// Family provider managing conversion state keyed by lead ID.
final leadConversionProvider =
    StateNotifierProvider.family<
      LeadConversionNotifier,
      LeadConversionState,
      String
    >((ref, leadId) {
      final repo = ref.watch(customersRepositoryProvider);
      return LeadConversionNotifier(repo, ref);
    });
