import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../state/app_controller.dart';
import '../widgets/panel.dart';
import '../widgets/section_header.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final theme = context.bee;
    return ListView(
      padding: const EdgeInsets.fromLTRB(34, 34, 34, 42),
      children: [
        const SectionHeader(
          title: 'About',
          subtitle: 'Version, documentation, attribution, and caveats.',
        ),
        const SizedBox(height: 26),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BUMBLEBEE DESKTOP',
                style: TextStyle(
                  color: theme.text,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Local endpoint inventory UI for the Bumblebee scanner.',
                style: TextStyle(
                  color: theme.muted,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _Fact(label: 'App version', value: AppController.appVersion),
                  _Fact(
                    label: 'Bundle ID',
                    value: AppController.bundleIdentifier,
                  ),
                  _Fact(label: 'Hostname', value: controller.localHostname),
                  _Fact(
                    label: 'Catalogs loaded',
                    value: controller.catalogs.length.toString(),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _CodeBlock(
                label: 'Scanner',
                value:
                    controller.scannerVersion ?? 'Scanner version unavailable',
              ),
              const SizedBox(height: 14),
              _CodeBlock(
                label: 'Helper path',
                value: controller.binaryPath ?? 'Helper binary not resolved',
              ),
              const SizedBox(height: 14),
              _UpdateBlock(controller: controller),
              const SizedBox(height: 14),
              const _SourceLinks(),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _Grid(
          children: const [
            _InfoPanel(
              icon: Icons.menu_book_outlined,
              title: 'Documentation',
              items: [
                'Baseline scans use the default local package inventory path.',
                'Project scans focus on the current application workspace.',
                'Deep scans require explicit directories and verify the resolved roots before scanning.',
                'Diagnostics and findings are shown on the Dashboard after every run.',
              ],
            ),
            _InfoPanel(
              icon: Icons.checklist_outlined,
              title: 'What The Scan Checks',
              items: [
                'Installed and project package records emitted by the Bumblebee helper.',
                'Exact catalog matches by ecosystem, normalized package name, and version.',
                'Scanner diagnostics from the stream, including parse warnings and skipped files.',
                'Files considered and package records received for progress visibility.',
              ],
            ),
            _InfoPanel(
              icon: Icons.warning_amber_outlined,
              title: 'Concerns',
              items: [
                'No exposures means no catalog match was found in received package records; it is not a full malware verdict.',
                'Catalog freshness matters. Sync or import current threat intelligence before relying on results.',
                'Deep scans can include sensitive paths. Choose roots deliberately and review the verified scope.',
                'Diagnostics deserve review even when findings are zero.',
              ],
            ),
            _InfoPanel(
              icon: Icons.help_outline,
              title: 'FAQ',
              items: [
                'Where are warnings? Open Dashboard, then Diagnostics.',
                'Where are matches? Open Dashboard, then Exposure Findings.',
                'Where is history? The History section stores recent local scan results.',
                'What gets deleted? Clear Data removes local history and the active result.',
              ],
            ),
            _InfoPanel(
              icon: Icons.handshake_outlined,
              title: 'Attribution',
              items: [
                'Desktop app source is published at github.com/drmhse/bumblebee-ui.',
                'Bumblebee scanner and bundled threat catalog format come from github.com/perplexityai/bumblebee.',
                'Bundled catalogs are seeded from the upstream threat_intel directory and retain source references in each catalog file.',
                'Desktop shell is a Flutter UI wrapper around the local Bumblebee helper.',
                'Material icons and Flutter framework components are used for application UI.',
              ],
            ),
            _InfoPanel(
              icon: Icons.lock_outline,
              title: 'Data Handling',
              items: [
                'Scans run through the local helper binary resolved by this app.',
                'The app stores scan history under the user application support directory.',
                'Catalog sync downloads JSON files from raw.githubusercontent.com/perplexityai/bumblebee/main/threat_intel/.',
                'Imported catalog files are copied into local application support storage.',
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _UpdateBlock extends StatelessWidget {
  const _UpdateBlock({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final theme = context.bee;
    final info = controller.updateInfo;
    final status = controller.checkingForUpdates
        ? 'Checking GitHub releases...'
        : info == null
        ? 'Current version ${AppController.appVersion}.'
        : info.available
        ? 'Update available: ${info.latestVersion} for ${info.platformLabel}.'
        : info.newerReleaseAvailable
        ? 'Release ${info.latestVersion} is newer, but no ${info.platformLabel} download was found.'
        : 'Bumblebee is current at ${info.currentVersion}.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UPDATES',
          style: TextStyle(color: theme.muted, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(status, style: TextStyle(color: theme.text)),
            OutlinedButton.icon(
              onPressed: controller.checkingForUpdates
                  ? null
                  : controller.checkForUpdates,
              icon: Icon(
                controller.checkingForUpdates ? Icons.sync : Icons.update,
                color: theme.muted,
                size: 18,
              ),
              label: Text(
                controller.checkingForUpdates
                    ? 'CHECKING'
                    : 'CHECK GITHUB RELEASES',
              ),
            ),
            if (info != null && info.available)
              FilledButton.icon(
                onPressed: () => _LinkChip.open(context, info.assetUrl!),
                icon: const Icon(Icons.download_outlined, size: 18),
                label: Text('DOWNLOAD ${info.assetName ?? 'UPDATE'}'),
              ),
            if (info != null && info.newerReleaseAvailable)
              OutlinedButton.icon(
                onPressed: () => _LinkChip.open(context, info.releaseUrl),
                icon: Icon(Icons.open_in_new, color: theme.muted, size: 18),
                label: const Text('OPEN RELEASE'),
              ),
          ],
        ),
      ],
    );
  }
}

class _SourceLinks extends StatelessWidget {
  const _SourceLinks();

  static const projectRepoUrl = 'https://github.com/drmhse/bumblebee-ui';
  static const scannerRepoUrl = 'https://github.com/perplexityai/bumblebee';
  static const catalogUrl =
      'https://github.com/perplexityai/bumblebee/tree/main/threat_intel';
  static const rawCatalogBase =
      'https://raw.githubusercontent.com/perplexityai/bumblebee/main/threat_intel/';

  @override
  Widget build(BuildContext context) {
    final theme = context.bee;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SOURCE LINKS',
          style: TextStyle(color: theme.muted, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const [
            _LinkChip(label: 'Desktop app repository', url: projectRepoUrl),
            _LinkChip(label: 'Scanner repository', url: scannerRepoUrl),
            _LinkChip(label: 'Threat catalog directory', url: catalogUrl),
          ],
        ),
        const SizedBox(height: 10),
        _CodeBlock(label: 'Catalog sync base', value: rawCatalogBase),
      ],
    );
  }
}

class _LinkChip extends StatelessWidget {
  const _LinkChip({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final theme = context.bee;
    return TextButton.icon(
      onPressed: () => open(context, url),
      icon: Icon(Icons.open_in_new, color: theme.muted, size: 16),
      label: Text(
        label,
        style: TextStyle(color: theme.muted, fontWeight: FontWeight.w800),
      ),
    );
  }

  static Future<void> open(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open $url')));
    }
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 1100;
        return GridView.count(
          crossAxisCount: wide ? 2 : 1,
          childAspectRatio: wide ? 2.6 : 3.4,
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: children,
        );
      },
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.bee;
    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(color: theme.muted, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          SelectableText(
            value,
            style: TextStyle(
              color: theme.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.bee;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(color: theme.muted, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.surfaceAlt,
            border: Border.all(color: theme.border),
          ),
          child: SelectableText(value, style: TextStyle(color: theme.text)),
        ),
      ],
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.icon,
    required this.title,
    required this.items,
  });

  final IconData icon;
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = context.bee;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.accent),
              const SizedBox(width: 12),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: theme.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.circle, size: 7, color: theme.accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        items[index],
                        style: TextStyle(color: theme.muted, height: 1.25),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
