import 'package:flutter/material.dart';
import '../screens/team_screen.dart';

export '../screens/team_screen.dart';

/// Team entrypoint wrapping [TeamScreen] for route and architectural consistency.
class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TeamScreen();
  }
}
