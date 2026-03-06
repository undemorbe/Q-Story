// ignore_for_file: library_private_types_in_public_api

import 'package:mobx/mobx.dart';
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
    try {
      final entity = await _processQrUseCase(data);
      lastScannedData = entity.content;
      scanHistory.add(entity.content);
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
