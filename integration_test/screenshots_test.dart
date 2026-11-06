// Captures App Store / Play screenshots on a simulator:
// flutter drive --driver=test_driver/integration_test.dart \
//   --target=integration_test/screenshots_test.dart -d <device>
import 'package:contemplatio/data/content_repository.dart';
import 'package:contemplatio/data/lumen_settings.dart';
import 'package:contemplatio/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> wait(WidgetTester t, [int ms = 1800]) async {
    for (var i = 0; i < ms ~/ 100; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> shot(WidgetTester t, String name) async {
    await wait(t, 1500);
    await binding.takeScreenshot(name);
  }

  Future<void> back(WidgetTester t) async {
    t.state<NavigatorState>(find.byType(Navigator).first).pop();
    await wait(t);
  }

  Future<void> tab(WidgetTester t, String label) async {
    await t.tap(find.bySemanticsLabel(label).last);
    await wait(t);
  }

  Future<void> tapText(WidgetTester t, String text) async {
    await t.tap(find.text(text).last);
    await wait(t);
  }

  testWidgets('store screenshots', (t) async {
    SharedPreferences.setMockInitialValues({
      'onboardingDone': true,
      'themeMode': 'dark',
    });
    final settings = await LumenSettings.load();
    await t.pumpWidget(
      LumenApp(settings: settings, repository: ContentRepository()),
    );
    await wait(t, 3000);
    await shot(t, '01-inicio');

    await tapText(t, 'Começar');
    await shot(t, '02-contemplacao');
    await back(t);

    await tab(t, 'Mistérios');
    await shot(t, '03-misterios');

    await tab(t, 'Via Sacra');
    await shot(t, '04-via-sacra');
    await t.tap(find.textContaining('Josemaria').first);
    await wait(t);
    await t.tap(find.textContaining('Começar').last);
    await wait(t);
    await shot(t, '05-estacao');
    await back(t);
    await back(t);

    await tab(t, 'Início');
    await tapText(t, 'Guia');
    await shot(t, '06-guia');
    await back(t);

    settings.themeMode = 'light';
    await wait(t, 2500);
    await shot(t, '07-inicio-claro');
  });
}
