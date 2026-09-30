import 'package:flutter/material.dart';
import '../pages/invoices_page.dart';

/// Legacy export wrapper forwarding to the unified InvoicesPage.
class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InvoicesPage();
  }
}
