import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_widgets.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _message = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final api = context.read<ApiService>();
      await api.post(
        '/api/contact',
        body: {
          'name': _name.text.trim(),
          'email': _email.text.trim(),
          'phone': _phone.text.trim(),
          'message': _message.text.trim(),
        },
        auth: false,
      );

      if (!mounted) return;
      _formKey.currentState?.reset();
      _name.clear();
      _email.clear();
      _phone.clear();
      _message.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you! Your enquiry has been sent. We will get back to you shortly.'),
          backgroundColor: Colors.green,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit enquiry. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = Responsive.pagePadding(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Text(
                'Get In Touch With PeakForge',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Have questions regarding memberships, training schedules, or personal coaching? Send us an enquiry.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = Responsive.isMobile(context);
                  return Flex(
                    direction: isMobile ? Axis.vertical : Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contact Form
                      Expanded(
                        flex: isMobile ? 0 : 6,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Send an Enquiry',
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _name,
                                    decoration: const InputDecoration(
                                      labelText: 'Full Name *',
                                      prefixIcon: Icon(Icons.person_outline),
                                    ),
                                    validator: (v) => Validators.requiredField(v, label: 'Name'),
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _email,
                                    decoration: const InputDecoration(
                                      labelText: 'Email Address *',
                                      prefixIcon: Icon(Icons.email_outlined),
                                    ),
                                    validator: Validators.email,
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _phone,
                                    decoration: const InputDecoration(
                                      labelText: 'Phone Number (Optional)',
                                      prefixIcon: Icon(Icons.phone_outlined),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _message,
                                    maxLines: 4,
                                    decoration: const InputDecoration(
                                      labelText: 'Your Message / Question *',
                                      alignLabelWithHint: true,
                                    ),
                                    validator: (v) => Validators.requiredField(v, label: 'Message'),
                                  ),
                                  const SizedBox(height: 20),
                                  AppButton(
                                    label: 'Submit Enquiry',
                                    loading: _submitting,
                                    onPressed: _submit,
                                    expanded: true,
                                    icon: Icons.send,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (!isMobile) const SizedBox(width: 24),
                      if (isMobile) const SizedBox(height: 24),
                      // Quick info
                      Expanded(
                        flex: isMobile ? 0 : 4,
                        child: Column(
                          children: [
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Quick Assistance',
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Prefer to call or visit? Our front desk staff is available during all operational hours.',
                                      style: TextStyle(fontSize: 13, height: 1.4),
                                    ),
                                    const SizedBox(height: 16),
                                    const Divider(),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(Icons.call, size: 18),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(AppConstants.gymPhone, style: const TextStyle(fontSize: 13)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(Icons.email, size: 18),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(AppConstants.gymEmail, style: const TextStyle(fontSize: 13)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_city, size: 18),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(AppConstants.gymCity, style: const TextStyle(fontSize: 13)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
