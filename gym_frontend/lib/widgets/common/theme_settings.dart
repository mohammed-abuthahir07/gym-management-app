import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../../theme/theme_controller.dart';

class ThemeSettingsDialog extends StatelessWidget {
  const ThemeSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    return AlertDialog(
      title: const Text('Appearance'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Theme mode'),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ],
              selected: {theme.mode},
              onSelectionChanged: (value) => theme.setMode(value.first),
            ),
            const SizedBox(height: 20),
            const Text('Color theme'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: AppPalettes.all.map((palette) {
                final selected = theme.palette.id == palette.id;
                return ChoiceChip(
                  label: Text(palette.name),
                  selected: selected,
                  avatar: CircleAvatar(backgroundColor: palette.primary),
                  onSelected: (_) => theme.setPalette(palette),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
      ],
    );
  }
}

void showThemeSettings(BuildContext context) {
  showDialog(context: context, builder: (_) => const ThemeSettingsDialog());
}
