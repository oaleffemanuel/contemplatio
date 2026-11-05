import 'package:contemplatio/data/content_repository.dart';
import 'package:contemplatio/data/lumen_settings.dart';
import 'package:contemplatio/data/models.dart';
import 'package:contemplatio/main.dart';
import 'dart:io';

import 'package:flutter/widgets.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('weekday mysteries follow Rosarium Virginis Mariae', () {
    expect(mysterySetForWeekday(DateTime.monday), 'joyful');
    expect(mysterySetForWeekday(DateTime.tuesday), 'sorrowful');
    expect(mysterySetForWeekday(DateTime.wednesday), 'glorious');
    expect(mysterySetForWeekday(DateTime.thursday), 'luminous');
    expect(mysterySetForWeekday(DateTime.friday), 'sorrowful');
    expect(mysterySetForWeekday(DateTime.saturday), 'joyful');
    expect(mysterySetForWeekday(DateTime.sunday), 'glorious');
    expect(romanNumeral(14), 'XIV');
    expect(romanNumeral(9), 'IX');
  });

  test(
    'bundled content: 4 sets x 5 mysteries, Via Sacra St Josemaría first',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final repo = ContentRepository();
      final sets = await repo.mysterySets();
      expect(sets.map((s) => s.id), [
        'joyful',
        'luminous',
        'sorrowful',
        'glorious',
      ]);
      expect(sets.every((s) => s.mysteries.length == 5), isTrue);
      expect(
        sets.every((s) => s.mysteries.every((m) => m.meditations.isNotEmpty)),
        isTrue,
      );
      final collections = await repo.viaSacraCollections();
      expect(collections.first.author, 'São Josemaria Escrivá');
      expect(collections.first.stations, hasLength(14));
    },
  );

  testWidgets('first launch shows the introduction', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = await LumenSettings.load();
    await tester.pumpWidget(
      LumenApp(settings: settings, repository: _diskRepository()),
    );
    await tester.pump();
    expect(find.text('BEM-VINDO AO LUMEN'), findsOneWidget);
    await tester.tap(find.text('Pular'));
    await tester.pump();
    expect(settings.onboardingDone, isTrue);
  });

  testWidgets('app opens on the home tab after the introduction', (tester) async {
    SharedPreferences.setMockInitialValues({'onboardingDone': true});
    final settings = await LumenSettings.load();
    final repo = _diskRepository();
    // Warm the repository with real I/O; the screens then read its cache.
    await tester.runAsync(() async {
      await repo.mysterySets();
      await repo.viaSacraCollections();
      await repo.saintWorks();
    });
    await tester.pumpWidget(LumenApp(settings: settings, repository: repo));
    // Asset loading is real I/O: let it finish outside the fake clock.
    for (var i = 0; i < 30; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    // Floating tab bar shows the label of the selected tab only.
    expect(find.bySemanticsLabel('Mistérios'), findsWidgets);
    expect(find.text('MISTÉRIOS DE HOJE'), findsOneWidget);
  });

  testWidgets('tapping the open tab scrolls it back to the top', (tester) async {
    SharedPreferences.setMockInitialValues({'onboardingDone': true});
    final settings = await LumenSettings.load();
    final repo = _diskRepository();
    await tester.runAsync(() async {
      await repo.mysterySets();
      await repo.viaSacraCollections();
      await repo.saintWorks();
    });
    await tester.pumpWidget(LumenApp(settings: settings, repository: repo));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final list = find.byType(Scrollable).first;
    await tester.drag(list, const Offset(0, -600));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    final position = tester.state<ScrollableState>(list).position;
    expect(position.pixels, greaterThan(0));
    await tester.tap(find.bySemanticsLabel('Início'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(position.pixels, 0);
  });
}

/// Reads assets from disk: rootBundle caches futures across tests, which can
/// stay bound to a previous test's fake clock.
ContentRepository _diskRepository() =>
    ContentRepository(loadAsset: (path) => File(path).readAsString());
