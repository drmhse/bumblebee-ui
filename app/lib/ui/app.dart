import 'package:flutter/material.dart';

import '../state/app_controller.dart';
import 'shell/main_shell.dart';

class BumblebeeApp extends StatefulWidget {
  const BumblebeeApp({
    super.key,
    this.loadHistoryOnStartup = true,
    this.checkForUpdatesOnStartup = true,
    this.syncCatalogsOnStartup = true,
  });

  final bool loadHistoryOnStartup;
  final bool checkForUpdatesOnStartup;
  final bool syncCatalogsOnStartup;

  @override
  State<BumblebeeApp> createState() => _BumblebeeAppState();
}

class _BumblebeeAppState extends State<BumblebeeApp> {
  late final AppController controller;

  @override
  void initState() {
    super.initState();
    controller = AppController()
      ..initialize(
        loadHistory: widget.loadHistoryOnStartup,
        checkForUpdatesOnStartup: widget.checkForUpdatesOnStartup,
        syncCatalogsOnStartup: widget.syncCatalogsOnStartup,
      );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          title: 'Bumblebee',
          debugShowCheckedModeBanner: false,
          theme: controller.theme.materialTheme(),
          home: MainShell(controller: controller),
        );
      },
    );
  }
}
