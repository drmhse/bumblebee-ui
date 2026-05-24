import 'package:flutter/material.dart';

import '../../core/theme/bee_theme.dart';
import '../../state/app_controller.dart';
import 'section_header.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final theme = controller.theme;
    return Container(
      width: 252,
      decoration: BoxDecoration(
        color: theme.surfaceAlt,
        border: Border(right: BorderSide(color: theme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 58, 18, 24),
            child: Row(
              children: [
                _BumblebeeLogo(theme: theme),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BUMBLEBEE',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.text,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'ENDPOINT INVENTORY',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.muted,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _NavItem(
            controller: controller,
            section: AppSection.dashboard,
            icon: Icons.dashboard_outlined,
            label: 'DASHBOARD',
          ),
          _NavItem(
            controller: controller,
            section: AppSection.inventory,
            icon: Icons.inventory_2_outlined,
            label: 'INVENTORY',
          ),
          _NavItem(
            controller: controller,
            section: AppSection.threatIntel,
            icon: Icons.shield_outlined,
            label: 'THREAT INTEL',
          ),
          _NavItem(
            controller: controller,
            section: AppSection.history,
            icon: Icons.history,
            label: 'HISTORY',
          ),
          _NavItem(
            controller: controller,
            section: AppSection.about,
            icon: Icons.info_outline,
            label: 'ABOUT',
          ),
          if (controller.updateInfo?.available == true)
            _UpdateAvailableCard(controller: controller),
          const Spacer(),
          _SidebarActions(controller: controller),
        ],
      ),
    );
  }
}

class _UpdateAvailableCard extends StatelessWidget {
  const _UpdateAvailableCard({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final theme = controller.theme;
    final info = controller.updateInfo!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
      child: InkWell(
        onTap: () => controller.setSection(AppSection.about),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.accent.withValues(alpha: theme.isDark ? 0.14 : 0.2),
            border: Border.all(color: theme.accent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.system_update_alt, color: theme.accent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'UPDATE AVAILABLE',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${info.latestVersion} for ${info.platformLabel}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: theme.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarActions extends StatelessWidget {
  const _SidebarActions({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final theme = controller.theme;
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          _ActionButton(
            icon: Icons.palette_outlined,
            label: controller.theme.name.toUpperCase(),
            onPressed: () => _showThemePanel(context, controller),
          ),
          const SizedBox(height: 8),
          _ActionButton(
            icon: Icons.delete_outline,
            label: 'CLEAR DATA',
            danger: true,
            onPressed: () => _confirmClearData(context, controller),
          ),
          const SizedBox(height: 4),
          Divider(color: theme.border),
        ],
      ),
    );
  }

  Future<void> _confirmClearData(
    BuildContext context,
    AppController controller,
  ) async {
    final theme = controller.theme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.surface,
          title: Text('CLEAR LOCAL DATA?', style: TextStyle(color: theme.text)),
          content: Text(
            'This removes scan history and the active result from this machine.',
            style: TextStyle(color: theme.muted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('CLEAR DATA'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) await controller.clearHistory();
  }

  void _showThemePanel(BuildContext context, AppController controller) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close theme selector',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 252),
            child: _ThemePanel(controller: controller),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final offset = Tween<Offset>(
          begin: const Offset(-0.08, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
        return SlideTransition(position: offset, child: child);
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final theme = context.bee;
    final color = danger ? theme.danger : theme.accent;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: 18),
        label: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}

class _ThemePanel extends StatelessWidget {
  const _ThemePanel({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final theme = controller.theme;
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 430,
        height: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border(right: BorderSide(color: theme.border)),
          boxShadow: const [BoxShadow(blurRadius: 18, color: Colors.black45)],
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.palette_outlined, color: theme.accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'THEME',
                      style: TextStyle(
                        color: theme.text,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: theme.muted),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a visual mode. Preview cards show background, panels, text, and accent behavior.',
                style: TextStyle(color: theme.muted),
              ),
              const SizedBox(height: 22),
              Expanded(
                child: ListView.separated(
                  itemCount: BeeThemes.all.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = BeeThemes.all[index];
                    return _ThemePreviewCard(
                      theme: item,
                      selected: item.id == controller.themeId,
                      onTap: () {
                        controller.setTheme(item.id);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemePreviewCard extends StatelessWidget {
  const _ThemePreviewCard({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  final BeeTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.background,
          border: Border.all(color: selected ? theme.accent : theme.border),
        ),
        child: Row(
          children: [
            _ThemeSkeleton(theme: theme),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme.name.toUpperCase(),
                    style: TextStyle(
                      color: theme.text,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    theme.isDark ? 'Dark interface' : 'Light interface',
                    style: TextStyle(color: theme.muted),
                  ),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle, color: theme.accent),
          ],
        ),
      ),
    );
  }
}

class _ThemeSkeleton extends StatelessWidget {
  const _ThemeSkeleton({required this.theme});

  final BeeTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 58,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.surfaceAlt,
        border: Border.all(color: theme.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 18, height: 18, color: theme.accent),
              const SizedBox(width: 6),
              Expanded(child: Container(height: 8, color: theme.text)),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              children: [
                Container(width: 18, color: theme.surface),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    children: [
                      Container(height: 7, color: theme.muted),
                      const SizedBox(height: 5),
                      Container(height: 7, color: theme.accent),
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

class _BumblebeeLogo extends StatelessWidget {
  const _BumblebeeLogo({required this.theme});

  final BeeTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: theme.accent.withValues(alpha: theme.isDark ? 0.12 : 0.2),
        border: Border.all(color: theme.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Image.asset(
        'assets/brand/bumblebee-logo.png',
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.controller,
    required this.section,
    required this.icon,
    required this.label,
  });

  final AppController controller;
  final AppSection section;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = controller.theme;
    final active = controller.section == section;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: InkWell(
        onTap: () => controller.setSection(section),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: active ? theme.surface : Colors.transparent,
            border: Border.all(
              color: active ? theme.border : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: active ? theme.text : theme.muted),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: active ? theme.text : theme.muted,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
