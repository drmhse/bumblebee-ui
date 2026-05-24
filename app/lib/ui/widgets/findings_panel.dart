import 'package:flutter/material.dart';

import '../../data/models/bumblebee_record.dart';
import '../../state/app_controller.dart';
import 'panel.dart';
import 'section_header.dart';

class FindingsPanel extends StatelessWidget {
  const FindingsPanel({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final bee = context.bee;
    final findings = controller.currentResult?.findings ?? const [];
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                findings.isEmpty
                    ? Icons.verified_user_outlined
                    : Icons.warning_amber,
                color: findings.isEmpty ? bee.success : bee.danger,
              ),
              const SizedBox(width: 10),
              Text(
                'EXPOSURE FINDINGS',
                style: TextStyle(color: bee.muted, fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              Text(
                '${findings.length}',
                style: TextStyle(color: bee.text, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (findings.isEmpty)
            Text(
              'No catalog matches in the active result.',
              style: TextStyle(color: bee.muted),
            )
          else
            for (final finding in findings.take(6))
              _FindingRow(record: finding),
        ],
      ),
    );
  }
}

class _FindingRow extends StatelessWidget {
  const _FindingRow({required this.record});

  final BumblebeeRecord record;

  @override
  Widget build(BuildContext context) {
    final bee = context.bee;
    final severity = record.stringValue('severity').toUpperCase();
    final packageName = record.stringValue('package_name');
    final version = record.stringValue('version');
    final catalog = record.stringValue('catalog_name');
    final source = record.stringValue('source_file');
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                severity.isEmpty ? 'MATCH' : severity,
                style: TextStyle(
                  color: bee.danger,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$packageName${version.isEmpty ? '' : ' @$version'}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: bee.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          if (catalog.isNotEmpty)
            Text(
              catalog,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: bee.muted),
            ),
          if (source.isNotEmpty)
            Text(
              source,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: bee.muted),
            ),
        ],
      ),
    );
  }
}
