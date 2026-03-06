import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/di/service_locator.dart';
import '../stores/qr_store.dart';
import '../../../../core/l10n/app_localizations.dart';

class QrScannerView extends StatefulWidget {
  const QrScannerView({super.key});

  @override
  State<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<QrScannerView> with WidgetsBindingObserver {
  final QrStore _store = getIt<QrStore>();
  final MobileScannerController _controller = MobileScannerController();
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }
  
  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    if (status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.cameraPermissionRequired),
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.openSettings,
              onPressed: () {
                openAppSettings();
              },
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) {
      return;
    }
    
    switch (state) {
      case AppLifecycleState.resumed:
        // No need to manually start, MobileScanner widget handles it
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // Only stop if it is actually running
        if (_controller.value.isRunning) {
          _controller.stop();
        }
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _store.onScan(barcode.rawValue!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Scanned: ${barcode.rawValue}')),
                  );
                }
              }
            },
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: Icon(
                _isTorchOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
                size: 32,
              ),
              onPressed: () {
                setState(() {
                  _isTorchOn = !_isTorchOn;
                  _controller.toggleTorch();
                });
              },
            ),
          ),
          Positioned(
            bottom: 80,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _showManualInputDialog(context);
                  },
                  icon: const Icon(Icons.keyboard),
                  label: const Text('Manual Input'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showHistoryBottomSheet(context);
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('History'),
                ),
              ],
            ),
          ),
          Observer(
            builder: (_) {
              if (_store.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              final l10n = AppLocalizations.of(context);
              if (_store.lastScannedData != null && l10n != null) {
                 return Positioned(
                   bottom: 150,
                   left: 0,
                   right: 0,
                   child: Center(
                     child: Container(
                       padding: const EdgeInsets.all(8),
                       color: Colors.black54,
                       child: Text(
                         '${l10n.scanResult}: ${_store.lastScannedData}',
                         style: const TextStyle(color: Colors.white),
                       ),
                     ),
                   ),
                 );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  void _showManualInputDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manual Input'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: 'Enter QR code data'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                _store.onManualInput(textController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showHistoryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Observer(
        builder: (_) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Scan History',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _store.scanHistory.length,
                itemBuilder: (context, index) {
                  final item = _store.scanHistory[index];
                  return ListTile(
                    title: Text(item),
                    onTap: () {
                      _store.onManualInput(item);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
