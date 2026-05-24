import 'package:flutter/material.dart';

import '../../core/theme/bee_theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle.toUpperCase(),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

extension BeeThemeOnContext on BuildContext {
  BeeTheme get bee {
    final inherited = Theme.of(this).extension<BeeThemeToken>();
    return inherited?.theme ?? BeeThemes.command;
  }
}
