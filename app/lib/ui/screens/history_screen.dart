import 'package:flutter/material.dart';

import '../../data/models/bumblebee_record.dart';
import '../../state/app_controller.dart';
import '../widgets/empty_state.dart';
import '../widgets/panel.dart';
import '../widgets/section_header.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final bee = context.bee;
    return Padding(
      padding: const EdgeInsets.all(34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Scan History',
            subtitle:
                'Review complete Bumblebee snapshots kept on this machine.',
          ),
          const SizedBox(height: 28),
          Expanded(
            child: controller.history.isEmpty
                ? EmptyState(
                    icon: Icons.history,
                    title: 'No Scan History',
                    message:
                        'Completed scans are saved locally and will appear here.',
                    action: FilledButton.icon(
                      onPressed: () =>
                          controller.setSection(AppSection.dashboard),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('RUN A SCAN'),
                    ),
                  )
                : Panel(
                    padding: EdgeInsets.zero,
                    child: ListView.separated(
                      itemCount: controller.history.length,
                      separatorBuilder: (_, _) =>
                          Divider(height: 1, color: bee.border),
                      itemBuilder: (context, index) {
                        final result = controller.history[index];
                        return _HistoryRow(
                          result: result,
                          onTap: () => controller.showHistory(result),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.result, required this.onTap});

  final ScanResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bee = context.bee;
    return ListTile(
      onTap: onTap,
      leading: Icon(
        result.findingsCount == 0
            ? Icons.verified_outlined
            : Icons.warning_amber,
        color: result.findingsCount == 0 ? bee.success : bee.danger,
      ),
      title: Text(
        '${result.profile.toUpperCase()} • ${result.endpoint}',
        style: TextStyle(color: bee.text, fontWeight: FontWeight.w900),
      ),
      subtitle: Text(
        '${result.completedAt?.toLocal().toString().split('.').first ?? result.startedAt} • ${result.status}',
        style: TextStyle(color: bee.muted),
      ),
      trailing: Text(
        '${result.packageCount} packages / ${result.findingsCount} findings',
        style: TextStyle(color: bee.accent, fontWeight: FontWeight.w900),
      ),
    );
  }
}
