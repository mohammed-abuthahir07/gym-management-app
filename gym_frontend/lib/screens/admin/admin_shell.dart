import 'package:flutter/material.dart';

import '../../widgets/common/app_shell.dart';
import 'admin_challenges_page.dart';
import 'admin_contacts_page.dart';
import 'admin_content_page.dart';
import 'admin_dashboard_page.dart';
import 'admin_exercises_page.dart';
import 'admin_fees_page.dart';
import 'admin_members_page.dart';
import 'admin_notifications_page.dart';
import 'admin_plans_page.dart';
import 'admin_profile_page.dart';
import 'admin_promotions_page.dart';
import 'admin_reports_page.dart';
import 'admin_trainers_page.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      AdminDashboardPage(),
      AdminMembersPage(),
      AdminTrainersPage(),
      AdminPlansPage(),
      AdminFeesPage(),
      AdminPromotionsPage(),
      AdminChallengesPage(),
      AdminExercisesPage(),
      AdminContentPage(),
      AdminContactsPage(),
      AdminReportsPage(),
      AdminNotificationsPage(),
      AdminProfilePage(),
    ];

    return AppShell(
      title: 'PeakForge Admin',
      showLogout: true,
      items: const [
        AppNavItem('Dashboard', Icons.dashboard_outlined),
        AppNavItem('Members', Icons.people_outline),
        AppNavItem('Trainers', Icons.sports_outlined),
        AppNavItem('Plans', Icons.card_membership_outlined),
        AppNavItem('Fees', Icons.receipt_long_outlined),
        AppNavItem('Promotions', Icons.local_offer_outlined),
        AppNavItem('Challenges', Icons.military_tech_outlined),
        AppNavItem('Exercises', Icons.fitness_center_outlined),
        AppNavItem('Content', Icons.photo_library_outlined),
        AppNavItem('Enquiries', Icons.contact_mail_outlined),
        AppNavItem('Reports', Icons.analytics_outlined),
        AppNavItem('Alerts', Icons.notification_add_outlined),
        AppNavItem('Profile', Icons.admin_panel_settings_outlined),
      ],
      index: _index,
      onSelect: (value) => setState(() => _index = value),
      body: pages[_index],
    );
  }
}
