import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:qstory/core/errors/failures.dart';
import 'package:qstory/core/util/result.dart';
import 'package:qstory/features/history/domain/entities/daily_fact_entity.dart';
import 'package:qstory/features/history/domain/repositories/daily_fact_repository.dart';
import 'package:qstory/features/history/presentation/stores/daily_fact_store.dart';

class MockDailyFactRepository extends Mock implements DailyFactRepository {}

void main() {
  late DailyFactStore store;
  late MockDailyFactRepository mockRepository;
  late int testMonth;
  late int testDay;

  setUp(() {
    mockRepository = MockDailyFactRepository();
    store = DailyFactStore(mockRepository);
    final now = DateTime.now();
    testMonth = now.month;
    testDay = now.day;
  });

  group('DailyFactStore', () {
    group('initialization', () {
      test('initializes with empty facts', () {
        expect(store.facts, isEmpty);
      });

      test('initializes with no current fact', () {
        expect(store.currentFact, null);
      });

      test('initializes not loading', () {
        expect(store.isLoading, false);
      });

      test('initializes with no error', () {
        expect(store.errorMessage, null);
      });
    });

    group('loadDailyFact', () {
      late List<DailyFactEntity> testFacts;

      setUp(() {
        testFacts = [
          const DailyFactEntity(
            year: 1812,
            text: 'Battle of Borodino',
            imageUrl: null,
            pageExtract: null,
            wikipediaUrl: null,
          ),
          const DailyFactEntity(
            year: 1917,
            text: 'October Revolution',
            imageUrl: null,
            pageExtract: null,
            wikipediaUrl: null,
          ),
        ];
      });

      test('loads facts successfully', () async {
        when(mockRepository.getFactsForDate(testMonth, testDay))
            .thenAnswer((_) async => Result.ok(testFacts));

        await store.loadDailyFact();

        expect(store.facts, testFacts);
        expect(store.currentFact, isNotNull);
        expect(store.isLoading, false);
      });

      test('sets random current fact from loaded facts', () async {
        when(mockRepository.getFactsForDate(testMonth, testDay))
            .thenAnswer((_) async => Result.ok(testFacts));

        await store.loadDailyFact();

        expect(testFacts.contains(store.currentFact), true);
      });

      test('handles empty facts list', () async {
        when(mockRepository.getFactsForDate(testMonth, testDay))
            .thenAnswer((_) async => Result.ok([]));

        await store.loadDailyFact();

        expect(store.facts, isEmpty);
        expect(store.currentFact, null);
      });

      test('sets error on network failure', () async {
        when(mockRepository.getFactsForDate(testMonth, testDay))
            .thenAnswer((_) async => Result.err(NetworkFailure()));

        await store.loadDailyFact();

        expect(store.errorMessage, isNotEmpty);
        expect(store.errorMessage, contains('соединения'));
      });

      test('sets error on not found failure', () async {
        when(mockRepository.getFactsForDate(testMonth, testDay))
            .thenAnswer((_) async => Result.err(NotFoundFailure()));

        await store.loadDailyFact();

        expect(store.errorMessage, isNotEmpty);
        expect(store.errorMessage, contains('фактов'));
      });

      test('does not reload if same day and facts exist', () async {
        var callCount = 0;
        when(mockRepository.getFactsForDate(testMonth, testDay))
            .thenAnswer((_) async {
          callCount++;
          return Result.ok(testFacts);
        });

        await store.loadDailyFact();
        expect(callCount, 1);

        store.facts = testFacts;
        store.currentFact = testFacts.first;

        await store.loadDailyFact();
        expect(callCount, 1);
      });

      test('force=true bypasses cache', () async {
        var callCount = 0;
        when(mockRepository.getFactsForDate(testMonth, testDay))
            .thenAnswer((_) async {
          callCount++;
          return Result.ok(testFacts);
        });

        await store.loadDailyFact();
        expect(callCount, 1);

        await store.loadDailyFact(force: true);
        expect(callCount, 2);
      });

      test('clears error on successful load', () async {
        var callCount = 0;
        when(mockRepository.getFactsForDate(testMonth, testDay))
            .thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            return Result.err(NetworkFailure());
          }
          return Result.ok(testFacts);
        });

        await store.loadDailyFact();
        expect(store.errorMessage, isNotEmpty);

        await store.loadDailyFact(force: true);
        expect(store.errorMessage, null);
      });

      test('sets isLoading during fetch', () async {
        var isLoadingDuringFetch = false;
        when(mockRepository.getFactsForDate(testMonth, testDay)).thenAnswer((_) async {
          isLoadingDuringFetch = store.isLoading;
          return Result.ok(testFacts);
        });

        await store.loadDailyFact(force: true);

        expect(isLoadingDuringFetch, true);
        expect(store.isLoading, false);
      });
    });

    group('nextFact', () {
      late List<DailyFactEntity> testFacts;

      setUp(() {
        testFacts = [
          const DailyFactEntity(
            year: 1812,
            text: 'Fact 1',
            imageUrl: null,
            pageExtract: null,
            wikipediaUrl: null,
          ),
          const DailyFactEntity(
            year: 1917,
            text: 'Fact 2',
            imageUrl: null,
            pageExtract: null,
            wikipediaUrl: null,
          ),
          const DailyFactEntity(
            year: 1991,
            text: 'Fact 3',
            imageUrl: null,
            pageExtract: null,
            wikipediaUrl: null,
          ),
        ];
      });

      test('selects different fact from loaded set', () async {
        when(mockRepository.getFactsForDate(testMonth, testDay))
            .thenAnswer((_) async => Result.ok(testFacts));

        await store.loadDailyFact();
        final firstFact = store.currentFact;

        bool foundDifferent = false;
        for (int i = 0; i < 10; i++) {
          await store.nextFact();
          if (store.currentFact?.text != firstFact?.text) {
            foundDifferent = true;
            break;
          }
        }

        expect(foundDifferent, true);
      });

      test('handles single fact by keeping it', () async {
        final singleFact = [testFacts.first];
        when(mockRepository.getFactsForDate(testMonth, testDay))
            .thenAnswer((_) async => Result.ok(singleFact));

        await store.loadDailyFact();
        final fact = store.currentFact;

        await store.nextFact();

        expect(store.currentFact, fact);
      });

      test('refetches if facts list is empty', () async {
        var callCount = 0;
        when(mockRepository.getFactsForDate(testMonth, testDay))
            .thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            return Result.ok([]);
          }
          return Result.ok(testFacts);
        });

        await store.loadDailyFact();
        expect(store.facts, isEmpty);

        await store.nextFact();

        expect(store.facts, testFacts);
      });

      test('always returns a fact when available', () async {
        when(mockRepository.getFactsForDate(testMonth, testDay))
            .thenAnswer((_) async => Result.ok(testFacts));

        await store.loadDailyFact();

        for (int i = 0; i < 20; i++) {
          await store.nextFact();
          expect(store.currentFact, isNotNull);
          expect(testFacts.contains(store.currentFact), true);
        }
      });
    });

    group('error messages', () {
      test('humanizes network failure', () async {
        when(mockRepository.getFactsForDate(testMonth, testDay))
            .thenAnswer((_) async => Result.err(NetworkFailure()));

        await store.loadDailyFact();

        expect(store.errorMessage, contains('Wikipedia'));
      });

      test('humanizes not found failure', () async {
        when(mockRepository.getFactsForDate(testMonth, testDay))
            .thenAnswer((_) async => Result.err(NotFoundFailure()));

        await store.loadDailyFact();

        expect(store.errorMessage, contains('фактов'));
      });

      test('uses custom server failure message', () async {
        const customMsg = 'Custom server error';
        when(mockRepository.getFactsForDate(testMonth, testDay))
            .thenAnswer((_) async => Result.err(ServerFailure(customMsg)));

        await store.loadDailyFact();

        expect(store.errorMessage, customMsg);
      });
    });

    group('cache behavior', () {
      late List<DailyFactEntity> facts;

      setUp(() {
        facts = [
          const DailyFactEntity(
            year: 1812,
            text: 'Fact',
            imageUrl: null,
            pageExtract: null,
            wikipediaUrl: null,
          ),
        ];
      });

      test('caches facts by date - does not reload on same day', () async {
        var callCount = 0;
        when(mockRepository.getFactsForDate(testMonth, testDay))
            .thenAnswer((_) async {
          callCount++;
          return Result.ok(facts);
        });

        await store.loadDailyFact();
        expect(callCount, 1);

        await store.loadDailyFact();
        expect(callCount, 1);
      });
    });
  });
}
