// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$MapStore on _MapStore, Store {
  late final _$markersAtom = Atom(name: '_MapStore.markers', context: context);

  @override
  ObservableList<MapMarkerEntity> get markers {
    _$markersAtom.reportRead();
    return super.markers;
  }

  @override
  set markers(ObservableList<MapMarkerEntity> value) {
    _$markersAtom.reportWrite(value, super.markers, () {
      super.markers = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_MapStore.isLoading', context: context);

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
      Atom(name: '_MapStore.errorMessage', context: context);

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

  late final _$isSubmittingAtom =
      Atom(name: '_MapStore.isSubmitting', context: context);

  @override
  bool get isSubmitting {
    _$isSubmittingAtom.reportRead();
    return super.isSubmitting;
  }

  @override
  set isSubmitting(bool value) {
    _$isSubmittingAtom.reportWrite(value, super.isSubmitting, () {
      super.isSubmitting = value;
    });
  }

  late final _$submitErrorAtom =
      Atom(name: '_MapStore.submitError', context: context);

  @override
  String? get submitError {
    _$submitErrorAtom.reportRead();
    return super.submitError;
  }

  @override
  set submitError(String? value) {
    _$submitErrorAtom.reportWrite(value, super.submitError, () {
      super.submitError = value;
    });
  }

  late final _$submitMarkerAsyncAction =
      AsyncAction('_MapStore.submitMarker', context: context);

  @override
  Future<bool> submitMarker(MarkerSubmissionEntity payload) {
    return _$submitMarkerAsyncAction.run(() => super.submitMarker(payload));
  }

  late final _$loadMarkersAsyncAction =
      AsyncAction('_MapStore.loadMarkers', context: context);

  @override
  Future<void> loadMarkers() {
    return _$loadMarkersAsyncAction.run(() => super.loadMarkers());
  }

  late final _$markAsCompletedAsyncAction =
      AsyncAction('_MapStore.markAsCompleted', context: context);

  @override
  Future<void> markAsCompleted(String markerId) {
    return _$markAsCompletedAsyncAction
        .run(() => super.markAsCompleted(markerId));
  }

  @override
  String toString() {
    return '''
markers: ${markers},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
isSubmitting: ${isSubmitting},
submitError: ${submitError}
    ''';
  }
}
