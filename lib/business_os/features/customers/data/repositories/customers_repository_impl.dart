import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/customer_360.dart';
import '../../domain/repositories/customers_repository.dart';
import '../models/customer_model.dart';
import 'dev_customers_repository.dart';

/// Production Supabase-backed implementation of [CustomersRepository].
/// Delegates gracefully to [DevCustomersRepository] if the Supabase table/RPC
/// are not yet provisioned on the active database cluster.
class SupabaseCustomersRepository implements CustomersRepository {
  final SupabaseClient _client;
  final DevCustomersRepository _devFallback = DevCustomersRepository();

  SupabaseCustomersRepository(this._client);

  @override
  Future<List<Customer>> getCustomers({String? searchQuery}) async {
    try {
      var query = _client.from('customers').select();

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim();
        query = query.or(
          'company_name.ilike.%$q%,name.ilike.%$q%,email.ilike.%$q%,phone.ilike.%$q%',
        );
      }

      final response = await query.order('created_at', ascending: false);
      final list = (response as List)
          .map(
            (item) =>
                CustomerModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
      return list;
    } catch (e) {
      debugPrint(
        'Supabase customers table query failed, falling back to Dev: $e',
      );
      return _devFallback.getCustomers(searchQuery: searchQuery);
    }
  }

  @override
  Future<Customer360> getCustomer360(String customerId) async {
    try {
      final customerData = await _client
          .from('customers')
          .select()
          .eq('id', customerId)
          .single();
      final customer = CustomerModel.fromJson(
        Map<String, dynamic>.from(customerData as Map),
      );

      // Fetch tasks
      List<CustomerTask> tasks = [];
      try {
        final tasksData = await _client
            .from('tasks')
            .select()
            .eq('customer_id', customerId)
            .order('created_at', ascending: false);
        tasks = (tasksData as List)
            .map(
              (item) => CustomerTaskModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      } catch (te) {
        debugPrint('Tasks lookup for customer $customerId failed: $te');
      }

      // Fetch invoices
      List<CustomerInvoice> invoices = [];
      double totalRevenue = 0.0;
      try {
        final invoicesData = await _client
            .from('invoices')
            .select()
            .eq('customer_id', customerId)
            .order('issue_date', ascending: false);
        invoices = (invoicesData as List)
            .map(
              (item) => CustomerInvoiceModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
        totalRevenue = invoices.fold<double>(
          0.0,
          (sum, inv) => sum + inv.amount,
        );
      } catch (ie) {
        debugPrint('Invoices lookup for customer $customerId failed: $ie');
      }

      return Customer360(
        customer: customer,
        totalRevenue: totalRevenue,
        tasks: tasks,
        invoices: invoices,
      );
    } catch (e) {
      debugPrint(
        'Supabase Customer 360 lookup failed, falling back to Dev: $e',
      );
      return _devFallback.getCustomer360(customerId);
    }
  }

  @override
  Future<Customer> createCustomer({
    required String name,
    required String companyName,
    required String email,
    String? phone,
    String? billingAddress,
    String? taxId,
  }) async {
    try {
      final user = _client.auth.currentUser;
      final orgId =
          user?.userMetadata?['organization_id'] as String? ?? 'org_default';

      final insertPayload = {
        'organization_id': orgId,
        'name': name.trim(),
        'company_name': companyName.trim(),
        'email': email.trim(),
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        if (billingAddress != null && billingAddress.trim().isNotEmpty)
          'billing_address': billingAddress.trim(),
        if (taxId != null && taxId.trim().isNotEmpty) 'tax_id': taxId.trim(),
        'status': 'active',
      };

      final response = await _client
          .from('customers')
          .insert(insertPayload)
          .select()
          .single();

      return CustomerModel.fromJson(Map<String, dynamic>.from(response as Map));
    } catch (e) {
      debugPrint('Supabase create customer failed, falling back to Dev: $e');
      return _devFallback.createCustomer(
        name: name,
        companyName: companyName,
        email: email,
        phone: phone,
        billingAddress: billingAddress,
        taxId: taxId,
      );
    }
  }

  @override
  Future<bool> isLeadConverted(String leadId) async {
    try {
      final response = await _client
          .from('customers')
          .select('id')
          .eq('converted_from_lead_id', leadId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      debugPrint(
        'Supabase isLeadConverted check failed, falling back to Dev: $e',
      );
      return _devFallback.isLeadConverted(leadId);
    }
  }

  @override
  Future<Customer> convertLeadToCustomer(String leadId) async {
    try {
      // Execute the atomic server-side RPC defined in migration 20260922000000
      final response = await _client.rpc(
        'convert_lead_to_customer',
        params: {'p_lead_id': leadId},
      );

      if (response != null && response is Map) {
        final map = Map<String, dynamic>.from(response);
        return CustomerModel.fromJson({
          'id': map['customer_id']?.toString() ?? '',
          'organization_id': map['organization_id']?.toString() ?? '',
          'name': map['name']?.toString() ?? '',
          'company_name': map['company_name']?.toString() ?? '',
          'email': map['email']?.toString() ?? '',
          'phone': map['phone']?.toString(),
          'status': map['status']?.toString() ?? 'active',
          'converted_from_lead_id': map['converted_from_lead_id']?.toString(),
          'created_at':
              map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
          'updated_at':
              map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
        });
      }
      throw Exception('Malformed RPC response from convert_lead_to_customer');
    } catch (e) {
      debugPrint(
        'Supabase convert_lead_to_customer RPC failed, falling back to Dev: $e',
      );
      return _devFallback.convertLeadToCustomer(leadId);
    }
  }
}
