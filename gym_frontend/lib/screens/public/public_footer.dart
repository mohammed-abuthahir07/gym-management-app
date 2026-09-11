import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class PublicFooter extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const PublicFooter({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Container(
      width: double.infinity,
      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64.0 : 24.0,
        vertical: 48.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section: Brand & Bio
          Row(
            children: [
              Icon(Icons.fitness_center_rounded, color: colorScheme.primary, size: 28),
              const SizedBox(width: 10),
              Text(
                AppConstants.appName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your ultimate fitness destination in Madurai. Train hard, track progress, and transform your body with expert trainers and modern equipment.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),

          // Side-by-Side 2-Column Alignment Grid (Like your reference image)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1: Quick Navigation
              Expanded(
                child: _buildFooterSection(
                  context,
                  title: 'QUICK NAVIGATION',
                  children: [
                    _buildLinkItem(context, 'Home', 0),
                    _buildLinkItem(context, 'Pricing Plans', 1),
                    _buildLinkItem(context, 'Promotions', 2),
                    _buildLinkItem(context, 'Gallery', 3),
                    _buildLinkItem(context, 'Trainers', 4),
                    _buildLinkItem(context, 'Location', 5),
                    _buildLinkItem(context, 'Contact Us', 6),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Column 2: Working Hours & Support
              Expanded(
                child: _buildFooterSection(
                  context,
                  title: 'WORKING & SUPPORT',
                  children: [
                    _buildTextItem(context, 'Mon - Sat: 5 AM - 10 PM'),
                    _buildTextItem(context, 'Sunday: 6 AM - 1 PM'),
                    const SizedBox(height: 12),
                    _buildTextItem(context, AppConstants.gymAddress),
                    _buildTextItem(context, AppConstants.gymPhone),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),
          Divider(color: colorScheme.outlineVariant.withOpacity(0.4)),
          const SizedBox(height: 20),

          // Bottom Copyright & Portal Link
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '© ${DateTime.now().year} ${AppConstants.appName}. All rights reserved.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('Member Portal'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSection(BuildContext context, {required String title, required List<Widget> children}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 2,
          width: 32,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildLinkItem(BuildContext context, String label, int tabIndex) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: () {
          if (onNavigateTab != null) {
            onNavigateTab!(tabIndex);
          }
        },
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildTextItem(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}