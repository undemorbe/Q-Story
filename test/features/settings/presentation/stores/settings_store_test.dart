import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:qstory/features/settings/domain/repositories/settings_repository.dart';
import 'package:qstory/features/settings/presentation/stores/settings_store.dart';

@GenerateNiceMocks([MockSpec<SettingsRepository>()])
import 'settings_store_test.mocks.dart';

void main() {
  late SettingsStore store;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
  });

  group('SettingsStore', () {
    test('initializes with default locale if no saved locale', () async {
      when(mockRepository.getLocale()).thenAnswer((_) async => null);
      store = SettingsStore(mockRepository);
      
      // Wait for async init
      await Future.delayed(Duration.zero);
      
      expect(store.locale, const Locale('en'));
    });

    test('initializes with saved locale', () async {
      when(mockRepository.getLocale()).thenAnswer((_) async => 'es');
      store = SettingsStore(mockRepository);

      // Wait for async init
      await Future.delayed(Duration.zero);

      expect(store.locale, const Locale('es'));
    });

    test('setLocale updates locale and saves to repository', () async {
      when(mockRepository.getLocale()).thenAnswer((_) async => null);
      store = SettingsStore(mockRepository);
      const newLocale = Locale('es');

      await store.setLocale(newLocale);

      expect(store.locale, newLocale);
      verify(mockRepository.setLocale('es')).called(1);
    });
  });
}
