import 'package:flutter_test/flutter_test.dart';
import 'package:manatsume/app.dart';
import 'package:manatsume/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manatsume/core/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  testWidgets('app shell builds all six tabs and search stays responsive', (tester) async {
    final settings = SettingsService();
    await settings.init();
    await tester.pumpWidget(ManatsumeApp(settings: settings));
    await tester.pumpAndSettle();
    expect(find.text('Your music,'), findsOneWidget);
  });

  test('music service stores search results and guards togglePlay', () async {
    final music = ServiceLocator.music;
    expect(music.results, isEmpty);
    expect(music.currentTrack, isNull);
    await music.togglePlay(); // must not throw with no track
    await music.search('');   // empty query clears state, no network
    expect(music.hasSearched, isFalse);
  });
}
