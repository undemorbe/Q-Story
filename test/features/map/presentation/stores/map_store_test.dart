import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:qstory/core/errors/failures.dart';
import 'package:qstory/core/util/result.dart';
import 'package:qstory/features/map/domain/entities/map_marker_entity.dart';
import 'package:qstory/features/map/domain/entities/marker_submission_entity.dart';
import 'package:qstory/features/map/domain/repositories/map_repository.dart';
import 'package:qstory/features/map/presentation/stores/map_store.dart';

class MockMapRepository extends Mock implements MapRepository {}

void main() {
  late MapStore store;
  late MockMapRepository mockRepository;

  setUp(() {
    mockRepository = MockMapRepository();
    store = MapStore(mockRepository);
  });

  group('MapStore', () {
    group('initialization', () {
      test('initializes with empty markers', () {
        expect(store.markers, isEmpty);
      });

      test('initializes with all status filter', () {
        expect(store.statusFilter, MarkerStatusFilter.all);
      });

      test('initializes with no type filter', () {
        expect(store.typeFilter, null);
      });

      test('initializes not loading', () {
        expect(store.isLoading, false);
      });

      test('initializes with no error', () {
        expect(store.errorMessage, null);
      });
    });

    group('loading markers', () {
      late List<MapMarkerEntity> markers;

      setUp(() {
        markers = [
          const MapMarkerEntity(
            id: 'm1',
            lat: 55.7558,
            lon: 37.6173,
            title: 'Kremlin',
            compressedDescription: 'Ancient fortress',
            type: 'history',
            isCompleted: false,
          ),
          const MapMarkerEntity(
            id: 'm2',
            lat: 55.7505,
            lon: 37.5363,
            title: 'Cathedral',
            compressedDescription: 'Grand cathedral',
            type: 'architecture',
            isCompleted: true,
          ),
        ];
      });

      test('loads markers successfully', () async {
        when(mockRepository.getMarkers())
            .thenAnswer((_) async => Result.ok(markers));

        await store.loadMarkers();

        expect(store.markers, markers);
        expect(store.isLoading, false);
        expect(store.errorMessage, null);
      });

      test('sets error on network failure', () async {
        when(mockRepository.getMarkers()).thenAnswer(
          (_) async => Result.err(NetworkFailure()),
        );

        await store.loadMarkers();

        expect(store.markers, isEmpty);
        expect(store.errorMessage, isNotEmpty);
      });

      test('sets error on server failure', () async {
        const msg = 'Server error';
        when(mockRepository.getMarkers()).thenAnswer(
          (_) async => Result.err(ServerFailure(msg)),
        );

        await store.loadMarkers();

        expect(store.errorMessage, msg);
      });

      test('sets isLoading during fetch', () async {
        when(mockRepository.getMarkers()).thenAnswer((_) async {
          expect(store.isLoading, true);
          return Result.ok([]);
        });

        await store.loadMarkers();

        expect(store.isLoading, false);
      });

      test('clears previous error on new load', () async {
        when(mockRepository.getMarkers()).thenAnswer(
          (_) async => Result.err(NetworkFailure()),
        );
        await store.loadMarkers();
        expect(store.errorMessage, isNotEmpty);

        when(mockRepository.getMarkers())
            .thenAnswer((_) async => Result.ok([]));
        await store.loadMarkers();

        expect(store.errorMessage, null);
      });
    });

    group('filters - availableTypes', () {
      late List<MapMarkerEntity> markers;

      setUp(() {
        markers = [
          const MapMarkerEntity(
            id: 'm1',
            lat: 0,
            lon: 0,
            title: 'A',
            compressedDescription: 'desc',
            type: 'history',
            isCompleted: false,
          ),
          const MapMarkerEntity(
            id: 'm2',
            lat: 0,
            lon: 0,
            title: 'B',
            compressedDescription: 'desc',
            type: 'culture',
            isCompleted: false,
          ),
          const MapMarkerEntity(
            id: 'm3',
            lat: 0,
            lon: 0,
            title: 'C',
            compressedDescription: 'desc',
            type: 'history',
            isCompleted: false,
          ),
        ];
      });

      test('extracts unique types from markers', () async {
        when(mockRepository.getMarkers())
            .thenAnswer((_) async => Result.ok(markers));

        await store.loadMarkers();

        expect(store.availableTypes, ['culture', 'history']);
      });

      test('returns sorted types', () async {
        final sortedMarkers = [
          const MapMarkerEntity(
            id: 'm1',
            lat: 0,
            lon: 0,
            title: 'A',
            compressedDescription: 'desc',
            type: 'zebra',
            isCompleted: false,
          ),
          const MapMarkerEntity(
            id: 'm2',
            lat: 0,
            lon: 0,
            title: 'B',
            compressedDescription: 'desc',
            type: 'apple',
            isCompleted: false,
          ),
        ];

        when(mockRepository.getMarkers())
            .thenAnswer((_) async => Result.ok(sortedMarkers));

        await store.loadMarkers();

        expect(store.availableTypes, ['apple', 'zebra']);
      });
    });

    group('filters - filteredMarkers', () {
      late List<MapMarkerEntity> testMarkers;

      setUp(() async {
        testMarkers = [
          const MapMarkerEntity(
            id: 'm1',
            lat: 0,
            lon: 0,
            title: 'History 1',
            compressedDescription: 'desc',
            type: 'history',
            isCompleted: false,
          ),
          const MapMarkerEntity(
            id: 'm2',
            lat: 0,
            lon: 0,
            title: 'History 2',
            compressedDescription: 'desc',
            type: 'history',
            isCompleted: true,
          ),
          const MapMarkerEntity(
            id: 'm3',
            lat: 0,
            lon: 0,
            title: 'Culture 1',
            compressedDescription: 'desc',
            type: 'culture',
            isCompleted: false,
          ),
        ];

        when(mockRepository.getMarkers())
            .thenAnswer((_) async => Result.ok(testMarkers));
        await store.loadMarkers();
      });

      test('returns all markers when no filter set', () {
        expect(store.filteredMarkers.length, 3);
      });

      test('filters by status - completed', () {
        store.setStatusFilter(MarkerStatusFilter.completed);

        expect(store.filteredMarkers.length, 1);
        expect(store.filteredMarkers.first.id, 'm2');
      });

      test('filters by status - not completed', () {
        store.setStatusFilter(MarkerStatusFilter.notCompleted);

        expect(store.filteredMarkers.length, 2);
        expect(store.filteredMarkers.any((m) => m.id == 'm1'), true);
        expect(store.filteredMarkers.any((m) => m.id == 'm3'), true);
      });

      test('filters by type', () {
        store.setTypeFilter('history');

        expect(store.filteredMarkers.length, 2);
        expect(store.filteredMarkers.every((m) => m.type == 'history'), true);
      });

      test('combines status and type filters', () {
        store.setStatusFilter(MarkerStatusFilter.completed);
        store.setTypeFilter('history');

        expect(store.filteredMarkers.length, 1);
        expect(store.filteredMarkers.first.id, 'm2');
      });

      test('clears type filter when set to null', () {
        store.setTypeFilter('history');
        expect(store.filteredMarkers.length, 2);

        store.setTypeFilter(null);
        expect(store.filteredMarkers.length, 3);
      });
    });

    group('submitMarker', () {
      test('returns true on successful submission', () async {
        final reloadedMarkers = [
          const MapMarkerEntity(
            id: 'new',
            lat: 0,
            lon: 0,
            title: 'New',
            compressedDescription: 'desc',
            type: 'history',
            isCompleted: false,
          ),
        ];

        when(mockRepository.submitMarker(any<MarkerSubmissionEntity>()))
            .thenAnswer((_) async => Result.ok(null));
        when(mockRepository.getMarkers())
            .thenAnswer((_) async => Result.ok(reloadedMarkers));

        final payload = MarkerSubmissionEntity(
          marker: MarkerPayload(
            id: 'm1',
            lat: 0,
            lon: 0,
            title: 'Test',
            type: 'history',
            compressedDescription: 'desc',
          ),
          building: BuildingPayload(
            id: 'b1',
            title: 'Building',
            compressedDescription: 'desc',
            descriptionTop: 'top',
            descriptionMain: 'main',
            descriptionBottom: 'bottom',
            image: 'url',
            dateStart: '2020-01-01',
            dateEnd: '2020-12-31',
            type: 'history',
            person: 'Person',
            resources: ['wiki'],
          ),
        );

        final result = await store.submitMarker(payload);

        expect(result, true);
        expect(store.markers, reloadedMarkers);
        expect(store.submitError, null);
      });

      test('returns false and sets error on failure', () async {
        when(mockRepository.submitMarker(any<MarkerSubmissionEntity>()))
            .thenAnswer((_) async => Result.err(NetworkFailure()));

        final payload = MarkerSubmissionEntity(
          marker: MarkerPayload(
            id: 'm1',
            lat: 0,
            lon: 0,
            title: 'Test',
            type: 'history',
            compressedDescription: 'desc',
          ),
          building: BuildingPayload(
            id: 'b1',
            title: 'Building',
            compressedDescription: 'desc',
            descriptionTop: 'top',
            descriptionMain: 'main',
            descriptionBottom: 'bottom',
            image: 'url',
            dateStart: '2020-01-01',
            dateEnd: '2020-12-31',
            type: 'history',
            person: 'Person',
            resources: ['wiki'],
          ),
        );

        final result = await store.submitMarker(payload);

        expect(result, false);
        expect(store.submitError, isNotEmpty);
      });

      test('sets isSubmitting flag during submission', () async {
        when(mockRepository.submitMarker(any<MarkerSubmissionEntity>()))
            .thenAnswer((_) async {
          expect(store.isSubmitting, true);
          return Result.ok(null);
        });

        final payload = MarkerSubmissionEntity(
          marker: MarkerPayload(
            id: 'm1',
            lat: 0,
            lon: 0,
            title: 'Test',
            type: 'history',
            compressedDescription: 'desc',
          ),
          building: BuildingPayload(
            id: 'b1',
            title: 'Building',
            compressedDescription: 'desc',
            descriptionTop: 'top',
            descriptionMain: 'main',
            descriptionBottom: 'bottom',
            image: 'url',
            dateStart: '2020-01-01',
            dateEnd: '2020-12-31',
            type: 'history',
            person: 'Person',
            resources: ['wiki'],
          ),
        );

        await store.submitMarker(payload);

        expect(store.isSubmitting, false);
      });
    });

    group('humanize errors', () {
      test('humanizes network failure', () async {
        when(mockRepository.getMarkers()).thenAnswer(
          (_) async => Result.err(NetworkFailure()),
        );

        await store.loadMarkers();

        expect(store.errorMessage, contains('соединения'));
      });

      test('humanizes not found failure', () async {
        when(mockRepository.getMarkers()).thenAnswer(
          (_) async => Result.err(NotFoundFailure()),
        );

        await store.loadMarkers();

        expect(store.errorMessage, contains('не найдены'));
      });
    });
  });
}
