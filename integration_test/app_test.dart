// Runs on a real device or emulator:
//   flutter test integration_test
// Boots the full app with an in-memory database and fake sensors/network
// (so it needs no permissions) and walks through the main screens.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qstory/core/di/service_locator.dart';
import 'package:qstory/core/navigation/app_router.dart';
import 'package:qstory/core/storage/app_database.dart';
import 'package:qstory/features/activity/domain/entities/activity.dart';
import 'package:qstory/features/activity/presentation/stores/journal_store.dart';
import 'package:qstory/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/helpers/fake_http.dart';
import '../test/helpers/fakes.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app starts, tabs work, a visit shows up in statistics', (t) async {
    SharedPreferences.setMockInitialValues({'has_seen_onboarding': true, 'auto_tracking': false, 'locale': 'en'});
    await setupServiceLocator(
      database: await AppDatabase.inMemory(),
      preferences: await SharedPreferences.getInstance(),
      sensors: FakeSensors(),
      dio: fakeDio((_) => {
            'result': {'photos': []},
            'query': {'pages': []},
            'results': {'bindings': []},
            'elements': [],
          }),
      share: FakeShare(),
      mail: FakeMail(),
    );
    await getIt<JournalStore>().recordVisit(place('node/1', title: 'Test monument'), VisitMethod.manual);

    await t.pumpWidget(QStoryApp(router: buildRouter()));
    await t.pumpAndSettle(const Duration(seconds: 1));
    expect(find.byType(NavigationBar), findsOneWidget);

    await t.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Stats')));
    await t.pumpAndSettle(const Duration(seconds: 1));
    await t.scrollUntilVisible(find.textContaining(RegExp('First.*Test monument')), 400,
        scrollable: find.byType(Scrollable).first);
    expect(find.textContaining('Test monument'), findsWidgets);

    for (final tab in ['Favorites', 'Profile', 'Map']) {
      await t.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text(tab)));
      await t.pumpAndSettle(const Duration(seconds: 1));
    }
  });
}
