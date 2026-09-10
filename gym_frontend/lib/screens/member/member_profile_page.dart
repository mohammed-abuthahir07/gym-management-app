import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth/auth_controller.dart';
import '../../services/api_service.dart';
import '../../utils/json_helpers.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_widgets.dart';

class MemberProfilePage extends StatefulWidget {
  const MemberProfilePage({super.key});

  @override
  State<MemberProfilePage> createState() => _MemberProfilePageState();
}

class _MemberProfilePageState extends State<MemberProfilePage> {
  bool _loading = true;
  String? _error;
  bool _saving = false;
  bool _hasExistingProfile = false;

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _age = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _goal = TextEditingController();
  final _medical = TextEditingController();
  String _email = '';

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _age.dispose();
    _height.dispose();
    _weight.dispose();
    _goal.dispose();
    _medical.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final api = context.read<ApiService>();
    final auth = context.read<AuthController>();

    try {
      Map<String, dynamic> data = {};
      try {
        final res = await api.get('/api/member/profile') as Map<String, dynamic>;
        if (res['profile'] is Map) {
          data = Map<String, dynamic>.from(res['profile'] as Map);
          _hasExistingProfile = true;
        }
      } catch (_) {
        // Fallback to auth profile
        final authRes = await api.get('/api/member/auth/profile') as Map<String, dynamic>;
        if (authRes['member'] is Map) {
          data = Map<String, dynamic>.from(authRes['member'] as Map);
        }
      }

      _name.text = asString(data['name'], auth.user?['name'] ?? '');
      _phone.text = asString(data['phone'], auth.user?['phone'] ?? '');
      _age.text = asString(data['age']);
      _height.text = asString(data['height']);
      _weight.text = asString(data['weight']);
      _goal.text = asString(data['fitness_goal'], auth.user?['fitness_goal'] ?? '');
      _medical.text = asString(data['medical_notes']);
      _email = asString(data['email'], auth.user?['email'] ?? '');
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Failed to load member profile.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final api = context.read<ApiService>();
    final body = {
      'name': _name.text.trim(),
      'phone': _phone.text.trim(),
      'age': int.tryParse(_age.text.trim()) ?? 0,
      'height': double.tryParse(_height.text.trim()) ?? 0.0,
      'weight': double.tryParse(_weight.text.trim()) ?? 0.0,
      'fitness_goal': _goal.text.trim(),
      'medical_notes': _medical.text.trim(),
    };

    try {
      if (_hasExistingProfile) {
        await api.put('/api/member/profile', body: body);
      } else {
        try {
          await api.post('/api/member/profile', body: body);
          _hasExistingProfile = true;
        } catch (_) {
          await api.put('/api/member/profile', body: body);
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = Responsive.pagePadding(context);

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
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: theme.colorScheme.primary,
                            child: const Icon(Icons.person, color: Colors.white, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_name.text.isNotEmpty ? _name.text : 'Member Profile', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                if (_email.isNotEmpty)
                                  Text(_email, style: TextStyle(color: theme.textTheme.bodySmall?.color)),
                                const SizedBox(height: 4),
                                const StatusBadge(label: 'MEMBER ROLE'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 20),
                      Text('Personal & Contact Information', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(labelText: 'Full Name *', prefixIcon: Icon(Icons.badge_outlined)),
                        validator: (v) => Validators.requiredField(v, label: 'Name'),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _phone,
                        decoration: const InputDecoration(labelText: 'Phone Number *', prefixIcon: Icon(Icons.phone_outlined)),
                        validator: (v) => Validators.requiredField(v, label: 'Phone'),
                      ),
                      const SizedBox(height: 24),
                      Text('Physical Stats & Fitness Goals', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _age,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Age (Years)', prefixIcon: Icon(Icons.cake_outlined)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextFormField(
                              controller: _height,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Height (cm)', prefixIcon: Icon(Icons.height_outlined)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextFormField(
                              controller: _weight,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Weight (kg)', prefixIcon: Icon(Icons.scale_outlined)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _goal,
                        decoration: const InputDecoration(
                          labelText: 'Fitness Goal / Purpose',
                          prefixIcon: Icon(Icons.flag_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _medical,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Medical Notes / Physical Limitations',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.health_and_safety_outlined),
                        ),
                      ),
                      const SizedBox(height: 28),
                      AppButton(
                        label: 'Save Profile Details',
                        loading: _saving,
                        onPressed: _saveProfile,
                        expanded: true,
                        icon: Icons.save_outlined,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
