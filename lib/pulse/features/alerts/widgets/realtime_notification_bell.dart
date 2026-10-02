import 'package:flutter/material.dart';
import '../../../core/theme/pulse_theme.dart';
import '../services/multi_channel_alerting_engine.dart';

/// Realtime Notification Bell Widget with live badge count & dropdown drawer
class RealtimeNotificationBell extends StatelessWidget {
  final MultiChannelAlertingEngine engine;

  const RealtimeNotificationBell({
    super.key,
    required this.engine,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: engine,
      builder: (context, _) {
        final unreadCount = engine.unreadNotificationCount;
        final notifications = engine.notifications;

        return PopupMenuButton<void>(
          tooltip: 'In-App Notifications',
          color: PulseColors.surfaceObsidian,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: PulseColors.cardGlassBorder),
          ),
          offset: const Offset(0, 48),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: PulseColors.electricCyan,
                size: 22,
              ),
              if (unreadCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: PulseColors.coralRedAlert,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : unreadCount.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          itemBuilder: (ctx) {
            return [
              PopupMenuItem<void>(
                enabled: false,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'REALTIME NOTIFICATIONS',
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: PulseColors.electricCyan,
                        ),
                      ),
                      if (notifications.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            engine.clearAllNotifications();
                            Navigator.of(ctx).pop();
                          },
                          child: const Text(
                            'Clear All',
                            style: TextStyle(fontSize: 10, color: PulseColors.textMuted),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const PopupMenuDivider(),
              if (notifications.isEmpty)
                const PopupMenuItem<void>(
                  enabled: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'No recent notification alerts',
                        style: TextStyle(color: PulseColors.textMuted, fontSize: 12),
                      ),
                    ),
                  ),
                )
              else
                ...notifications.take(5).map((notif) {
                  return PopupMenuItem<void>(
                    onTap: () {
                      engine.markNotificationAsRead(notif.id);
                    },
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            notif.severity == 'CRITICAL'
                                ? Icons.error_outline_rounded
                                : Icons.warning_amber_rounded,
                            color: notif.severity == 'CRITICAL'
                                ? PulseColors.coralRedAlert
                                : Colors.amber,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                notif.title,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: notif.isRead
                                      ? PulseColors.textSecondary
                                      : PulseColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                notif.message,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: PulseColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ];
          },
        );
      },
    );
  }
}
