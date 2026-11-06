import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../activity/domain/entities/activity.dart';
import '../../../activity/presentation/stores/journal_store.dart';
import '../../../places/domain/entities/place.dart';
import '../../../places/presentation/widgets/place_labels.dart';
import '../../../settings/presentation/stores/settings_store.dart';
import '../../domain/scan_resolver.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> with WidgetsBindingObserver {
  final ScanResolver _resolver = getIt<ScanResolver>();
  final JournalStore _journal = getIt<JournalStore>();
  final SettingsStore _settings = getIt<SettingsStore>();
  final MobileScannerController _camera = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
    autoStart: false,
  );
  final ValueNotifier<int> _tab = getIt<ValueNotifier<int>>(instanceName: 'currentTab');

  /// Index of the scanner tab in the bottom navigation.
  static const int tabIndex = 1;

  static final List<Place> _recent = [];
  bool _busy = false;
  String? _lastRaw;
  DateTime _lastAt = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tab.addListener(_syncCamera);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncCamera());
  }

  /// The tab stays alive in an IndexedStack, so the camera is only
  /// running while the scanner tab is actually visible.
  void _syncCamera() {
    if (!mounted) return;
    if (_tab.value == tabIndex) {
      unawaited(_camera.start());
    } else {
      unawaited(_camera.stop());
    }
  }

  @override
  void dispose() {
    _tab.removeListener(_syncCamera);
    WidgetsBinding.instance.removeObserver(this);
    _camera.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_camera.value.hasCameraPermission) return;
    switch (state) {
      case AppLifecycleState.resumed:
        _syncCamera();
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        unawaited(_camera.stop());
    }
  }

  void _onDetect(BarcodeCapture capture) {
    final raw = capture.barcodes.map((b) => b.rawValue).whereType<String>().firstOrNull;
    if (raw == null) return;
    final now = DateTime.now();
    if (raw == _lastRaw && now.difference(_lastAt) < const Duration(seconds: 4)) return;
    _lastRaw = raw;
    _lastAt = now;
    _handle(raw, fromCamera: true);
  }

  Future<void> _handle(String raw, {required bool fromCamera}) async {
    if (_busy) return;
    final l = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    final outcome = await _resolver.resolve(raw, language: _settings.languageCode);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (outcome) {
      case ScanFoundPlace(place: final p):
        await _journal.log(ActivityEventType.scan, place: p);
        await _journal.recordVisit(p, fromCamera ? VisitMethod.qr : VisitMethod.manual);
        _recent.removeWhere((e) => e.id == p.id);
        _recent.insert(0, p);
        if (_recent.length > 20) _recent.removeLast();
        if (mounted) unawaited(context.push('/place', extra: p));
      case ScanLink(uri: final u):
        _snack(l.qrExternal, actionLabel: l.openLink, action: () => launchUrl(u, mode: LaunchMode.externalApplication));
      case ScanUnknown():
        _snack(l.qrUnknown);
      case ScanFailed(failure: final f):
        _snack(f is NotFoundFailure ? l.placeNotFound : '${l.error}: ${f.message}');
    }
  }

  void _snack(String msg, {String? actionLabel, VoidCallback? action}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      action: action == null ? null : SnackBarAction(label: actionLabel!, onPressed: action),
    ));
  }

  Future<void> _manualInput() async {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.manualInput),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l.enterQrHint),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text), child: Text(l.submit)),
        ],
      ),
    );
    controller.dispose();
    if (value != null && value.trim().isNotEmpty) await _handle(value, fromCamera: false);
  }

  void _showRecent() {
    final l = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l.scanHistory, style: Theme.of(context).textTheme.titleLarge)),
          if (_recent.isEmpty)
            Padding(padding: const EdgeInsets.all(24), child: Text(l.noScansYet))
          else
            Flexible(
              child: ListView(shrinkWrap: true, children: [
                for (final p in _recent)
                  ListTile(
                    leading: Icon(p.category.icon, color: p.source.color),
                    title: Text(p.title),
                    subtitle: Text(p.source.label(l)),
                    onTap: () {
                      Navigator.pop(ctx);
                      context.push('/place', extra: p);
                    },
                  ),
              ]),
            ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final gold = context.gold;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _camera,
            onDetect: _onDetect,
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.no_photography_outlined, color: Colors.white70, size: 48),
                  const SizedBox(height: 12),
                  Text(l.cameraPermissionRequired,
                      textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 12),
                  OutlinedButton(onPressed: _manualInput, child: Text(l.manualInput)),
                ]),
              ),
            ),
          ),
          // Viewfinder
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration:
                  BoxDecoration(border: Border.all(color: gold, width: 2), borderRadius: BorderRadius.circular(8)),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                      child: Text(l.scannerHint, style: const TextStyle(color: Colors.white, fontSize: 13)),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _camera.toggleTorch(),
                    icon: ValueListenableBuilder(
                      valueListenable: _camera,
                      builder: (_, state, __) => Icon(
                        state.torchState == TorchState.on ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
          if (_busy)
            Container(
              color: Colors.black45,
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  CircularProgressIndicator(color: gold),
                  const SizedBox(height: 12),
                  Text(l.resolvingPlace, style: const TextStyle(color: Colors.white)),
                ]),
              ),
            ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Row(children: [
              Expanded(
                child: FilledButton.icon(
                    onPressed: _manualInput, icon: const Icon(Icons.keyboard), label: Text(l.manualInput)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                    onPressed: _showRecent, icon: const Icon(Icons.history), label: Text(l.scanHistory)),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
