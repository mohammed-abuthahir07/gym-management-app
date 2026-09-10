import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth/auth_controller.dart';
import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_widgets.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _admin;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final api = context.read<ApiService>();
    final auth = context.read<AuthController>();

    try {
      final res = await api.get('/api/admin/auth/profile') as Map<String, dynamic>;
      if (res['admin'] is Map) {
        _admin = Map<String, dynamic>.from(res['admin'] as Map);
      } else {
        _admin = auth.user;
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      _admin = auth.user;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final padding = Responsive.pagePadding(context);

    final name = asString(_admin?['name'], 'System Administrator');
    final email = asString(_admin?['email']);
    final phone = asString(_admin?['phone']);
    final status = asString(_admin?['status'], 'ACTIVE');
    final joined = asString(_admin?['created_at']).split('T').first;

    return AsyncStateView(
      loading: _loading,
      error: _error,
      onRetry: _fetchProfile,
      isEmpty: false,
      emptyMessage: '',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: scheme.secondary,
                          child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 36),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              const Text('Head Administrator / Owner', style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 6),
                              StatusBadge(label: status, positive: status == 'ACTIVE'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const Divider(),
                    const SizedBox(height: 20),
                    Text('Administrative Account Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _ProfileTile(icon: Icons.person_outline, label: 'Administrator Name', value: name),
                    _ProfileTile(icon: Icons.email_outlined, label: 'Superuser Email', value: email),
                    _ProfileTile(icon: Icons.phone_outlined, label: 'Emergency Contact', value: phone.isNotEmpty ? phone : '9000000000'),
                    _ProfileTile(icon: Icons.verified_user_outlined, label: 'System Access Level', value: 'FULL ROOT / ADMIN PRIVILEGES'),
                    if (joined.isNotEmpty)
                      _ProfileTile(icon: Icons.date_range_outlined, label: 'Account Created', value: joined),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 14),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
