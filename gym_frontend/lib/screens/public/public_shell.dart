import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth/auth_controller.dart';
import '../../utils/constants.dart';
import '../../widgets/common/app_shell.dart';
import 'contact_page.dart';
import 'gallery_page.dart';
import 'home_page.dart';
import 'location_page.dart';
import 'pricing_page.dart';
import 'promotions_page.dart';
import 'trainers_page.dart';

class PublicShell extends StatefulWidget {
  const PublicShell({super.key});

  @override
  State<PublicShell> createState() => _PublicShellState();
}

class _PublicShellState extends State<PublicShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final pages = const [
      HomePage(),
      PricingPage(),
      PromotionsPage(),
      GalleryPage(),
      PublicTrainersPage(),
      LocationPage(),
      ContactPage(),
    ];
    return AppShell(
      title: AppConstants.appName,
      items: const [
        AppNavItem('Home', Icons.home_outlined),
        AppNavItem('Pricing', Icons.payments_outlined),
        AppNavItem('Promotions', Icons.local_offer_outlined),
        AppNavItem('Gallery', Icons.photo_outlined),
        AppNavItem('Trainers', Icons.groups_outlined),
        AppNavItem('Location', Icons.place_outlined),
        AppNavItem('Contact', Icons.mail_outlined),
      ],
      index: _index,
      onSelect: (value) => setState(() => _index = value),
      trailing: Row(
        children: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            child: const Text('Register'),
          ),
          if (auth.isLoggedIn)
            TextButton(
              onPressed: () => Navigator.pushNamed(context, auth.homeRouteForRole()),
              child: const Text('Dashboard'),
            ),
        ],
      ),
      body: pages[_index],
    );
  }
}
