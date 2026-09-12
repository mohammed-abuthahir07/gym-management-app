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
  bool _saving = false;

  String? _error;
  Map<String, dynamic>? _trainer;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    final api = context.read<ApiService>();
    final auth = context.read<AuthController>();

    try {
      final response = await api.get(
        '/api/trainer/auth/profile',
      );

      if (response is Map<String, dynamic>) {
        final trainerData = response['trainer'] ?? response['data'] ?? response;

        if (trainerData is Map) {
          _trainer = Map<String, dynamic>.from(trainerData);
        } else {
          _trainer = auth.user;
        }
      } else {
        _trainer = auth.user;
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
        });
      }
    } catch (_) {
      _trainer = auth.user;

      if (_trainer == null && mounted) {
        setState(() {
          _error = 'Failed to load trainer profile';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _openEditProfile() async {
    if (_trainer == null) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _EditTrainerProfileDialog(
        trainer: Map<String, dynamic>.from(_trainer!),
      ),
    );

    if (result == null || !mounted) return;

    await _updateProfile(
      name: result['name']!,
      email: result['email']!,
      phone: result['phone'] ?? '',
    );
  }

  Future<void> _updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    final api = context.read<ApiService>();

    try {
      final response = await api.put(
        '/api/trainer/profile',
        body: {
          'name': name,
          'email': email,
          'phone': phone.isEmpty ? null : phone,
        },
      );

      if (!mounted) return;

      // Safely parse different backend response structures
      Map<String, dynamic>? updatedTrainerData;
      if (response is Map<String, dynamic>) {
        final raw = response['trainer'] ?? response['data'] ?? response;
        if (raw is Map) {
          updatedTrainerData = Map<String, dynamic>.from(raw);
        }
      }

      setState(() {
        if (updatedTrainerData != null) {
          _trainer = updatedTrainerData;
        } else {
          // Fallback optimistic update if response format is unexpected
          _trainer = {
            ...?_trainer,
            'name': name,
            'email': email,
            'phone': phone,
          };
        }
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trainer profile updated successfully'),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update trainer profile'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final padding = Responsive.pagePadding(context);

    final name = asString(
      _trainer?['name'],
      'PeakForge Coach',
    );

    final email = asString(
      _trainer?['email'],
    );

    final phone = asString(
      _trainer?['phone'],
    );

    final status = asString(
      _trainer?['status'],
      'ACTIVE',
    );

    final createdAt = asString(
      _trainer?['created_at'],
    );

    final joined = createdAt.contains('T')
        ? createdAt.split('T').first
        : createdAt;

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
            constraints: const BoxConstraints(
              maxWidth: 850,
            ),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(
                  Responsive.isMobile(context) ? 20 : 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(
                      context,
                      name: name,
                      status: status,
                    ),
                    const SizedBox(height: 28),
                    const Divider(),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Staff Information',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _saving ? null : _openEditProfile,
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                          ),
                          label: const Text('Edit Profile'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _ProfileTile(
                      icon: Icons.badge_outlined,
                      label: 'Full Name',
                      value: name,
                    ),
                    _ProfileTile(
                      icon: Icons.email_outlined,
                      label: 'Official Email',
                      value: email.isNotEmpty ? email : 'Not specified',
                    ),
                    _ProfileTile(
                      icon: Icons.phone_outlined,
                      label: 'Phone Number',
                      value: phone.isNotEmpty ? phone : 'Not specified',
                    ),
                    _ProfileTile(
                      icon: Icons.shield_outlined,
                      label: 'System Role',
                      value: 'TRAINER (COACH)',
                    ),
                    if (joined.isNotEmpty)
                      _ProfileTile(
                        icon: Icons.calendar_today_outlined,
                        label: 'Staff Since',
                        value: joined,
                      ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'You can update your name, email address and phone number. '
                              'Your trainer role, status and other system information '
                              'cannot be changed from this page.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context, {
    required String name,
    required String status,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mobile = Responsive.isMobile(context);

    final avatar = CircleAvatar(
      radius: mobile ? 30 : 36,
      backgroundColor: scheme.primary,
      child: Icon(
        Icons.fitness_center,
        color: scheme.onPrimary,
        size: mobile ? 30 : 36,
      ),
    );

    final information = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Certified Fitness Coach',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        StatusBadge(
          label: status,
          positive: status.toUpperCase() == 'ACTIVE',
        ),
      ],
    );

    return Row(
      crossAxisAlignment: mobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        avatar,
        SizedBox(width: mobile ? 16 : 20),
        Expanded(
          child: information,
        ),
      ],
    );
  }
}

// ================================================================
// EDIT TRAINER PROFILE DIALOG
// ================================================================

class _EditTrainerProfileDialog extends StatefulWidget {
  const _EditTrainerProfileDialog({
    required this.trainer,
  });

  final Map<String, dynamic> trainer;

  @override
  State<_EditTrainerProfileDialog> createState() =>
      _EditTrainerProfileDialogState();
}

class _EditTrainerProfileDialogState extends State<_EditTrainerProfileDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: asString(widget.trainer['name']),
    );
    _emailController = TextEditingController(
      text: asString(widget.trainer['email']),
    );
    _phoneController = TextEditingController(
      text: asString(widget.trainer['phone']),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Name is required';
    if (name.length < 2) return 'Name must contain at least 2 characters';
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return null;
    if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(phone)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop({
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mobile = Responsive.isMobile(context);

    return AlertDialog(
      title: const Text('Edit Trainer Profile'),
      content: SizedBox(
        width: mobile ? double.maxFinite : 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: _validateName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Official Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter your phone number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: _validatePhone,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Only name, email and phone number can be changed.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(
            Icons.save_outlined,
            size: 18,
          ),
          label: const Text('Save Changes'),
        ),
      ],
    );
  }
}

// ================================================================
// PROFILE TILE
// ================================================================

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mobile = Responsive.isMobile(context);

    if (mobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: scheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    softWrap: true,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Icon(
              icon,
              size: 20,
              color: scheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 145,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              softWrap: true,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}