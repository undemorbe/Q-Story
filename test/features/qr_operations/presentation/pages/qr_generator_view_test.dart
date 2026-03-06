import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:qstory/core/di/service_locator.dart';
import 'package:qstory/features/qr_operations/presentation/pages/qr_generator_view.dart';
import 'package:qstory/features/qr_operations/presentation/stores/qr_store.dart';
import 'package:qstory/core/l10n/app_localizations.dart';

@GenerateNiceMocks([MockSpec<QrStore>()])
import 'qr_generator_view_test.mocks.dart';

void main() {
  late MockQrStore mockStore;

  setUp(() {
    mockStore = MockQrStore();
    getIt.registerSingleton<QrStore>(mockStore);
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
      home: Scaffold(body: QrGeneratorView()),
    );
  }

  testWidgets('renders input field and generate button', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.text('Enter Data'), findsOneWidget);
  });

  testWidgets('calls setGeneratedData when button is pressed', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextField), 'test qr');
    await tester.tap(find.byIcon(Icons.check));
    await tester.pump();

    verify(mockStore.setGeneratedData('test qr')).called(1);
  });
}
