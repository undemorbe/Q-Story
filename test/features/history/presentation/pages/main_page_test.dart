import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:qstory/core/di/service_locator.dart';
import 'package:qstory/features/history/presentation/pages/main_page.dart';
import 'package:qstory/features/history/presentation/stores/history_store.dart';
import 'package:qstory/features/history/domain/entities/history_entity.dart';
import 'package:qstory/core/l10n/app_localizations.dart';

@GenerateNiceMocks([MockSpec<HistoryStore>()])
import 'main_page_test.mocks.dart';

void main() {
  late MockHistoryStore mockStore;

  setUp(() {
    mockStore = MockHistoryStore();
    getIt.registerSingleton<HistoryStore>(mockStore);
  });

  tearDown(() {
    getIt.reset();
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('en')],
      home: MainPage(),
    );
  }

  testWidgets('calls loadHistory on init', (tester) async {
    when(mockStore.filteredList).thenReturn([]);
    when(mockStore.isLoading).thenReturn(false);
    when(mockStore.errorMessage).thenReturn(null);

    await tester.pumpWidget(createWidgetUnderTest());
    verify(mockStore.loadHistory()).called(1);
  });

  testWidgets('shows loading indicator when loading', (tester) async {
    when(mockStore.filteredList).thenReturn([]);
    when(mockStore.isLoading).thenReturn(true);
    when(mockStore.errorMessage).thenReturn(null);

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error message when error occurs', (tester) async {
    when(mockStore.filteredList).thenReturn([]);
    when(mockStore.isLoading).thenReturn(false);
    when(mockStore.errorMessage).thenReturn('Error Message');

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Error: Error Message'), findsOneWidget);
  });

  testWidgets('shows history list when loaded', (tester) async {
    final historyList = [
      const HistoryEntity(
        id: '1',
        title: 'Test Title',
        subtitle: 'Test Subtitle',
        description: 'Test Description',
        imageUrl: 'http://test.com/image.jpg',
        yearRange: '2023',
      )
    ];

    when(mockStore.filteredList).thenReturn(historyList);
    when(mockStore.isLoading).thenReturn(false);
    when(mockStore.errorMessage).thenReturn(null);

    // To avoid network image issues, we can rely on the fact that CachedNetworkImage
    // will probably fail gracefully or we can just expect the card content text
    await tester.pumpWidget(createWidgetUnderTest());
    
    // We expect the title to be found
    expect(find.text('Test Title'), findsOneWidget);
  });
}
