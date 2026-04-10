// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$QrStore on _QrStore, Store {
  late final _$generatedDataAtom =
      Atom(name: '_QrStore.generatedData', context: context);

  @override
  String? get generatedData {
    _$generatedDataAtom.reportRead();
    return super.generatedData;
  }

  @override
  set generatedData(String? value) {
    _$generatedDataAtom.reportWrite(value, super.generatedData, () {
      super.generatedData = value;
    });
  }

  late final _$lastScannedDataAtom =
      Atom(name: '_QrStore.lastScannedData', context: context);

  @override
  String? get lastScannedData {
    _$lastScannedDataAtom.reportRead();
    return super.lastScannedData;
  }

  @override
  set lastScannedData(String? value) {
    _$lastScannedDataAtom.reportWrite(value, super.lastScannedData, () {
      super.lastScannedData = value;
    });
  }

  late final _$lastScannedContentAtom =
      Atom(name: '_QrStore.lastScannedContent', context: context);

  @override
  QrContentModel? get lastScannedContent {
    _$lastScannedContentAtom.reportRead();
    return super.lastScannedContent;
  }

  @override
  set lastScannedContent(QrContentModel? value) {
    _$lastScannedContentAtom.reportWrite(value, super.lastScannedContent, () {
      super.lastScannedContent = value;
    });
  }

  late final _$scannedPlaceDataAtom =
      Atom(name: '_QrStore.scannedPlaceData', context: context);

  @override
  QrDataModel? get scannedPlaceData {
    _$scannedPlaceDataAtom.reportRead();
    return super.scannedPlaceData;
  }

  @override
  set scannedPlaceData(QrDataModel? value) {
    _$scannedPlaceDataAtom.reportWrite(value, super.scannedPlaceData, () {
      super.scannedPlaceData = value;
    });
  }

  late final _$pendingQrCodeIdAtom =
      Atom(name: '_QrStore.pendingQrCodeId', context: context);

  @override
  String? get pendingQrCodeId {
    _$pendingQrCodeIdAtom.reportRead();
    return super.pendingQrCodeId;
  }

  @override
  set pendingQrCodeId(String? value) {
    _$pendingQrCodeIdAtom.reportWrite(value, super.pendingQrCodeId, () {
      super.pendingQrCodeId = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_QrStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_QrStore.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$scanHistoryAtom =
      Atom(name: '_QrStore.scanHistory', context: context);

  @override
  ObservableList<String> get scanHistory {
    _$scanHistoryAtom.reportRead();
    return super.scanHistory;
  }

  @override
  set scanHistory(ObservableList<String> value) {
    _$scanHistoryAtom.reportWrite(value, super.scanHistory, () {
      super.scanHistory = value;
    });
  }

  late final _$onScanAsyncAction =
      AsyncAction('_QrStore.onScan', context: context);

  @override
  Future<void> onScan(String data) {
    return _$onScanAsyncAction.run(() => super.onScan(data));
  }

  late final _$fetchPlaceInfoAsyncAction =
      AsyncAction('_QrStore.fetchPlaceInfo', context: context);

  @override
  Future<void> fetchPlaceInfo(String qrCode) {
    return _$fetchPlaceInfoAsyncAction.run(() => super.fetchPlaceInfo(qrCode));
  }

  late final _$saveScanStatisticsAsyncAction =
      AsyncAction('_QrStore.saveScanStatistics', context: context);

  @override
  Future<void> saveScanStatistics(String qrCodeId, String placeTitle) {
    return _$saveScanStatisticsAsyncAction
        .run(() => super.saveScanStatistics(qrCodeId, placeTitle));
  }

  late final _$getTotalScansAsyncAction =
      AsyncAction('_QrStore.getTotalScans', context: context);

  @override
  Future<int> getTotalScans() {
    return _$getTotalScansAsyncAction.run(() => super.getTotalScans());
  }

  late final _$hasScannedAsyncAction =
      AsyncAction('_QrStore.hasScanned', context: context);

  @override
  Future<bool> hasScanned(String qrCodeId) {
    return _$hasScannedAsyncAction.run(() => super.hasScanned(qrCodeId));
  }

  late final _$markMarkerAsCompletedAsyncAction =
      AsyncAction('_QrStore.markMarkerAsCompleted', context: context);

  @override
  Future<void> markMarkerAsCompleted(String markerId) {
    return _$markMarkerAsCompletedAsyncAction
        .run(() => super.markMarkerAsCompleted(markerId));
  }

  late final _$isMarkerCompletedAsyncAction =
      AsyncAction('_QrStore.isMarkerCompleted', context: context);

  @override
  Future<bool> isMarkerCompleted(String markerId) {
    return _$isMarkerCompletedAsyncAction
        .run(() => super.isMarkerCompleted(markerId));
  }

  late final _$_QrStoreActionController =
      ActionController(name: '_QrStore', context: context);

  @override
  void setGeneratedData(String data) {
    final _$actionInfo = _$_QrStoreActionController.startAction(
        name: '_QrStore.setGeneratedData');
    try {
      return super.setGeneratedData(data);
    } finally {
      _$_QrStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearPendingQrCode() {
    final _$actionInfo = _$_QrStoreActionController.startAction(
        name: '_QrStore.clearPendingQrCode');
    try {
      return super.clearPendingQrCode();
    } finally {
      _$_QrStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearScannedPlaceData() {
    final _$actionInfo = _$_QrStoreActionController.startAction(
        name: '_QrStore.clearScannedPlaceData');
    try {
      return super.clearScannedPlaceData();
    } finally {
      _$_QrStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearLastScannedData() {
    final _$actionInfo = _$_QrStoreActionController.startAction(
        name: '_QrStore.clearLastScannedData');
    try {
      return super.clearLastScannedData();
    } finally {
      _$_QrStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void onManualInput(String input) {
    final _$actionInfo =
        _$_QrStoreActionController.startAction(name: '_QrStore.onManualInput');
    try {
      return super.onManualInput(input);
    } finally {
      _$_QrStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
generatedData: ${generatedData},
lastScannedData: ${lastScannedData},
lastScannedContent: ${lastScannedContent},
scannedPlaceData: ${scannedPlaceData},
pendingQrCodeId: ${pendingQrCodeId},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
scanHistory: ${scanHistory}
    ''';
  }
}
