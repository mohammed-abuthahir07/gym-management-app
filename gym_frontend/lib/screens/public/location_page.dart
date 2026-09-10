import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../../utils/responsive.dart';

class LocationPage extends StatelessWidget {
  const LocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final padding = Responsive.pagePadding(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Text(
                'Visit PeakForge Gym',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Located in the heart of Madurai with dedicated parking, state-of-the-art facilities, and locker rooms.',
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
                      // Info Cards
                      Expanded(
                        flex: isMobile ? 0 : 5,
                        child: Column(
                          children: [
                            _LocationInfoCard(
                              icon: Icons.place,
                              title: 'Gym Location',
                              value: AppConstants.gymAddress,
                              subtitle: AppConstants.gymCity,
                            ),
                            const SizedBox(height: 16),
                            const _LocationInfoCard(
                              icon: Icons.access_time,
                              title: 'Operating Hours',
                              value: AppConstants.gymHours,
                              subtitle: 'Open all days of the week',
                            ),
                            const SizedBox(height: 16),
                            const _LocationInfoCard(
                              icon: Icons.phone,
                              title: 'Contact Phone',
                              value: AppConstants.gymPhone,
                              subtitle: 'Reception & Membership Inquiries',
                            ),
                            const SizedBox(height: 16),
                            const _LocationInfoCard(
                              icon: Icons.email,
                              title: 'Email Address',
                              value: AppConstants.gymEmail,
                              subtitle: 'Official Support & Partnerships',
                            ),
                          ],
                        ),
                      ),
                      if (!isMobile) const SizedBox(width: 24),
                      if (isMobile) const SizedBox(height: 24),
                      // Visual Map Placeholder
                      Expanded(
                        flex: isMobile ? 0 : 6,
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Container(
                            height: 380,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  scheme.surfaceContainerHighest,
                                  scheme.surfaceContainerLow,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Map grid lines simulation
                                Positioned.fill(
                                  child: Opacity(
                                    opacity: 0.1,
                                    child: GridPaper(
                                      color: scheme.onSurface,
                                      divisions: 2,
                                      subdivisions: 1,
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: scheme.primary,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: scheme.primary.withValues(alpha: 0.4),
                                            blurRadius: 20,
                                            spreadRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      AppConstants.appName,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'KK Nagar, Madurai, Tamil Nadu',
                                      style: TextStyle(
                                        color: theme.textTheme.bodySmall?.color,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: scheme.surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: scheme.outlineVariant),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.directions, color: scheme.primary, size: 18),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Easily accessible via Ring Road & Mattuthavani',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationInfoCard extends StatelessWidget {
  const _LocationInfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: scheme.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 14, height: 1.3),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
