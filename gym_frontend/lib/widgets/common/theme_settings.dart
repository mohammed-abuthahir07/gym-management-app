import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../../theme/theme_controller.dart';

class ThemeSettingsDialog extends StatelessWidget {
  const ThemeSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final width = MediaQuery.sizeOf(context).width;
    return AlertDialog(
      title: const Text('Appearance'),
      content: SizedBox(
        width: width < 520 ? width - 48 : 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Theme mode',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 10),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode_outlined, size: 16),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode_outlined, size: 16),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('System'),
                    icon: Icon(Icons.settings_suggest_outlined, size: 16),
                  ),
                ],
                selected: {theme.mode},
                onSelectionChanged: (value) => theme.setMode(value.first),
              ),
              const SizedBox(height: 22),
              Text(
                'Color theme',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

void showThemeSettings(BuildContext context) {
  showDialog(context: context, builder: (_) => const ThemeSettingsDialog());
}
