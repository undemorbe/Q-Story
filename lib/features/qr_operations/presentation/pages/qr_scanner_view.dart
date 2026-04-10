import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/di/service_locator.dart';
import '../../../history/domain/entities/history_entity.dart';
import '../../data/models/qr_data_model.dart';
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
  Timer? _scanResultTimer;
  
  // Cooldown to prevent multiple rapid scans
  bool _isOnCooldown = false;
  static const Duration _scanCooldown = Duration(seconds: 2);

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
    _scanResultTimer?.cancel();
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
            onDetect: (capture) async {
              // Skip if on cooldown to prevent multiple rapid scans
              if (_isOnCooldown || _store.isLoading) return;
              
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  // Start cooldown after successful scan detection
                  _isOnCooldown = true;
                  
                  await _store.onScan(barcode.rawValue!);
                  
                  // Reset cooldown after delay
                  Future.delayed(_scanCooldown, () {
                    if (mounted) {
                      setState(() {
                        _isOnCooldown = false;
                      });
                    }
                  });
                  
                  // If we have a pending QR code ID, show confirmation dialog
                  if (context.mounted && _store.pendingQrCodeId != null) {
                    _showConfirmationDialog(context, _store.pendingQrCodeId!);
                  }
                  // Otherwise if we have embedded JSON content, show QR result page
                  else if (context.mounted && _store.lastScannedContent != null) {
                     context.push('/qr-result', extra: _store.lastScannedContent);
                  } else if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text('Scanned: ${barcode.rawValue}')),
                     );
                  }
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
          // Debug mode buttons - only visible in debug mode
          if (kDebugMode)
            Positioned(
              bottom: 140,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _simulateQrScan('865a965a-9068-42ec-bdac-22455bd35ff7'),
                      icon: const Icon(Icons.bug_report, color: Colors.orange),
                      label: const Text('Debug: pavlov-1'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.withValues(alpha: 0.8),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _simulateQrScan('05de0784-6014-4da0-9898-ae10152d76be'),
                      icon: const Icon(Icons.bug_report, color: Colors.orange),
                      label: const Text('Debug: loffe-1'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Observer(
            builder: (_) {
              // Auto-hide scan result after 5 seconds
              if (_store.lastScannedData != null) {
                _scanResultTimer?.cancel();
                _scanResultTimer = Timer(const Duration(seconds: 5), () {
                  _store.clearLastScannedData();
                });
              }
              
              if (_store.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              final l10n = AppLocalizations.of(context);
              if (_store.lastScannedData != null && l10n != null) {
                 return IgnorePointer(
                   child: Positioned(
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
                      // If we have a pending QR code ID after manual input, show confirmation
                      if (_store.pendingQrCodeId != null) {
                        _showConfirmationDialog(context, _store.pendingQrCodeId!);
                      }
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

  void _showErrorSnackBar(BuildContext context, String errorMessage) {
    // Determine if error is from server or app
    final isServerError = errorMessage.toLowerCase().contains('network') ||
        errorMessage.toLowerCase().contains('failed to get') ||
        errorMessage.toLowerCase().contains('invalid_input') ||
        errorMessage.toLowerCase().contains('statuscode');
    
    final backgroundColor = isServerError ? Colors.red.shade700 : Colors.orange.shade700;
    final message = isServerError ? 'Ошибка на сервере' : 'Ошибка в приложении';
    final icon = isServerError ? Icons.error_outline : Icons.warning_amber_rounded;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  if (errorMessage.isNotEmpty && errorMessage != message)
                    Text(
                      errorMessage,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, String qrCodeId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Найдено место'),
        content: Text('Перейти к информации об объекте?\n\nID: $qrCodeId'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _store.clearPendingQrCode();
            },
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // Fetch place info from API
              await _store.fetchPlaceInfo(qrCodeId);
              
              if (context.mounted && _store.scannedPlaceData != null) {
                _navigateToHistoryDetail(context, _store.scannedPlaceData!);
              } else if (context.mounted && _store.errorMessage != null) {
                _showErrorSnackBar(context, _store.errorMessage!);
              }
            },
            child: const Text('Перейти'),
          ),
        ],
      ),
    );
  }

  void _navigateToHistoryDetail(BuildContext context, QrDataModel placeData) async {
    // Save scan statistics to local DB
    await _store.saveScanStatistics(placeData.id, placeData.title);
    
    // Mark marker as completed (QR code ID matches marker ID)
    await _store.markMarkerAsCompleted(placeData.id);
    
    // Convert QrDataModel to HistoryEntity for the detail page
    final historyEntity = HistoryEntity(
      id: placeData.id,
      title: placeData.title,
      subtitle: placeData.compressedDescription,
      description: placeData.fullDescription,
      imageUrl: placeData.image ?? '',
      yearRange: placeData.yearRange ?? '',
      resources: placeData.resources,
    );
    
    if (context.mounted) {
      context.push('/history-detail', extra: historyEntity);
    }
    _store.clearScannedPlaceData();
    _store.clearPendingQrCode();
  }

  /// Simulates a QR scan for debug mode testing
  Future<void> _simulateQrScan(String qrCodeId) async {
    await _store.onScan(qrCodeId);
    
    // If we have a pending QR code ID, show confirmation dialog
    if (mounted && _store.pendingQrCodeId != null) {
      _showConfirmationDialog(context, _store.pendingQrCodeId!);
    }
  }
}
