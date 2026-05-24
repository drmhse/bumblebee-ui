import 'package:flutter/material.dart';

import '../../state/app_controller.dart';
import '../screens/about_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/history_screen.dart';
import '../screens/inventory_screen.dart';
import '../screens/threat_intel_screen.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/top_status_bar.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final theme = controller.theme;
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(controller: controller),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(color: theme.background),
              child: Column(
                children: [
                  TopStatusBar(controller: controller),
                  Expanded(child: _screen()),
                  _Footer(controller: controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _screen() {
    if (!controller.initialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return switch (controller.section) {
      AppSection.dashboard => DashboardScreen(controller: controller),
      AppSection.inventory => InventoryScreen(controller: controller),
      AppSection.threatIntel => ThreatIntelScreen(controller: controller),
      AppSection.history => HistoryScreen(controller: controller),
      AppSection.about => AboutScreen(controller: controller),
    };
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final theme = controller.theme;
    final result = controller.currentResult;
    final activeRoot =
        controller.verifiedScope?.roots.firstOrNull?.path ??
        result?.roots.firstOrNull?['path']?.toString() ??
        'not verified';
    final status = controller.verifyingScope
        ? 'VERIFYING SCOPE'
        : controller.scanning
        ? 'SCAN RUNNING'
        : result == null
        ? 'READY'
        : 'SCAN ${result.status.toUpperCase()}';
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: theme.surfaceAlt,
        border: Border(top: BorderSide(color: theme.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              'HOSTNAME: ',
              style: TextStyle(color: theme.muted, fontWeight: FontWeight.w800),
            ),
            Text(controller.endpointLabel, style: TextStyle(color: theme.text)),
            const SizedBox(width: 32),
            Text(
              'ACTIVE ROOT: ',
              style: TextStyle(color: theme.muted, fontWeight: FontWeight.w800),
            ),
            SizedBox(
              width: 260,
              child: Text(
                activeRoot,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: theme.text),
              ),
            ),
            Icon(
              Icons.circle,
              size: 12,
              color: controller.scanning ? theme.warning : theme.accent,
            ),
            const SizedBox(width: 8),
            Text(
              status,
              style: TextStyle(
                color: theme.accent,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 24),
            Text(
              result?.completedAt?.toLocal().toString().split('.').first ??
                  'never',
              style: TextStyle(color: theme.muted),
            ),
          ],
        ),
      ),
    );
  }
}
