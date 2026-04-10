import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for managing scan statistics
class ScanStatisticsLocalDataSource {
  static const String _scanHistoryKey = 'scan_history';
  
  final SharedPreferences _prefs;

  ScanStatisticsLocalDataSource(this._prefs);

  /// Saves a scan event to local storage
  Future<void> saveScan({
    required String qrCodeId,
    required String placeTitle,
    required DateTime scannedAt,
  }) async {
    final scanData = {
      'qrCodeId': qrCodeId,
      'placeTitle': placeTitle,
      'scannedAt': scannedAt.toIso8601String(),
    };
    
    final scans = await getScanHistory();
    scans.add(scanData);
    
    final jsonString = jsonEncode(scans);
    await _prefs.setString(_scanHistoryKey, jsonString);
  }

  /// Gets all scan history from local storage
  Future<List<Map<String, dynamic>>> getScanHistory() async {
    final jsonString = _prefs.getString(_scanHistoryKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  /// Gets the total number of scans
  Future<int> getTotalScans() async {
    final scans = await getScanHistory();
    return scans.length;
  }

  /// Checks if a specific QR code has been scanned
  Future<bool> hasScanned(String qrCodeId) async {
    final scans = await getScanHistory();
    return scans.any((scan) => scan['qrCodeId'] == qrCodeId);
  }

  /// Clears all scan history
  Future<void> clearScanHistory() async {
    await _prefs.remove(_scanHistoryKey);
  }
}
