import 'package:flutter/material.dart';

import '../../data/models/scan_config.dart';
import '../../state/app_controller.dart';
import '../widgets/diagnostics_panel.dart';
import '../widgets/findings_panel.dart';
import '../widgets/panel.dart';
import '../widgets/scan_status_panel.dart';
import '../widgets/section_header.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final result = controller.currentResult;
    final verifiedRootCount = controller.verifiedScope?.roots.length;
    final scannedRootCount = result?.roots.length;
    final catalogEntries = controller.catalogs.fold<int>(
      0,
      (total, catalog) => total + catalog.entries,
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.all(34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Overview',
            subtitle: 'Summary of your Bumblebee scan results.',
          ),
          const SizedBox(height: 28),
          if (controller.errorMessage != null)
            _ErrorBanner(message: controller.errorMessage!),
          ScanStatusPanel(controller: controller),
          const SizedBox(height: 24),
          _ScanSetup(controller: controller),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 760 ? 2 : 4;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: columns == 2 ? 1.55 : 1.18,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _MetricCard(
                    title: 'Scan Duration',
                    value: result == null
                        ? 'Not run'
                        : '${(result.durationMs / 1000).toStringAsFixed(2)}s',
                    note: result == null
                        ? 'Run timing appears after completion'
                        : 'Wall-clock runtime',
                  ),
                  _MetricCard(
                    title: 'Scope Coverage',
                    value:
                        '${verifiedRootCount ?? scannedRootCount ?? 0} roots',
                    note: verifiedRootCount != null
                        ? 'Verified before scan'
                        : result == null
                        ? 'Not verified yet'
                        : 'Recorded by summary',
                  ),
                  _MetricCard(
                    title: 'Catalog Coverage',
                    value: '$catalogEntries',
                    note:
                        '${controller.catalogs.length} exposure catalogs loaded',
                  ),
                  _MetricCard(
                    title: 'Diagnostics',
                    value: '${result?.diagnosticsCount ?? 0}',
                    note: result == null
                        ? 'No active scan result'
                        : result.diagnosticsCount == 0
                        ? 'No scanner diagnostics'
                        : 'Review warnings from scan stream',
                    onTap: result?.diagnostics.isEmpty == false
                        ? () => showDiagnosticsDialog(context, controller)
                        : null,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _EcosystemPanel(controller: controller)),
              const SizedBox(width: 16),
              Expanded(child: _RootsPanel(controller: controller)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: FindingsPanel(controller: controller)),
              const SizedBox(width: 16),
              Expanded(child: DiagnosticsPanel(controller: controller)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScanSetup extends StatelessWidget {
  const _ScanSetup({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final bee = context.bee;
    final roots = controller.config.normalizedRoots;
    final scope = controller.verifiedScope;
    final scopeMatches = scope?.matches(controller.config) ?? false;
    final canScan =
        !controller.scanning &&
        !controller.verifyingScope &&
        (controller.config.profile != ScanProfile.deep || scopeMatches);
    return Panel(
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: bee.accent),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'ACTIVE SCOPE: ${controller.config.profile.name.toUpperCase()}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: bee.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              _ScopeStatus(
                verifying: controller.verifyingScope,
                rootCount: scopeMatches ? scope!.roots.length : 0,
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  Checkbox(
                    value: controller.config.findingsOnly,
                    onChanged: controller.scanning
                        ? null
                        : (value) => controller.setFindingsOnly(value ?? false),
                  ),
                  Text(
                    'FINDINGS ONLY',
                    style: TextStyle(
                      color: bee.muted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (controller.config.profile.name == 'deep') ...[
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey(controller.config.roots.join('|')),
                    initialValue: controller.config.roots.join(', '),
                    enabled: !controller.scanning && !controller.verifyingScope,
                    onChanged: controller.setDeepRoots,
                    decoration: InputDecoration(
                      labelText: 'Deep root paths',
                      helperText: roots.isEmpty
                          ? 'Required for Deep scans'
                          : 'Resolved: ${roots.join(', ')}',
                      helperMaxLines: 2,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: controller.scanning || controller.verifyingScope
                      ? null
                      : controller.pickDeepRoot,
                  icon: Icon(
                    controller.verifyingScope ? Icons.sync : Icons.folder_open,
                  ),
                  label: Text(
                    controller.verifyingScope ? 'VERIFYING' : 'BROWSE',
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: canScan ? controller.runScan : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('SCAN NOW'),
                ),
              ],
            ),
            if (scopeMatches) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Root is valid. Start the scan when ready.',
                  style: TextStyle(color: bee.muted, fontSize: 12),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ScopeStatus extends StatelessWidget {
  const _ScopeStatus({required this.verifying, required this.rootCount});

  final bool verifying;
  final int rootCount;

  @override
  Widget build(BuildContext context) {
    final bee = context.bee;
    final valid = rootCount > 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          verifying
              ? Icons.sync
              : valid
              ? Icons.check_circle_outline
              : Icons.radio_button_unchecked,
          color: valid ? bee.success : bee.muted,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          verifying
              ? 'CHECKING ROOT'
              : valid
              ? '$rootCount VALID ROOT${rootCount == 1 ? '' : 'S'}'
              : 'ROOT NOT READY',
          style: TextStyle(
            color: valid ? bee.success : bee.muted,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.note,
    this.onTap,
  });

  final String title;
  final String value;
  final String note;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bee = context.bee;
    final card = Panel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: bee.muted, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: bee.text,
              fontSize: 28,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            note.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: bee.muted,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return card;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: card),
    );
  }
}

class _EcosystemPanel extends StatelessWidget {
  const _EcosystemPanel({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final bee = context.bee;
    final counts = <String, int>{};
    for (final record in controller.currentResult?.packages ?? []) {
      final key = record.stringValue('ecosystem').toUpperCase();
      counts[key] = (counts[key] ?? 0) + 1;
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ECOSYSTEMS',
            style: TextStyle(color: bee.muted, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 20),
          for (final entry in entries.take(6))
            _Bar(
              label: entry.key,
              value: entry.value,
              max: entries.first.value,
              onTap: () => controller.openInventory(ecosystem: entry.key),
            ),
          if (entries.isEmpty)
            Text('No package records yet.', style: TextStyle(color: bee.muted)),
        ],
      ),
    );
  }
}

class _RootsPanel extends StatelessWidget {
  const _RootsPanel({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final bee = context.bee;
    final roots = controller.currentResult?.roots ?? [];
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SCANNED ROOTS',
            style: TextStyle(color: bee.muted, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          for (final root in roots.take(7))
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  final path = root['path']?.toString() ?? '';
                  if (path.isNotEmpty) controller.openInventory(root: path);
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _rootKindLabel(root['kind']?.toString()),
                        style: TextStyle(
                          color: bee.accent,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        root['path']?.toString() ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: bee.text),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (roots.isEmpty)
            Text('No roots recorded yet.', style: TextStyle(color: bee.muted)),
        ],
      ),
    );
  }

  String _rootKindLabel(String? kind) {
    if (kind == null || kind.isEmpty || kind == 'unknown') {
      return 'EXPLICIT ROOT';
    }
    return kind.replaceAll('_', ' ').toUpperCase();
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.label,
    required this.value,
    required this.max,
    required this.onTap,
  });

  final String label;
  final int value;
  final int max;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bee = context.bee;
    final width = max == 0 ? 0.0 : value / max;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: bee.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text('$value', style: TextStyle(color: bee.muted)),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: width,
                color: bee.accent,
                backgroundColor: bee.surfaceAlt,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final bee = context.bee;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Panel(
        child: Text(
          message,
          style: TextStyle(color: bee.danger, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
