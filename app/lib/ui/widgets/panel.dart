import 'package:flutter/material.dart';

import '../../core/theme/bee_theme.dart';

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<BeeThemeToken>()?.theme;
    final border = theme?.border ?? Theme.of(context).dividerColor;
    final surface = theme?.surface ?? Theme.of(context).colorScheme.surface;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: border),
      ),
      child: child,
    );
  }
}
