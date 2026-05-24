import 'package:flutter/material.dart';

import '../../data/models/bumblebee_record.dart';
import '../../state/app_controller.dart';
import 'panel.dart';
import 'section_header.dart';

class ScanStatusPanel extends StatelessWidget {
  const ScanStatusPanel({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final bee = context.bee;
    final result = controller.currentResult;
    final outcome = _ScanOutcome.from(result);
    final running = controller.scanning;
    final verifying = controller.verifyingScope;
    final progressValue = running || verifying
        ? null
        : result == null
        ? 0.0
        : 1.0;
    final phase = verifying
        ? 'Verifying scope'
        : running
        ? 'Receiving records'
        : result == null
        ? 'Ready'
        : result.status;
    final snapshotTime = result?.completedAt
        ?.toLocal()
        .toString()
        .split('.')
        .first;

    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                outcome.icon,
                color: switch (outcome.severity) {
                  _OutcomeSeverity.success => bee.success,
                  _OutcomeSeverity.warning => bee.warning,
                  _OutcomeSeverity.danger => bee.danger,
                  _OutcomeSeverity.neutral => bee.muted,
                },
                size: 48,
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      outcome.title,
                      style: TextStyle(
                        color: bee.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      outcome.detail,
                      style: TextStyle(
                        color: outcome.severity == _OutcomeSeverity.success
                            ? bee.success
                            : bee.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Text(
                phase.toUpperCase(),
                style: TextStyle(color: bee.muted, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          if (snapshotTime != null) ...[
            const SizedBox(height: 12),
            Text(
              'SNAPSHOT FROM $snapshotTime',
              style: TextStyle(
                color: bee.muted,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: progressValue,
            color: running ? bee.warning : bee.accent,
            backgroundColor: bee.surfaceAlt,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 28,
            runSpacing: 12,
            children: [
              _StatusStat(
                label: 'Packages checked',
                value: '${result?.packageRecordsChecked ?? 0}',
              ),
              _StatusStat(
                label: 'Findings',
                value: '${result?.findings.length ?? 0}',
              ),
              _StatusStat(
                label: 'Diagnostics',
                value: '${result?.diagnostics.length ?? 0}',
              ),
              _StatusStat(
                label: 'Files considered',
                value: result?.summary == null
                    ? 'available at summary'
                    : '${result?.filesConsidered ?? 0}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _OutcomeSeverity { neutral, success, warning, danger }

class _ScanOutcome {
  const _ScanOutcome({
    required this.title,
    required this.detail,
    required this.icon,
    required this.severity,
  });

  final String title;
  final String detail;
  final IconData icon;
  final _OutcomeSeverity severity;

  static _ScanOutcome from(ScanResult? result) {
    if (result == null) {
      return const _ScanOutcome(
        title: 'NO ACTIVE SCAN RESULT',
        detail:
            'Choose or confirm the scope, then run a scan for the selected profile.',
        icon: Icons.info_outline,
        severity: _OutcomeSeverity.neutral,
      );
    }
    if (!result.hasCompleteSummary) {
      return _ScanOutcome(
        title: 'SCAN NOT AUTHORITATIVE',
        detail:
            'Result status is ${result.status}. Review diagnostics before trusting this run.',
        icon: Icons.report_problem_outlined,
        severity: _OutcomeSeverity.warning,
      );
    }
    if (result.findingsCount > 0) {
      return _ScanOutcome(
        title: 'EXPOSURES DETECTED',
        detail:
            'Known catalog matches: ${result.findingsCount}. ${result.packageRecordsChecked} package records checked.',
        icon: Icons.warning_amber,
        severity: _OutcomeSeverity.danger,
      );
    }
    if (result.packageRecordsChecked == 0) {
      return _ScanOutcome(
        title: 'NO PACKAGE RECORDS SCANNED',
        detail:
            'Bumblebee completed with ${result.diagnosticsCount} diagnostics. Check that the selected root contains supported package metadata.',
        icon: Icons.report_problem_outlined,
        severity: _OutcomeSeverity.warning,
      );
    }
    return _ScanOutcome(
      title: 'NO EXPOSURES DETECTED',
      detail:
          'No catalog matches in ${result.packageRecordsChecked} checked package records.',
      icon: Icons.verified_user_outlined,
      severity: _OutcomeSeverity.success,
    );
  }
}

class _StatusStat extends StatelessWidget {
  const _StatusStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final bee = context.bee;
    return SizedBox(
      width: 190,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: bee.muted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: bee.text, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
