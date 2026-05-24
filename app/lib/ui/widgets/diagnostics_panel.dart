import 'package:flutter/material.dart';

import '../../data/models/bumblebee_record.dart';
import '../../state/app_controller.dart';
import 'panel.dart';
import 'section_header.dart';

class DiagnosticsPanel extends StatelessWidget {
  const DiagnosticsPanel({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final bee = context.bee;
    final diagnostics = controller.currentResult?.diagnostics ?? const [];
    final warnings = diagnostics.where((record) {
      return record.stringValue('level').toLowerCase() != 'info';
    }).toList();
    final visible = warnings.isEmpty ? diagnostics.take(4).toList() : warnings;
    return _ClickSurface(
      enabled: diagnostics.isNotEmpty,
      onTap: () => showDiagnosticsDialog(context, controller),
      child: Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.report_outlined, color: bee.accent),
                const SizedBox(width: 10),
                Text(
                  'DIAGNOSTICS',
                  style: TextStyle(
                    color: bee.muted,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Text(
                  '${diagnostics.length}',
                  style: TextStyle(
                    color: bee.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (diagnostics.isEmpty)
              Text(
                'No scanner diagnostics for the active result.',
                style: TextStyle(color: bee.muted),
              )
            else
              for (final diagnostic in visible.take(6))
                _DiagnosticRow(record: diagnostic),
            if (diagnostics.length > visible.take(6).length)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+${diagnostics.length - visible.take(6).length} more diagnostics in this run',
                  style: TextStyle(
                    color: bee.muted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> showDiagnosticsDialog(
  BuildContext context,
  AppController controller,
) {
  final bee = context.bee;
  final diagnostics = controller.currentResult?.diagnostics ?? const [];
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: bee.surface,
        title: Row(
          children: [
            Icon(Icons.report_outlined, color: bee.accent),
            const SizedBox(width: 12),
            Text('DIAGNOSTICS', style: TextStyle(color: bee.text)),
            const Spacer(),
            Text('${diagnostics.length}', style: TextStyle(color: bee.muted)),
          ],
        ),
        content: SizedBox(
          width: 820,
          height: 520,
          child: diagnostics.isEmpty
              ? Center(
                  child: Text(
                    'No scanner diagnostics for the active result.',
                    style: TextStyle(color: bee.muted),
                  ),
                )
              : ListView.separated(
                  itemCount: diagnostics.length,
                  separatorBuilder: (_, _) => Divider(color: bee.border),
                  itemBuilder: (context, index) {
                    return _DiagnosticDetail(record: diagnostics[index]);
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CLOSE'),
          ),
        ],
      );
    },
  );
}

class _ClickSurface extends StatelessWidget {
  const _ClickSurface({
    required this.enabled,
    required this.onTap,
    required this.child,
  });

  final bool enabled;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: child),
    );
  }
}

class _DiagnosticDetail extends StatelessWidget {
  const _DiagnosticDetail({required this.record});

  final BumblebeeRecord record;

  @override
  Widget build(BuildContext context) {
    final bee = context.bee;
    final level = record.stringValue('level').toUpperCase();
    final path = record.stringValue('path');
    final message = record.stringValue('message');
    final color = level == 'WARN'
        ? bee.warning
        : level == 'ERROR'
        ? bee.danger
        : bee.muted;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                level.isEmpty ? 'INFO' : level,
                style: TextStyle(color: color, fontWeight: FontWeight.w900),
              ),
              if (path.isNotEmpty) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: SelectableText(
                    path,
                    style: TextStyle(color: bee.muted),
                  ),
                ),
              ],
            ],
          ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 8),
            SelectableText(
              message,
              style: TextStyle(color: bee.text, fontWeight: FontWeight.w700),
            ),
          ],
        ],
      ),
    );
  }
}

class _DiagnosticRow extends StatelessWidget {
  const _DiagnosticRow({required this.record});

  final BumblebeeRecord record;

  @override
  Widget build(BuildContext context) {
    final bee = context.bee;
    final level = record.stringValue('level').toUpperCase();
    final path = record.stringValue('path');
    final message = record.stringValue('message');
    final color = level == 'WARN'
        ? bee.warning
        : level == 'ERROR'
        ? bee.danger
        : bee.muted;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                level.isEmpty ? 'INFO' : level,
                style: TextStyle(color: color, fontWeight: FontWeight.w900),
              ),
              if (path.isNotEmpty) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    path,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: bee.muted),
                  ),
                ),
              ],
            ],
          ),
          if (message.isNotEmpty)
            Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: bee.text),
            ),
        ],
      ),
    );
  }
}
