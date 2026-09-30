import 'package:flutter/material.dart';
import 'customers_screen.dart';

export 'customers_screen.dart';

/// Legacy page entrypoint wrapping [CustomersScreen] for route compatibility.
class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomersScreen();
  }
}
