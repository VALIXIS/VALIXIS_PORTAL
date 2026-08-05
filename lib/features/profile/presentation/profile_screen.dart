import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/components/app_section_title.dart';
import '../../../shared/components/empty_state.dart';

/// Profile screen — placeholder layout.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionTitle(
            title: 'Profile',
            subtitle: 'Your account and preferences',
          ),
          const SizedBox(height: AppSpacing.xl),
          const Expanded(
            child: EmptyState(
              icon: Icons.person_outline_rounded,
              title: 'Profile not set up',
              description:
                  'Your profile details will appear here once configured.',
            ),
          ),
        ],
      ),
    );
  }
}
