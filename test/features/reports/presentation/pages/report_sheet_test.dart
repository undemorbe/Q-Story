import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:qstory/core/di/service_locator.dart';
import 'package:qstory/core/l10n/app_localizations.dart';
import 'package:qstory/core/services/report_service.dart';
import 'package:qstory/features/reports/presentation/pages/report_sheet.dart';

class MockReportService extends Mock implements ReportService {
  @override
  String getCategoryLabel(ReportCategory category, String languageCode) {
    return 'Test Category';
  }

  @override
  Future<void> sendReport({
    required String markerId,
    required String markerTitle,
    required ReportCategory category,
    required String text,
  }) {
    return Future<void>.value();
  }
}

void main() {
  late MockReportService mockReportService;

  setUp(() {
    mockReportService = MockReportService();
    getIt.registerSingleton<ReportService>(mockReportService);
  });

  tearDown(() {
    if (getIt.isRegistered<ReportService>()) {
      getIt.unregister<ReportService>();
    }
  });

  Widget buildTestWidget() {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ru')],
      home: Scaffold(
        body: const ReportSheet(
          markerId: 'test-123',
          markerTitle: 'Test Marker',
        ),
      ),
    );
  }

  group('ReportSheet', () {
    testWidgets('renders with category dropdown and text field', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButtonFormField), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('send button disabled when category not selected', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('send button disabled when text is empty', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Select category
      await tester.tap(find.byType(DropdownButtonFormField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test Category').first);
      await tester.pumpAndSettle();

      // Text field is empty, button should still be disabled
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('character counter updates as text is entered', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('0/500'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pump();

      expect(find.text('4/500'), findsOneWidget);
    });

    testWidgets('close button closes sheet', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
    });
  });
}
