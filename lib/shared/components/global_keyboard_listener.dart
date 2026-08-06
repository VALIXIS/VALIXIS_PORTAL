import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'export_center_dialog.dart';
import 'global_search_dialog.dart';

/// Accessibility keyboard shortcut listener (Ctrl/Cmd + K for Global Search, Ctrl/Cmd + E for Export Center).
class GlobalKeyboardListener extends StatelessWidget {
  const GlobalKeyboardListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () {
          GlobalSearchDialog.show(context);
        },
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () {
          GlobalSearchDialog.show(context);
        },
        const SingleActivator(LogicalKeyboardKey.keyE, control: true): () {
          ExportCenterDialog.show(context);
        },
        const SingleActivator(LogicalKeyboardKey.keyE, meta: true): () {
          ExportCenterDialog.show(context);
        },
      },
      child: Focus(
        autofocus: true,
        child: child,
      ),
    );
  }
}
