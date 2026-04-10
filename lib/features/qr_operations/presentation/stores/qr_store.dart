// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:mobx/mobx.dart';
import '../../data/models/qr_content_model.dart';
import '../../data/models/qr_data_model.dart';
import '../../domain/repositories/qr_repository.dart';
import '../../domain/usecases/process_qr_usecase.dart';
import '../../data/datasources/scan_statistics_local_data_source.dart';
import '../../../map/data/datasources/completed_markers_local_data_source.dart';

part 'qr_store.g.dart';

class QrStore = _QrStore with _$QrStore;

abstract class _QrStore with Store {
  final ProcessQrUseCase _processQrUseCase;
  final QrRepository _qrRepository;
  final ScanStatisticsLocalDataSource _scanStatisticsLocalDataSource;
  final CompletedMarkersLocalDataSource _completedMarkersLocalDataSource;

  _QrStore(
    this._processQrUseCase,
    this._qrRepository,
    this._scanStatisticsLocalDataSource,
    this._completedMarkersLocalDataSource,
  );

  @observable
  String? generatedData;

  @observable
  String? lastScannedData;

  @observable
  QrContentModel? lastScannedContent;

  /// API response data for the scanned place
  @observable
  QrDataModel? scannedPlaceData;

  /// The QR code ID that was scanned (for confirmation dialog)
  @observable
  String? pendingQrCodeId;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  ObservableList<String> scanHistory = ObservableList<String>();

  @action
  void setGeneratedData(String data) {
    generatedData = data;
  }

  @action
  Future<void> onScan(String data) async {
    isLoading = true;
    errorMessage = null;
    lastScannedContent = null;
    scannedPlaceData = null;
    pendingQrCodeId = null;
    
    try {
      final entity = await _processQrUseCase(data);
      lastScannedData = entity.content;
      scanHistory.add(entity.content);

      // Try parsing JSON content (for embedded QR data format)
      try {
        final jsonMap = jsonDecode(entity.content);
        if (jsonMap is Map<String, dynamic>) {
          lastScannedContent = QrContentModel.fromJson(jsonMap);
        }
      } catch (_) {
        // Not a JSON or invalid format - treat as raw QR code ID
        // Store the raw data as the pending QR code ID
        pendingQrCodeId = entity.content.trim();
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  /// Fetches place info from API using the scanned QR code
  @action
  Future<void> fetchPlaceInfo(String qrCode) async {
    isLoading = true;
    errorMessage = null;
    
    try {
      final placeData = await _qrRepository.getPlaceInfo(qrCode);
      scannedPlaceData = placeData;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  /// Clears the pending QR code ID (called when dialog is dismissed)
  @action
  void clearPendingQrCode() {
    pendingQrCodeId = null;
  }

  /// Clears the scanned place data (called after navigation)
  @action
  void clearScannedPlaceData() {
    scannedPlaceData = null;
  }

  /// Clears the last scanned data (called when scan result banner times out)
  @action
  void clearLastScannedData() {
    lastScannedData = null;
  }

  @action
  void onManualInput(String input) {
    onScan(input);
  }

  /// Saves scan statistics to local database
  @action
  Future<void> saveScanStatistics(String qrCodeId, String placeTitle) async {
    await _scanStatisticsLocalDataSource.saveScan(
      qrCodeId: qrCodeId,
      placeTitle: placeTitle,
      scannedAt: DateTime.now(),
    );
  }

  /// Gets total number of scans from local database
  @action
  Future<int> getTotalScans() async {
    return await _scanStatisticsLocalDataSource.getTotalScans();
  }

  /// Checks if a specific QR code has been scanned
  @action
  Future<bool> hasScanned(String qrCodeId) async {
    return await _scanStatisticsLocalDataSource.hasScanned(qrCodeId);
  }

  /// Marks a marker as completed in local storage
  @action
  Future<void> markMarkerAsCompleted(String markerId) async {
    await _completedMarkersLocalDataSource.markAsCompleted(markerId);
  }

  /// Checks if a marker is completed
  @action
  Future<bool> isMarkerCompleted(String markerId) async {
    return await _completedMarkersLocalDataSource.isCompleted(markerId);
  }
}
