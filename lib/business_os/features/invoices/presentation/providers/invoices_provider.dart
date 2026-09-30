import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../data/repositories/dev_invoices_repository.dart';
import '../../data/repositories/supabase_invoices_repository.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/repositories/invoices_repository.dart';

export '../../domain/entities/invoice.dart';
export '../../domain/entities/invoice_line_item.dart';
export '../../domain/repositories/invoices_repository.dart';
export '../../domain/utils/financial_calculator.dart';

/// Provider for the InvoicesRepository.
final invoicesRepositoryProvider = Provider<InvoicesRepository>((ref) {
  try {
    final client = sp.Supabase.instance.client;
    if (kDebugMode && client.auth.currentSession == null) {
      return DevInvoicesRepository();
    }
    return SupabaseInvoicesRepository(client);
  } catch (e) {
    debugPrint('Supabase client unavailable, using DevInvoicesRepository fallback: $e');
    return DevInvoicesRepository();
  }
});

/// State for the invoices list.
@immutable
class InvoicesListState {
  final List<Invoice> invoices;
  final bool isLoading;
  final String? error;
  final String filterStatus;
  final String searchQuery;

  const InvoicesListState({
    required this.invoices,
    this.isLoading = false,
    this.error,
    this.filterStatus = 'all',
    this.searchQuery = '',
  });

  const InvoicesListState.initial()
      : invoices = const [],
        isLoading = true,
        error = null,
        filterStatus = 'all',
        searchQuery = '';

  List<Invoice> get filteredInvoices {
    var list = invoices;
    if (filterStatus != 'all') {
      list = list.where((i) => i.status.toLowerCase() == filterStatus.toLowerCase()).toList();
    }
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      list = list.where((i) {
        return i.invoiceNumber.toLowerCase().contains(q) ||
            (i.customerCompany != null && i.customerCompany!.toLowerCase().contains(q)) ||
            (i.customerName != null && i.customerName!.toLowerCase().contains(q));
      }).toList();
    }
    return list;
  }

  InvoicesListState copyWith({
    List<Invoice>? invoices,
    bool? isLoading,
    String? error,
    String? filterStatus,
    String? searchQuery,
  }) {
    return InvoicesListState(
      invoices: invoices ?? this.invoices,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filterStatus: filterStatus ?? this.filterStatus,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// StateNotifier managing invoice collection retrieval and state updates.
class InvoicesListNotifier extends StateNotifier<InvoicesListState> {
  final InvoicesRepository _repository;

  InvoicesListNotifier(this._repository) : super(const InvoicesListState.initial()) {
    loadInvoices();
  }

  Future<void> loadInvoices({bool refresh = false}) async {
    if (!refresh && state.invoices.isNotEmpty) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repository.getInvoices();
      if (!mounted) return;
      state = state.copyWith(invoices: list, isLoading: false, error: null);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void setFilterStatus(String status) {
    state = state.copyWith(filterStatus: status);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void addOrUpdateInvoice(Invoice invoice) {
    final updatedList = List<Invoice>.from(state.invoices);
    final idx = updatedList.indexWhere((i) => i.id == invoice.id);
    if (idx != -1) {
      updatedList[idx] = invoice;
    } else {
      updatedList.insert(0, invoice);
    }
    state = state.copyWith(invoices: updatedList);
  }

  Future<Invoice> recordPayment({
    required String invoiceId,
    required double amount,
    required String paymentMethod,
    DateTime? paymentDate,
    String? referenceNo,
    String? notes,
  }) async {
    final updated = await _repository.recordPayment(
      invoiceId: invoiceId,
      amount: amount,
      paymentMethod: paymentMethod,
      paymentDate: paymentDate,
      referenceNo: referenceNo,
      notes: notes,
    );
    addOrUpdateInvoice(updated);
    return updated;
  }
}

final invoicesListProvider =
    StateNotifierProvider<InvoicesListNotifier, InvoicesListState>((ref) {
  final repository = ref.watch(invoicesRepositoryProvider);
  return InvoicesListNotifier(repository);
});
