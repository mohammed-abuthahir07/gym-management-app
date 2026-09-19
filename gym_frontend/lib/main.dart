import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/auth/auth_controller.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/member/member_shell.dart';
import 'screens/public/public_shell.dart';
import 'screens/trainer/trainer_shell.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  final api = ApiService(storage);
  final auth = AuthController(api, storage);
  final theme = ThemeController();

  await Future.wait([
    auth.load(),
    theme.load(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storage),
        Provider<ApiService>.value(value: api),
        ChangeNotifierProvider<AuthController>.value(value: auth),
        ChangeNotifierProvider<ThemeController>.value(value: theme),
      ],
      child: const PeakForgeApp(),
    ),
  );
}

class PeakForgeApp extends StatelessWidget {
  const PeakForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.light(theme.palette),
      darkTheme: AppTheme.dark(theme.palette),
      themeMode: theme.mode,
      initialRoute: '/',
      routes: {
        '/': (context) => const PublicShell(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/member': (context) => const _RoleGate(
              expectedRole: 'MEMBER',
              child: MemberShell(),
            ),
        '/trainer': (context) => const _RoleGate(
              expectedRole: 'TRAINER',
              child: TrainerShell(),
            ),
        '/admin': (context) => const _RoleGate(
              expectedRole: 'ADMIN',
              child: AdminShell(),
            ),
      },
    );
  }
}

class _RoleGate extends StatelessWidget {
  const _RoleGate({
    required this.expectedRole,
    required this.child,
  });

  final String expectedRole;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    if (!auth.isLoggedIn || auth.role != expectedRole) {
      return const LoginScreen();
    }
    return child;
  }
}
