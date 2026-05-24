import 'package:flutter/material.dart';

import 'panel.dart';
import 'section_header.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.framed = true,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final bool framed;

  @override
  Widget build(BuildContext context) {
    final bee = context.bee;
    final body = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: bee.accent, size: 46),
            const SizedBox(height: 16),
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: bee.text,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: bee.muted),
            ),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
    return framed ? Panel(child: body) : body;
  }
}
