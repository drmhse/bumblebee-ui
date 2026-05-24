import 'package:flutter/material.dart';

import '../../state/app_controller.dart';
import '../widgets/empty_state.dart';
import '../widgets/panel.dart';
import '../widgets/section_header.dart';

class ThreatIntelScreen extends StatelessWidget {
  const ThreatIntelScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final bee = context.bee;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Threat Intelligence',
            subtitle: 'Manage and update your Bumblebee exposure catalogs.',
          ),
          const SizedBox(height: 28),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CATALOG SYNCHRONIZATION',
                  style: TextStyle(
                    color: bee.muted,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Catalogs match local inventory against known supply-chain compromises.',
                  style: TextStyle(color: bee.muted),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Icon(Icons.shield_outlined, color: bee.accent, size: 42),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LOCAL VULNERABILITY DATABASE',
                            style: TextStyle(
                              color: bee.text,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '${controller.catalogs.length} active JSON catalogs',
                            style: TextStyle(color: bee.muted),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: controller.syncingCatalogs
                          ? null
                          : controller.syncCatalogs,
                      icon: const Icon(Icons.cloud_download_outlined),
                      label: Text(
                        controller.syncingCatalogs
                            ? 'SYNCING'
                            : 'SYNC FROM UPSTREAM',
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: controller.importCatalog,
                      icon: const Icon(Icons.add),
                      label: const Text('IMPORT'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _CatalogList(controller: controller)),
              const SizedBox(width: 24),
              Expanded(child: _CustomCatalogs(controller: controller)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CatalogList extends StatelessWidget {
  const _CatalogList({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final bee = context.bee;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACTIVE CATALOGS',
            style: TextStyle(color: bee.muted, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          if (controller.catalogs.isEmpty)
            const EmptyState(
              icon: Icons.shield_outlined,
              title: 'No Catalogs Loaded',
              message:
                  'Sync from upstream or import a JSON exposure catalog before scanning.',
              framed: false,
            )
          else
            for (final catalog in controller.catalogs)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: bee.success),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            catalog.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: bee.text,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '${catalog.entries} entries',
                            style: TextStyle(color: bee.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _CustomCatalogs extends StatelessWidget {
  const _CustomCatalogs({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final bee = context.bee;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CUSTOM SOURCES',
            style: TextStyle(color: bee.muted, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Text(
            'Add organizational JSON exposure catalogs to sweep local metadata for proprietary threats.',
            style: TextStyle(color: bee.muted),
          ),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            onPressed: controller.importCatalog,
            icon: const Icon(Icons.add),
            label: const Text('ADD CUSTOM CATALOG'),
          ),
          const SizedBox(height: 20),
          Text(
            'Upstream source: github.com/perplexityai/bumblebee/threat_intel. Bumblebee matches exact ecosystem, normalized package name, and version.',
            style: TextStyle(color: bee.muted, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
