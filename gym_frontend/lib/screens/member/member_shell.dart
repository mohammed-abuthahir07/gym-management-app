import 'package:flutter/material.dart';

import '../../widgets/common/app_shell.dart';
import 'member_analytics_page.dart';
import 'member_challenges_page.dart';
import 'member_cheat_days_page.dart';
import 'member_dashboard_page.dart';
import 'member_diet_page.dart';
import 'member_exercises_page.dart';
import 'member_fees_page.dart';
import 'member_notifications_page.dart';
import 'member_profile_page.dart';
import 'member_progress_page.dart';
import 'member_workout_page.dart';
import 'member_chat_page.dart';

class MemberShell extends StatefulWidget {
  const MemberShell({super.key});

  @override
  State<MemberShell> createState() => _MemberShellState();
}

class _MemberShellState extends State<MemberShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      MemberDashboardPage(),
      MemberWorkoutPage(),
      MemberExercisesPage(),
      MemberDietPage(),
      MemberCheatDaysPage(),
      MemberProgressPage(),
      MemberChallengesPage(),
      MemberNotificationsPage(),
      MemberChatPage(),
      MemberAnalyticsPage(),
      MemberFeesPage(),
      MemberProfilePage(),
    ];

    return AppShell(
      title: 'PeakForge Member',
      showLogout: true,
      items: const [
        AppNavItem('Dashboard', Icons.dashboard_outlined),
        AppNavItem('Workout', Icons.fitness_center_outlined),
        AppNavItem('Exercises', Icons.menu_book_outlined),
        AppNavItem('Diet Plan', Icons.restaurant_outlined),
        AppNavItem('Cheat Days', Icons.fastfood_outlined),
        AppNavItem('Progress', Icons.show_chart_outlined),
        AppNavItem('Challenges', Icons.military_tech_outlined),
        AppNavItem('Alerts', Icons.notifications_outlined),
        AppNavItem('Trainer Chat', Icons.chat_bubble_outline),
        AppNavItem('Analytics', Icons.analytics_outlined),
        AppNavItem('Fees', Icons.receipt_long_outlined),
        AppNavItem('Profile', Icons.person_outline),
      ],
      index: _index,
      onSelect: (value) => setState(() => _index = value),
      body: pages[_index],
    );
  }
}
