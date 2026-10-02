import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/telemetry_provider.dart';

class OfflineStatusPill extends StatelessWidget {
  const OfflineStatusPill({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TelemetryProvider>(context);

    if (provider.isOnline && !provider.isUsingCachedData) {
      return const SizedBox.shrink();
    }

    final cacheTimeStr = provider.lastCacheTimestamp != null
        ? DateFormat('HH:mm:ss').format(provider.lastCacheTimestamp!)
        : 'recently';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB74D).withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB74D).withOpacity(0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB74D).withOpacity(0.15),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: Color(0xFFFFB74D), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Viewing cached state (Offline) • Last synced at $cacheTimeStr • Auto-reconnecting in ${provider.nextBackoffSec}s...',
              style: const TextStyle(
                color: Color(0xFFFFB74D),
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => provider.simulateNetworkReconnect(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: const Color(0xFFFFB74D),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            icon: const Icon(Icons.sync_rounded, size: 14),
            label: const Text(
              'Reconnect',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
