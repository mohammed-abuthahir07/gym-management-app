import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth/auth_controller.dart';
import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_widgets.dart';

class TrainerProfilePage extends StatefulWidget {
  const TrainerProfilePage({super.key});

  @override
  State<TrainerProfilePage> createState() => _TrainerProfilePageState();
}

class _TrainerProfilePageState extends State<TrainerProfilePage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _trainer;

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
      final res = await api.get('/api/trainer/auth/profile') as Map<String, dynamic>;
      if (res['trainer'] is Map) {
        _trainer = Map<String, dynamic>.from(res['trainer'] as Map);
      } else {
        _trainer = auth.user;
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      _trainer = auth.user;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final padding = Responsive.pagePadding(context);

    final name = asString(_trainer?['name'], 'PeakForge Coach');
    final email = asString(_trainer?['email']);
    final phone = asString(_trainer?['phone']);
    final status = asString(_trainer?['status'], 'ACTIVE');
    final joined = asString(_trainer?['created_at']).split('T').first;

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
                          backgroundColor: scheme.primary,
                          child: const Icon(Icons.fitness_center, color: Colors.white, size: 36),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text('Certified Fitness Coach', style: TextStyle(color: theme.textTheme.bodySmall?.color)),
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
                    Text('Staff Information', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _ProfileTile(icon: Icons.badge_outlined, label: 'Full Name', value: name),
                    _ProfileTile(icon: Icons.email_outlined, label: 'Official Email', value: email),
                    _ProfileTile(icon: Icons.phone_outlined, label: 'Phone Number', value: phone.isNotEmpty ? phone : 'Not specified'),
                    _ProfileTile(icon: Icons.shield_outlined, label: 'System Role', value: 'TRAINER (COACH)'),
                    if (joined.isNotEmpty)
                      _ProfileTile(icon: Icons.calendar_today_outlined, label: 'Staff Since', value: joined),
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
