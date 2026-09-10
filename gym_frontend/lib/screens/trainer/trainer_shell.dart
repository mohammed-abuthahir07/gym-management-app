import 'package:flutter/material.dart';

import '../../widgets/common/app_shell.dart';
import 'trainer_analytics_page.dart';
import 'trainer_chat_page.dart';
import 'trainer_cheat_days_page.dart';
import 'trainer_classes_page.dart';
import 'trainer_dashboard_page.dart';
import 'trainer_diet_plans_page.dart';
import 'trainer_members_page.dart';
import 'trainer_profile_page.dart';
import 'trainer_workout_plans_page.dart';

class TrainerShell extends StatefulWidget {
  const TrainerShell({super.key});

  @override
  State<TrainerShell> createState() => _TrainerShellState();
}

class _TrainerShellState extends State<TrainerShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      TrainerDashboardPage(),
      TrainerMembersPage(),
      TrainerWorkoutPlansPage(),
      TrainerDietPlansPage(),
      TrainerClassesPage(),
      TrainerCheatDaysPage(),
      TrainerAnalyticsPage(),
      TrainerChatPage(),
      TrainerProfilePage(),
    ];

    return AppShell(
      title: 'PeakForge Trainer',
      showLogout: true,
      items: const [
        AppNavItem('Dashboard', Icons.dashboard_outlined),
        AppNavItem('Trainees', Icons.groups_outlined),
        AppNavItem('Workouts', Icons.fitness_center_outlined),
        AppNavItem('Diet Plans', Icons.restaurant_outlined),
        AppNavItem('Classes', Icons.calendar_month_outlined),
        AppNavItem('Cheat Logs', Icons.fastfood_outlined),
        AppNavItem('Analytics', Icons.analytics_outlined),
        AppNavItem('Chat', Icons.chat_bubble_outline),
        AppNavItem('Profile', Icons.person_outline),
      ],
      index: _index,
      onSelect: (value) => setState(() => _index = value),
      body: pages[_index],
    );
  }
}
