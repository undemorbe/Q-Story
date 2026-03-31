// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:mobx/mobx.dart';
import '../../data/models/qr_content_model.dart';
import '../../domain/usecases/process_qr_usecase.dart';

part 'qr_store.g.dart';

class QrStore = _QrStore with _$QrStore;

abstract class _QrStore with Store {
  final ProcessQrUseCase _processQrUseCase;

  _QrStore(this._processQrUseCase);

  @observable
  String? generatedData;

  @observable
  String? lastScannedData;

  @observable
  QrContentModel? lastScannedContent;

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
    try {
      final entity = await _processQrUseCase(data);
      lastScannedData = entity.content;
      scanHistory.add(entity.content);

      // Try parsing JSON content
      try {
        final jsonMap = jsonDecode(entity.content);
        if (jsonMap is Map<String, dynamic>) {
          lastScannedContent = QrContentModel.fromJson(jsonMap);
        }
      } catch (_) {
        // Not a JSON or invalid format, handle as simple text or ignore
        // For now, if it's not JSON, we just leave lastScannedContent as null
        // We could create a default model for simple text if needed
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  void onManualInput(String input) {
    onScan(input);
  }
}
