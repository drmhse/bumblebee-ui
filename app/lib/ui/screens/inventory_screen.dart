import 'package:flutter/material.dart';

import '../../data/models/bumblebee_record.dart';
import '../../state/app_controller.dart';
import '../widgets/empty_state.dart';
import '../widgets/panel.dart';
import '../widgets/section_header.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  static const int _pageSize = 100;

  late final TextEditingController _queryController;
  late String query;
  late String ecosystem;
  String? root;
  int page = 0;

  @override
  void initState() {
    super.initState();
    query = widget.controller.inventoryQuery;
    ecosystem = widget.controller.inventoryEcosystem;
    root = widget.controller.inventoryRoot;
    _queryController = TextEditingController(text: query);
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bee = context.bee;
    final records = _filtered();
    final pageCount = records.isEmpty
        ? 1
        : ((records.length - 1) ~/ _pageSize) + 1;
    final safePage = page.clamp(0, pageCount - 1);
    if (safePage != page) page = safePage;
    final pageStart = records.isEmpty ? 0 : safePage * _pageSize;
    final pageEnd = records.isEmpty
        ? 0
        : (pageStart + _pageSize).clamp(0, records.length);
    final visibleRecords = records.sublist(pageStart, pageEnd);
    final ecosystems = _ecosystems();
    final result = widget.controller.currentResult;
    final total = result?.packages.length ?? 0;
    final inventorySuppressed =
        result != null && total == 0 && result.packageRecordsSuppressed > 0;
    final findingsOnlyPending =
        result == null && widget.controller.config.findingsOnly;
    return Padding(
      padding: const EdgeInsets.all(34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Inventory',
            subtitle: 'Browse scanned packages and extensions.',
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _queryController,
                  onChanged: (value) {
                    setState(() {
                      query = value;
                      page = 0;
                    });
                    widget.controller.setInventoryFilters(query: value);
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search package name...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: ecosystem,
                items: [
                  for (final item in ['ALL', ...ecosystems])
                    DropdownMenuItem(value: item, child: Text(item)),
                ],
                onChanged: (value) {
                  final next = value ?? 'ALL';
                  setState(() {
                    ecosystem = next;
                    page = 0;
                  });
                  widget.controller.setInventoryFilters(ecosystem: next);
                },
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: query.isEmpty && ecosystem == 'ALL' && root == null
                    ? null
                    : () => setState(() {
                        query = '';
                        ecosystem = 'ALL';
                        root = null;
                        page = 0;
                        _queryController.clear();
                        widget.controller.resetInventoryFilters();
                      }),
                icon: const Icon(Icons.filter_alt_off),
                label: const Text('RESET'),
              ),
            ],
          ),
          if (root != null) ...[
            const SizedBox(height: 12),
            _ActiveRootFilter(
              root: root!,
              onClear: () => setState(() {
                root = null;
                page = 0;
                widget.controller.setInventoryFilters(clearRoot: true);
              }),
            ),
          ],
          const SizedBox(height: 24),
          Expanded(
            child: total == 0
                ? _InventoryEmptyState(
                    controller: widget.controller,
                    checkedCount: result?.packageRecordsChecked ?? 0,
                    inventorySuppressed: inventorySuppressed,
                    findingsOnlyPending: findingsOnlyPending,
                  )
                : Panel(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _HeaderRow(bee: bee),
                        if (records.isEmpty)
                          const Expanded(
                            child: EmptyState(
                              icon: Icons.search_off,
                              title: 'No Matching Packages',
                              message:
                                  'Adjust the search term, ecosystem, or root filter.',
                              framed: false,
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.builder(
                              itemCount: visibleRecords.length,
                              itemBuilder: (context, index) =>
                                  _PackageRow(record: visibleRecords[index]),
                            ),
                          ),
                        _PaginationBar(
                          shownStart: pageStart + 1,
                          shownEnd: pageEnd,
                          filteredTotal: records.length,
                          inventoryTotal: total,
                          page: safePage,
                          pageCount: pageCount,
                          onPrevious: safePage == 0
                              ? null
                              : () => setState(() => page = safePage - 1),
                          onNext: safePage >= pageCount - 1
                              ? null
                              : () => setState(() => page = safePage + 1),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<String> _ecosystems() {
    final values =
        widget.controller.currentResult?.packages
            .map((record) => record.stringValue('ecosystem').toUpperCase())
            .toSet()
            .toList() ??
        [];
    values.sort();
    return values;
  }

  List<BumblebeeRecord> _filtered() {
    final lower = query.toLowerCase();
    return (widget.controller.currentResult?.packages ?? []).where((record) {
      final matchesQuery =
          lower.isEmpty ||
          record.stringValue('package_name').toLowerCase().contains(lower);
      final matchesEco =
          ecosystem == 'ALL' ||
          record.stringValue('ecosystem').toUpperCase() == ecosystem;
      final source = record.stringValue('source_file');
      final matchesRoot = root == null || source.startsWith(root!);
      return matchesQuery && matchesEco && matchesRoot;
    }).toList();
  }
}

class _InventoryEmptyState extends StatelessWidget {
  const _InventoryEmptyState({
    required this.controller,
    required this.checkedCount,
    required this.inventorySuppressed,
    required this.findingsOnlyPending,
  });

  final AppController controller;
  final int checkedCount;
  final bool inventorySuppressed;
  final bool findingsOnlyPending;

  @override
  Widget build(BuildContext context) {
    final title = inventorySuppressed
        ? 'Inventory Suppressed'
        : findingsOnlyPending
        ? 'Findings-Only Mode'
        : 'No Inventory Yet';
    final message = inventorySuppressed
        ? 'This scan checked $checkedCount package records in findings-only mode, so package rows were not stored. Turn off Findings Only and run the scan again to browse inventory.'
        : findingsOnlyPending
        ? 'Findings-only scans skip package inventory rows. Turn it off before running a scan if you want this page populated.'
        : 'Run a scan from the Dashboard to populate package inventory.';

    return EmptyState(
      icon: inventorySuppressed || findingsOnlyPending
          ? Icons.visibility_off_outlined
          : Icons.inventory_2_outlined,
      title: title,
      message: message,
      action: FilledButton.icon(
        onPressed: () => controller.setSection(AppSection.dashboard),
        icon: const Icon(Icons.play_arrow),
        label: const Text('GO TO DASHBOARD'),
      ),
    );
  }
}

class _ActiveRootFilter extends StatelessWidget {
  const _ActiveRootFilter({required this.root, required this.onClear});

  final String root;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final bee = context.bee;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: bee.border),
        color: bee.surface,
      ),
      child: Row(
        children: [
          Icon(Icons.account_tree_outlined, color: bee.accent, size: 18),
          const SizedBox(width: 10),
          Text(
            'ROOT',
            style: TextStyle(color: bee.muted, fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              root,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: bee.text, fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            onPressed: onClear,
            icon: Icon(Icons.close, color: bee.muted),
            tooltip: 'Clear root filter',
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.bee});

  final dynamic bee;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: bee.border)),
      ),
      child: Row(
        children: [
          const Expanded(flex: 5, child: Text('PACKAGE')),
          const SizedBox(width: 16),
          const Expanded(flex: 1, child: Text('VERSION')),
          const SizedBox(width: 16),
          const Expanded(flex: 1, child: Text('ECOSYSTEM')),
          const SizedBox(width: 16),
          const Expanded(
            flex: 1,
            child: Tooltip(
              message:
                  'Evidence quality: high means exact package and version from canonical metadata; low can be a config reference rather than installed-version proof.',
              child: Text('EVIDENCE'),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(flex: 4, child: Text('SOURCE FILE')),
        ],
      ),
    );
  }
}

class _PackageRow extends StatelessWidget {
  const _PackageRow({required this.record});

  final BumblebeeRecord record;

  @override
  Widget build(BuildContext context) {
    final bee = context.bee;
    final confidence = record.stringValue('confidence').toLowerCase();
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: bee.border)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              record.stringValue('package_name'),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: bee.text, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Text(
              record.stringValue('version'),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: bee.accent),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: _Badge(
              text: record.stringValue('ecosystem').toUpperCase(),
              color: bee.accent,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Tooltip(
              message: _evidenceHelp(confidence),
              child: _Badge(
                text: confidence.toUpperCase(),
                color: _evidenceColor(bee, confidence),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: Text(
              record.stringValue('source_file'),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: bee.muted),
            ),
          ),
        ],
      ),
    );
  }

  Color _evidenceColor(dynamic bee, String confidence) {
    return switch (confidence) {
      'high' => bee.success,
      'medium' => bee.warning,
      _ => bee.muted,
    };
  }

  String _evidenceHelp(String confidence) {
    return switch (confidence) {
      'high' => 'Exact identity and version from canonical package metadata.',
      'medium' => 'Reliable identity, but version or source is partial.',
      _ =>
        'Config/path/spec reference only; not installed exact-version proof.',
    };
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.shownStart,
    required this.shownEnd,
    required this.filteredTotal,
    required this.inventoryTotal,
    required this.page,
    required this.pageCount,
    required this.onPrevious,
    required this.onNext,
  });

  final int shownStart;
  final int shownEnd;
  final int filteredTotal;
  final int inventoryTotal;
  final int page;
  final int pageCount;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final bee = context.bee;
    final range = filteredTotal == 0 ? '0' : '$shownStart-$shownEnd';
    final filterNote = filteredTotal == inventoryTotal
        ? '$inventoryTotal packages'
        : '$filteredTotal of $inventoryTotal packages';

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: bee.border)),
      ),
      child: Row(
        children: [
          Text(
            'SHOWING $range',
            style: TextStyle(color: bee.text, fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 12),
          Text(filterNote.toUpperCase(), style: TextStyle(color: bee.muted)),
          const Spacer(),
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous page',
          ),
          Text(
            'PAGE ${page + 1} / $pageCount',
            style: TextStyle(color: bee.muted, fontWeight: FontWeight.w900),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next page',
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
