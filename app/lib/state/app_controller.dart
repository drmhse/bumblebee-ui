import 'dart:async';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';

import '../core/theme/bee_theme.dart';
import '../data/models/bumblebee_record.dart';
import '../data/models/scan_config.dart';
import '../data/models/scan_scope.dart';
import '../data/services/app_paths.dart';
import '../data/services/bumblebee_binary_resolver.dart';
import '../data/services/scan_history_store.dart';
import '../data/services/scan_runner.dart';
import '../data/services/threat_catalog_service.dart';

enum AppSection { dashboard, inventory, threatIntel, history, about }

class AppController extends ChangeNotifier {
  AppController()
    : _paths = AppPaths(),
      _catalogService = ThreatCatalogService(AppPaths()),
      _historyStore = ScanHistoryStore(AppPaths()),
      _runner = ScanRunner(BumblebeeBinaryResolver());

  final AppPaths _paths;
  final ThreatCatalogService _catalogService;
  final ScanHistoryStore _historyStore;
  final ScanRunner _runner;

  BeeThemeId themeId = BeeThemeId.command;
  AppSection section = AppSection.dashboard;
  ScanConfig config = const ScanConfig();
  ScanResult? currentResult;
  ScanScope? verifiedScope;
  List<ScanResult> history = [];
  List<ThreatCatalogInfo> catalogs = [];
  bool initialized = false;
  bool scanning = false;
  bool verifyingScope = false;
  bool syncingCatalogs = false;
  String? errorMessage;
  String? binaryPath;
  String? scannerVersion;
  String localHostname = Platform.localHostname;
  String inventoryQuery = '';
  String inventoryEcosystem = 'ALL';
  String? inventoryRoot;
  static const appVersion = '1.0.0+1';
  static const bundleIdentifier = 'bumblebee.drmhse.com';

  BeeTheme get theme => BeeThemes.byId(themeId);
  String get endpointLabel {
    final endpoint = currentResult?.endpoint;
    if (endpoint != null && endpoint != 'unknown') return endpoint;
    return localHostname;
  }

  Future<void> initialize({bool loadHistory = true}) async {
    try {
      await _paths.supportDir();
      catalogs = await _catalogService.listCatalogs().timeout(
        const Duration(seconds: 4),
      );
      await _resolveBinaryPreview().timeout(const Duration(seconds: 3));
    } catch (error) {
      errorMessage = 'Startup warning: $error';
    } finally {
      initialized = true;
    }
    notifyListeners();
    if (loadHistory) {
      unawaited(_loadHistoryAfterStartup());
    }
  }

  Future<void> _loadHistoryAfterStartup() async {
    try {
      history = await _historyStore.load().timeout(const Duration(seconds: 8));
    } catch (error) {
      errorMessage = 'History warning: $error';
      history = [];
    }
    notifyListeners();
  }

  void setTheme(BeeThemeId id) {
    themeId = id;
    notifyListeners();
  }

  void setSection(AppSection next) {
    section = next;
    notifyListeners();
  }

  void openInventory({String ecosystem = 'ALL', String? root}) {
    inventoryQuery = '';
    inventoryEcosystem = ecosystem;
    inventoryRoot = root;
    section = AppSection.inventory;
    notifyListeners();
  }

  void setInventoryFilters({
    String? query,
    String? ecosystem,
    String? root,
    bool clearRoot = false,
  }) {
    if (query != null) inventoryQuery = query;
    if (ecosystem != null) inventoryEcosystem = ecosystem;
    if (clearRoot) {
      inventoryRoot = null;
    } else if (root != null) {
      inventoryRoot = root;
    }
    notifyListeners();
  }

  void resetInventoryFilters() {
    inventoryQuery = '';
    inventoryEcosystem = 'ALL';
    inventoryRoot = null;
    notifyListeners();
  }

  void setProfile(ScanProfile profile) {
    config = config.copyWith(profile: profile);
    currentResult = null;
    verifiedScope = null;
    notifyListeners();
  }

