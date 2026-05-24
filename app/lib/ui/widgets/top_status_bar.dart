import 'package:flutter/material.dart';

import '../../data/models/scan_config.dart';
import '../../state/app_controller.dart';

class TopStatusBar extends StatelessWidget {
  const TopStatusBar({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final theme = controller.theme;
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 34),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.border)),
      ),
      child: Row(
        children: [
          const Spacer(),
          _ProfilePicker(controller: controller),
          const SizedBox(width: 28),
          FilledButton.icon(
            onPressed: controller.scanning || controller.verifyingScope
                ? null
                : controller.runScan,
            icon: Icon(
              controller.scanning || controller.verifyingScope
                  ? Icons.sync
                  : Icons.play_arrow,
            ),
            label: Text(
              controller.verifyingScope
                  ? 'VERIFYING'
                  : controller.scanning
                  ? 'SCANNING'
                  : 'RUN SCAN',
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePicker extends StatelessWidget {
  const _ProfilePicker({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<ScanProfile>(
      value: controller.config.profile,
      underline: const SizedBox.shrink(),
      items: [
        for (final profile in ScanProfile.values)
          DropdownMenuItem(
            value: profile,
            child: Text(profile.name.toUpperCase()),
          ),
      ],
      onChanged: (value) {
        if (value != null) controller.setProfile(value);
      },
    );
  }
}
