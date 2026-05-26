import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:qstory/core/di/service_locator.dart';
import 'package:qstory/core/l10n/app_localizations.dart';
import 'package:qstory/core/services/email_service.dart';
import 'package:qstory/features/profile/presentation/pages/help_support_sheet.dart';

class MockEmailService extends Mock implements EmailService {}

void main() {
  late MockEmailService mockEmailService;

  setUp(() {
    mockEmailService = MockEmailService();
    when(mockEmailService.sendSupportMessage(any as String)).thenAnswer((_) => Future.value());
    getIt.registerSingleton<EmailService>(mockEmailService);
  });

  tearDown(() {
    getIt.unregister<EmailService>();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ru')],
      home: Scaffold(
        body: const HelpSupportSheet(),
      ),
    );
  }

  group('HelpSupportSheet', () {
    testWidgets('renders with TextField and buttons', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('send button disabled when empty', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('send button enabled when text entered', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('character counter works', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('0/500'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();

      expect(find.text('5/500'), findsOneWidget);
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