  void setDeepRoots(String value) {
    final roots = value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty);
    config = config.copyWith(roots: roots.toList());
    currentResult = null;
    verifiedScope = null;
    notifyListeners();
  }

  Future<void> pickDeepRoot() async {
    if (scanning || verifyingScope) return;
    final path = await getDirectoryPath(confirmButtonText: 'Use Directory');
    if (path == null || path.trim().isEmpty) return;
    final nextRoots = [...config.roots, path.trim()];
    final unique = <String>[];
    for (final root in nextRoots) {
      final normalized = ScanConfig(roots: [root]).normalizedRoots.first;
      if (unique.any((item) {
        return ScanConfig(roots: [item]).normalizedRoots.first == normalized;
      })) {
        continue;
      }
      unique.add(root);
    }
    config = config.copyWith(profile: ScanProfile.deep, roots: unique);
    currentResult = null;
    verifiedScope = null;
    notifyListeners();
    await verifyScanScope();
  }

  void setFindingsOnly(bool value) {
    config = config.copyWith(findingsOnly: value);
    currentResult = null;
    notifyListeners();
  }

  Future<void> verifyScanScope() async {
    if (verifyingScope || scanning) return;
    verifyingScope = true;
    errorMessage = null;
    notifyListeners();
    try {
      verifiedScope = await _runner.resolveScope(config);
    } catch (error) {
      verifiedScope = null;
      errorMessage = 'Scope verification failed: $error';
    } finally {
      verifyingScope = false;
      notifyListeners();
    }
  }

  Future<void> runScan() async {
    if (scanning) return;
    scanning = true;
    errorMessage = null;
    setSection(AppSection.dashboard);
    notifyListeners();
    try {
      verifiedScope = await _runner.resolveScope(config);
      final catalogDir = await _catalogService.ensureCatalogs();
      final result = await _runner.run(
        config: config,
        catalogDir: catalogDir,
        onUpdate: (partial) {
          currentResult = partial;
          notifyListeners();
        },
      );
      currentResult = result;
      history = [
        result,
        ...history.where((item) => item.id != result.id),
      ].take(50).toList();
      await _historyStore.save(history);
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      scanning = false;
      notifyListeners();
    }
  }

  Future<void> syncCatalogs() async {
    if (syncingCatalogs) return;
    syncingCatalogs = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _catalogService.syncFromUpstream();
      catalogs = await _catalogService.listCatalogs();
    } catch (error) {
      errorMessage = 'Catalog sync failed: $error';
    } finally {
      syncingCatalogs = false;
      notifyListeners();
    }
  }

  Future<void> importCatalog() async {
    const group = XTypeGroup(label: 'JSON catalogs', extensions: ['json']);
    final file = await openFile(acceptedTypeGroups: [group]);
    if (file == null) return;
    await _catalogService.importCatalog(File(file.path));
    catalogs = await _catalogService.listCatalogs();
    notifyListeners();
  }

  void showHistory(ScanResult result) {
    currentResult = result;
    section = AppSection.dashboard;
    notifyListeners();
  }

  Future<void> clearHistory() async {
    history = [];
    currentResult = null;
    await _historyStore.save(history);
    notifyListeners();
  }

  Future<void> _resolveBinaryPreview() async {
    try {
      binaryPath = await BumblebeeBinaryResolver().resolve();
      scannerVersion = await _scannerVersion(binaryPath!);
    } catch (_) {
      binaryPath = null;
      scannerVersion = null;
    }
  }

  Future<String?> _scannerVersion(String path) async {
    try {
      final result = await Process.run(path, ['version']);
      final output = '${result.stdout}\n${result.stderr}'.trim();
      if (result.exitCode != 0 || output.isEmpty) return null;
      return output.split('\n').take(4).join('\n');
    } catch (_) {
      return null;
    }
  }
}
